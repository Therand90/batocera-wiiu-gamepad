# Batocera Wii U GamePad

Turn an Android phone or tablet into a practical second-screen Wii U GamePad for **Cemu on Batocera 44**.

> **Status:** early development snapshot. The Batocera-side runtime is based on a setup validated on Batocera 44 / Wayland / LabWC. A one-command release installer is the target, but the first public release is not published yet.

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
docs/android.md        Android/Moonlight notes
docs/troubleshooting.md
```

## Installation target

A release ZIP will be self-contained and installable from Batocera 44 with a single command. The installer is designed to:

- back up files before changing them;
- modify only the Wii U options it needs in `batocera.conf`;
- inject only the required LabWC rules;
- configure Cemu's TV/GamePad audio devices without replacing the whole Cemu config;
- auto-detect the current TV audio sink and primary display geometry;
- preserve Sunshine pairing, certificates and credentials;
- never use `/userdata/workspace` on an end-user installation.

## Privacy and proprietary files

This project does **not** distribute:

- Sunshine pairing state or credentials;
- private certificates/keys;
- `apps.json` from a user's Sunshine profile;
- Wii U system libraries (`*.rpl`) or other proprietary Wii U files.

Do not add those files to issues, commits or release archives.

## Android client

A custom Moonlight Android build named **Moonlight WiiU** was used during development. Its source/build history is being reconstructed before it is published as a release asset. Moonlight Android is GPLv3 software and any distributed modified build must be accompanied by the corresponding source.

## License

Project integration code is released under GPL-3.0. Third-party projects such as Sunshine and Moonlight retain their own copyright notices and GPL licensing.
