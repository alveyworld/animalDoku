# Game Design Document — Animal Doku

> **Related docs:** [Formal Rules & Data Model](AnimalDoku_Formal_Rules_and_Data_Model.md) (authoritative for game logic) · [Implementation Roadmap](IMPLEMENTATION_ROADMAP.md) (build plan)

## Product Vision

Create a relaxing mobile logic puzzle inspired by the feel of **meowDoku**, but with interchangeable animal themes instead of being cat-focused.

## Design Goals

- Easy to learn in under a minute.
- Calm, polished, satisfying gameplay.
- Cosmetic animal themes that don't affect gameplay.
- Small MVP suitable for building in Cursor.

## Platform

| Field | Value |
|-------|-------|
| Platform | iOS |
| UI framework | SwiftUI |
| Minimum iOS | 17+ |
| Orientation | Portrait only (MVP) |
| Distribution | App Store (v1.0) |

## Core Gameplay

- Square grid-based logic puzzle (8×8 for MVP).
- Players place animal icons into cells according to puzzle constraints defined in the [Formal Rules](AnimalDoku_Formal_Rules_and_Data_Model.md).
- One unique solution per puzzle.
- Tap to place/remove animals; toggle Mark mode to mark cells impossible (X).
- Undo, redo, reset, and hints.

See [Formal Rules § Interaction Model](AnimalDoku_Formal_Rules_and_Data_Model.md#interaction-model) for exact tap behavior.

## Win Condition

The puzzle is solved when exactly **one animal** is placed in every row, column, and colored region, no animals touch (including diagonally), and no rule violations remain.

Most cells remain empty — only `size` animals are placed on an `size × size` board.

## Difficulty

- Easy
- Medium
- Hard
- Expert

For MVP, difficulty is **metadata only** (a label on each bundled puzzle). All MVP puzzles use an 8×8 board. Board-size scaling by difficulty is a Future feature.

## Animal Themes

Themes only change visuals, sounds, and colors. They do not affect puzzle logic.

**MVP themes (locked):**

| Theme | ID |
|-------|-----|
| Frogs | `frogs` |
| Dogs | `dogs` |
| Foxes | `foxes` |

**Future themes:** Birds, Rabbits, Bears, and more.

## Visual Style

- Soft, minimal UI
- Rounded corners
- Pastel colors
- Gentle animations
- Calm sound effects

## Accessibility

Goals from product vision, with testable requirements:

| Requirement | Spec |
|-------------|------|
| Large touch targets | Minimum 44×44 pt per interactive cell and toolbar button |
| Colorblind-friendly regions | Each region has a distinct pattern or border in addition to color (see Formal Rules `Region.color`) |
| High contrast mode | Increased border weight; text/icon contrast ratio ≥ 4.5:1 |
| Sound toggle | Disables all game sound effects |
| Reduce Motion | Animations are optional; respect system setting |
| VoiceOver | Each cell announces row, column, region, and state |

## Screens & Navigation

### MVP screens

| Screen | Purpose |
|--------|---------|
| **Game** | Board, mode toggle (Place / Mark), toolbar, settings access |
| **Win overlay** | Completion celebration and play-again action |
| **Settings sheet** | Theme picker, sound toggle, high contrast toggle |

### Navigation flow (MVP)

```
App launch → Game (default puzzle)
Game → Win overlay (on completion)
Win overlay → Play Again → Game (reset)
Game → Settings sheet (modal)
```

**MVP entry:** App launches directly into Game with the default bundled puzzle. No home screen.

**v1.1:** Home screen with puzzle picker and difficulty filter.

## Win Screen

Shown when Rule 5 (puzzle completion) is satisfied.

| Element | MVP (v0.1) | v1.0 |
|---------|------------|------|
| Title | "Puzzle Complete!" | Same |
| Elapsed time | Hidden | Shown |
| Hints used | Hidden | Shown |
| Primary action | **Play Again** — resets current puzzle | Same |
| Board after win | Locked (no further edits until Play Again) | Same |

## MVP Scope

Scope is split into two release tiers to enable early playtesting without over-building.

### v0.1 — First playable (internal milestone)

- 8×8 board with colored regions
- 1 bundled puzzle (hand-authored JSON)
- 1 default theme (Frogs)
- Place / remove animal
- Mark blocked (X) via Mark mode
- Validation with violation highlighting
- Undo, redo, reset
- Hint system (per Formal Rules)
- Win screen (title + Play Again)
- Sound toggle
- Accessibility basics (large targets, region patterns)

### v1.0 — App Store ready

Everything in v0.1, plus:

- 5–10 bundled puzzles across difficulty labels
- 3 themes (Frogs, Dogs, Foxes) + theme switcher
- Settings sheet (theme, sound, high contrast)
- Timer shown on win screen
- App icon and launch screen
- Tutorial (if ready; otherwise v1.1)

### Explicitly not in MVP

- Save progress (schema defined; ships v1.1)
- Statistics, achievements, daily puzzles
- Puzzle generator (MVP uses bundled JSON)
- Cloud save, accounts, backend

## Suggested Project Structure

See [Implementation Roadmap §5](IMPLEMENTATION_ROADMAP.md#5-suggested-architecture) for the iOS folder layout.

## Development Order

Aligned with [Implementation Roadmap §7](IMPLEMENTATION_ROADMAP.md#7-recommended-development-order):

1. Puzzle data model + JSON schema
2. Validator (with unit tests)
3. GameSession (with unit tests)
4. One hand-crafted puzzle
5. Board rendering
6. Placement interactions → **first playable milestone**
7. Undo, redo, reset
8. Win screen
9. Themes + switcher
10. Hint system
11. Sound + settings
12. Accessibility polish

## Future Features

- Daily puzzles
- Puzzle generator
- Save progress
- Statistics
- More themes
- Achievements
- Cloud save
- Home screen / puzzle picker (also planned for v1.1)

## Open Design Decisions

| # | Decision | Status |
|---|----------|--------|
| 1 | Exact puzzle rules | **Resolved** — see [Formal Rules](AnimalDoku_Formal_Rules_and_Data_Model.md) |
| 2 | Puzzle generation strategy | **Resolved for MVP** — hand-authored JSON; generator is Future |
| 3 | Tutorial flow | **Open** — content, length, and skip behavior TBD |
| 4 | Input for X-marking | **Resolved** — separate Place / Mark mode toggle (see Formal Rules) |
| 5 | Monetization (ads, IAP) | **Open** — not specified |

## First Milestone

Build one fully playable puzzle with one theme, validation, undo/redo/reset, hint, and a win screen before expanding content or polish.

This matches Formal Rules MVP v0.1 and Implementation Roadmap Phase 3 completion.
