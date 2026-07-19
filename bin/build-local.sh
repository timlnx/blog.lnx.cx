#!/bin/bash
# SPDX-FileCopyrightText: 2026 Tim Case <tim@lnx.cx>
# SPDX-License-Identifier: MIT

# Local Mac build using rootless podman.
# Builds a native ARM64 image (quay.io/fedora/fedora:41 is multi-arch).
# Images come from ~/blog-images/ or override with BLOG_IMAGES env var.
set -euo pipefail

usage() {
    cat <<EOF
Usage: $(basename "$0") [-h|--help]

Build the blog locally using rootless podman. Pulls images from ~/blog-images/
(or the path in \$BLOG_IMAGES) and writes the built site to _site/.

The container image (localhost/blog-builder) is built automatically on first
run or when it doesn't exist. To force a rebuild after Containerfile or Gemfile
changes, remove the image first:

  podman rmi localhost/blog-builder

Options:
  -h, --help    Show this help and exit

Environment:
  BLOG_IMAGES   Path to local image store (default: \$HOME/blog-images)

More information: https://github.com/timlnx/blog.lnx.cx/blob/main/DEPLOY.md
EOF
}

for arg in "$@"; do
    case "$arg" in
        -h|--help) usage; exit 0 ;;
        *) echo "$(basename "$0"): unexpected argument: $arg" >&2; usage >&2; exit 1 ;;
    esac
done

# This script lives in bin/, so the repo root is one level up. CDPATH is cleared
# because an exported CDPATH makes cd echo its target, which would put two lines
# in REPO_DIR when this is invoked as `bin/build-local.sh` rather than
# `./bin/build-local.sh`.
REPO_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
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
