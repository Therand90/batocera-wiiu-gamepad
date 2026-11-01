# Tested configuration

## Batocera

Validated on:

- Batocera: **44**
- image date: **2026/10/31 15:58**
- architecture: **x86-64-v3**
- kernel: **7.2.8**
- display server: **Wayland**
- compositor: **LabWC**

Reference hardware:

- AMD Ryzen 7 8745HS
- Radeon 780M
- primary output: HDMI-A-1
- primary resolution: 1920x1080 @ 60 Hz
- data partition: ext4

## Wii U GamePad runtime

Validated end-to-end:

- automatic detection of the TV audio sink
- automatic detection of the primary display
- automatic GamePad placement directly to the right of the primary display
- virtual `WIIU-GAMEPAD` output at 854x480
- Cemu GamePad View moved/fullscreened on the virtual output
- Android GamePad video through Sunshine/Moonlight
- direct touchscreen input mapped to the GamePad output
- local DualSense controls
- separate TV / GamePad audio routing
- Sunshine NoCursor capture
- clean shutdown and return to EmulationStation
- automatic cleanup of virtual output and audio sink

Reference auto-detected values on the validation machine:

```text
TV sink: alsa_output.pci-0000_c3_00.1.hdmi-stereo-extra1
Primary output: HDMI-A-1
GamePad position: 1920,0
```

These values are **not hard-coded** in the portable runtime; they are recorded only as the reference test result.

## Known limitation

Batocera 44 currently ships Cemu commit:

```text
3310f3b8b184d64a62b89fd59088c799432badf5
```

That revision predates upstream Cemu PR #2099 (`sndcore: Fix DRC device mix mask indexing`).

As a result, the Batocera stock Cemu build can still exhibit the DRC/GamePad audio mix bug that originally motivated that upstream fix. This limitation is independent of the Wii U GamePad streaming/runtime integration itself.
