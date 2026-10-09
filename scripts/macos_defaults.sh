#!/bin/bash
# Apply macOS defaults (Finder, Dock, screenshots, appearance).
# Usage: ./scripts/macos_defaults.sh [--check]   (--check only reports drift, changes nothing)
set -e

if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "macos_defaults.sh: macOS only, skipping"
    exit 0
fi

MODE="${1:-apply}"
DRIFT=0

# setting <domain> <key> <type> <value>
setting() {
    local DOMAIN="$1" KEY="$2" TYPE="$3" VALUE="$4"
    if [[ "$MODE" == "--check" ]]; then
        local CURRENT EXPECTED="$VALUE"
        CURRENT="$(defaults read "$DOMAIN" "$KEY" 2> /dev/null || echo "<unset>")"
        if [[ "$TYPE" == "bool" ]]; then
            [[ "$VALUE" == "true" ]] && EXPECTED="1" || EXPECTED="0"
        fi
        if [[ "$CURRENT" != "$EXPECTED" ]]; then
            echo "DRIFT  $DOMAIN $KEY: current=$CURRENT expected=$EXPECTED"
            DRIFT=$((DRIFT + 1))
        fi
    else
        defaults write "$DOMAIN" "$KEY" "-$TYPE" "$VALUE"
    fi
}

# Finder
setting com.apple.finder ShowPathbar bool true
setting com.apple.finder ShowStatusBar bool true
# List view, grouped/arranged by name
setting com.apple.finder FXPreferredViewStyle string Nlsv
setting com.apple.finder FXPreferredGroupBy string Name
setting com.apple.finder FXArrangeGroupViewBy string Name
# New windows open the home folder
setting com.apple.finder NewWindowTarget string PfHm
setting com.apple.finder ShowHardDrivesOnDesktop bool true
setting com.apple.finder ShowExternalHardDrivesOnDesktop bool true
setting com.apple.finder ShowMountedServersOnDesktop bool true
setting com.apple.finder ShowRemovableMediaOnDesktop bool true

# Dock: no recent apps, don't reorder Spaces, bottom-right hot corner = Quick Note
setting com.apple.dock tilesize int 43
setting com.apple.dock show-recents bool false
setting com.apple.dock mru-spaces bool false
setting com.apple.dock wvous-br-corner int 14

# Screenshots go to the clipboard, no floating thumbnail
setting com.apple.screencapture target string clipboard
setting com.apple.screencapture show-thumbnail bool false

# Appearance: dark mode, yellow accent + highlight
setting NSGlobalDomain AppleInterfaceStyle string Dark
setting NSGlobalDomain AppleAccentColor int 2
setting NSGlobalDomain AppleHighlightColor string "1.000000 0.937255 0.690196 Yellow"

if [[ "$MODE" == "--check" ]]; then
    echo "macOS defaults drift: $DRIFT"
    exit "$((DRIFT > 0 ? 1 : 0))"
fi

killall Finder Dock SystemUIServer &> /dev/null || true
echo ">>> macOS defaults applied (appearance changes may need a logout) <<<"
