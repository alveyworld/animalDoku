# Animal Doku — Implementation Stories

Actionable developer stories derived from [IMPLEMENTATION_ROADMAP.md](../IMPLEMENTATION_ROADMAP.md), using the structure from [Story_Template.md](../Story_Template.md).

## How to use

1. Work stories **in order** within each phase unless dependencies allow parallel work.
2. Each story is **one PR-sized task** — complete it fully before moving on.
3. Mark stories done in this index as you ship them.
4. Source of truth for game logic: [Formal Rules](../AnimalDoku_Formal_Rules_and_Data_Model.md). UX scope: [GDD](../AnimalDoku_Game_Design_Document.md).

## Release tiers

| Tier | Meaning |
|------|---------|
| **v0.1** | First playable internal milestone |
| **v1.0** | App Store ready |
| **v1.1** | Post-launch improvements |
| **Future** | Not scheduled |

## Story index (execution order)

### Phase 1 — Project Setup

| ID | Story | Release | Effort | Status |
|----|-------|---------|--------|--------|
| [P1.1](phase-1/P1.1-xcode-project-setup.md) | Xcode project setup | v0.1 | XS | ⬜ |
| [P1.2](phase-1/P1.2-folder-structure.md) | Folder structure & module boundaries | v0.1 | XS | ⬜ |
| [P1.3](phase-1/P1.3-test-targets.md) | Unit & UI test targets | v0.1 | XS | ⬜ |
| [P1.4](phase-1/P1.4-design-system-tokens.md) | Design system tokens | v0.1 | XS | ⬜ |
| [P1.5](phase-1/P1.5-asset-catalog.md) | Asset catalog placeholder | v0.1 | XS | ⬜ |

### Phase 2 — Core Architecture

| ID | Story | Release | Effort | Status |
|----|-------|---------|--------|--------|
| [P2.1](phase-2/P2.1-core-swift-types.md) | Core Swift types | v0.1 | XS | ⬜ |
| [P2.2](phase-2/P2.2-game-action-savegame.md) | GameAction & SaveGame models | v0.1 | XS | ⬜ |
| [P2.3](phase-2/P2.3-puzzle-json-loader.md) | Puzzle JSON schema & PuzzleLoader | v0.1 | XS | ⬜ |
| [P2.4](phase-2/P2.4-validator-uniqueness.md) | Validator — row/col/region uniqueness | v0.1 | S | ⬜ |
| [P2.5](phase-2/P2.5-validator-no-touch.md) | Validator — no-touch rule | v0.1 | S | ⬜ |
| [P2.6](phase-2/P2.6-validator-completion.md) | Validator — completion check | v0.1 | XS | ⬜ |
| [P2.7](phase-2/P2.7-validator-violations.md) | Validator — violation feedback | v0.1 | S | ⬜ |
| [P2.8](phase-2/P2.8-author-mvp-puzzle.md) | Author MVP puzzle content | v0.1 | S | ⬜ |
| [P2.9](phase-2/P2.9-validator-unit-tests.md) | Validator unit test suite | v0.1 | S | ⬜ |

### Phase 3 — Core Gameplay

| ID | Story | Release | Effort | Status |
|----|-------|---------|--------|--------|
| [P3.1](phase-3/P3.1-game-session.md) | GameSession state container | v0.1 | S | ✅ |
| [P3.2](phase-3/P3.2-place-remove-block-actions.md) | Place, remove & block actions | v0.1 | S | ✅ |
| [P3.3](phase-3/P3.3-undo.md) | Undo | v0.1 | XS | ✅ |
| [P3.4](phase-3/P3.4-redo.md) | Redo | v0.1 | XS | ✅ |
| [P3.5](phase-3/P3.5-reset.md) | Reset | v0.1 | XS | ✅ |
| [P3.6](phase-3/P3.6-hint-system.md) | Hint system | v0.1 | S | ✅ |
| [P3.7](phase-3/P3.7-gamesession-unit-tests.md) | GameSession unit tests | v0.1 | S | ✅ |
| [P3.8](phase-3/P3.8-cell-view.md) | CellView component | v0.1 | S | ✅ |
| [P3.9](phase-3/P3.9-board-view.md) | BoardView component | v0.1 | S | ✅ |
| [P3.10](phase-3/P3.10-region-patterns.md) | Colorblind region patterns | v0.1 | S | ✅ |
| [P3.11](phase-3/P3.11-input-mode-toggle.md) | Place / Mark input mode toggle | v0.1 | XS | ✅ |
| [P3.12](phase-3/P3.12-game-toolbar.md) | Game toolbar | v0.1 | XS | ✅ |
| [P3.13](phase-3/P3.13-game-view-model.md) | GameViewModel | v0.1 | S | ✅ |
| [P3.14](phase-3/P3.14-game-view.md) | GameView screen | v0.1 | S | ✅ |
| [P3.15](phase-3/P3.15-win-screen.md) | Win screen overlay | v0.1 | S | ✅ |
| [P3.16](phase-3/P3.16-app-entry-point.md) | App entry point | v0.1 | XS | ✅ |

**Milestone:** After P3.14 + P3.15 + P2.8 — first fully playable puzzle.

