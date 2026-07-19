#!/bin/bash
# SPDX-FileCopyrightText: 2026 Tim Case <tim@lnx.cx>
# SPDX-License-Identifier: MIT

# Upload one or more images to the server image store and print markdown snippets.
set -euo pipefail

SERVER="tc@lnx.cx"
IMAGE_STORE="/srv/blog-images"
URL_BASE="/assets/images"

usage() {
    cat <<EOF
Usage: $(basename "$0") [-h|--help] <local-file> ...

Upload one or more images to the blog image store on lnx.cx and print markdown
snippets ready to paste into a post. Filenames are slugified for tidy URLs, e.g.
"Screenshot 2026-07-09 at 2.14.14 AM.png" -> screenshot-2026-07-09-at-2-14-14-am.png

Arguments:
  local-file    One or more image files to upload

Options:
  -h, --help    Show this help and exit

Examples:
  $(basename "$0") ~/Desktop/photo.jpg
  $(basename "$0") ~/Desktop/*.png

More information: https://github.com/timlnx/blog.lnx.cx/blob/main/DEPLOY.md
EOF
}

# slugify a filename: lowercase, collapse non-alphanumeric runs to hyphens,
# keep (and lowercase) the extension. "A Photo.PNG" -> "a-photo.png"
slugify() {
    local name base ext slug
    name="$1"
    if [[ "$name" == *.* ]]; then
        base="${name%.*}"
        ext=".$(printf '%s' "${name##*.}" | tr '[:upper:]' '[:lower:]')"
    else
        base="$name"
        ext=""
    fi
    slug="$(printf '%s' "$base" \
        | tr '[:upper:]' '[:lower:]' \
        | LC_ALL=C sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"
    printf '%s%s' "$slug" "$ext"
}

# --- parse args ---
FILES=()
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help) usage; exit 0 ;;
        --) shift; while [ $# -gt 0 ]; do FILES+=("$1"); shift; done; break ;;
        -*) echo "$(basename "$0"): unknown option: $1" >&2; usage >&2; exit 1 ;;
        *) FILES+=("$1") ;;
    esac
    shift
done

if [ ${#FILES[@]} -eq 0 ]; then
    usage >&2
    exit 1
fi

# --- validate everything exists before uploading anything ---
for f in "${FILES[@]}"; do
    if [ ! -f "$f" ]; then
        echo "$(basename "$0"): file not found: $f" >&2
        exit 1
    fi
done

# --- upload each, collecting the slugified remote names ---
REMOTE_NAMES=()
for f in "${FILES[@]}"; do
    remote="$(slugify "$(basename "$f")")"
    echo "Uploading $(basename "$f") -> $remote" >&2
    scp -q "$f" "$SERVER:$IMAGE_STORE/$remote"
    REMOTE_NAMES+=("$remote")
done

# --- print the markdown snippets (stdout; upload chatter above was stderr) ---
echo "" >&2
echo "Paste into your post:" >&2
for remote in "${REMOTE_NAMES[@]}"; do
    echo "![Caption]($URL_BASE/$remote \"Alt Text\")"
    echo ""
done
