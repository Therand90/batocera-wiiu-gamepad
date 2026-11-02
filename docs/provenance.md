# Build provenance

## Moonlight WiiU Android — production signing validation

The first production-signed Android build was validated before the public release:

- workflow: `Build Moonlight WiiU production APK`
- successful production build: **#3**
- run ID: `41323727098`
- workflow head commit: `069414f02c126734997e8581182c0bd5b422c1b8`
- Moonlight upstream commit: `b48494cb96bff23d8886c4775cc4f39a1075495d`
- Android version name: `0.2.0`
- Android version code: `20261101`
- package ID: `com.therand.wiiugamepad`
- APK SHA-256: `cd7bb0ea1adc6f1e73ee3923c71d2cdc34a86b49feca4bb4c55819776dbaf447`

Production signing certificate:

```text
CN=Therand90, OU=WiiU GamePad, O=Therand90, L=Bertrix, ST=Luxembourg, C=BE
SHA-256:
AC:16:EE:09:A1:5B:FC:B2:2D:3E:17:8F:54:06:B1:7C:
22:E1:AB:93:C3:BA:C0:68:FE:6D:F6:53:BA:A3:15:0C
RSA 4096 bits
```

The private production keystore is **not** stored in the repository. GitHub Actions receives it
only from encrypted repository secrets. The workflow verifies the APK certificate fingerprint
before uploading the production artifact.

The resulting production-signed APK was subsequently installed and tested on the reference Android
device with the Batocera 44 runtime. Video, direct touch, fullscreen behavior, GamePad audio,
controller workflow, cursor exclusion, pairing, and stream operation were validated before the
public v0.2.0 release.

## Moonlight WiiU Android — v0.2.0-rc2

The v0.2.0-rc2 Android client is built from:

- repository: `Therand90/batocera-wiiu-gamepad`
- workflow: `Build Moonlight WiiU GamePad`
- successful RC build: **#13**
- run ID: `41318727878`
- workflow head commit: `0e62047eac6fa2d4865d503c51c31753ddecef83`
- Moonlight upstream commit: `b48494cb96bff23d8886c4775cc4f39a1075495d`
- APK SHA-256: `730d765b7ce4ffe71dce80aea410a02372778bad24249daaba4df613bfec293a`

rc2 uses the same stable RC test signing identity as rc1:

```text
88:5D:4E:69:63:E5:AC:72:BD:ED:37:2F:F3:15:17:84:
CC:EB:B3:66:D0:91:29:FB:57:47:B5:B7:94:61:40:7E
```

This allows rc2 to update rc1 in place without uninstalling or re-pairing.

This document records the exact development and RC artifacts used by the Wii U GamePad project.

## Moonlight WiiU Android — v0.2.0-rc1

The v0.2.0-rc1 Android client is built from:

- repository: `Therand90/batocera-wiiu-gamepad`
- workflow: `Build Moonlight WiiU GamePad`
- successful RC build: **#12**
- run ID: `41312315206`
- workflow head commit: `7b27dbbfa1682f87af5224ec2979afe54f9da1c2`
- Moonlight upstream commit: `b48494cb96bff23d8886c4775cc4f39a1075495d`
- APK SHA-256: `62354d3bed6325e56b9dd8bed8b85f8484bdc7ea66f147b8faacd5cd2f87dd0f`

RC test signing certificate SHA-256 fingerprint:

```text
88:5D:4E:69:63:E5:AC:72:BD:ED:37:2F:F3:15:17:84:
CC:EB:B3:66:D0:91:29:FB:57:47:B5:B7:94:61:40:7E
```

This is intentionally a **non-production RC test identity**. It exists only so successive
test APKs can update one another. It must be replaced by a private production signing
identity before a public Android release.

### Upgrade note from the original development APK

The original validated development APK was produced by the historical
`Therand90/batocera.linux` workflow run #10 and has SHA-256:

```text
523ef85a6cbfb5eaf2d91283d0556bf7e42e24ac3e08f79b9b16873df678b1cf
```

Its certificate fingerprint is:

```text
2F:5E:93:6E:7F:80:7C:D8:A2:02:BA:CC:36:24:F9:EA:
FF:FE:45:F1:2B:61:9F:A7:95:B8:6C:4D:93:35:C5:B3
```

The historical workflow attempted to preserve a stable debug key, but the embedded
keystore was truncated/corrupt and was not actually used by AGP. Historical successful
runs therefore received ephemeral runner-generated debug identities; for example run #8
and run #10 have different certificates.

Because v0.2.0-rc1 deliberately moves to a stable RC test identity, Android cannot install
it over that original development APK. The old development APK must be uninstalled once
before installing v0.2.0-rc1.

## Sunshine NoCursor

The validated custom Sunshine AppImage remains:

- file: `Sunshine-NoCursor.AppImage`
- SHA-256: `4d0d08677277526274bb023cd5a93562cb340e74935261bdb54d63a539662b94`
- historical repository: `Therand90/batocera.linux`
- workflow: `Wii U Sunshine No Cursor`
- run: **#1**
- run ID: `36424613321`
- workflow head commit: `84876d4d73bb3ae2a939b3742cc09ec46bcf4900`
- Sunshine upstream tag: `v2026.914.233613`

The source change was intentionally tiny:

```diff
-bool display_cursor = true;
+bool display_cursor = false;
```

No Sunshine pairing state, credentials, private certificates, Wii U RPL files, or other
proprietary Wii U system files belong in release archives.
