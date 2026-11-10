#!/opt/homebrew/bin/bash
# SPDX-FileCopyrightText: 2026 Tim Case <tim@lnx.cx>
# SPDX-License-Identifier: MIT

# Make a per-page social preview (og:image) from a source image and record it
# in the page's front matter.
set -euo pipefail
unset CDPATH

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="${REPO_ROOT}/_config.yml"
OUT_DIR="assets/opengraph"
MIN_SIDE=200   # Facebook ignores og images smaller than this on either side

usage() {
    cat <<EOF
Usage: $(basename "$0") [-h|--help] [-a|--alt TEXT] [-n|--dry-run] <source-image> <page>

Downscale a source image to fit inside the og.max box from _config.yml
(keeping the aspect ratio, never enlarging), save it under ${OUT_DIR}/, and
write an og_image: block with the real width and height into the page's front
matter. Re-running replaces any existing og_image: block.

Arguments:
  source-image  The full-size image to make the preview from
  page          The page or post to attach it to, e.g. audio.markdown

Options:
  -a, --alt TEXT  Alt text for the preview (default: the page title)
  -n, --dry-run   Print what would happen without writing anything
  -h, --help      Show this help and exit

Example:
  $(basename "$0") -a "Audio-Technica ATH-WP900 headphones" \\
      assets/images/audiophile/ATH-WP900.jpg audio.markdown
EOF
}

die() { echo "error: $*" >&2; exit 1; }

ALT=""
DRY_RUN=0
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) usage; exit 0 ;;
        -a|--alt) [[ $# -ge 2 ]] || die "$1 needs a value"; ALT="$2"; shift 2 ;;
        -n|--dry-run) DRY_RUN=1; shift ;;
        --) shift; POSITIONAL+=("$@"); break ;;
        -*) die "unknown option: $1 (try --help)" ;;
        *) POSITIONAL+=("$1"); shift ;;
    esac
done
[[ ${#POSITIONAL[@]} -eq 2 ]] || { usage >&2; exit 2; }
SOURCE="${POSITIONAL[0]}"
PAGE="${POSITIONAL[1]}"

command -v magick >/dev/null || die "ImageMagick (magick) not found"
[[ -f "$SOURCE" ]] || die "no such source image: $SOURCE"
[[ -f "$PAGE" ]] || die "no such page: $PAGE"
[[ "$(head -n1 "$PAGE")" == "---" ]] || die "$PAGE has no front matter"

# og.max from _config.yml
read -r MAX_W MAX_H < <(ruby -ryaml -e '
    m = (YAML.load_file(ARGV[0]).dig("og", "max") || {})
    puts "#{m["width"]} #{m["height"]}"' "$CONFIG")
[[ "$MAX_W" =~ ^[0-9]+$ && "$MAX_H" =~ ^[0-9]+$ ]] \
    || die "og.max.width / og.max.height missing from $CONFIG"

if [[ -z "$ALT" ]]; then
    ALT="$(sed -n '2,/^---$/s/^title:[[:space:]]*//p' "$PAGE" | head -n1)"
    ALT="${ALT#[\"\']}"; ALT="${ALT%[\"\']}"
    echo "note: no --alt given, using the page title: ${ALT}" >&2
fi

ext="${SOURCE##*.}"; ext="${ext,,}"
[[ "$ext" == "jpeg" ]] && ext="jpg"
slug="$(basename "${PAGE%.*}")"

# Compute the fitted size first so it can go in the filename. ImageMagick's
# '>' flag means "only shrink"; -format on an -resize'd image reports the result.
read -r W H < <(magick "$SOURCE" -auto-orient -resize "${MAX_W}x${MAX_H}>" \
                    -format '%w %h\n' info:)
OUT_REL="${OUT_DIR}/${slug}-${W}x${H}.${ext}"
OUT_ABS="${REPO_ROOT}/${OUT_REL}"

echo "source:  $SOURCE ($(magick identify -format '%wx%h' "$SOURCE"))"
echo "max box: ${MAX_W}x${MAX_H}"
echo "output:  $OUT_REL (${W}x${H})"
if (( W < MIN_SIDE || H < MIN_SIDE )); then
    echo "warning: ${W}x${H} is under ${MIN_SIDE}px on a side; some platforms will ignore it" >&2
fi

# Escape for a double-quoted YAML scalar
alt_yaml="${ALT//\\/\\\\}"; alt_yaml="${alt_yaml//\"/\\\"}"
BLOCK="og_image:
  path: ${OUT_REL}
  width: ${W}
  height: ${H}
  alt: \"${alt_yaml}\""

if (( DRY_RUN )); then
    printf 'would write to %s front matter:\n%s\n' "$PAGE" "$BLOCK"
    exit 0
fi

mkdir -p "${REPO_ROOT}/${OUT_DIR}"
magick "$SOURCE" -auto-orient -resize "${MAX_W}x${MAX_H}>" -strip \
    -quality 85 "$OUT_ABS"

# Rewrite front matter: drop any old og_image: block (the key plus its
# indented lines), then add the new one just before the closing ---.
tmp="$(mktemp "${PAGE}.XXXXXX")"
BLOCK="$BLOCK" awk '
    NR == 1 && $0 == "---" { infm = 1; print; next }
    infm && $0 == "---"     { print ENVIRON["BLOCK"]; print; infm = 0; next }
    infm && /^og_image:/    { skip = 1; next }
    infm && skip && /^[[:space:]]/ { next }
    { skip = 0; print }
' "$PAGE" > "$tmp"
mv "$tmp" "$PAGE"

echo "updated $PAGE front matter"
echo "old previews for this page in ${OUT_DIR}/ are not deleted; remove stale ones by hand:"
ls -1 "${REPO_ROOT}/${OUT_DIR}/${slug}-"* 2>/dev/null | sed "s|^${REPO_ROOT}/|  |" || true
