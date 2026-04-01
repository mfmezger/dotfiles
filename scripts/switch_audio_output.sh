#!/bin/bash
set -e

if ! command -v pactl >/dev/null 2>&1; then
    notify-send "Audio output" "pactl is not installed"
    exit 1
fi

CURRENT_SINK="$(pactl get-default-sink)"
mapfile -t SINKS < <(pactl list short sinks | awk '{print $2}')

if [ "${#SINKS[@]}" -eq 0 ]; then
    notify-send "Audio output" "No audio sinks found"
    exit 1
fi

NEXT_SINK="${SINKS[0]}"
for INDEX in "${!SINKS[@]}"; do
    if [ "${SINKS[$INDEX]}" = "$CURRENT_SINK" ]; then
        NEXT_INDEX=$(((INDEX + 1) % ${#SINKS[@]}))
        NEXT_SINK="${SINKS[$NEXT_INDEX]}"
        break
    fi
done

pactl set-default-sink "$NEXT_SINK"

while read -r INPUT_ID _; do
    pactl move-sink-input "$INPUT_ID" "$NEXT_SINK"
done < <(pactl list short sink-inputs)

notify-send "Audio output" "Switched to ${NEXT_SINK}"
