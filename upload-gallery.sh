#!/bin/bash
# Upload a simpleGals output directory to the blog gallery store.
set -euo pipefail

usage() {
    cat <<EOF
Usage: $(basename "$0") [-h|--help] <project-dir>

Upload a simpleGals gallery to the blog gallery store on lnx.cx.
The gallery name is the basename of <project-dir> and determines the URL path.
The script uploads <project-dir>/out/ automatically.

Example: given /path/to/2026-05-Red-Hat-Summit/, the gallery will be
reachable at:
  https://blog.lnx.cx/galleries/2026-05-Red-Hat-Summit/

Also adds an entry to _data/galleries.yml in the blog repo if the gallery
is not already listed there. Commit and push that file to publish the listing.

Arguments:
  project-dir    Path to the simpleGals project directory (contains out/)

Options:
  -h, --help    Show this help and exit
EOF
}

if [ $# -eq 0 ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    [ $# -eq 0 ] && exit 1 || exit 0
fi

if [ $# -gt 1 ]; then
    echo "$(basename "$0"): too many arguments" >&2
    usage >&2
    exit 1
fi

PROJECT_DIR="${1%/}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVER="tc@lnx.cx"
IMAGE_STORE="/srv/galleries"
DATA_FILE="$SCRIPT_DIR/_data/galleries.yml"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "$(basename "$0"): directory not found: $PROJECT_DIR" >&2
    exit 1
fi

LOCAL_DIR="$PROJECT_DIR/out"

if [ ! -d "$LOCAL_DIR" ]; then
    echo "$(basename "$0"): no out/ directory found in $PROJECT_DIR" >&2
    exit 1
fi

GALLERY_NAME="$(basename "$PROJECT_DIR")"
TITLE=$(grep -m1 '<h1>' "$LOCAL_DIR/index.html" 2>/dev/null \
    | sed 's|<[^>]*>||g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
[ -z "$TITLE" ] && TITLE="$GALLERY_NAME"
UPLOAD_DATE="$(date +%Y-%m-%d)"

echo "Gallery name : $GALLERY_NAME"
echo "Title        : $TITLE"
echo "Source       : $LOCAL_DIR/"
echo "Destination  : $SERVER:$IMAGE_STORE/$GALLERY_NAME/"
echo ""

ssh "$SERVER" "mkdir -p \"$IMAGE_STORE/$GALLERY_NAME\""
rsync -av --progress "$LOCAL_DIR/" "$SERVER:$IMAGE_STORE/$GALLERY_NAME/"

if ! grep -q "name: $GALLERY_NAME" "$DATA_FILE" 2>/dev/null; then
    printf -- '- name: %s\n  title: %s\n  date: %s\n' \
        "$GALLERY_NAME" "$TITLE" "$UPLOAD_DATE" >> "$DATA_FILE"
    echo ""
    echo "Added '$GALLERY_NAME' to $DATA_FILE"
    echo "Commit and push _data/galleries.yml to publish the gallery listing."
fi

echo ""
echo "Done. Gallery reachable at:"
echo "  https://blog.lnx.cx/galleries/$GALLERY_NAME/"
