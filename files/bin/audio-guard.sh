#!/bin/bash
export LC_ALL=C

BASE='/userdata/system/wiiu-gamepad'
# shellcheck source=/dev/null
. "$BASE/bin/common.sh"
load_config

HDMI="$TV_SINK"
PAD="$PAD_SINK"
LOG="$BASE/logs/audio-guard.log"
mkdir -p "$BASE/logs"

TV_ID=''
PAD_ID=''

log() {
    printf '%s | %s\n' "$(date '+%F %T')" "$*" >> "$LOG"
}

cemu_inputs() {
    pactl list sink-inputs 2>/dev/null | awk '
        /^Sink Input #[0-9]+/ {
            if (id != "" && cemu) print id, sink
            id=$3; sub(/^#/, "", id); sink=""; cemu=0; next
        }
        /^[[:space:]]+Sink:/ { sink=$2 }
        /application\.process\.binary = "cemu"/ { cemu=1 }
        END { if (id != "" && cemu) print id, sink }
    '
}

log "Démarrage (TV=$HDMI PAD=$PAD)"

while pgrep -f '/usr/bin/cemu/cemu' >/dev/null 2>&1; do
    HDMI_NUM="$(pactl list short sinks 2>/dev/null | awk -v n="$HDMI" '$2==n {print $1; exit}')"
    PAD_NUM="$(pactl list short sinks 2>/dev/null | awk -v n="$PAD" '$2==n {print $1; exit}')"

    if [ -z "$HDMI_NUM" ] || [ -z "$PAD_NUM" ]; then
        sleep 0.1
        continue
    fi

    mapfile -t INPUTS < <(cemu_inputs)

    if [ -n "$TV_ID" ] && ! printf '%s\n' "${INPUTS[@]}" | grep -q "^${TV_ID} "; then
        TV_ID=''; PAD_ID=''
    fi
    if [ -n "$PAD_ID" ] && ! printf '%s\n' "${INPUTS[@]}" | grep -q "^${PAD_ID} "; then
        TV_ID=''; PAD_ID=''
    fi

    if [ -z "$TV_ID" ] || [ -z "$PAD_ID" ]; then
        for line in "${INPUTS[@]}"; do
            ID="${line%% *}"
            SINK="${line##* }"
            [ "$SINK" = "$HDMI_NUM" ] && TV_ID="$ID"
            [ "$SINK" = "$PAD_NUM" ] && PAD_ID="$ID"
        done
        if [ -n "$TV_ID" ] && [ -n "$PAD_ID" ]; then
            log "Appris : TV=$TV_ID GAMEPAD=$PAD_ID"
        fi
    fi

    pactl set-default-sink "$HDMI" >/dev/null 2>&1 || true
    [ -n "$TV_ID" ] && pactl move-sink-input "$TV_ID" "$HDMI" >/dev/null 2>&1 || true
    [ -n "$PAD_ID" ] && pactl move-sink-input "$PAD_ID" "$PAD" >/dev/null 2>&1 || true
    sleep 0.10
done

log 'Arrêt : Cemu fermé'
