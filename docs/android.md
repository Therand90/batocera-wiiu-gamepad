# Android / Moonlight

The Wii U client is a dedicated Moonlight Android build branded **Moonlight WiiU**.

See [pairing.md](pairing.md) for the complete first-pairing procedure.

## Automatic Wii U profile

On first launch after installing this version, the client automatically applies a Wii U GamePad profile:

- stream resolution: **854x480** (the native Wii U GamePad LCD resolution)
- frame rate: **60 FPS**
- stereo audio
- host audio streaming enabled
- touchscreen-as-trackpad disabled
- stretch video disabled
- bitrate reset to Moonlight's automatic value for 854x480/60

Using the Android panel's native resolution for the network stream would only upscale an
854x480 GamePad source before transmission. Instead, Moonlight requests the native GamePad
stream and scales it locally to the phone/tablet display.

The migration is versioned and runs once. Advanced users can still change streaming settings
after the automatic profile has been applied.

## Recommended Moonlight settings

The automatic profile is intended to work without manual tuning. The following options are still
useful depending on the device and network.

### Fullscreen

**Fullscreen can be enabled in Moonlight's settings.**

This is optional and was validated during development. It maximizes the usable GamePad area on the
phone/tablet while keeping the project's fixed anti-gesture bezel around the video.

### Bitrate

The default automatic bitrate is appropriate for most local networks, but the bitrate can be
adjusted manually in Moonlight if necessary.

A higher bitrate may improve image quality on a strong Wi-Fi/LAN connection. A lower bitrate can
improve stability if the Android device has weak Wi-Fi, packet loss, stutter, or latency spikes.

Because the GamePad source is only **854x480 at 60 FPS**, extremely high bitrates are unnecessary.
Prefer the lowest bitrate that gives a clean, stable image on the actual network.

### Resolution and frame rate

For normal use, keep:

- **854x480**
- **60 FPS**

The GamePad source itself is 854x480, so selecting a much higher stream resolution does not add
real GamePad detail; it mainly increases bandwidth and encode/decode work.

### Stretch video

Keep stretch disabled unless the user deliberately prefers a distorted full-panel image.

Preserving aspect ratio avoids changing touch geometry and keeps the Wii U GamePad image faithful
to its native shape.

## Phone / tablet display adaptation

Moonlight WiiU keeps the stream at the GamePad's native 854x480 resolution and lets
`StreamView` scale it locally to the available Android display while preserving aspect ratio.

To reduce accidental Android edge gestures, the video uses the same fixed safe bezel that was
validated in the original development APK:

- **16 dp** left/right
- **24 dp** top/bottom

These margins are deliberately fixed. Android gesture/cutout insets are **not added on top**,
because doing so produced unnecessarily thick black borders on some phones in fullscreen mode.

Direct touch coordinates are attached to the video surface itself.

## Touch routing

The Batocera LabWC rule maps Sunshine's `libvirtualhid Touchscreen` directly to
`WIIU-GAMEPAD`, so Android touches target the Wii U GamePad output rather than the TV display.

## Practical recommendations

- Connect the Android device to a stable Wi-Fi network, preferably 5 GHz or better when available.
- Keep the physical controller connected directly to Batocera; Moonlight WiiU is primarily the
  GamePad display/touch surface.
- A phone/tablet controller mount can make the setup feel much closer to the original Wii U
  GamePad.
- If image quality is already clean and latency is low, increasing bitrate further provides little
  benefit.
- If the stream becomes unstable, reduce bitrate before changing the 854x480/60 profile.
