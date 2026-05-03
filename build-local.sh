#!/bin/bash
# Local Mac build using rootless podman.
# Builds a native ARM64 image (quay.io/fedora/fedora:41 is multi-arch).
# Images come from ~/blog-images/ or override with BLOG_IMAGES env var.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BLOG_IMAGES="${BLOG_IMAGES:-$HOME/blog-images}"
OUTPUT_DIR="$REPO_DIR/_site"
IMAGE_NAME="localhost/blog-builder"

if [ ! -d "$BLOG_IMAGES" ]; then
    echo "WARNING: $BLOG_IMAGES not found, building without images"
    BLOG_IMAGES="/dev/null"
fi

if ! podman image exists "$IMAGE_NAME" 2>/dev/null; then
    echo "Building container image..."
    podman build -t "$IMAGE_NAME" "$REPO_DIR"
fi

mkdir -p "$OUTPUT_DIR"

podman run --rm \
    -v "$REPO_DIR:/src:ro" \
    -v "$BLOG_IMAGES:/images:ro" \
    -v "$OUTPUT_DIR:/output" \
    --userns=keep-id \
    "$IMAGE_NAME"

echo "Built to: $OUTPUT_DIR"
