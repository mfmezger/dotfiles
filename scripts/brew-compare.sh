#!/bin/bash
# Brewfile comparison script
# Usage: ./scripts/brew-compare.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$REPO_ROOT" || exit 1

uvx --from python "$SCRIPT_DIR/brew_compare.py"
