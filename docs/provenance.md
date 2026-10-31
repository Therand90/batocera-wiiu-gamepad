# Build provenance

This document records the exact development artifacts used by the validated Wii U GamePad setup.

## Moonlight WiiU Android

The validated APK is the exact artifact produced by the historical GitHub Actions workflow run:

- repository: `Therand90/batocera.linux`
- workflow: `Build Moonlight WiiU GamePad`
- run: **#10**
- run ID: `36557329450`
- workflow head commit: `0b886d3fc39bddbf48de339e2fc62f7c8eb851ea`
- Moonlight upstream commit: `b48494cb96bff23d8886c4775cc4f39a1075495d`
- APK SHA-256: `523ef85a6cbfb5eaf2d91283d0556bf7e42e24ac3e08f79b9b16873df678b1cf`
- artifact name: `Moonlight-WiiU-GamePad.apk`

The uploaded development APK was compared byte-for-byte with the still-available run #10 artifact and the SHA-256 values are identical.

The historical build used a stable **debug** signing key embedded in the temporary workflow. That key is intentionally **not** copied into this repository. Public releases should use a dedicated release signing key stored outside Git.

## Sunshine NoCursor

The validated custom Sunshine AppImage came from:

- repository: `Therand90/batocera.linux`
- workflow: `Wii U Sunshine No Cursor`
- run: **#1**
- run ID: `36424613321`
- workflow head commit: `84876d4d73bb3ae2a939b3742cc09ec46bcf4900`
- Sunshine upstream tag: `v2026.914.233613`
- validated AppImage SHA-256: `4d0d08677277526274bb023cd5a93562cb340e74935261bdb54d63a539662b94`

The source change was intentionally tiny:

```diff
-bool display_cursor = true;
+bool display_cursor = false;
```

The old Actions artifact used a seven-day retention period and has expired, but the exact build workflow and source revision remain recoverable from the historical commit. The active Batocera runtime copy is the validated binary reference.
