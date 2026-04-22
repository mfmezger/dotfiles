#!/bin/bash
set -e

if ! command -v gnome-keyring-daemon > /dev/null 2>&1; then
    exit 0
fi

if pgrep -x gnome-keyring-daemon > /dev/null 2>&1; then
    exit 0
fi

eval "$(gnome-keyring-daemon --start --components=secrets,pkcs11,ssh)"
