#!/bin/bash
set -e

# ensure_repo TARGET URL [clone options...]. Never update or replace an existing checkout.
ensure_repo() {
    local target="$1" url="$2" origin
    shift 2

    if [[ ! -e "$target" && ! -L "$target" ]]; then
        git clone "$@" -- "$url" "$target"
        return
    fi

    # Require this checkout's own .git (not an enclosing repo), origin and HEAD.
    if [[ -e "$target/.git" ]] && origin=$(git -C "$target" config --local --get remote.origin.url) &&
        [[ "${origin%.git}" == "${url%.git}" ]] && git -C "$target" rev-parse --verify --quiet 'HEAD^{commit}' > /dev/null; then
        echo ">>> Keeping existing checkout: $target <<<"
        return 0
    fi

    printf 'Cannot install %s: %s already exists and is not the expected checkout. Left untouched.\n' "$url" "$target" >&2
    return 1
}

backup_if_exists() {
    local target="$HOME/$1"
    local timestamp
    local backup_path
    local counter

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        timestamp="$(date +"%Y%m%d-%H%M%S")"
        backup_path="${target}.backup.${timestamp}"
        counter=1

        while [ -e "$backup_path" ]; do
            backup_path="${target}.backup.${timestamp}.${counter}"
            counter=$((counter + 1))
        done

        echo "Backing up existing $target to $backup_path"
        mv "$target" "$backup_path"
    fi
}
