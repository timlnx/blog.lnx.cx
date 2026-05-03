#!/bin/bash
# Upload an image to the server image store and print the markdown reference.
set -euo pipefail

usage() {
    cat <<EOF
Usage: $(basename "$0") [-h|--help] <local-file> [remote-name]

Upload an image to the blog image store on lnx.cx and print the markdown
image reference ready to paste into a post.

Arguments:
  local-file    Path to the image file to upload
  remote-name   Filename to use on the server (default: basename of local-file)

Examples:
  $(basename "$0") ~/Desktop/photo.jpg
  $(basename "$0") ~/Desktop/photo.jpg my-renamed-photo.jpg

Options:
  -h, --help    Show this help and exit

More information: https://github.com/timlnx/blog.lnx.cx/blob/main/DEPLOY.md
EOF
}

if [ $# -eq 0 ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    [ $# -eq 0 ] && exit 1 || exit 0
fi

if [ $# -gt 2 ]; then
    echo "$(basename "$0"): too many arguments" >&2
    usage >&2
    exit 1
fi

LOCAL_FILE="$1"
REMOTE_NAME="${2:-$(basename "$LOCAL_FILE")}"
SERVER="tc@lnx.cx"
IMAGE_STORE="/srv/blog-images"

if [ ! -f "$LOCAL_FILE" ]; then
    echo "$(basename "$0"): file not found: $LOCAL_FILE" >&2
    exit 1
fi

scp "$LOCAL_FILE" "$SERVER:$IMAGE_STORE/$REMOTE_NAME"
echo ""
echo "Uploaded. Reference in posts as:"
echo "  ![alt text](/assets/images/$REMOTE_NAME)"
