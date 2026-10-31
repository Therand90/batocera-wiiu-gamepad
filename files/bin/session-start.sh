#!/bin/bash

BASE='/userdata/system/wiiu-gamepad'
BIN="$BASE/bin"
RUN='/tmp/wiiu-gamepad'
LOG="$BASE/logs/session-start.log"

. "$BIN/common.sh"
mkdir -p "$RUN" "$BASE/logs"
exec >>"$LOG" 2>&1

echo
echo "===== $(date '+%F %T') | gameStart ====="

if ! "$BIN/ensure-labwc.sh"; then
    echo 'ERREUR : impossible de préparer LabWC'
    exit 1
fi

if ! "$BIN/configure.sh"; then
    echo 'ERREUR : détection/configuration impossible'
    exit 1
fi
load_config

if ! wlr-randr 2>/dev/null | grep -q "^${PAD_OUTPUT} "; then
    echo "Création de $PAD_OUTPUT"
    wtype -M logo -M ctrl -k F11 -m ctrl -m logo
    i=0
    while ! wlr-randr 2>/dev/null | grep -q "^${PAD_OUTPUT} "; do
        sleep 0.1
        i=$((i + 1))
        [ "$i" -ge 30 ] && break
    done
fi

if wlr-randr 2>/dev/null | grep -q "^${PAD_OUTPUT} "; then
    wlr-randr --output "$PAD_OUTPUT" --custom-mode 854x480 --pos "${GAMEPAD_X},${GAMEPAD_Y}"
    echo "$PAD_OUTPUT prêt : 854x480 @ ${GAMEPAD_X},${GAMEPAD_Y}"
else
    echo "ERREUR : impossible de créer $PAD_OUTPUT"
    exit 1
fi

if ! pactl list short sinks 2>/dev/null | awk -v p="$PAD_SINK" '$2==p{found=1} END{exit !found}'; then
    MODULE_ID="$(pactl load-module module-null-sink sink_name="$PAD_SINK" rate=48000 channels=2)"
    echo "$MODULE_ID" > "$RUN/null-module.id"
    echo "Sink $PAD_SINK créé : module $MODULE_ID"
else
    echo "Sink $PAD_SINK déjà présent"
fi

pactl set-default-sink "$TV_SINK" 2>/dev/null || true
rm -f "$RUN/session.pgid"

python3 - "$BIN/session-run.sh" <<'DETACH_PY'
import subprocess
import sys
subprocess.Popen(
    [sys.argv[1]],
    stdin=subprocess.DEVNULL,
    stdout=subprocess.DEVNULL,
    stderr=subprocess.DEVNULL,
    start_new_session=True,
    close_fds=True,
)
DETACH_PY

i=0
while [ ! -s "$RUN/session.pgid" ]; do
    sleep 0.05
    i=$((i + 1))
    [ "$i" -ge 20 ] && break
done

if [ -s "$RUN/session.pgid" ]; then
    echo "Session détachée PGID=$(cat "$RUN/session.pgid")"
else
    echo 'ATTENTION : PGID de session non enregistré'
fi
