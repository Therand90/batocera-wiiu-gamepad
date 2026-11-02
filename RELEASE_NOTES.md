# v0.2.0

First public release of **Batocera Wii U GamePad**.

This release turns an Android phone or tablet into a practical Wii U GamePad companion for
Cemu on Batocera 44 using a dedicated virtual display, Sunshine, and the custom Moonlight WiiU
Android client.

## Highlights

- dedicated virtual `WIIU-GAMEPAD` output at **854x480**
- automatic Cemu GamePad View placement
- direct Android touchscreen input mapped only to the GamePad display
- separate TV and GamePad audio routing
- Sunshine NoCursor streaming
- automatic Wii U session start/stop integration
- automatic cleanup on game exit
- local physical controller support
- Moonlight WiiU automatic **854x480 / 60 FPS** profile
- optional Moonlight fullscreen
- adjustable Moonlight bitrate
- fixed anti-gesture bezel:
  - 16 dp left/right
  - 24 dp top/bottom
- manual host-by-IP fallback when Moonlight LAN discovery is unavailable
- Sunshine Web UI pairing guide and first-account setup documentation
- automatic Sunshine CSRF origin configuration from local IPv4 addresses
- multi-monitor-safe virtual display placement

## Multi-monitor placement

The virtual GamePad is placed after the right-most logical edge of active physical displays.

The calculation handles:

- multiple outputs
- monitors placed left or right of the primary display
- scaling
- 90°/270° rotation
- a pre-existing `WIIU-GAMEPAD` output

The reference machine is a single-display Batocera 44 system. Multi-monitor cases are covered by
automated tests.

## Android client

The production Android application uses:

- package ID: `com.therand.wiiugamepad`
- version name: `0.2.0`
- version code: `20261101`
- Moonlight upstream base: `b48494cb96bff23d8886c4775cc4f39a1075495d`

The production APK is signed with the project's private long-term Android signing key.
The private key is never stored in this repository; GitHub Actions receives it through encrypted
repository secrets and verifies the resulting certificate fingerprint before uploading artifacts.

The production-signed APK is built from the same validated Wii U client patch used for RC testing.
The final production-signed APK was then tested on the reference Android device and validated
end-to-end before publication.

## Sunshine / first pairing

Sunshine is intentionally started only during Wii U sessions.

For first pairing:

1. launch a Wii U game;
2. open Moonlight WiiU;
3. select the host, or add the Batocera IPv4 address manually;
4. open `https://<BATOCERA-IP>:47990`;
5. create the Sunshine Web UI username/password on a fresh install;
6. enter Moonlight's four-digit PIN in Sunshine's **PIN Pairing** page.

See `docs/pairing.md` for the complete procedure.

## Cemu DRC audio

Development with ZombiU identified a Cemu DRC audio bug that was fixed upstream in
Cemu PR #2099: `sndcore: Fix DRC device mix mask indexing`.

A sufficiently recent Cemu build containing that fix is recommended for correct DRC/GamePad audio.

## Reference validation

The runtime was validated end-to-end on:

- Batocera 44
- Wayland + LabWC
- x86-64-v3
- AMD Ryzen 7 8745HS / Radeon 780M
- 1920x1080 @ 60 Hz primary display

See `docs/tested.md` and `docs/provenance.md` for details.
