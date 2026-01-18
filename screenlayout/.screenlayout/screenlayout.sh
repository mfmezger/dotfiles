#!/bin/sh
xrandr --output HDMI-0 --mode 2560x1440 --pos 0x0 --rotate right \
    --output DP-0 --primary --mode 2560x1440 --rate 144 --pos 1440x605 --rotate normal \
    --output DP-1 --off \
    --output DP-2 --mode 2560x1440 --rate 100 --pos 4000x605 --rotate normal \
    --output DP-3 --off \
    --output DP-4 --off \
    --output DP-5 --off \
    --output HDMI-A-1-1 --off \
    --output DisplayPort-1-3 --off \
    --output DisplayPort-1-4 --off \
    --output DisplayPort-1-5 --off
