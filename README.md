# Batocera Wii U GamePad

Turn an Android phone or tablet into a practical second-screen Wii U GamePad for **Cemu on Batocera 44**.

> **Status:** v0.2.0. The Batocera runtime and Moonlight WiiU integration are release-ready for Batocera 44 / Wayland / LabWC. The reference setup was validated end-to-end; multi-monitor placement is additionally covered by automated tests.

## Demo

[▶ Watch the 45-second Wii U GamePad demo](media/gamepad-demo.mp4)

The demo was recorded on the validated Batocera 44 setup and shows the real TV + Android GamePad workflow in operation.

## What it does

The project creates a dedicated `WIIU-GAMEPAD` virtual output, moves Cemu's **GamePad View** to it, streams that output to Android through Sunshine/Moonlight, maps the Android virtual touchscreen back to that output, and keeps TV and GamePad audio separated.

```text
Cemu GamePad View
      │
      ▼
WIIU-GAMEPAD (854x480)
      │
      ▼
Sunshine (Wayland capture)
      │
      ▼
Moonlight WiiU on Android

Cemu TV audio ───────────────► TV / HDMI
Cemu GamePad audio ──────────► WIIU_GAMEPAD_AUDIO ─► Moonlight
```

The physical controls can remain on a local controller connected to Batocera. The Android device provides the second display and touchscreen; a phone/tablet-to-controller mount is optional.

## Quick start

1. Extract the Batocera release ZIP on the Batocera machine.
2. Run:

   ```bash
   bash install.sh
   ```

3. Install the bundled **Moonlight WiiU** APK on the Android phone/tablet.
4. Put the Android device and Batocera machine on the same local network.
5. Launch a Wii U game from EmulationStation.
6. Wait for Cemu to start. Sunshine NoCursor starts automatically only during the Wii U session.
7. Open Moonlight WiiU and select the Batocera host.
8. If automatic host discovery fails, press **+** in Moonlight and enter the Batocera machine's local IPv4 address only.
9. Moonlight displays a four-digit PIN.
10. Open Sunshine's Web UI at:

    ```text
    https://<BATOCERA-IP>:47990
    ```

11. On a **fresh installation**, Sunshine asks you to create the Web UI username/password. The
    release does not ship default credentials. On upgrades, sign in with the existing credentials.
12. Open **PIN Pairing**, enter Moonlight's PIN, and confirm.
13. Connect from Moonlight and use the Android device as the Wii U GamePad display/touchscreen.

After the Batocera installation is complete **and the bundled Moonlight WiiU APK has been installed or copied to the Android device**, the extracted release directory can safely be deleted. The installed runtime lives under `/userdata/system/wiiu-gamepad` with its Batocera hook under `/userdata/system/scripts/wiiu-gamepad.sh`.

If the Sunshine Web UI credentials are forgotten, stop the Wii U session and reset them with:

```bash
/userdata/system/wiiu-gamepad/sunshine/Sunshine-NoCursor.AppImage \
  --creds NEW_USERNAME NEW_PASSWORD
```

See [docs/pairing.md](docs/pairing.md) for the complete pairing procedure and [docs/android.md](docs/android.md) for Moonlight settings.

## Recommended Moonlight settings

The client automatically applies the normal Wii U profile:

- **854x480**
- **60 FPS**
- host audio enabled
- touchscreen-as-trackpad disabled
- stretch disabled
- automatic bitrate

Optional user adjustments:

- **Fullscreen:** may be enabled in Moonlight settings and was validated during development.
- **Bitrate:** may be raised on a strong connection for image quality or lowered if Wi-Fi causes stutter/latency.
- Keep **854x480 / 60 FPS** unless there is a specific reason to change it; higher stream resolutions do not add real GamePad detail.

Moonlight WiiU keeps a fixed anti-gesture bezel around the video:

- 16 dp left/right
- 24 dp top/bottom

This was chosen to reduce accidental Android edge gestures without wasting excessive screen area.

## Validated behavior

The reference setup has been validated with:

- Batocera 44, x86_64, Wayland + LabWC
- Cemu Linux
- virtual GamePad output at 854x480
- Android touchscreen mapped only to the GamePad output
- separate TV / GamePad audio routing
- local DualSense controls
- Sunshine capture with the cursor excluded from the GamePad stream
- Moonlight streaming at ~60 FPS
- automatic start/stop with Batocera's Wii U game hooks
- automatic cleanup when returning to EmulationStation
- manual Moonlight host entry when LAN auto-discovery is unavailable
- Sunshine Web UI pairing from an Android browser
- Moonlight fullscreen with the fixed anti-gesture bezel
- production Android build/signing pipeline with certificate verification

## Cemu DRC audio fix

During development with **ZombiU**, a Cemu DRC audio bug was identified and fixed upstream:

- Cemu PR: https://github.com/cemu-project/Cemu/pull/2099
- Fix: `sndcore: Fix DRC device mix mask indexing`

The fix restores DRC/GamePad audio that could otherwise disappear, including the Prepper voice and sonar/ping audio in ZombiU.

Batocera 44 initially shipped a Cemu revision from September 10, 2026, which predates that upstream fix. A sufficiently recent Cemu build is therefore recommended.

## Repository layout

```text
files/bin/             Batocera runtime scripts
files/hook/            Batocera gameStart/gameStop hook
files/sunshine/        Sunshine configuration template
install.sh             Installer used by release ZIPs
uninstall.sh           Conservative uninstaller
tools/audit.sh         Safe diagnostic collector
docs/architecture.md   Runtime design
docs/pairing.md        Sunshine/Moonlight first pairing
docs/android.md        Android/Moonlight settings
docs/troubleshooting.md
media/gamepad-demo.mp4 Real-hardware demo
```

## Installer behavior

The installer is designed to:

- back up files before changing them;
- modify only the Wii U options it needs in `batocera.conf`;
- inject only the required LabWC rules;
- configure Cemu's TV/GamePad audio devices without replacing the whole Cemu config;
- auto-detect the current TV audio sink and physical display layout;
- place the virtual GamePad after the right-most active monitor, including scaled/rotated multi-monitor layouts;
- automatically populate Sunshine's local Web UI CSRF origins from the machine's active IPv4 addresses;
- preserve Sunshine pairing, certificates and credentials on upgrades;
- never use `/userdata/workspace` on an end-user installation.

## Privacy and proprietary files

This project does **not** distribute:

- Sunshine pairing state or credentials;
- private certificates/keys;
- `apps.json` from a user's Sunshine profile;
- Wii U system libraries (`*.rpl`) or other proprietary Wii U files.

Do not add those files to issues, commits or release archives.

## Android client

A dedicated Moonlight Android build named **Moonlight WiiU** provides direct touch input and an automatic Wii U profile. It streams at the GamePad's native 854x480/60 and scales locally to the phone/tablet display. A validated fixed 16 dp left/right and 24 dp top/bottom safe bezel reduces accidental Android edge gestures without oversized fullscreen borders. The corresponding source patch and reproducible build workflow are included in this repository.

## License

Project integration code is released under GPL-3.0. Third-party projects such as Sunshine and Moonlight retain their own copyright notices and GPL licensing.
