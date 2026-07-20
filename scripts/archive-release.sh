#!/usr/bin/env bash
# Archive a Release build for TestFlight / App Store Connect (P7.2).
#
# Prerequisites:
#   - Apple Developer Program membership
#   - DEVELOPMENT_TEAM set in Xcode (Signing & Capabilities) or via env:
#       export DEVELOPMENT_TEAM=XXXXXXXXXX
#   - Logged into Xcode with the team that owns com.animaldoku.AnimalDoku
#
# Usage:
#   ./scripts/archive-release.sh              # archive only
#   ./scripts/archive-release.sh --upload     # archive + export/upload via ExportOptions.plist
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCHEME="${SCHEME:-AnimalDoku}"
CONFIG="${CONFIG:-Release}"
ARCHIVE_PATH="${ARCHIVE_PATH:-$ROOT/build/AnimalDoku.xcarchive}"
EXPORT_PATH="${EXPORT_PATH:-$ROOT/build/export}"
EXPORT_OPTIONS="${EXPORT_OPTIONS:-$ROOT/ExportOptions.plist}"
DERIVED="$ROOT/build/DerivedData"

UPLOAD=0
for arg in "$@"; do
  case "$arg" in
    --upload) UPLOAD=1 ;;
    -h|--help)
      sed -n '1,20p' "$0"
      exit 0
      ;;
  esac
done

mkdir -p "$ROOT/build"

EXTRA_SETTINGS=()
if [[ -n "${DEVELOPMENT_TEAM:-}" ]]; then
  EXTRA_SETTINGS+=("DEVELOPMENT_TEAM=$DEVELOPMENT_TEAM")
fi

echo "=== Archiving $SCHEME ($CONFIG) → $ARCHIVE_PATH ==="
xcodebuild archive \
  -scheme "$SCHEME" \
  -configuration "$CONFIG" \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  -derivedDataPath "$DERIVED" \
  "${EXTRA_SETTINGS[@]+${EXTRA_SETTINGS[@]}}"

APP_PATH="$ARCHIVE_PATH/Products/Applications/AnimalDoku.app"
echo ""
echo "=== Archive hygiene checks ==="
test -d "$APP_PATH"
test -f "$APP_PATH/PrivacyInfo.xcprivacy"
# App icon must be present in the asset catalog compile output / Info.
/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP_PATH/Info.plist"
/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$APP_PATH/Info.plist"
# Release must not honor UI-test flags (strings may still appear in DEBUG unit-test slices only).
if strings "$APP_PATH/AnimalDoku" 2>/dev/null | grep -q -- '-uiTestPuzzle'; then
  echo "WARNING: -uiTestPuzzle string found in binary (verify #if DEBUG gating)." >&2
else
  echo "OK: -uiTestPuzzle not present in Release binary strings"
fi
echo "OK: PrivacyInfo.xcprivacy present"
echo "OK: Archive created at $ARCHIVE_PATH"

if [[ "$UPLOAD" -eq 1 ]]; then
  echo ""
  echo "=== Export / upload via $EXPORT_OPTIONS ==="
  rm -rf "$EXPORT_PATH"
  xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS" \
    -exportPath "$EXPORT_PATH" \
    "${EXTRA_SETTINGS[@]+${EXTRA_SETTINGS[@]}}"
  echo "Export finished. Check App Store Connect → TestFlight for processing."
else
  echo ""
  echo "Archive only. To upload:"
  echo "  open $ARCHIVE_PATH"
  echo "  # or: $0 --upload"
fi
