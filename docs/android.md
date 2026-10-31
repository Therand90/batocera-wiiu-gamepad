# Android / Moonlight

The validated Android client is a custom Moonlight build branded **Moonlight WiiU**.

Validated settings during development:

- 60 FPS
- stereo audio
- stream resolution can be 1280x720 while Sunshine captures the 854x480 GamePad output
- `Use touchscreen as trackpad` disabled
- audio streaming enabled

The Batocera LabWC rule maps Sunshine's `libvirtualhid Touchscreen` directly to `WIIU-GAMEPAD`, so Android touches target the Wii U GamePad screen rather than the TV display.

## Distribution status

The development APK is intentionally not committed to Git. Before a public release, the corresponding modified Moonlight source/build history must be published alongside the APK as required by its GPLv3 license.
