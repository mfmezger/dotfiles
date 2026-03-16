#!/bin/bash
set -e

cat <<'EOF' | rofi -dmenu -i -p "Hyprland keys" -theme-str 'listview { lines: 24; }'
Hyprland Keybindings Cheat Sheet
================================

General
Super+Return      Open Ghostty
Super+Q           Close focused window
Super+F           Fullscreen
Super+Shift+Space Toggle floating
Super+Space       Cycle floating windows
Super+Escape      Exit fullscreen

Focus
Super+J/K/B/O     Focus left/down/up/right
Super+Arrows      Focus with arrow keys

Move Windows
Super+Shift+J/K/B/O   Move window left/down/up/right
Super+Shift+Arrows    Move with arrow keys

Layout
Super+E           Toggle split
Super+G           Toggle pseudotile
Super+R           Enter resize mode

Workspaces
Super+1..0        Switch workspace 1..10
Super+Shift+1..0  Move window to workspace 1..10
Super+Tab         Next workspace
Super+Shift+Tab   Previous workspace

Launchers
Super+D           App launcher
Super+T           Window switcher
Super+W           Brave
Super+N           Thunar
Print             Screenshot

Audio And Power
Super+P           Switch audio output
Super+Shift+P     Power profile menu
XF86Audio*        Volume and mute
XF86MonBrightness* Brightness

System
Super+L           Lock screen
Super+Shift+C     Reload Hyprland
Super+Shift+E     Wlogout
F1                Show this help

Resize Mode
J/K/B/O or Arrows Resize active window
Escape or Return  Exit resize mode
EOF
