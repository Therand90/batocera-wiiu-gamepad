# Architecture

## Batocera lifecycle

`/userdata/system/scripts/wiiu-gamepad.sh` only reacts to Wii U launches.

### gameStart

1. Re-inject the required LabWC rules if Batocera regenerated `rc.xml` at boot.
2. Detect the current TV audio sink and primary output geometry.
3. Patch only the required Cemu audio fields.
4. Create `WIIU-GAMEPAD` through LabWC's virtual-output action.
5. Configure the virtual output as 854x480 and place it directly to the right of the primary display.
6. Create the `WIIU_GAMEPAD_AUDIO` null sink.
7. Start a detached session runner so the Batocera launcher is not blocked.
8. Wait for Cemu, start the audio guard, then launch Sunshine NoCursor.

The detached runner uses Python `subprocess.Popen(..., start_new_session=True, close_fds=True)`. This behavior is intentional: using `setsid` directly kept Batocera's launcher attached during development and caused a long black-screen delay before Cemu appeared.

### gameStop

1. Terminate the detached Sunshine/audio session group.
2. Restore the detected TV audio sink as default.
3. Remove only `WIIU_GAMEPAD_AUDIO`.
4. Remove `WIIU-GAMEPAD`.
5. Clean `/tmp/wiiu-gamepad`.

## LabWC

Batocera 44 regenerates `/userdata/system/.config/labwc/rc.xml` at boot. The project therefore re-applies three narrowly scoped pieces at every Wii U launch:

- virtual-output add/remove keybinds;
- a `GamePad View*` window rule that moves Cemu's GamePad window to `WIIU-GAMEPAD` and fullscreen it;
- mapping `libvirtualhid Touchscreen` exclusively to `WIIU-GAMEPAD` with mouse emulation disabled.

## Audio

Cemu is configured with two outputs:

- TV output -> the currently detected Batocera default/physical sink;
- GamePad output -> `WIIU_GAMEPAD_AUDIO`.

The audio guard identifies Cemu sink inputs and continuously keeps them on their intended sinks while Cemu is running.
