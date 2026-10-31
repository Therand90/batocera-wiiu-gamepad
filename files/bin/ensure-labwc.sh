#!/bin/bash
set -e

RC='/userdata/system/.config/labwc/rc.xml'

export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/var/run}"

[ -f "$RC" ] || {
    echo "ERREUR : $RC introuvable" >&2
    exit 1
}

python3 <<'PY'
from pathlib import Path
import xml.etree.ElementTree as ET

p = Path('/userdata/system/.config/labwc/rc.xml')
s = p.read_text()
changed = False

keybinds = '''    <keybind key="W-C-F11">
      <action name="VirtualOutputAdd" output_name="WIIU-GAMEPAD" />
    </keybind>
    <keybind key="W-C-F12">
      <action name="VirtualOutputRemove" output_name="WIIU-GAMEPAD" />
    </keybind>
'''

rule = '''    <windowRule title="GamePad View*">
      <action name="MoveToOutput">
        <output>WIIU-GAMEPAD</output>
      </action>
      <action name="ToggleFullscreen" />
    </windowRule>
'''

touch = '''  <touch deviceName="libvirtualhid Touchscreen"
         mapToOutput="WIIU-GAMEPAD"
         mouseEmulation="no" />
'''

if 'VirtualOutputAdd" output_name="WIIU-GAMEPAD"' not in s:
    if '  </keyboard>' not in s:
        raise SystemExit('ERREUR : </keyboard> introuvable')
    s = s.replace('  </keyboard>', keybinds + '  </keyboard>', 1)
    changed = True

if 'title="GamePad View*"' not in s:
    if '  </windowRules>' not in s:
        raise SystemExit('ERREUR : </windowRules> introuvable')
    s = s.replace('  </windowRules>', rule + '  </windowRules>', 1)
    changed = True

if 'deviceName="libvirtualhid Touchscreen"' not in s:
    if '</labwc_config>' not in s:
        raise SystemExit('ERREUR : </labwc_config> introuvable')
    s = s.replace('</labwc_config>', touch + '\n</labwc_config>', 1)
    changed = True

ET.fromstring(s)
if changed:
    p.write_text(s)
    print('CHANGED')
else:
    print('OK')
PY

LABWC_PID="$(pgrep -o -x labwc 2>/dev/null || true)"
if [ -n "$LABWC_PID" ]; then
    LABWC_PID="$LABWC_PID" labwc --reconfigure
fi
