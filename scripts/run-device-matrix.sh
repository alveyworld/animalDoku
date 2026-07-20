#!/usr/bin/env bash
# Run P6.4 device-matrix UI tests and copy screenshots into docs/device-matrix/.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${DEVICE_MATRIX_OUT:-$ROOT/docs/device-matrix}"
TMP_SHOTS="/tmp/animaldoku-device-matrix"
SCHEME="${SCHEME:-AnimalDoku}"
# Pin OS so destinations resolve (SE is on 18.1; "latest" may skip it).
OS="${DEVICE_MATRIX_OS:-18.1}"
mkdir -p "$OUT" "$TMP_SHOTS"

# slug|destination name
DEVICES=(
  "se|iPhone SE (3rd generation)"
  "iphone16|iPhone 16"
  "promax|iPhone 16 Pro Max"
)

run_device() {
  local slug="$1"
  local name="$2"
  echo ""
  echo "=== Device matrix: $name ($slug) OS=$OS ==="
  mkdir -p "$TMP_SHOTS"
  printf '%s' "$slug" > "$TMP_SHOTS/current-slug"
  DEVICE_MATRIX_OUT="$TMP_SHOTS" DEVICE_MATRIX_SLUG="$slug" \
    xcodebuild test \
      -scheme "$SCHEME" \
      -destination "platform=iOS Simulator,name=$name,OS=$OS" \
      -only-testing:AnimalDokuUITests/DeviceMatrixUITests \
      -only-testing:AnimalDokuUITests/GameplayUITests
  # Prefer copying only this slug's shots into the docs folder.
  cp -f "$TMP_SHOTS/$slug-"*.png "$OUT/" 2>/dev/null || true
}

for entry in "${DEVICES[@]}"; do
  slug="${entry%%|*}"
  name="${entry#*|}"
  run_device "$slug" "$name"
done

echo ""
echo "Screenshots in $OUT:"
ls -la "$OUT" || true
echo "Device matrix run complete."
