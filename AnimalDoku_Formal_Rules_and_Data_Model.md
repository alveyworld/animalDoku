# AnimalDoku Formal Rules Specification & Data Model

> Version: 1.1 (MVP)
>
> **Related docs:** [Game Design Document](AnimalDoku_Game_Design_Document.md) (UX, themes, release scope) · [Implementation Roadmap](IMPLEMENTATION_ROADMAP.md) (build plan)
>
> **Platform note:** Types below are shown as pseudocode. The iOS implementation uses equivalent Swift structs and enums (SwiftUI, iOS 17+).

## Overview

AnimalDoku is a single-solution logic puzzle inspired by the mechanics of Meowdoku (also known as the Queens puzzle). The game theme is cosmetic; players may choose different animal icon sets without changing the puzzle rules.

---

# Core Rules

## Objective

Place exactly **one animal** in every:

- Row
- Column
- Colored region

while ensuring that **no two animals touch**, including diagonally.

A puzzle always has exactly one valid solution.

---

## Rule 1 — One Animal per Row

Every row must contain exactly one animal.

**Valid**

```text
🐶 . . .
. . 🐶 .
```

**Invalid**

```text
🐶 . 🐶 .
```

---

## Rule 2 — One Animal per Column

Every column must contain exactly one animal.

---

## Rule 3 — One Animal per Region

The board is partitioned into colored regions.

Each region must contain exactly one animal.

Regions may have irregular shapes.

---

## Rule 4 — Animals Cannot Touch

Animals may not be adjacent in any of the eight surrounding cells.

Forbidden neighbors: N, S, E, W, NE, NW, SE, SW.

Equivalent rule: for every placed animal, all eight neighboring cells are invalid placement targets.

---

## Rule 5 — Puzzle Completion

A puzzle is solved only when:

- Every row contains exactly one animal.
- Every column contains exactly one animal.
- Every region contains exactly one animal.
- No animals touch.
- No rule violations remain.

**Acceptance criteria:**

- **AC-5.1:** Given a partial board, when validated, then `isComplete` is `false`.
- **AC-5.2:** Given a board matching `puzzle.solution`, when validated, then `isComplete` is `true`.
- **AC-5.3:** Given a full board with any rule violation, when validated, then `isComplete` is `false`.

---

# Interaction Model

## Input Modes

The game has two mutually exclusive input modes, toggled via a toolbar control:

| Mode | Tap empty cell | Tap blocked (X) cell | Tap animal cell |
|------|----------------|----------------------|-----------------|
| **Place** (default) | Place animal | No effect | Remove animal |
| **Mark** | Toggle blocked (X) | Clear X → empty | No effect |

## Placement Validation

- Invalid placements are **allowed** but **highlighted** (violations shown on affected cells).
- Placing an animal does not auto-clear a blocked mark; blocked cells reject placement in Place mode.
- After puzzle completion, the board is **locked** until the player taps Play Again (reset).

## Undo / Redo / Reset

| Action | Behavior |
|--------|----------|
| **Undo** | Reverts the last action (place, remove, block, clear block, hint). No-op if history is empty. |
| **Redo** | Reapplies the last undone action. Cleared when a new action is taken after undo. |
| **Reset** | Restores board to initial state (all cells empty). Clears undo/redo stacks, hint count, and timer. Does not change selected theme or settings. |

## Pre-filled Givens

MVP puzzles start with **all cells empty**. No pre-filled animals.

Future: optional `initialPlacements: Position[]` on `Puzzle` (empty array for MVP puzzles).

---

# Hint System

| Field | Spec |
|-------|------|
| **Behavior** | Reveal the correct animal placement for one unsolved cell from `puzzle.solution` |
| **Target selection** | If player has a cell selected, hint that cell; otherwise hint the first unsolved cell in row-major order |
| **Limit** | Maximum **3** hints per puzzle attempt |
| **Preconditions** | Target cell must be empty (not animal, not blocked) |
| **Side effects** | Sets cell to `animal`; increments `hintsUsed`; recorded in undo history |
| **Undo** | Hint placements are undoable |

