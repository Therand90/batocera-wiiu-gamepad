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

SUN_CONF="$BASE/sunshine/sunshine.conf"
CSRF_ORIGINS="$(ip -4 -o addr show scope global 2>/dev/null | awk '
{
    split($4, a, "/")
    if (a[1] != "") {
        if (out != "") out = out ","
        out = out "https://" a[1] ":47990"
    }
}
END { print out }
')"

if [ -n "$CSRF_ORIGINS" ] && [ -f "$SUN_CONF" ]; then
    CSRF_ORIGINS="$CSRF_ORIGINS" python3 <<'PY'
from pathlib import Path
import os
import re

p = Path('/userdata/system/wiiu-gamepad/sunshine/sunshine.conf')
s = p.read_text()
value = os.environ['CSRF_ORIGINS']
line = f'csrf_allowed_origins = {value}'

if re.search(r'^csrf_allowed_origins\s*=.*$', s, flags=re.M):
    s = re.sub(r'^csrf_allowed_origins\s*=.*$', line, s, count=1, flags=re.M)
else:
    if s and not s.endswith('\n'):
        s += '\n'
    s += line + '\n'

p.write_text(s)
PY
fi

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

printf 'TV sink: %s\nPrimary output: %s\nGamePad position: %s,%s\nSunshine CSRF origins: %s\n' \
    "$TV_SINK" "${PRIMARY_OUTPUT:-unknown}" "$GAMEPAD_X" "$GAMEPAD_Y" "${CSRF_ORIGINS:-built-in defaults}"
