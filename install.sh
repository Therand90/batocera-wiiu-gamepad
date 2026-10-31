#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
FILES="$ROOT/files"
ACTIVE='/userdata/system/wiiu-gamepad'
BIN="$ACTIVE/bin"
SUN="$ACTIVE/sunshine"
HOOK='/userdata/system/scripts/wiiu-gamepad.sh'
RC='/userdata/system/.config/labwc/rc.xml'
CEMU='/userdata/system/configs/cemu/settings.xml'
BATOCERA='/userdata/system/batocera.conf'
STAMP="$(date '+%Y%m%d-%H%M%S')"
BACKUP="$ACTIVE/backups/install-$STAMP"

[ "$(id -u)" -eq 0 ] || { echo 'ERREUR : lancer cet installateur en root sous Batocera.' >&2; exit 1; }

for cmd in python3 pactl wlr-randr wtype labwc batocera-resolution; do
    command -v "$cmd" >/dev/null 2>&1 || { echo "ERREUR : commande requise absente : $cmd" >&2; exit 1; }
done

echo '===== Batocera Wii U GamePad - installation ====='
mkdir -p "$BIN" "$SUN" "$ACTIVE/logs" "$ACTIVE/backups" /userdata/system/scripts
mkdir -p "$BACKUP"

[ -f "$RC" ]       && cp -a "$RC" "$BACKUP/rc.xml"
[ -f "$CEMU" ]     && cp -a "$CEMU" "$BACKUP/settings.xml"
[ -f "$BATOCERA" ] && cp -a "$BATOCERA" "$BACKUP/batocera.conf"
[ -f "$HOOK" ]     && cp -a "$HOOK" "$BACKUP/wiiu-gamepad.sh"
echo "Backup pré-installation : $BACKUP"

cp -f "$FILES/bin/"*.sh "$BIN/"
chmod +x "$BIN/"*.sh
cp -f "$FILES/hook/wiiu-gamepad.sh" "$HOOK"
chmod +x "$HOOK"
cp -f "$FILES/sunshine/sunshine.conf" "$SUN/sunshine.conf"

if [ -f "$FILES/sunshine/Sunshine-NoCursor.AppImage" ]; then
    cp -f "$FILES/sunshine/Sunshine-NoCursor.AppImage" "$SUN/Sunshine-NoCursor.AppImage"
fi
if [ ! -x "$SUN/Sunshine-NoCursor.AppImage" ]; then
    echo 'ERREUR : Sunshine-NoCursor.AppImage absent.' >&2
    echo 'Le dépôt source ne contient volontairement pas les binaires ; utiliser un ZIP de release ou fournir le binaire validé.' >&2
    exit 1
fi
chmod +x "$SUN/Sunshine-NoCursor.AppImage"

python3 <<'PY'
from pathlib import Path
p = Path('/userdata/system/batocera.conf')
desired = {
    'wiiu.cemu_touchpad': '1',
    'wiiu.cemu_gamepad': 'true',
}
lines = p.read_text().splitlines() if p.exists() else []
out = []
for line in lines:
    key = line.split('=', 1)[0].strip() if '=' in line else ''
    if key not in desired:
        out.append(line)
if out and out[-1] != '':
    out.append('')
for key, value in desired.items():
    out.append(f'{key}={value}')
p.write_text('\n'.join(out) + '\n')
PY

"$BIN/configure.sh"
"$BIN/ensure-labwc.sh"

for f in "$BIN/"*.sh "$HOOK"; do bash -n "$f"; done
python3 - <<'PY'
import xml.etree.ElementTree as ET
ET.parse('/userdata/system/.config/labwc/rc.xml')
print('LabWC XML : OK')
PY

echo
echo 'Installation terminée.'
echo 'Le pairing, les certificats et les credentials Sunshine existants n’ont pas été modifiés.'
echo 'Lancez ensuite un jeu Wii U depuis EmulationStation.'