**Acceptance criteria:**

- **AC-H.1:** Given 0 hints used, when hint is requested on an empty cell in the solution, then that cell becomes `animal` and `hintsUsed` is 1.
- **AC-H.2:** Given 3 hints used, when hint is requested, then no change occurs.
- **AC-H.3:** Given a blocked target cell, when hint is requested, then no change occurs (player must clear X first).

---

# Player Actions

Players may:

- Place an animal (Place mode)
- Remove an animal (Place mode, tap animal cell)
- Mark a cell as impossible / clear mark (Mark mode)
- Undo
- Redo
- Reset
- Request a hint

---

# Cell States

| State | Description |
|-------|-------------|
| `empty` | No player action |
| `blocked` | Marked impossible (X) |
| `animal` | Animal placed |

---

# Game State

The game stores:

| Field | MVP scope |
|-------|-----------|
| Current board | v0.1 |
| Original puzzle | v0.1 |
| Player moves (undo/redo stacks) | v0.1 |
| Timer (`elapsedSeconds`) | Tracked in v0.1; displayed on win screen in v1.0 |
| Hint count (`hintsUsed`) | v0.1 |
| Mistake count | **Deferred to v1.1** — not tracked in MVP |
| Input mode (Place / Mark) | v0.1 |
| Completion flag | v0.1 |

Timer pauses when the app enters background; resumes on foreground.

---

# Data Model

## Position

```swift
struct Position: Codable, Equatable {
    let row: Int
    let col: Int
}
```

## CellState

```swift
enum CellState: String, Codable {
    case empty
    case blocked
    case animal
}
```

## Cell

```swift
struct Cell: Codable, Equatable {
    let row: Int
    let col: Int
    let regionId: Int
    var state: CellState
}
```

## Region

```swift
struct Region: Codable, Equatable {
    let id: Int
    let color: String      // hex color, e.g. "#A8D8EA"
    let cells: [Position]
}
```

## Puzzle

```swift
enum Difficulty: String, Codable {
    case easy, medium, hard, expert
}

struct Puzzle: Codable, Identifiable {
    let id: String
    let size: Int
    let regions: [Region]
    let solution: [Position]
    let difficulty: Difficulty
    let initialPlacements: [Position]  // always [] for MVP
}
```

## Theme

```swift
struct Theme: Identifiable {
    let id: String
    let name: String
    let animal: String
    let icon: String           // asset name
    let primaryColor: String   // hex
    let accentColor: String    // hex
}
```

## SaveGame (v1.1)

```swift
struct SaveGame: Codable {
    let puzzleId: String
    let elapsedSeconds: Int
    let cells: [Cell]
    let hintsUsed: Int
    let mistakes: Int
    let completed: Bool
}
```

Schema is defined now; persistence ships in v1.1 per GDD.

---

# Puzzle JSON Schema

MVP puzzles are **hand-authored JSON** files bundled in the app.

## Example

```json
{
  "id": "puzzle-001",
  "size": 8,
  "difficulty": "easy",
  "initialPlacements": [],
  "regions": [
    {
      "id": 0,
      "color": "#A8D8EA",
      "cells": [
        { "row": 0, "col": 0 },
        { "row": 0, "col": 1 }
      ]
    }
  ],
  "solution": [
    { "row": 0, "col": 3 },
    { "row": 1, "col": 7 }
  ]
}
```

## Invariants

Every bundled puzzle MUST satisfy:

1. `size` is a positive integer (8 for MVP).
2. Regions partition all `size × size` cells exactly once.
3. Region `id` values are contiguous from `0` to `size - 1`.
4. Each region has a unique `color` and a distinct visual pattern index (for colorblind support).
5. `solution.length == size` (exactly one animal per row).
6. `solution` satisfies Rules 1–4.
7. `solution` is the **only** valid solution.
8. `initialPlacements` is `[]` for all MVP puzzles.

