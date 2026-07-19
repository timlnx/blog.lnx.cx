#!/bin/bash
# SPDX-FileCopyrightText: 2026 Tim Case <tim@lnx.cx>
# SPDX-License-Identifier: MIT

# Runs inside the blog-builder container.
# Mounts expected:
#   /src    - git checkout of the repo (read-only)
#   /images - image store (read-only)
#   /output - build destination on host (read-write)
set -euo pipefail

WORKDIR=/tmp/site
mkdir -p "$WORKDIR"

rsync -a --delete /src/ "$WORKDIR/"
mkdir -p "$WORKDIR/assets/images"
cp -r /images/. "$WORKDIR/assets/images/"

cd "$WORKDIR"
bundle exec jekyll clean
bundle exec jekyll build --destination /output
