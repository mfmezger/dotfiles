#!/bin/bash
set -e

backup_if_exists() {
    local target="$HOME/$1"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "Backing up existing $target to $target.backup"
        mv "$target" "$target.backup"
    fi
}
