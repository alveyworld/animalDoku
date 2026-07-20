# Device Matrix — Animal Doku

Living checklist for [P6.4 Device matrix testing](../stories/phase-6/P6.4-device-matrix-testing.md).

**Date:** 2026-07-17  
**Build:** local / simulator (iOS 18.1)  
**Runner:** `scripts/run-device-matrix.sh` (`DeviceMatrixUITests` + `GameplayUITests`)

## Supported target

| Field | Decision |
|-------|----------|
| Device family | **iPhone-only** (`TARGETED_DEVICE_FAMILY = 1`) |
| iPad / universal | **Out of scope for v1.x** — not verified as a supported layout target |
| Minimum layout phone | iPhone SE (3rd gen) / 375 pt width (covers SE 2nd gen class) |
| Orientation | Portrait only (`UIInterfaceOrientationPortrait`) |
| Min iOS | 17+ |

## Results

| Device | Board fits | ≥44pt cells | Toolbar / sheet / win | Portrait | Play-to-win | Screenshots |
|--------|:----------:|:-----------:|:---------------------:|:--------:|:-----------:|-------------|
| iPhone SE (3rd gen) | PASS | PASS | PASS | PASS | PASS | [game](device-matrix/se-game.png) · [settings](device-matrix/se-settings.png) · [win](device-matrix/se-win.png) |
| iPhone 16 | PASS | PASS | PASS | PASS | PASS | [game](device-matrix/iphone16-game.png) · [settings](device-matrix/iphone16-settings.png) · [win](device-matrix/iphone16-win.png) |
| iPhone 16 Pro Max | PASS | PASS | PASS | PASS | PASS | [game](device-matrix/promax-game.png) · [settings](device-matrix/promax-settings.png) · [win](device-matrix/promax-win.png) |
| iPad | — | — | — | — | — | N/A (iPhone-only target) |

### How checks were performed

| Check | Method |
|-------|--------|
| Board square + fully visible | `DeviceMatrixUITests.testBoardIsSquareAndCellsMeetTouchTarget` (`gameBoard` aspect) |
| ≥44 pt cells | Same UITest on live frames + `BoardViewTests` SE / Pro Max layout math |
| Toolbar / settings / win | `testToolbarSettingsAndWinLayouts` (open settings sheet, solve to win) |
| Portrait lock | `testPortraitLayoutPersistsAfterRotationAttempt` + Info.plist portrait-only |
| Play-to-win | `GameplayUITests.testPlayPuzzle001ToWinUndoAndPlayAgain` on each destination |

## Re-run

```bash
./scripts/run-device-matrix.sh
# Optional:
# DEVICE_MATRIX_OS=18.1 ./scripts/run-device-matrix.sh
```

Screenshots are written under `/tmp/animaldoku-device-matrix/` during the UITest run, then copied into `docs/device-matrix/`.

## Notes

- Fixed `gameView` accessibility containment so child identifiers (`gameBoard`, `gameToolbar`, cells) are not overwritten by the parent id (needed for reliable matrix queries).
- Place/Mark mode toggle is gone (P6.5); chrome verified is gesture hint + toolbar + settings + win.
- No layout defects filed from this run.
