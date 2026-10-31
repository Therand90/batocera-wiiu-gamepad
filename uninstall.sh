#!/bin/bash
set -euo pipefail

ACTIVE='/userdata/system/wiiu-gamepad'
HOOK='/userdata/system/scripts/wiiu-gamepad.sh'
RC='/userdata/system/.config/labwc/rc.xml'

[ "$(id -u)" -eq 0 ] || { echo 'ERREUR : lancer en root.' >&2; exit 1; }

[ -x "$ACTIVE/bin/session-stop.sh" ] && "$ACTIVE/bin/session-stop.sh" || true
rm -f "$HOOK"

if [ -f "$RC" ]; then
python3 <<'PY'
from pathlib import Path
import re
import xml.etree.ElementTree as ET
p = Path('/userdata/system/.config/labwc/rc.xml')
s = p.read_text()
patterns = [
    r'\s*<keybind key="W-C-F11">\s*<action name="VirtualOutputAdd" output_name="WIIU-GAMEPAD"\s*/>\s*</keybind>',
    r'\s*<keybind key="W-C-F12">\s*<action name="VirtualOutputRemove" output_name="WIIU-GAMEPAD"\s*/>\s*</keybind>',
    r'\s*<windowRule title="GamePad View\*">.*?</windowRule>',
    r'\s*<touch deviceName="libvirtualhid Touchscreen"\s+mapToOutput="WIIU-GAMEPAD"\s+mouseEmulation="no"\s*/>',
]
for pat in patterns:
    s = re.sub(pat, '\n', s, flags=re.S)
ET.fromstring(s)
p.write_text(s)
PY
fi

rm -rf "$ACTIVE"
echo 'Runtime Wii U GamePad supprimé.'
echo 'Les préférences Cemu/Batocera existantes ont volontairement été laissées intactes.'
