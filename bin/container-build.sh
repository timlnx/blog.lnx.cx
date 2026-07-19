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

# _plugins/atom_feed.rb generates the feed and has no unit tests, so checking the
# built document is the check. set -e means a bad feed fails the container run,
# which stops blog-poll.sh before it rsyncs anything to the docroot.
python3 bin/validate-feed.py /output/feed.xml
