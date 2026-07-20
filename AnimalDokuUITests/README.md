# AnimalDoku UI Tests

## Launch arguments

| Argument | Purpose |
|---|---|
| `-uiTestPuzzle <name>` | Load a bundled puzzle and skip Home / tutorial (e.g. `puzzle-001`) |
| `-uiTestReduceMotion` | Force reduced-motion animations for stable timing |
| `-disableHomeScreen` | Launch into the default puzzle without Home (non-UI-test rollback) |

UI-test puzzle launches also clear persisted save files so each run starts on an empty board.

## Accessibility identifiers

| Element | Identifier |
|---|---|
| Game root | `gameView` |
| Board | `gameBoard` |
| Board cell | `cell_<row>_<col>` (0-based); custom actions Mark / Place animal |
| Undo | `toolbarUndo` (also labeled “Undo”) |
| Redo | `toolbarRedo` |
| Reset | `toolbarReset` |
| Hint | `toolbarHint` |
| Win overlay | `winScreen` |
| Play Again | `playAgainButton` |

## Running

```bash
xcodebuild test \
  -scheme AnimalDoku \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.1' \
  -only-testing:AnimalDokuUITests/GameplayUITests
```

`Puzzle001.solution` in `Fixtures/Puzzle001Solution.swift` mirrors `Resources/Puzzles/puzzle-001.json`. Drift is caught by `Puzzle001SolutionContractTests` in the unit test target.

## Accessibility audits (P6.3)

```bash
xcodebuild test \
  -scheme AnimalDoku \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.1' \
  -only-testing:AnimalDokuUITests/AccessibilityUITests
```

See `docs/accessibility-audit.md` for the full checklist and triaged exceptions.

## Device matrix (P6.4)

```bash
./scripts/run-device-matrix.sh
```

Runs `DeviceMatrixUITests` + `GameplayUITests` on iPhone SE (3rd), iPhone 16, and iPhone 16 Pro Max (iOS 18.1). Screenshots land in `docs/device-matrix/`; checklist in `docs/device-matrix.md`.

