#!/bin/bash
set -e

BASE='/userdata/system/wiiu-gamepad'
# shellcheck source=/dev/null
. "$BASE/bin/common.sh"

TV_SINK="$(detect_tv_sink)"
PRIMARY_OUTPUT="$(detect_primary_output)"
read -r GAMEPAD_X GAMEPAD_Y <<EOF_POS
$(detect_gamepad_position "$PRIMARY_OUTPUT")
EOF_POS

if [ -z "$TV_SINK" ]; then
    echo 'ERREUR : aucune sortie audio TV détectée.' >&2
    exit 1
fi

write_config "$TV_SINK" "$PRIMARY_OUTPUT" "$GAMEPAD_X" "$GAMEPAD_Y"

CEMU='/userdata/system/configs/cemu/settings.xml'
if [ -f "$CEMU" ]; then
    TV_SINK="$TV_SINK" python3 <<'PY'
from pathlib import Path
import os
import re

p = Path('/userdata/system/configs/cemu/settings.xml')
s = p.read_text()
values = {
    'TVVolume': '100',
    'PadVolume': '100',
    'TVDevice': os.environ['TV_SINK'],
    'PadDevice': 'WIIU_GAMEPAD_AUDIO',
    'open_pad': 'true',
}

for tag, value in values.items():
    pattern = rf'(<{tag}>).*?(</{tag}>)'
    replacement = lambda m, v=value: m.group(1) + v + m.group(2)
    s, count = re.subn(pattern, replacement, s, count=1, flags=re.S)
    if count == 0 and tag != 'open_pad':
        raise SystemExit(f'ERREUR : balise Cemu {tag} introuvable')

p.write_text(s)
PY
else
    echo "ATTENTION : $CEMU absent ; les réglages audio Cemu seront appliqués au prochain gameStart si le fichier existe alors." >&2
fi

printf 'TV sink: %s\nPrimary output: %s\nGamePad position: %s,%s\n' \
    "$TV_SINK" "${PRIMARY_OUTPUT:-unknown}" "$GAMEPAD_X" "$GAMEPAD_Y"
