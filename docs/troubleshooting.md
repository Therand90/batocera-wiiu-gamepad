# Troubleshooting

## Moonlight cannot find the Batocera host

Sunshine is not a permanent background service in this project.

Launch a Wii U game first and wait for Cemu/Sunshine to start. Then open Moonlight WiiU.

If automatic discovery still fails, press **+** in Moonlight and enter the Batocera machine's
local IPv4 address only, without `https://` and without `:47990`.

Example:

```text
192.168.1.42
```

Automatic discovery is optional; manual IP connections work normally.

## Sunshine asks for a username/password

The Sunshine Web UI credentials are separate from Moonlight's four-digit pairing PIN.

### Fresh installation

The project does not ship a preset username/password. On the first Web UI access, Sunshine should
ask the user to create the Web UI account. Create a username/password, then continue to
**PIN Pairing** and enter the PIN shown by Moonlight.

### Forgotten credentials

Close the Wii U game first so Sunshine is not running, then reset the Web UI credentials with:

```bash
/userdata/system/wiiu-gamepad/sunshine/Sunshine-NoCursor.AppImage \
  --creds NEW_USERNAME NEW_PASSWORD
```

Launch the Wii U game again and sign in with the new credentials.

The Web UI username/password and Moonlight's four-digit pairing PIN are two different things.

## Sunshine shows a CSRF Protection Error during pairing

The current runtime automatically populates `csrf_allowed_origins` with the machine's active local
IPv4 Web UI origins and enables LAN Web UI access.

If this error appears after upgrading from an older build, rerun the current installer or run:

```bash
/userdata/system/wiiu-gamepad/bin/configure.sh
```

Then restart the Wii U game so Sunshine restarts with the refreshed configuration.

## GamePad stream is black

Verify that Cemu's **GamePad View** is actually open. Sunshine captures the dedicated
`WIIU-GAMEPAD` output; an output with no rendered GamePad window is not useful.

## Black borders are larger than expected

Moonlight WiiU intentionally keeps a small anti-gesture bezel around the streamed GamePad image:

- 16 dp left/right
- 24 dp top/bottom

Fullscreen can be enabled in Moonlight settings. The bezel remains intentionally present to reduce
accidental Android edge gestures.

## Stream stutters or Wi-Fi is unstable

Keep the stream at **854x480 / 60 FPS** and reduce Moonlight's bitrate first.

The GamePad source does not benefit materially from a much higher stream resolution, while a lower
bitrate can substantially improve stability on weaker wireless links.

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

For ZombiU specifically, use a Cemu revision that contains upstream PR #2099
(`sndcore: Fix DRC device mix mask indexing`).

## One-minute black screen before Cemu

Do not replace the Python detached runner with a simple `setsid`/`setsid -f`. The Python
`start_new_session=True` behavior is deliberate and was validated to avoid keeping Batocera's
launcher blocked.