## Content Verification

Properties 6–7 are verified **offline at puzzle authoring time**, not at runtime.

Puzzles should be solvable by logical deduction without guessing (content quality guideline for authors and future generator).

---

# Validation

## Algorithm

When the board state changes:

1. Verify at most one animal per row.
2. Verify at most one animal per column.
3. Verify at most one animal per region.
4. Verify no neighboring animals in any of 8 directions.
5. If no violations and exactly `size` animals placed, verify completion (Rule 5).

Overall complexity is **O(n)** per validation pass, where n = `size`.

## ValidationResult

```swift
enum RuleType: String, Codable {
    case row, column, region, adjacency
}

struct RuleViolation: Equatable {
    let rule: RuleType
    let positions: [Position]
}

struct ValidationResult: Equatable {
    let isValid: Bool           // true if zero violations
    let isComplete: Bool        // true if valid and Rule 5 satisfied
    let violations: [RuleViolation]
}
```

**Acceptance criteria:**

- **AC-V.1:** Given two animals in the same row, when validated, then `isValid` is `false` and a `row` violation lists both positions.
- **AC-V.2:** Given two diagonally adjacent animals, when validated, then an `adjacency` violation is returned.
- **AC-V.3:** Given a board matching `solution`, when validated, then `isValid` and `isComplete` are both `true`.

---

# Puzzle Requirements

Every puzzle in the catalog must:

- Have exactly one solution.
- Be solvable by logical deduction (content guideline).
- Require no guessing (content guideline).
- Be deterministic.

**MVP delivery:** bundled JSON files authored and verified offline. Runtime puzzle generator is a Future feature.

---

# MVP Scope

Aligned with [GDD MVP Scope](AnimalDoku_Game_Design_Document.md#mvp-scope).

| Feature | v0.1 Playable | v1.0 Ship | Future |
|---------|:-------------:|:---------:|:------:|
| 8×8 board + regions | ✓ | ✓ | |
| Validation engine | ✓ | ✓ | |
| Place / remove | ✓ | ✓ | |
| Mark blocked (X) | ✓ | ✓ | |
| Undo / redo / reset | ✓ | ✓ | |
| Hint system | ✓ | ✓ | |
| Win screen | ✓ | ✓ | |
| 1 bundled puzzle | ✓ | | |
| 5–10 bundled puzzles | | ✓ | |
| 3 themes + switcher | | ✓ | |
| Timer (tracked) | ✓ | | |
| Timer (displayed) | | ✓ | |
| Save progress | | | v1.1 |
| Tutorial | | ✓? | |
| Puzzle generator | | | ✓ |
| Daily puzzles | | | ✓ |
| Statistics / achievements | | | ✓ |
| Cloud save | | | ✓ |

---

# Recommended Folder Structure (iOS)

```text
AnimalDoku/
├── App/
├── Models/
├── Engine/
│   ├── Validator.swift
│   ├── GameSession.swift
│   └── HintService.swift
├── Services/
│   └── PuzzleLoader.swift
├── ViewModels/
├── UI/
│   ├── Components/
│   └── Screens/
├── Themes/
├── Resources/
│   └── Puzzles/
└── Tests/
```

See [Implementation Roadmap §5](IMPLEMENTATION_ROADMAP.md#5-suggested-architecture) for full layout.

---

# Open Questions

| # | Question | Owner | Notes |
|---|----------|-------|-------|
| 1 | Tutorial flow (content, length, skippable?) | Design | Does not block v0.1 |
| 2 | Monetization model | Product | Does not block v0.1 |
| 3 | Mistake counting rules | Design | Deferred to v1.1 |

All interaction, hint, validation, and MVP scope decisions required for v0.1 development are resolved in this document.