### Phase 4 — Supporting Features

| ID | Story | Release | Effort | Status |
|----|-------|---------|--------|--------|
| [P4.1](phase-4/P4.1-theme-catalog.md) | Theme catalog & assets | v1.0 | S | ✅ |
| [P4.2](phase-4/P4.2-theme-switcher.md) | Theme switcher UI | v1.0 | S | ✅ |
| [P4.3](phase-4/P4.3-settings-store.md) | SettingsStore persistence | v1.0 | XS | ✅ |
| [P4.4](phase-4/P4.4-settings-sheet.md) | Settings sheet | v1.0 | XS | ✅ |
| [P4.5](phase-4/P4.5-sound-service.md) | Sound effects & SoundService | v1.0 | XS | ✅ |
| [P4.6](phase-4/P4.6-timer-service.md) | Timer service & win display | v1.0 | XS | ✅ |
| [P4.7](phase-4/P4.7-save-game-persistence.md) | Save game persistence | v1.1 | S | ✅ |
| [P4.8](phase-4/P4.8-home-puzzle-select.md) | Home & puzzle selection | v1.1 | S | ✅ |
| [P4.9](phase-4/P4.9-expand-puzzle-catalog.md) | Expand puzzle catalog by difficulty | v1.1 | M | ✅ |

### Phase 5 — Polish

| ID | Story | Release | Effort | Status |
|----|-------|---------|--------|--------|
| [P5.1](phase-5/P5.1-placement-animations.md) | Placement animations | v1.0 | S | ✅ |
| [P5.2](phase-5/P5.2-win-animations.md) | Win animations | v1.0 | XS | ✅ |
| [P5.3](phase-5/P5.3-high-contrast-mode.md) | High contrast mode | v1.0 | S | ✅ |
| [P5.4](phase-5/P5.4-app-icon-launch-screen.md) | App icon & launch screen | v1.0 | XS | ✅ |
| [P5.5](phase-5/P5.5-tutorial-flow.md) | Tutorial flow | v1.1 | S | ✅ |
| [P5.6](phase-5/P5.6-haptic-feedback.md) | Haptic feedback | v1.1 | XS | ✅ |
| [P5.7](phase-5/P5.7-drag-to-mark.md) | Drag-to-mark gesture | v1.1 | S | ✅ |

### Phase 6 — Testing

| ID | Story | Release | Effort | Status |
|----|-------|---------|--------|--------|
| [P6.1](phase-6/P6.1-puzzle-integrity-tests.md) | Puzzle integrity tests | v0.1 | S | ✅ |
| [P6.2](phase-6/P6.2-ui-test-play-to-win.md) | UI test — play to win | v1.0 | S | ✅ |
| [P6.3](phase-6/P6.3-accessibility-audit.md) | Accessibility audit | v1.0 | S | ✅ |
| [P6.4](phase-6/P6.4-device-matrix-testing.md) | Device matrix testing | v1.1 | S | ✅ |
| [P6.5](phase-6/P6.5-unified-tap-mark-place.md) | Tap to mark / double-tap to place | v1.1 | S | ✅ |

### Phase 7 — Deployment

| ID | Story | Release | Effort | Status |
|----|-------|---------|--------|--------|
| [P7.1](phase-7/P7.1-privacy-manifest.md) | Privacy manifest | v1.0 | XS | ✅ |
| [P7.2](phase-7/P7.2-testflight-beta.md) | TestFlight beta | v1.1 | S | ✅ |
| [P7.3](phase-7/P7.3-app-store-submission.md) | App Store submission | v1.1 | S | ⬜ |

### Phase 8 — Look and Feel

| ID | Story | Release | Effort | Status |
|----|-------|---------|--------|--------|
| [P8.1](phase-8/P8.1-bright-accessible-colors.md) | Bright colors, higher contrast, no pattern lines | v1.1 | S | ✅ |
| [P8.2](phase-8/P8.2-bold-mark-xs.md) | Bigger bolder white mark Xs | v1.1 | XS | ✅ |
| [P8.3](phase-8/P8.3-cartoon-animal-heads.md) | Cartoon animal heads + look-around | v1.1 | M | ✅ |

## Dependency graph (simplified)

```text
P1.* → P2.1 → P2.2,P2.3,P2.4 → P2.5 → P2.6 → P2.7 → P2.8,P2.9
P2.* → P3.1 → P3.2 → P3.3 → P3.4,P3.5,P3.6 → P3.7
P1.4 → P3.8 → P3.9 → P3.10
P3.2,P3.8 → P3.11,P3.12 → P3.13 → P3.14 → P3.15,P3.16
P4.1 → P4.2 → P4.4; P4.3 → P4.4,P4.5
P3.14 → P6.2; P2.8 → P6.1
P3.11,P5.7 → P6.5
P1.4,P3.9,P3.10,P5.3 → P8.1
P3.8,P8.1 → P8.2
P4.1,P3.8,P5.1 → P8.3
```

## Effort key

| Label | Meaning |
|-------|---------|
| XS | ≤ 1 day |
| S | 1–2 days |
| M | 2–4 days |
| L | 1–2 weeks |
