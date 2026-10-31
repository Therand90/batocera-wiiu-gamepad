# Troubleshooting

## GamePad stream is black

Verify that Cemu's **GamePad View** is actually open. Sunshine captures the dedicated `WIIU-GAMEPAD` output; an output with no rendered GamePad window is not useful.

## Touch controls affect the TV instead of the GamePad

Run:

```bash
/userdata/system/wiiu-gamepad/bin/ensure-labwc.sh
```

Then verify that LabWC contains a `libvirtualhid Touchscreen` mapping to `WIIU-GAMEPAD`.

## No GamePad audio

Check:

```bash
pactl list short sinks
grep -E '<(TVDevice|PadDevice|TVVolume|PadVolume)' /userdata/system/configs/cemu/settings.xml
```

`PadDevice` must be `WIIU_GAMEPAD_AUDIO`.

For ZombiU specifically, use a Cemu revision that contains upstream PR #2099 (`sndcore: Fix DRC device mix mask indexing`).

## One-minute black screen before Cemu

Do not replace the Python detached runner with a simple `setsid`/`setsid -f`. The Python `start_new_session=True` behavior is deliberate and was validated to avoid keeping Batocera's launcher blocked.
