#!/bin/bash
set -e

if ! command -v rofi >/dev/null 2>&1; then
    notify-send "Power profile" "rofi is not installed"
    exit 1
fi

if ! command -v powerprofilesctl >/dev/null 2>&1; then
    notify-send "Power profile" "powerprofilesctl is not installed"
    exit 1
fi

CURRENT_PROFILE="$(powerprofilesctl get)"
SELECTED_PROFILE="$(
    printf "balanced\nperformance\npower-saver\n" |
        rofi -dmenu -i -p "Power profile" -mesg "Current: ${CURRENT_PROFILE}"
)"

if [ -z "$SELECTED_PROFILE" ]; then
    exit 0
fi

powerprofilesctl set "$SELECTED_PROFILE"
notify-send "Power profile" "Switched to ${SELECTED_PROFILE}"
