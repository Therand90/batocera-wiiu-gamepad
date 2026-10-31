#!/bin/bash

BASE='/userdata/system/wiiu-gamepad'
RUN='/tmp/wiiu-gamepad'
GUARD="$BASE/bin/audio-guard.sh"
SUN="$BASE/sunshine/Sunshine-NoCursor.AppImage"
CONF="$BASE/sunshine/sunshine.conf"
LOG="$BASE/logs/session-run.log"
SUNLOG="$BASE/logs/sunshine-nocursor.log"
GUARDLOG="$BASE/logs/audio-guard.log"

export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/var/run}"

mkdir -p "$RUN" "$BASE/logs"

PGID="$(ps -o pgid= -p $$ 2>/dev/null | tr -d ' ')"
[ -n "$PGID" ] || PGID="$$"
echo "$PGID" > "$RUN/session.pgid"

{
    echo
    echo "===== $(date '+%F %T') | session-run ====="
    echo "PID=$$ PGID=$PGID"
    echo 'Attente de Cemu...'
} >> "$LOG"

i=0
while ! pgrep -f '/usr/bin/cemu/cemu' >/dev/null 2>&1; do
    sleep 0.1
    i=$((i + 1))
    if [ "$i" -ge 600 ]; then
        echo "$(date '+%F %T') | Cemu absent après 60 s, abandon" >> "$LOG"
        exit 1
    fi
done

echo "$(date '+%F %T') | Cemu détecté" >> "$LOG"

pkill -f "$GUARD" 2>/dev/null || true
rm -f "$GUARDLOG"
"$GUARD" >"$BASE/logs/audio-guard.stdout.log" 2>&1 </dev/null &
echo $! > "$RUN/audio-guard.pid"

i=0
while ! grep -q 'Appris :' "$GUARDLOG" 2>/dev/null; do
    sleep 0.1
    i=$((i + 1))
    [ "$i" -ge 150 ] && break
done

if grep -q 'Appris :' "$GUARDLOG" 2>/dev/null; then
    tail -n 1 "$GUARDLOG" >> "$LOG"
else
    echo "$(date '+%F %T') | Audio Guard lancé, apprentissage encore en cours" >> "$LOG"
fi

if [ ! -x "$SUN" ]; then
    echo "$(date '+%F %T') | ERREUR : Sunshine-NoCursor.AppImage absent" >> "$LOG"
    exit 1
fi

echo "$(date '+%F %T') | Lancement Sunshine NoCursor" >> "$LOG"
exec "$SUN" "$CONF" >>"$SUNLOG" 2>&1
