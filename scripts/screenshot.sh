#!/bin/bash

# Create screenshots directory if it doesn't exist
mkdir -p ~/Pictures/Screenshots

# Generate filename with timestamp
FILENAME=~/Pictures/Screenshots/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png

# Take screenshot with selection
# -s: select window or rectangle
# -f: freeze screen while selecting (helps avoid capturing the selection tool itself sometimes)
if scrot -s -f "$FILENAME"; then
    # Copy to clipboard
    # We use xclip to read the file and put it in clipboard
    # -selection clipboard: use the Ctrl+V clipboard
    # -t image/png: specify mime type
    # -loop 1: keep xclip running to serve the selection (deprecated in some versions, but mostly harmless)
    # We silence output and background it properly
    xclip -selection clipboard -t image/png -i "$FILENAME" &

    # Notify user
    notify-send "Screenshot taken" "Saved to $FILENAME and copied to clipboard" -i "$FILENAME"
else
    notify-send "Screenshot aborted" "No screenshot taken"
fi
