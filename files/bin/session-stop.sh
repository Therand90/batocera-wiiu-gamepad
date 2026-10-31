#!/bin/bash

BASE='/userdata/system/wiiu-gamepad'
RUN='/tmp/wiiu-gamepad'
LOG="$BASE/logs/session-stop.log"
. "$BASE/bin/common.sh"
load_config

mkdir -p "$BASE/logs"
exec >>"$LOG" 2>&1

echo
echo "===== $(date '+%F %T') | gameStop ====="

if [ -s "$RUN/session.pgid" ]; then
    PGID="$(cat "$RUN/session.pgid")"
    case "$PGID" in
        ''|*[!0-9]*) ;;
        *)
            echo "Arrêt du groupe PGID=$PGID"
            kill -TERM -- "-$PGID" 2>/dev/null || true
            i=0
            while kill -0 -- "-$PGID" 2>/dev/null; do
                sleep 0.1
                i=$((i + 1))
                [ "$i" -ge 20 ] && break
            done
            kill -KILL -- "-$PGID" 2>/dev/null || true
            ;;
    esac
fi

pkill -TERM -f '/tmp/.mount_.*usr/bin/sunshine /userdata/system/wiiu-gamepad/sunshine/sunshine.conf' 2>/dev/null || true
pkill -TERM -f '/userdata/system/wiiu-gamepad/bin/audio-guard.sh' 2>/dev/null || true
sleep 0.2
pkill -KILL -f '/tmp/.mount_.*usr/bin/sunshine /userdata/system/wiiu-gamepad/sunshine/sunshine.conf' 2>/dev/null || true

[ -n "$TV_SINK" ] && pactl set-default-sink "$TV_SINK" 2>/dev/null || true

pactl list short modules 2>/dev/null | awk -v p="$PAD_SINK" '$2=="module-null-sink" && $0 ~ ("sink_name=" p) {print $1}' |
while read -r MODULE_ID; do
    [ -n "$MODULE_ID" ] || continue
    echo "Déchargement module audio $MODULE_ID"
    pactl unload-module "$MODULE_ID" 2>/dev/null || true
done

if wlr-randr 2>/dev/null | grep -q "^${PAD_OUTPUT} "; then
    echo "Suppression de $PAD_OUTPUT"
    wtype -M logo -M ctrl -k F12 -m ctrl -m logo
fi

rm -rf "$RUN"
echo 'Nettoyage terminé'
