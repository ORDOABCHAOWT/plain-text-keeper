#!/usr/bin/env zsh
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="$(mktemp -d /private/tmp/plain-text-keeper-build.XXXXXX)"
APP_NAME="Plain Text Keeper"
PUBLIC_BUNDLE_ID="io.github.ordoabchaowt.plain-text-keeper"
BUNDLE_ID="${APP_BUNDLE_ID:-$PUBLIC_BUNDLE_ID}"
DIST_DIR="$PROJECT_DIR/dist"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
INSTALL_PATH="/Applications/$APP_NAME.app"
MODULE_CACHE="$WORK_DIR/ModuleCache"
ICON_SOURCE="$PROJECT_DIR/Assets/AppIcon.icns"
MAIN_SOURCE="$WORK_DIR/main.swift"

# Preserve the identity of an existing local install; fresh public builds use PUBLIC_BUNDLE_ID.
if [[ -z "${APP_BUNDLE_ID:-}" && -f "$INSTALL_PATH/Contents/Info.plist" ]]; then
  EXISTING_BUNDLE_ID="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$INSTALL_PATH/Contents/Info.plist" 2>/dev/null || true)"
  if [[ -n "$EXISTING_BUNDLE_ID" ]]; then
    BUNDLE_ID="$EXISTING_BUNDLE_ID"
  fi
fi

trap 'rm -rf "$WORK_DIR"' EXIT
mkdir -p "$DIST_DIR"
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS" "$APP_BUNDLE/Contents/Resources" "$MODULE_CACHE"

if [[ ! -f "$ICON_SOURCE" ]]; then
  echo "Missing icon source: $ICON_SOURCE" >&2
  exit 1
fi

cp "$ICON_SOURCE" "$APP_BUNDLE/Contents/Resources/AppIcon.icns"

cp "$PROJECT_DIR/Sources/main.swift" "$MAIN_SOURCE"

swiftc "$MAIN_SOURCE" \
  -framework AppKit \
  -framework Carbon \
  -framework ServiceManagement \
  -target arm64-apple-macosx13.0 \
  -module-cache-path "$MODULE_CACHE" \
  -Xcc -fmodules-cache-path="$MODULE_CACHE" \
  -Osize \
  -o "$APP_BUNDLE/Contents/MacOS/PlainTextKeeper"

cat > "$APP_BUNDLE/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleDisplayName</key>
  <string>$APP_NAME</string>
  <key>CFBundleExecutable</key>
  <string>PlainTextKeeper</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>$APP_NAME</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSApplicationCategoryType</key>
  <string>public.app-category.utilities</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSHumanReadableCopyright</key>
  <string>Copyright © 2026 ORDOABCHAOWT</string>
</dict>
</plist>
PLIST

cat > "$APP_BUNDLE/Contents/PkgInfo" <<PKG
APPL????
PKG

codesign --force --sign - "$APP_BUNDLE" >/dev/null
codesign --verify --deep --strict "$APP_BUNDLE"

if [[ "${INSTALL_APP:-1}" == "1" ]]; then
  rm -rf "$INSTALL_PATH"
  cp -R "$APP_BUNDLE" "$INSTALL_PATH"
  echo "Built and installed: $INSTALL_PATH"
else
  echo "Built: $APP_BUNDLE"
fi
