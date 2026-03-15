#!/bin/bash
set -e

DIGITAL_VIBRANCE=57

if ! command -v nvidia-settings >/dev/null 2>&1; then
    exit 0
fi

# NVIDIA commonly exposes DigitalVibrance on a 0..63 scale.
# 57 is ~90% of the maximum value.
nvidia-settings --assign "[gpu:0]/DigitalVibrance=${DIGITAL_VIBRANCE}" >/dev/null 2>&1 || true
