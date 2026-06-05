#!/bin/bash
set -e

# Prefer Walker on Wayland; keep rofi as a fallback until Walker + Elephant are installed.
if command -v walker > /dev/null 2>&1 && command -v elephant > /dev/null 2>&1; then
    if ! pgrep -x elephant > /dev/null 2>&1; then
        elephant > /tmp/elephant.log 2>&1 &
        sleep 0.3
    fi

    if ! pgrep -af 'walker --gapplication-service' > /dev/null 2>&1; then
        walker --gapplication-service > /tmp/walker.log 2>&1 &
        sleep 0.2
    fi

    exec walker
fi

if command -v walker > /dev/null 2>&1 && ! command -v elephant > /dev/null 2>&1; then
    notify-send "Walker" "Missing Elephant backend; falling back to rofi" 2> /dev/null || true
fi

exec rofi -show combi -combi-modes "drun,run,calc"
