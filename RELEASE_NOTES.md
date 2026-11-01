# v0.1.0 — Release candidate

First packaged release of **Batocera Wii U GamePad**.

## Highlights

- Android phone/tablet used as Cemu's Wii U GamePad display
- dedicated 854x480 virtual Wayland output
- direct Android touchscreen mapping to the GamePad output
- local controller support remains on Batocera
- separate TV and GamePad audio routing
- Sunshine NoCursor capture
- automatic lifecycle integration with Batocera Wii U launches
- automatic cleanup when the game exits
- automatic detection of the TV audio sink and primary display geometry
- no dependency on `/userdata/workspace`

## Validated platform

- Batocera 44 — image **2026/10/31 15:58**
- x86-64-v3
- Wayland + LabWC
- kernel 7.2.8

See `docs/tested.md` for the full validation matrix.

## Known limitation

Batocera 44's stock Cemu revision predates upstream Cemu PR #2099, so the known DRC/GamePad audio mix bug can still occur in affected games such as ZombiU. This is a Cemu-version limitation, not a failure of the GamePad streaming/runtime integration.

## Installation

The release ZIP is intended to contain the validated Sunshine NoCursor binary.

From an extracted release directory on Batocera:

```bash
bash install.sh
```

The installer backs up existing Batocera/LabWC/Cemu settings before applying narrowly scoped changes. Existing Sunshine pairing and credentials are preserved.

## Android

The validated `Moonlight-WiiU-GamePad.apk` may be included under `android/`. Its exact build provenance and corresponding source patch are documented in `docs/provenance.md` and `build/moonlight/patch.py`.
