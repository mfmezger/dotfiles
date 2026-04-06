#!/bin/bash
set -e

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
