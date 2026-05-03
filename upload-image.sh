#!/bin/bash
# Upload an image to the server image store and print the markdown reference.
# Usage: ./upload-image.sh path/to/photo.jpg
# Optional: ./upload-image.sh photo.jpg custom-name.jpg
set -euo pipefail

LOCAL_FILE="${1:-}"
REMOTE_NAME="${2:-}"
SERVER="tim@lnx.cx"
IMAGE_STORE="/srv/blog-images"

if [ -z "$LOCAL_FILE" ]; then
    echo "Usage: $0 <local-file> [remote-name]" >&2
    exit 1
fi

if [ ! -f "$LOCAL_FILE" ]; then
    echo "Error: file not found: $LOCAL_FILE" >&2
    exit 1
fi

if [ -z "$REMOTE_NAME" ]; then
    REMOTE_NAME="$(basename "$LOCAL_FILE")"
fi

scp "$LOCAL_FILE" "$SERVER:$IMAGE_STORE/$REMOTE_NAME"
echo ""
echo "Uploaded. Reference in posts as:"
echo "  ![alt text](/assets/images/$REMOTE_NAME)"
