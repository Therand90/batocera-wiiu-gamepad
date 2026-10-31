#!/bin/bash
set -u
OUT="${1:-/userdata/wiiu-gamepad-audit-$(date +%Y%m%d-%H%M%S).txt}"
{
    echo '===== SYSTEM ====='
    uname -a
    batocera-es-swissknife --version 2>/dev/null || true
    echo
    echo '===== OUTPUTS ====='
    wlr-randr 2>/dev/null || true
    echo
    echo '===== AUDIO SINKS ====='
    pactl list short sinks 2>/dev/null || true
    echo
    echo '===== GAMEPAD RUNTIME ====='
    find /userdata/system/wiiu-gamepad -maxdepth 3 -type f 2>/dev/null | sort || true
    echo
    echo '===== BATOCERA WII U OPTIONS ====='
    grep -E '^wiiu\.' /userdata/system/batocera.conf 2>/dev/null || true
    echo
    echo '===== CEMU RELEVANT ====='
    grep -E '<(TVVolume|PadVolume|TVDevice|PadDevice|open_pad)' /userdata/system/configs/cemu/settings.xml 2>/dev/null || true
} > "$OUT"
echo "$OUT"
