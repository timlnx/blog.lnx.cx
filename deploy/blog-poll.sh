#!/bin/bash
# Polls GitHub for new commits; builds and deploys the site when found.
# Run by systemd.timer every 5 minutes as tc (rootless podman).
set -euo pipefail

REPO_DIR=/srv/blog.lnx.cx
IMAGE_STORE=/srv/blog-images
OUTPUT_DIR=/tmp/blog-output
DOCROOT=/var/www/blog.lnx.cx
IMAGE_NAME=localhost/blog-builder
LOG_TAG=blog-builder

log() { logger -t "$LOG_TAG" "$*"; }

cd "$REPO_DIR"
git fetch origin main --quiet

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" = "$REMOTE" ]; then
    log "No new commits ($(git rev-parse --short HEAD)). Nothing to do."
    exit 0
fi

log "New commits detected: $(git rev-parse --short HEAD) -> $(git rev-parse --short origin/main). Starting build."

git pull origin main --quiet

# Rebuild container image if Gemfile or Containerfile changed
if git diff "${LOCAL}" HEAD -- Gemfile Gemfile.lock Containerfile | grep -q .; then
    log "Containerfile or Gemfile changed, rebuilding image..."
    podman build -t "$IMAGE_NAME" "$REPO_DIR"
    log "Container image rebuilt."
fi

# Build the site
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

podman run --rm \
    --userns=keep-id \
    -v "${REPO_DIR}:/src:ro,Z" \
    -v "${IMAGE_STORE}:/images:ro,Z" \
    -v "${OUTPUT_DIR}:/output:Z" \
    "$IMAGE_NAME"

log "Jekyll build complete."

# Deploy with enforced permissions, never touch /scratch/
rsync -a --delete \
    --chmod=D755,F644 \
    --exclude=/scratch/ \
    "${OUTPUT_DIR}/" "${DOCROOT}/"

log "Deployed $(git rev-parse --short HEAD) to $DOCROOT"
