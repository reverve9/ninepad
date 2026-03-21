#!/bin/zsh
# =============================================================
# NinePAD — Build & Notarize & DMG
# 환경변수 필수:
#   APPLE_ID        — Apple Developer 계정 이메일
#   TEAM_ID         — Apple Developer Team ID
#   APP_PASSWORD    — App-specific password (앱 암호)
#   SIGNING_ID      — "Developer ID Application: Your Name (TEAM_ID)"
# =============================================================

set -euo pipefail

APP_NAME="NinePAD"
SCHEME="NinePAD"
BUILD_DIR="$(pwd)/build"
APP_PATH="$BUILD_DIR/Release/$APP_NAME.app"
DMG_PATH="$BUILD_DIR/$APP_NAME.dmg"
ZIP_PATH="$BUILD_DIR/$APP_NAME.zip"

# 환경변수 체크
: "${APPLE_ID:?환경변수 APPLE_ID를 설정하세요}"
: "${TEAM_ID:?환경변수 TEAM_ID를 설정하세요}"
: "${APP_PASSWORD:?환경변수 APP_PASSWORD를 설정하세요}"
: "${SIGNING_ID:?환경변수 SIGNING_ID를 설정하세요}"

echo "=== 1. Clean Build ==="
rm -rf "$BUILD_DIR"
xcodebuild -scheme "$SCHEME" \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR" \
    -archivePath "$BUILD_DIR/$APP_NAME.xcarchive" \
    archive

echo "=== 2. Export Archive ==="
xcodebuild -exportArchive \
    -archivePath "$BUILD_DIR/$APP_NAME.xcarchive" \
    -exportPath "$BUILD_DIR/Release" \
    -exportOptionsPlist "$(dirname "$0")/ExportOptions.plist"

echo "=== 3. Codesign Verify ==="
codesign --verify --deep --strict "$APP_PATH"
echo "Codesign OK"

echo "=== 4. Notarize ==="
# zip으로 압축 후 공증
ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

xcrun notarytool submit "$ZIP_PATH" \
    --apple-id "$APPLE_ID" \
    --team-id "$TEAM_ID" \
    --password "$APP_PASSWORD" \
    --wait

echo "=== 5. Staple ==="
xcrun stapler staple "$APP_PATH"

echo "=== 6. Create DMG ==="
# create-dmg가 설치되어 있으면 사용, 아니면 hdiutil
if command -v create-dmg &> /dev/null; then
    create-dmg \
        --volname "$APP_NAME" \
        --window-pos 200 120 \
        --window-size 600 400 \
        --icon-size 100 \
        --icon "$APP_NAME.app" 150 190 \
        --app-drop-link 450 190 \
        "$DMG_PATH" \
        "$APP_PATH"
else
    hdiutil create -volname "$APP_NAME" \
        -srcfolder "$APP_PATH" \
        -ov -format UDZO \
        "$DMG_PATH"
fi

echo "=== Done ==="
echo "DMG: $DMG_PATH"
ls -lh "$DMG_PATH"
