#!/bin/bash
set -e

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
FILENAME="$SCREENSHOT_DIR/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"

mkdir -p "$SCREENSHOT_DIR"

take_wayland_screenshot() {
    grim -g "$(slurp)" "$FILENAME"
    wl-copy < "$FILENAME"
}

take_x11_screenshot() {
    scrot -s -f "$FILENAME"
    xclip -selection clipboard -t image/png -i "$FILENAME" &
}

if [ -n "$WAYLAND_DISPLAY" ]; then
    SCREENSHOT_CMD="take_wayland_screenshot"
else
    SCREENSHOT_CMD="take_x11_screenshot"
fi

if $SCREENSHOT_CMD; then
    notify-send "Screenshot taken" "Saved to $FILENAME and copied to clipboard" -i "$FILENAME"
else
    notify-send "Screenshot aborted" "No screenshot taken"
fi
