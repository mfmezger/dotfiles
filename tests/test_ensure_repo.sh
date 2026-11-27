#!/bin/bash
# Run offline with: bash tests/test_ensure_repo.sh
set -e
source "$(dirname "$0")/../scripts/common.sh"

SANDBOX=$(mktemp -d)
trap 'rm -rf "$SANDBOX"' EXIT
SOURCE="$SANDBOX/origin"
TARGET="$SANDBOX/custom plugins/plugin"
git init -q "$SOURCE"
printf 'original\n' > "$SOURCE/plugin"
git -C "$SOURCE" add plugin
git -C "$SOURCE" -c user.name=test -c user.email=test@example.invalid -c commit.gpgsign=false commit -qm initial
URL="file://$SOURCE"
ensure_repo "$TARGET" "$URL" --depth=1
test -f "$TARGET/.git/shallow"
printf 'local edit\n' > "$TARGET/plugin"
ensure_repo "$TARGET" "$URL"
grep -qx 'local edit' "$TARGET/plugin"

expect_failure() {
    if ensure_repo "$@"; then
        echo "Unexpected success for $1" >&2
        exit 1
    fi
}

# Even inside the expected checkout, a plain directory is not a plugin clone.
mkdir "$TARGET/plain"
expect_failure "$TARGET/plain" "$URL"
expect_failure "$TARGET/plugin" "$URL"
ln -s missing "$SANDBOX/dangling"
expect_failure "$SANDBOX/dangling" "$URL"
test -L "$SANDBOX/dangling"
expect_failure "$TARGET" "$URL-other"
grep -qx 'local edit' "$TARGET/plugin"
expect_failure "$SANDBOX/new" "$URL-missing"
