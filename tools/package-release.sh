#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT/VERSION")"
DIST="$ROOT/dist"
STAGE="$DIST/batocera-wiiu-gamepad-v$VERSION"

SUN="${1:-$ROOT/vendor/Sunshine-NoCursor.AppImage}"
APK="${2:-$ROOT/vendor/Moonlight-WiiU-GamePad.apk}"

SUN_SHA='4d0d08677277526274bb023cd5a93562cb340e74935261bdb54d63a539662b94'
APK_SHA='523ef85a6cbfb5eaf2d91283d0556bf7e42e24ac3e08f79b9b16873df678b1cf'

[ -f "$SUN" ] || {
    echo "ERREUR : Sunshine NoCursor introuvable : $SUN" >&2
    exit 1
}

actual_sun="$(sha256sum "$SUN" | awk '{print $1}')"
[ "$actual_sun" = "$SUN_SHA" ] || {
    echo "ERREUR : le Sunshine fourni n'est pas le binaire validé." >&2
    echo "Attendu : $SUN_SHA" >&2
    echo "Reçu   : $actual_sun" >&2
    exit 1
}

rm -rf "$STAGE"
mkdir -p "$STAGE/files/sunshine" "$STAGE/android" "$DIST"

cp -a "$ROOT/install.sh" "$ROOT/uninstall.sh" "$ROOT/VERSION" "$ROOT/LICENSE" "$ROOT/README.md" "$STAGE/"
cp -a "$ROOT/files" "$ROOT/docs" "$STAGE/"
cp -a "$SUN" "$STAGE/files/sunshine/Sunshine-NoCursor.AppImage"
chmod +x "$STAGE/files/sunshine/Sunshine-NoCursor.AppImage"

if [ -f "$APK" ]; then
    actual_apk="$(sha256sum "$APK" | awk '{print $1}')"
    [ "$actual_apk" = "$APK_SHA" ] || {
        echo "ERREUR : l'APK fourni n'est pas le build Moonlight WiiU validé." >&2
        echo "Attendu : $APK_SHA" >&2
        echo "Reçu   : $actual_apk" >&2
        exit 1
    }
    cp -a "$APK" "$STAGE/android/Moonlight-WiiU-GamePad.apk"
else
    rmdir "$STAGE/android"
fi

(
    cd "$STAGE"
    find . -type f -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS.txt
)

(
    cd "$DIST"
    rm -f "batocera-wiiu-gamepad-v$VERSION.zip"
    zip -qr "batocera-wiiu-gamepad-v$VERSION.zip" "batocera-wiiu-gamepad-v$VERSION"
    sha256sum "batocera-wiiu-gamepad-v$VERSION.zip" > "batocera-wiiu-gamepad-v$VERSION.zip.sha256"
)

echo "Release package ready:"
echo "  $DIST/batocera-wiiu-gamepad-v$VERSION.zip"
[ -f "$APK" ] && echo "  Moonlight APK included under android/"
