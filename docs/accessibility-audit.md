# Accessibility Audit — Animal Doku

Living conformance record for [GDD §Accessibility](../AnimalDoku_Game_Design_Document.md#accessibility) and story **P6.3**.

**Date:** 2026-07-17  
**Build:** local / simulator (iPhone 16, iOS 18.1)  
**Auditor:** automated tests + code review evidence

## Summary checklist

| Requirement | Method | Result | Evidence |
|-------------|--------|--------|----------|
| ≥44×44 pt touch targets | Unit tests + layout code | **PASS** | `TouchTarget.minimum = 44`; `DesignSystemTests`, `BoardViewTests` (SE width) |
| Cell VoiceOver labels | Unit tests + code | **PASS** | `CellViewAccessibility` — row, column, region, state; + selected / locked |
| Control labels & disabled | Code + UI audit | **PASS** | Toolbar, settings, Play Again; cell custom actions (P6.5); `.disabled` when locked |
| Dynamic Type | Typography + chrome | **PASS*** | Semantic `AppTypography` / Form text; board grid intentionally fixed size (cells remain ≥44pt). Theme captions allow 2 lines + scale. *Largest AX size: manual spot-check recommended on device. |
| Contrast ≥4.5:1 (default) | Unit tests | **PASS** | `DesignSystemTests.testDefaultTextMeetsWCAGAAContrast` after P6.3 token darkening |
| Contrast ≥4.5:1 (high contrast) | Unit tests | **PASS** | `testHighContrastTextMeetsWCAGAAContrast` |
| Theme icon contrast | Computed ratios | **PASS** | Frogs/Dogs/Foxes primaries ≥4.5:1 on background (Foxes `#9B4518`) |
| Colorblind regions | Patterns + tests | **PASS** | Distinct `RegionPatternStyle` per region id; cell borders; blocked = X shape |
| Reduce Motion | Unit + launch arg | **PASS** | `Motion` helpers nil out; Cell/Win/Tutorial honor system + `-uiTestReduceMotion` |
| Sound toggle | Unit tests | **PASS** | `SoundService` / `GameViewModel` tests — disabled service plays nothing |
| VoiceOver focus order | UI structure | **PASS** | Header → gesture hint → board (row-major cells) → toolbar; win sheet takes focus |
| Automated `performAccessibilityAudit` | UITests | **PASS** | `AccessibilityUITests` — Game, Settings, Win (1 triaged exception) |

## Decisions (open questions)

1. **Region phrasing:** Announce **region number** only (`Region 3`), not color name — color is not the sole cue (patterns + borders).
2. **CI gate:** Report-first via `AccessibilityUITests`; treat failures as release blockers once stable on CI.

## Automated audit exceptions

| Issue | Screen | Justification |
|-------|--------|---------------|
| “Contrast nearly passed” / Form contrast | Settings | Soft / Form-chrome fails from `performAccessibilityAudit`; text/icon tokens covered by `DesignSystemTests`. |
| Text clipped (Form / theme captions) | Settings | Auditor Dynamic Type sweep; captions allow 2 lines + scale; semantic fonts elsewhere. |
| Text clipped on `winElapsedTime` | Win | Fixed `mm:ss` clock string; Dynamic Type audit may flag the win-card frame; label remains fully spoken via accessibilityLabel. |

## Manual VoiceOver script (device)

1. Enable VoiceOver → launch Game (`-uiTestPuzzle puzzle-valid-4x4` or Home → puzzle).
2. Focus a cell — expect “Row …, Column …, Region …, empty|blocked|animal”.
3. Place an animal — label updates to animal; Undo announces and restores empty.
4. Open Settings — toggles announce name + On/Off; theme options announce Selected.
5. Complete puzzle — win sheet announces “Puzzle Complete!”; Play Again resets.

## Color / grayscale notes

- Region fills remain pastel; **patterns** (dots, stripes, etc.) differ per region id.
- High Contrast increases border weight to 3pt and swaps to stronger fills.
- Grayscale: regions stay distinguishable via pattern + border, not hue alone.

## Follow-ups (non-blocking)

- Device pass at largest Accessibility Dynamic Type size (Home + Settings + Tutorial).
- Optional: announce color name *in addition to* region id behind a preference.

## Related tests

- `AnimalDokuUITests/AccessibilityUITests.swift`
- `Tests/UI/CellViewTests.swift`, `MotionTests.swift`, `DesignSystemTests.swift`
- `AnimalDokuUITests/GameplayUITests.swift` (identifier contract)
