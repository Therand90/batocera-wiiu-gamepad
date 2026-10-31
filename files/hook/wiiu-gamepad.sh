#!/bin/bash

EVENT="${1:-}"
SYSTEM="${2:-}"
BASE='/userdata/system/wiiu-gamepad'

[ "$SYSTEM" = 'wiiu' ] || exit 0

case "$EVENT" in
    gameStart) "$BASE/bin/session-start.sh" ;;
    gameStop)  "$BASE/bin/session-stop.sh" ;;
esac
