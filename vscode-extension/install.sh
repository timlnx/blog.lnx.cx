#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Tim Case <tim@lnx.cx>
# SPDX-License-Identifier: MIT

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    cat <<EOF
Usage: $(basename "$0") [-h|--help]

Build and install the blog.lnx.cx VS Code extension locally.

Runs npm install, packages with vsce, and installs the .vsix into VS Code.
After it finishes, reload VS Code (Cmd+Shift+P → Reload Window) to activate.

Options:
  -h, --help    Show this message and exit
EOF
    exit 0
}

for arg in "$@"; do
    case "$arg" in
        -h|--help) usage ;;
        *) echo "Unknown argument: $arg" >&2; usage ;;
    esac
done

if ! command -v code >/dev/null 2>&1; then
    echo "Error: 'code' CLI not found in PATH." >&2
    echo "Install via VS Code: Cmd+Shift+P → 'Shell Command: Install code command in PATH'" >&2
    exit 1
fi

cd "$SCRIPT_DIR"

echo "Installing dependencies..."
npm install

echo "Packaging extension..."
npx vsce package --no-dependencies

VSIX=$(ls -t ./*.vsix | head -1)
echo "Installing ${VSIX}..."
code --install-extension "${VSIX}"

echo ""
echo "Done. Reload VS Code (Cmd+Shift+P → Reload Window) to activate the extension."
