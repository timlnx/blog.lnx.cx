#!/bin/bash
# Polls GitHub for new commits; builds and deploys the site when found.
# Run by systemd.timer every 5 minutes as tc (rootless podman).
set -euo pipefail

VERBOSE=0
FORCE=0

usage() {
    cat <<EOF
Usage: $(basename "$0") [-h|--help] [-v|--verbose] [-f|--force]

Poll GitHub for new commits to timlnx/blog.lnx.cx. When new commits are
found, pull them, rebuild the site in a rootless podman container, and
rsync the output to the Apache docroot with enforced permissions.

This script is normally run automatically by the blog-builder systemd timer.
To run it manually: /usr/local/bin/blog-poll.sh

All output goes to stdout. When run by systemd, the journal captures it:
  journalctl --user -u blog-builder.service -f

Options:
  -h, --help     Show this help and exit
  -v, --verbose  Show git, rsync, and podman output (default: quiet)
  -f, --force    Build and deploy even if there are no new commits

More information: https://github.com/timlnx/blog.lnx.cx/blob/main/DEPLOY.md
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)    usage; exit 0 ;;
        -v|--verbose) VERBOSE=1; shift ;;
        -f|--force)   FORCE=1; shift ;;
        *) echo "$(basename "$0"): unexpected argument: $1" >&2; usage >&2; exit 1 ;;
    esac
done

REPO_DIR=/srv/blog.lnx.cx
IMAGE_STORE=/srv/blog-images
OUTPUT_DIR=/tmp/blog-output
DOCROOT=/var/www/blog.lnx.cx
IMAGE_NAME=localhost/blog-builder

log() { echo "[$(date '+%H:%M:%S')] $*"; }

cd "$REPO_DIR"

if [ "$VERBOSE" -eq 1 ]; then
    git fetch origin main
else
    git fetch origin main --quiet
fi

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" = "$REMOTE" ] && [ "$FORCE" -eq 0 ]; then
    log "No new commits ($(git rev-parse --short HEAD)). Nothing to do."
    exit 0
fi

if [ "$FORCE" -eq 1 ] && [ "$LOCAL" = "$REMOTE" ]; then
    log "Force build at $(git rev-parse --short HEAD)."
else
    log "New commits detected: $(git rev-parse --short HEAD) -> $(git rev-parse --short origin/main). Starting build."
    if [ "$VERBOSE" -eq 1 ]; then
        git pull origin main
    else
        git pull origin main --quiet
    fi
fi

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

# Deploy with enforced permissions, never touch /scratch/ or /galleries/
if [ "$VERBOSE" -eq 1 ]; then
    rsync -av --delete \
        --chmod=D755,F644 \
        --exclude=/scratch/ \
        --exclude=/galleries/ \
        --exclude=/.url-manifest.json \
        "${OUTPUT_DIR}/" "${DOCROOT}/"
else
    rsync -a --delete \
        --chmod=D755,F644 \
        --exclude=/scratch/ \
        --exclude=/galleries/ \
        --exclude=/.url-manifest.json \
        "${OUTPUT_DIR}/" "${DOCROOT}/"
fi

# Sync gallery store directly to docroot (incremental, skips unchanged files)
if [ -d /srv/galleries ]; then
    if [ "$VERBOSE" -eq 1 ]; then
        rsync -av /srv/galleries/ "${DOCROOT}/galleries/"
    else
        rsync -a /srv/galleries/ "${DOCROOT}/galleries/"
    fi
fi

log "Deployed $(git rev-parse --short HEAD) to $DOCROOT"

# Best-effort: submit this round's changed pages to the Wayback Machine. LOCAL
# is the pre-pull HEAD and HEAD is the commit we just deployed, so the diff is
# exactly what landed. The manifest was emitted into OUTPUT_DIR by the build
# (_plugins/url_manifest.rb). `|| true` guarantees this can never fail or delay
# the deploy, which has already completed above.
/usr/local/bin/archive-update.sh "$LOCAL" HEAD "$OUTPUT_DIR/.url-manifest.json" || true
