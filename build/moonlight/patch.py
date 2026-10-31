#!/usr/bin/env python3
from pathlib import Path
import re
import sys

root = Path(sys.argv[1] if len(sys.argv) > 1 else "moonlight")

# 1) Dedicated package/app name so it installs beside official Moonlight.
p = root / "app/build.gradle"
s = p.read_text()

s, count = re.subn(
    r'(nonRoot\s*\{.*?applicationId\s+)"com\.limelight"',
    r'\1"com.therand.wiiugamepad"',
    s,
    count=1,
    flags=re.S,
)
if count != 1:
    raise SystemExit("nonRoot applicationId patch failed")

s, count = re.subn(
    r'resValue\s+"string",\s*"app_label",\s*"Moonlight \(Debug\)"',
    'resValue "string", "app_label", "Moonlight WiiU"',
    s,
    count=1,
)
if count != 1:
    raise SystemExit("debug app label patch failed")
p.write_text(s)

# 2) GamePad-friendly defaults.
p = root / "app/src/main/java/com/limelight/preferences/PreferenceConfiguration.java"
s = p.read_text()
old = "private static final boolean DEFAULT_HOST_AUDIO = false;"
if old not in s:
    raise SystemExit("DEFAULT_HOST_AUDIO not found")
s = s.replace(old, "private static final boolean DEFAULT_HOST_AUDIO = true;", 1)

old = "private static final boolean DEFAULT_TOUCHSCREEN_TRACKPAD = true;"
if old not in s:
    raise SystemExit("DEFAULT_TOUCHSCREEN_TRACKPAD not found")
s = s.replace(old, "private static final boolean DEFAULT_TOUCHSCREEN_TRACKPAD = false;", 1)
p.write_text(s)

p = root / "app/src/main/res/xml/preferences.xml"
s = p.read_text()
pattern = re.compile(
    r'(android:key="checkbox_touchscreen_trackpad".*?android:defaultValue=")true(")',
    re.S,
)
s, count = pattern.subn(r'\1false\2', s, count=1)
if count != 1:
    raise SystemExit("touchscreen trackpad XML default patch failed")
p.write_text(s)

# 3) Absolute finger input behaves like direct touchscreen input.
p = root / "app/src/main/java/com/limelight/binding/input/touch/AbsoluteTouchContext.java"
s = p.read_text()
pattern = re.compile(
    r'if \(actionIndex == 0\) \{\s*'
    r'// Start the timers\s*'
    r'startTapDownTimer\(\);\s*'
    r'startLongPressTimer\(\);\s*'
    r'\}',
    re.S,
)
replacement = '''if (actionIndex == 0) {
              // Wii U GamePad mode: direct touch semantics.
              updatePosition(eventX, eventY);
              confirmedTap = true;
              conn.sendMouseButtonDown(MouseButtonPacket.BUTTON_LEFT);
          }'''
s, count = pattern.subn(replacement, s, count=1)
if count != 1:
    raise SystemExit("AbsoluteTouchContext touch-down patch failed")
p.write_text(s)

# 4) Re-enable Moonlight native touch packets in direct-touch mode.
p = root / "app/src/main/java/com/limelight/Game.java"
s = p.read_text()
pattern = re.compile(
    r'// TODO: Re-enable native touch when have a better solution for handling\s*'
    r'// cancelled touches from Android gestures and 3 finger taps to activate\s*'
    r'// the software keyboard\.\s*'
    r'/\*if \(!prefConfig\.touchscreenTrackpad && trySendTouchEvent\(view, event\)\) \{\s*'
    r'// If this host supports touch events and absolute touch is enabled,\s*'
    r'// send it directly as a touch event\.\s*'
    r'return true;\s*'
    r'\}\*/',
    re.S,
)
replacement = '''// Wii U GamePad mode: prefer native touch packets.
                  // If the host doesn't advertise native touch support, Moonlight falls
                  // through to the absolute-mouse compatibility path below.
                  if (!prefConfig.touchscreenTrackpad && trySendTouchEvent(view, event)) {
                      return true;
                  }'''
s, count = pattern.subn(replacement, s, count=1)
if count != 1:
    raise SystemExit("native touch block patch failed")
p.write_text(s)

# 5) Attach direct-touch listener to the video surface itself.
p = root / "app/src/main/java/com/limelight/Game.java"
s = p.read_text()
old = (
    '        streamView.setOnGenericMotionListener(this);\n'
    '        streamView.setOnKeyListener(this);\n'
    '        streamView.setInputCallbacks(this);\n'
    '\n'
    '        // Listen for touch events on the background touch view to enable trackpad mode\n'
    '        // to work on areas outside of the StreamView itself. We use a separate View\n'
    '        // for this rather than just handling it at the Activity level, because that\n'
    '        // allows proper touch splitting, which the OSC relies upon.\n'
    '        View backgroundTouchView = findViewById(R.id.backgroundTouchView);\n'
    '        backgroundTouchView.setOnTouchListener(this);'
)
new = (
    '        streamView.setOnGenericMotionListener(this);\n'
    '        streamView.setOnKeyListener(this);\n'
    '        streamView.setInputCallbacks(this);\n'
    '\n'
    '        // Wii U GamePad mode: direct touch coordinates are local to the video surface.\n'
    '        streamView.setOnTouchListener(this);\n'
    '\n'
    '        // Preserve upstream background handling only for trackpad mode.\n'
    '        View backgroundTouchView = findViewById(R.id.backgroundTouchView);\n'
    '        if (prefConfig.touchscreenTrackpad) {\n'
    '            backgroundTouchView.setOnTouchListener(this);\n'
    '        }'
)
if old not in s:
    raise SystemExit("StreamView/background touch listener block not found")
s = s.replace(old, new, 1)
p.write_text(s)

# 6) Safe bezel around the stream to avoid Android edge gestures.
p = root / "app/src/main/res/layout/activity_game.xml"
s = p.read_text()
marker = '        android:layout_gravity="center"\n        android:focusable="true"'
replacement = '''        android:layout_gravity="center"
              android:layout_marginStart="16dp"
              android:layout_marginEnd="16dp"
              android:layout_marginTop="24dp"
              android:layout_marginBottom="24dp"
              android:focusable="true"'''
if marker not in s:
    raise SystemExit("StreamView insertion point not found")
s = s.replace(marker, replacement, 1)

bg_marker = '        android:layout_height="match_parent"\n        android:layout_gravity="center" />'
bg_replacement = '''        android:layout_height="match_parent"
              android:layout_gravity="center"
              android:background="#000000" />'''
if bg_marker not in s:
    raise SystemExit("backgroundTouchView insertion point not found")
s = s.replace(bg_marker, bg_replacement, 1)
p.write_text(s)

print("Moonlight WiiU patches applied successfully")
