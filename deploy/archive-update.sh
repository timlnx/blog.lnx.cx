#!/bin/bash
# Submit recently-changed blog pages to the Internet Archive Wayback Machine.
#
# Called by blog-poll.sh at the very end of a successful deploy, as:
#   archive-update.sh "$LOCAL" "$HEAD" "$OUTPUT_DIR/.url-manifest.json" || true
#
# It git-diffs the *source* (never the rendered HTML — the footer's "last built
# on" date changes every page on every build) over LOCAL..HEAD, resolves each
# changed source path to its published URL via the build manifest emitted by
# _plugins/url_manifest.rb, picks at most 3 URLs in a fixed priority order, and
# submits them to the anonymous Save Page Now endpoint.
#
# Best-effort by contract: it exits 0 on every normal and error path so it can
# never fail or delay a deploy. See
# docs/superpowers/specs/2026-07-07-archive-update-pipeline-design.md.
set -euo pipefail

# ── Configuration ────────────────────────────────────────────────────────────

MAX_URLS=3                              # never submit more than this per run
RATE_LIMIT_SECONDS=60                   # skip if we submitted within this window
SPACING_SECONDS=7                       # gap between submissions (<3/min anon cap)
CONNECT_TIMEOUT=15                      # curl --connect-timeout
MAX_TIME=60                             # curl --max-time per submission
USER_AGENT="blog.lnx.cx archive-update"
SAVE_ENDPOINT="https://web.archive.org/save"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/blog-archive"
STATE_FILE="${STATE_DIR}/last-submit"

# ── Argument parsing ─────────────────────────────────────────────────────────

usage() {
    cat <<EOF
Usage: $(basename "$0") [-h|--help] [--dry-run] <old-ref> <new-ref> <manifest-path>

Submit blog pages changed between two git commits to the Wayback Machine.

Diffs the source over <old-ref>..<new-ref>, resolves each changed page to its
published URL via <manifest-path> (the .url-manifest.json emitted at build time
by _plugins/url_manifest.rb), and submits up to ${MAX_URLS} URLs in priority order:
new posts, new pages, updated posts, updated pages, then the index.

Positionals:
  <old-ref>        git ref before the change (e.g. pre-pull HEAD)
  <new-ref>        git ref after the change  (e.g. post-pull HEAD)
  <manifest-path>  path to .url-manifest.json produced by the build

Options:
  --dry-run    Print the URLs and tiers that would be submitted, then exit.
               Makes no network calls and does not touch the state file.
  -h, --help   Show this help and exit.

Runs git in the current working directory, so invoke it from the repo checkout
(blog-poll.sh cd's there before calling). Exits 0 on all normal and error paths.
EOF
}

DRY_RUN=0
POSITIONAL=()

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)  usage; exit 0 ;;
        --dry-run)  DRY_RUN=1; shift ;;
        --)         shift; while [ $# -gt 0 ]; do POSITIONAL+=("$1"); shift; done ;;
        -*)         echo "$(basename "$0"): unknown option: $1" >&2; usage >&2; exit 2 ;;
        *)          POSITIONAL+=("$1"); shift ;;
    esac
done

if [ "${#POSITIONAL[@]}" -ne 3 ]; then
    echo "$(basename "$0"): expected 3 positional arguments, got ${#POSITIONAL[@]}" >&2
    usage >&2
    exit 2
fi

OLD_REF="${POSITIONAL[0]}"
NEW_REF="${POSITIONAL[1]}"
MANIFEST_FILE="${POSITIONAL[2]}"

