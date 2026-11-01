# Architecture

## Batocera lifecycle

`/userdata/system/scripts/wiiu-gamepad.sh` only reacts to Wii U launches.

### gameStart

1. Re-inject the required LabWC rules if Batocera regenerated `rc.xml` at boot.
2. Detect the current TV audio sink and physical display layout.
3. Refresh Sunshine's allowed local Web UI origins from the machine's active IPv4 addresses.
4. Patch only the required Cemu audio fields.
5. Create `WIIU-GAMEPAD` through LabWC's virtual-output action.
6. Configure the virtual output as 854x480 and place it after the right-most logical edge of all active physical displays.
7. Create the `WIIU_GAMEPAD_AUDIO` null sink.
8. Start a detached session runner so the Batocera launcher is not blocked.
9. Wait for Cemu, start the audio guard, then launch Sunshine NoCursor.

The display-placement calculation accounts for existing monitors, output position, scaling, and
90°/270° rotation. If the layout parser cannot understand an unexpected `wlr-randr` format, the
runtime falls back to placing the GamePad directly after Batocera's primary display.

The detached runner uses Python `subprocess.Popen(..., start_new_session=True, close_fds=True)`. This behavior is intentional: using `setsid` directly kept Batocera's launcher attached during development and caused a long black-screen delay before Cemu appeared.

### gameStop

1. Terminate the detached Sunshine/audio session group.
2. Restore the detected TV audio sink as default.
3. Remove only `WIIU_GAMEPAD_AUDIO`.
4. Remove `WIIU-GAMEPAD`.
5. Clean `/tmp/wiiu-gamepad`.

## Sunshine lifecycle

Sunshine NoCursor is **not** a permanent system service.

It starts only after Cemu is detected during a Wii U session and stops when the Wii U game exits.
This keeps the host inactive when the GamePad stream is not needed.

As a consequence, first-time Moonlight pairing must be performed while a Wii U game is running.
See `docs/pairing.md`.

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

## Sunshine Web UI security

The runtime keeps Sunshine's Web UI LAN-scoped and automatically writes the machine's active
IPv4 origins to `csrf_allowed_origins`. This allows pairing from a browser on the local network
without hard-coding a machine-specific IP into the release package.
