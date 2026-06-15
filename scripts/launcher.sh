#!/bin/bash
set -e

# Prefer Walker on Wayland; keep rofi as a fallback until Walker + Elephant are installed.
if command -v walker > /dev/null 2>&1 && command -v elephant > /dev/null 2>&1; then
    LOG_DIR="${XDG_RUNTIME_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles}"
    mkdir -p "$LOG_DIR"

    if ! pgrep -x elephant > /dev/null 2>&1; then
        elephant > "$LOG_DIR/elephant.log" 2>&1 &
        sleep 0.3
    fi

    if ! pgrep -f 'walker --gapplication-service' > /dev/null 2>&1; then
        walker --gapplication-service > "$LOG_DIR/walker.log" 2>&1 &
        sleep 0.2
    fi

    exec walker
fi

if command -v walker > /dev/null 2>&1 && ! command -v elephant > /dev/null 2>&1; then
    notify-send "Walker" "Missing Elephant backend; falling back to rofi" 2> /dev/null || true
fi

exec rofi -show combi -combi-modes "drun,run,calc"