# Associative arrays require bash 4+. The Fedora server ships bash 5; this guard
# just fails loudly instead of misbehaving on an ancient bash.
if [ -z "${BASH_VERSINFO:-}" ] || [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    echo "$(basename "$0"): requires bash 4+" >&2
    exit 1
fi

log() { echo "[archive-update] $*"; }

# ── Manifest loading ─────────────────────────────────────────────────────────
#
# Parse the pretty-printed JSON into an associative array. The manifest is
# self-generated with a stable, one-entry-per-line shape
# (`    "key": "value",`) and ASCII-only keys/values, so a line-oriented parse
# is safe here without a JSON dependency. Top-level "site_url"/"generated_by"
# land in the map too (harmless: no source path collides with those names).

declare -A MANIFEST

load_manifest() {
    if [ ! -r "$MANIFEST_FILE" ]; then
        # Per the spec's failure mode: an unreadable manifest means "no
        # resolvable pages" -> clean best-effort exit.
        log "manifest not readable ($MANIFEST_FILE); nothing to do"
        return 1
    fi
    local key val
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*\"(.+)\":[[:space:]]*\"(.+)\"[,]?[[:space:]]*$ ]]; then
            key="${BASH_REMATCH[1]}"
            val="${BASH_REMATCH[2]}"
            MANIFEST["$key"]="$val"
        fi
    done < "$MANIFEST_FILE"
    return 0
}

# ── Git range validation ─────────────────────────────────────────────────────

valid_refs() {
    git rev-parse -q --verify "${OLD_REF}^{commit}" >/dev/null 2>&1 \
        && git rev-parse -q --verify "${NEW_REF}^{commit}" >/dev/null 2>&1
}

# ── mtime helper (portable across GNU and BSD stat) ──────────────────────────

file_mtime() {
    stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null || echo 0
}

# ── Classification ───────────────────────────────────────────────────────────
#
# Tiers (priority high -> low):
#   0  new post          (A, under _posts/)
#   1  new page          (A, not under _posts/)
#   2  updated post      (M, under _posts/)
#   3  updated page      (M, not under _posts/)
#   4  index "/"         (>=1 tier-0 post this run, OR index itself changed)
# Deletes are skipped; renames/copies treat the new path as new content.

TIER0=()   # new posts
TIER1=()   # new pages
TIER2=()   # updated posts
TIER3=()   # updated pages
INDEX_CHANGED=0

classify() {
    local root_url="${MANIFEST[site_url]:-}"
    root_url="${root_url%/}/"

    local status path rest eff url
    while IFS=$'\t' read -r status path rest; do
        [ -n "$status" ] || continue
        case "$status" in
            A)      eff=A ;;
            M|T)    eff=M ;;                       # type-change counts as update
            R*|C*)  eff=A; path="$rest" ;;         # rename/copy -> new path, new content
            D)      continue ;;                    # delete -> nothing to archive
            *)      continue ;;
        esac

        url="${MANIFEST[$path]:-}"
        [ -n "$url" ] || continue                  # not a page -> ignore

        # The index/root URL is only ever tier 4, never tier 1/3, so the
        # homepage sits at the bottom of the priority order and appears at
        # most once in the pool.
        if [ "$url" = "$root_url" ]; then
            INDEX_CHANGED=1
            continue
        fi

        if [ "$eff" = "A" ]; then
            if [[ "$path" == _posts/* ]]; then TIER0+=("$path"); else TIER1+=("$path"); fi
        else
            if [[ "$path" == _posts/* ]]; then TIER2+=("$path"); else TIER3+=("$path"); fi
        fi
    done < <(git diff --name-status "$OLD_REF" "$NEW_REF")
}

# ── Selection ────────────────────────────────────────────────────────────────
#
# Order within a tier: posts newest-first (paths start with YYYY-MM-DD, so a
# reverse sort is newest-first); pages alphabetical by path. Then concatenate
# tiers 0->4 and take the first MAX_URLS.

SELECTED_URLS=()
SELECTED_TIERS=()

# Emit the manifest URL for each path in an array, in the given sort order.
#   $1 = "asc" | "desc" ; remaining args = paths
urls_sorted() {
    local order="$1"; shift
    [ "$#" -gt 0 ] || return 0
    local sorted p
    if [ "$order" = "desc" ]; then
        sorted=$(printf '%s\n' "$@" | LC_ALL=C sort -r)
    else
        sorted=$(printf '%s\n' "$@" | LC_ALL=C sort)
    fi
    while IFS= read -r p; do
        [ -n "$p" ] || continue
        printf '%s\n' "${MANIFEST[$p]}"
    done <<< "$sorted"
}

add_tier() {
    local tier="$1" url
    shift
    while IFS= read -r url; do
        [ -n "$url" ] || continue
        [ "${#SELECTED_URLS[@]}" -lt "$MAX_URLS" ] || return 0
        SELECTED_URLS+=("$url")
        SELECTED_TIERS+=("$tier")
    done <<< "$*"
}

select_urls() {
    local root_url="${MANIFEST[site_url]:-}"
    root_url="${root_url%/}/"

    add_tier 0 "$(urls_sorted desc ${TIER0[@]+"${TIER0[@]}"})"
    add_tier 1 "$(urls_sorted asc  ${TIER1[@]+"${TIER1[@]}"})"
    add_tier 2 "$(urls_sorted desc ${TIER2[@]+"${TIER2[@]}"})"
    add_tier 3 "$(urls_sorted asc  ${TIER3[@]+"${TIER3[@]}"})"

    # Tier 4: index is a candidate if a new post landed or the index changed.
    if [ "${#SELECTED_URLS[@]}" -lt "$MAX_URLS" ]; then
        if [ "${#TIER0[@]}" -gt 0 ] || [ "$INDEX_CHANGED" -eq 1 ]; then
            SELECTED_URLS+=("$root_url")
            SELECTED_TIERS+=("4")
        fi
    fi
}

# ── Submission ───────────────────────────────────────────────────────────────

submit_one() {
    local url="$1" http_code rc
    http_code=$(curl -sS -A "$USER_AGENT" \
        --connect-timeout "$CONNECT_TIMEOUT" --max-time "$MAX_TIME" \
        -o /dev/null -w '%{http_code}' \
        "${SAVE_ENDPOINT}/${url}" 2>/dev/null) && rc=0 || rc=$?
    http_code="${http_code:-000}"
    if [ "$rc" -ne 0 ]; then
        log "  ERROR curl exit $rc: $url"
        return 1
    fi
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 400 ]; then
        log "  OK ($http_code): $url"
        return 0
    fi
    log "  ERROR HTTP $http_code: $url"
    return 1
}

submit_all() {
    local i=0 url
    for url in "${SELECTED_URLS[@]}"; do
        [ "$i" -eq 0 ] || sleep "$SPACING_SECONDS"
        if ! submit_one "$url"; then
            log "  stopping remaining submissions for this run"
            break
        fi
        i=$((i + 1))
    done
}

# ── Main ─────────────────────────────────────────────────────────────────────

main() {
    if ! valid_refs; then
        log "invalid git range (${OLD_REF}..${NEW_REF}); nothing to do"
        exit 0
    fi

    load_manifest || exit 0

    classify
    select_urls

    if [ "${#SELECTED_URLS[@]}" -eq 0 ]; then
        log "no changed pages to archive"
        exit 0
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        log "would submit ${#SELECTED_URLS[@]} URL(s):"
        local i
        for i in "${!SELECTED_URLS[@]}"; do
            printf '  tier %s  %s\n' "${SELECTED_TIERS[$i]}" "${SELECTED_URLS[$i]}"
        done
        exit 0
    fi

    mkdir -p "$STATE_DIR"
    if [ -f "$STATE_FILE" ]; then
        local age=$(( $(date +%s) - $(file_mtime "$STATE_FILE") ))
        if [ "$age" -le "$RATE_LIMIT_SECONDS" ]; then
            log "rate-limited (last submit ${age}s ago <= ${RATE_LIMIT_SECONDS}s); skipping"
            exit 0
        fi
    fi

    log "submitting ${#SELECTED_URLS[@]} URL(s) to the Wayback Machine"
    submit_all

    # Touch after the submission phase even on a partial/failed batch, so the
    # 60-second lock still holds (spec §11.5).
    touch "$STATE_FILE"
    exit 0
}

main
