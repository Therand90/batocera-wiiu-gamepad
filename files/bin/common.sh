#!/bin/bash

BASE='/userdata/system/wiiu-gamepad'
CONFIG="$BASE/config.env"
# shellcheck disable=SC2034
PAD_OUTPUT='WIIU-GAMEPAD'
PAD_SINK='WIIU_GAMEPAD_AUDIO'

export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/var/run}"

load_config() {
    # shellcheck source=/dev/null
    [ -f "$CONFIG" ] && . "$CONFIG"
    TV_SINK="${TV_SINK:-}"
    PRIMARY_OUTPUT="${PRIMARY_OUTPUT:-}"
    GAMEPAD_X="${GAMEPAD_X:-1920}"
    GAMEPAD_Y="${GAMEPAD_Y:-0}"
}

detect_tv_sink() {
    local sink
    sink="$(pactl get-default-sink 2>/dev/null || true)"
    if [ -n "$sink" ] && [ "$sink" != "$PAD_SINK" ] && \
       pactl list short sinks 2>/dev/null | awk -v s="$sink" '$2==s{ok=1} END{exit !ok}'; then
        printf '%s\n' "$sink"
        return 0
    fi

    pactl list short sinks 2>/dev/null | awk -v pad="$PAD_SINK" '$2!=pad {print $2; exit}'
}

detect_primary_output() {
    local out
    out="$(batocera-resolution currentOutput 2>/dev/null || true)"
    if [ -n "$out" ]; then
        printf '%s\n' "$out"
        return 0
    fi

    wlr-randr 2>/dev/null | awk '
/^[^[:space:]]/ { output=$1; next }
/^[[:space:]]+Enabled: yes/ && output != "" { print output; exit }
'
}

detect_gamepad_position() {
    local output="$1"
    local layout="$BASE/bin/display_layout.py"
    local pos=''

    if [ -x "$layout" ]; then
        pos="$(wlr-randr 2>/dev/null | "$layout" --primary "$output" 2>/dev/null || true)"
        if [ -n "$pos" ]; then
            printf '%s\n' "$pos"
            return 0
        fi
    fi

    # Conservative fallback for unexpected wlr-randr formats: place the GamePad
    # directly after Batocera's primary display, matching v0.1.0 behavior.
    local width='' xpos='0' ypos='0' mode
    mode="$(batocera-resolution currentMode 2>/dev/null | grep -Eo '[0-9]+x[0-9]+' | head -1 || true)"
    [ -n "$mode" ] && width="${mode%%x*}"

    if [ -n "$output" ]; then
        read -r xpos ypos <<EOF_POS
$(wlr-randr 2>/dev/null | awk -v out="$output" '
$1==out {inside=1; next}
inside && /^[^[:space:]]/ {exit}
inside && /Position:/ {
    split($2,p,",")
    print p[1], p[2]
    exit
}')
EOF_POS
    fi

    xpos="${xpos:-0}"
    ypos="${ypos:-0}"
    width="${width:-1920}"
    printf '%s %s\n' "$((xpos + width))" "$ypos"
}

write_config() {
    local tv="$1" output="$2" gx="$3" gy="$4"
    mkdir -p "$BASE"
    {
        printf 'TV_SINK=%q\n' "$tv"
        printf 'PRIMARY_OUTPUT=%q\n' "$output"
        printf 'GAMEPAD_X=%q\n' "$gx"
        printf 'GAMEPAD_Y=%q\n' "$gy"
    } > "$CONFIG"
}
