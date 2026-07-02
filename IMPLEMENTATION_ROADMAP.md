# Animal Doku — Complete Implementation Roadmap

This roadmap is derived strictly from [AnimalDoku_Game_Design_Document.md](AnimalDoku_Game_Design_Document.md) and [AnimalDoku_Formal_Rules_and_Data_Model.md](AnimalDoku_Formal_Rules_and_Data_Model.md). The repository currently contains documentation only — no application code exists yet.

---

## 1. Executive Summary

### Application Summary

Animal Doku is a relaxing iOS logic puzzle game inspired by MeowDoku / the Queens puzzle. Players place animal icons on a square grid partitioned into colored regions. The goal is to place exactly one animal per row, per column, and per region, with the added constraint that no two animals may touch — including diagonally. Animal themes (frogs, dogs, foxes, etc.) are purely cosmetic and do not affect puzzle logic.

### Primary User Journey

1. Launch the app.
2. (Unclear from docs) Select or start a puzzle — source/selection flow is not defined.
3. View an 8×8 board with colored regions.
4. Tap cells to place animals, remove animals, or mark cells as impossible (X).
5. Use undo, redo, reset, and hints as needed.
6. Receive validation feedback as placements are made.
7. Complete the puzzle when all constraints are satisfied.
8. See a win screen.

### Core Gameplay Loop

```
View board → Select cell → Place / Remove / Mark blocked
    → Validate constraints → Adjust strategy → Repeat
    → All constraints satisfied → Win screen
```

The loop is calm and self-paced: no time pressure is mandated in the MVP (timer is stored in game state but its UI role is undefined).

### Primary Goals

| Goal | Source |
|------|--------|
| Easy to learn in under a minute | GDD |
| Calm, polished, satisfying gameplay | GDD |
| Cosmetic themes that don't affect gameplay | Both docs |
| Small MVP suitable for building in Cursor | GDD |
| One unique, logically solvable solution per puzzle | Formal Rules |
| Accessible (colorblind-friendly, high contrast, large targets, sound toggle) | GDD |

---

## 2. Feature Breakdown

Features are organized by category. Items marked **GAP** are referenced in docs but not fully specified.

### Authentication

| Feature | What | Why | Depends On | Technical Considerations |
|---------|------|-----|------------|--------------------------|
| None required for MVP | — | Docs describe a local single-player puzzle with no accounts | — | No auth layer needed unless cloud save is added later |

### User Profiles

| Feature | What | Why | Depends On | Technical Considerations |
|---------|------|-----|------------|--------------------------|
| None for MVP | — | No user identity in docs | — | Defer unless statistics/cloud save require it |

### Gameplay

| Feature | What | Why | Depends On | Technical Considerations |
|---------|------|-----|------------|--------------------------|
| Grid board rendering | Display N×N cells with region colors | Core visual surface | Puzzle model, Theme | 8×8 for MVP; cell size must support large touch targets |
| Region visualization | Colored irregular regions on board | Rule 3 requires region awareness | Region model | Colorblind-friendly patterns needed — **GAP: method unspecified** |
| Place animal | Tap empty cell → animal state | Core action | Cell state, Validator | Must not place if cell is blocked |
| Remove animal | Tap animal cell → empty | Core action | Cell state | |
| Mark blocked (X) | Tap to mark cell impossible | Formal Rules player action | Cell state | **GAP: GDD MVP list omits this; Formal Rules includes it** |
| Constraint validation | Check row/col/region uniqueness + no-touch on placement | Immediate feedback | Validator engine | O(n) per placement per Formal Rules |
| Puzzle completion detection | Detect win when all rules satisfied | Win condition | Validator | Must verify full board, not partial |
| Undo | Revert last move | Player action | Move history | |
| Redo | Reapply undone move | Player action | Move history | **GAP: GDD MVP lists undo only; Formal Rules MVP lists undo/redo** |
| Reset | Clear all player moves | Player action | Game state | **GAP: reset scope undefined (moves only vs. full state including hints/timer?)** |
| Hint | Assist player | Player action | Puzzle solution | **GAP: hint behavior completely undefined** |
| Difficulty levels | Easy / Medium / Hard / Expert | GDD | Puzzle catalog | **GAP: MVP scope unclear — one difficulty or all four?** |
| Timer | Track elapsed time | Formal Rules game state | Game session | **GAP: display/pause behavior undefined** |
| Mistake count (optional) | Track invalid placements | Formal Rules (optional) | Validator | **GAP: what counts as a mistake? Block placement or allow + count?** |

### Game State

| Feature | What | Why | Depends On | Technical Considerations |
|---------|------|-----|------------|--------------------------|
| Current board state | Live cell states | Drives UI | Cell model | |
| Original puzzle snapshot | Immutable puzzle definition | Reset, validation reference | Puzzle model | |
| Move history stack | Ordered list of player actions | Undo/redo | Action model | Consider action union type: place, remove, block, hint |
| Hint count | Hints used this session | Formal Rules | Game session | |
| Elapsed seconds | Session timer | Formal Rules | Timer service | Background/foreground pause behavior **GAP** |
| Completion flag | Whether puzzle is solved | Win flow | Validator | |

### UI/UX

| Feature | What | Why | Depends On | Technical Considerations |
|---------|------|-----|------------|--------------------------|
| Soft minimal UI | Pastel colors, rounded corners | GDD visual style | Design system | Define color tokens early |
| Gentle animations | Placement, win transitions | GDD | SwiftUI animations | Keep subtle for "calm" feel |
| Win screen | Celebrate completion | GDD MVP | Completion detection | **GAP: content undefined (time, hints, replay?)** |
| Theme switching | Swap animal icons/colors/sounds | GDD MVP (3 themes) | Theme model, assets | Themes must not affect puzzle logic |
| Sound effects | Calm audio on actions | GDD | Audio assets | Sound toggle required |
| Sound toggle | Enable/disable audio | GDD accessibility | Settings storage | |
| High contrast mode | Improved visibility | GDD accessibility | Design system | **GAP: implementation approach undefined** |
| Large touch targets | Accessible tap areas | GDD accessibility | Board layout | Minimum 44pt per Apple HIG |
| Colorblind-friendly regions | Distinguishable regions without color alone | GDD accessibility | Region rendering | Patterns, borders, or labels — **GAP** |
| Tutorial | Onboarding flow | GDD open decision | Gameplay | **GAP: entirely undefined** |
| Puzzle selection UI | Choose puzzle to play | Implied | Puzzle catalog | **GAP: one fixed puzzle vs. list vs. difficulty picker** |

### Navigation

| Feature | What | Why | Depends On | Technical Considerations |
|---------|------|-----|------------|--------------------------|
| App entry / home | Starting screen | iOS app structure | — | **GAP: not defined in docs** |
| Game screen | Active puzzle play | Core | All gameplay | Likely primary screen for MVP |
| Settings screen (minimal) | Theme, sound, accessibility | Themes + a11y | UserDefaults | May be sheet or tab — **GAP** |
| Win → next action | Post-completion navigation | Win screen | Win screen | **GAP: replay, next puzzle, home?** |

### Data Storage

| Feature | What | Why | Depends On | Technical Considerations |
|---------|------|-----|------------|--------------------------|
| Puzzle data (bundled) | Static puzzle definitions | MVP needs puzzles | Puzzle model | JSON in app bundle unless generator ships |
| Theme definitions | Theme metadata + assets | 3 themes for MVP | Theme model | Asset catalog |
| Local save (in-progress) | Persist `SaveGame` | Formal Rules data model | Storage layer | GDD lists as Future; Formal Rules defines schema |
| Settings persistence | Theme choice, sound, a11y prefs | UX continuity | UserDefaults | |

### Notifications

| Feature | What | Why | Depends On | Technical Considerations |
|---------|------|-----|------------|--------------------------|
| Daily puzzle reminders | Push for daily puzzle | GDD Future | Backend, auth | Not MVP |
| None for MVP | — | Not in MVP scope | — | |

### Administration

| Feature | What | Why | Depends On | Technical Considerations |
|---------|------|-----|------------|--------------------------|
| None for MVP | — | No admin surface in docs | — | Puzzle authoring likely offline (JSON files) |

### Analytics

| Feature | What | Why | Depends On | Technical Considerations |
|---------|------|-----|------------|--------------------------|
| None specified | — | Not in docs | — | Optional: puzzle completion events in v1.1 |

### Testing

| Feature | What | Why | Depends On | Technical Considerations |
|---------|------|-----|------------|--------------------------|
| Validator unit tests | Prove rule enforcement | Correctness critical | Validator | Property-based tests valuable for no-touch rule |
| Puzzle integrity tests | Single solution, solvable | Formal Rules requirements | Puzzle data / generator | |
| UI tests | Critical flows | Regression safety | XCTest UI | Play one puzzle, win, undo |
| Snapshot tests | Visual regression | Theme/region rendering | Board UI | Optional for v1.1 |

### Deployment

| Feature | What | Why | Depends On | Technical Considerations |
|---------|------|-----|------------|--------------------------|
| Xcode project setup | iOS app target | Platform | — | Min iOS version **GAP** |
| App icons & launch screen | Store readiness | iOS requirement | Assets | |
| App Store metadata | Listing | Release | — | Post-MVP |
| TestFlight distribution | Beta testing | Quality | CI | v1.1 |

### Accessibility

| Feature | What | Why | Depends On | Technical Considerations |
|---------|------|-----|------------|--------------------------|
| VoiceOver labels | Screen reader support | iOS best practice | All interactive UI | Not explicitly in GDD but expected for iOS |
| Dynamic Type | Scalable text | iOS best practice | UI components | |
| Reduce Motion | Respect system setting | iOS best practice | Animations | |
| Colorblind-friendly regions | See UI/UX | GDD | Region rendering | **GAP** |
| High contrast | See UI/UX | GDD | Design system | **GAP** |
| Large touch targets | See UI/UX | GDD | Board layout | |

### Performance

| Feature | What | Why | Depends On | Technical Considerations |
|---------|------|-----|------------|--------------------------|
| Fast validation | O(n) per move | Formal Rules | Validator | Trivial at 8×8 |
| Smooth 60fps board | Calm feel | GDD polish | Rendering | SwiftUI should suffice |
| Low memory footprint | Mobile best practice | Small MVP | Asset sizing | Vector/SF Symbols vs. raster |

---

## 3. Implementation Roadmap

### Phase 1 – Project Setup (MVP)

- [ ] Create Xcode project (SwiftUI, iOS target)
- [ ] Define folder structure and module boundaries
- [ ] Add SwiftLint / formatting conventions
- [ ] Set up unit test target
- [ ] Define design tokens (colors, spacing, corner radius)
- [ ] Add placeholder asset catalog structure

### Phase 2 – Core Architecture (MVP)

- [ ] Implement core data models (`Position`, `Cell`, `Region`, `Puzzle`, `Theme`, `CellState`)
- [ ] Implement `GameAction` and move history types
- [ ] Implement `GameSession` state container
- [ ] Implement `Validator` engine (all 4 rules + completion)
- [ ] Create bundled puzzle JSON format and loader
- [ ] Author or procure at least one valid 8×8 puzzle with regions + solution
- [ ] Write validator unit tests

### Phase 3 – Core Gameplay (MVP)

- [ ] Build `BoardView` — grid + region colors
- [ ] Build `CellView` — empty / blocked / animal states
- [ ] Implement tap-to-place, tap-to-remove interactions
- [ ] Wire placement through validator
- [ ] Implement completion detection → win state
- [ ] Build `GameView` screen shell
- [ ] Implement undo
- [ ] Implement reset
- [ ] Implement hint (**blocked until hint behavior is defined**)
- [ ] Implement mark-blocked (X) (**confirm MVP inclusion**)
- [ ] Implement redo (**confirm MVP inclusion**)

### Phase 4 – Supporting Features

- [ ] Theme model + 3 theme asset sets (MVP)
- [ ] Theme switcher UI (MVP)
- [ ] Sound effects + toggle (MVP — implied by GDD visual style)
- [ ] Timer display and persistence (Version 1.1 unless clarified for MVP)
- [ ] Save in-progress game (Version 1.1 per GDD Future list)
- [ ] Puzzle selection / difficulty picker (Version 1.1 — MVP may be single puzzle)
- [ ] Settings screen (MVP minimal: theme + sound + a11y)

### Phase 5 – Polish (MVP + v1.1)

- [ ] Win screen (MVP)
- [ ] Placement and win animations (MVP)
- [ ] Colorblind region patterns (MVP per GDD accessibility)
- [ ] High contrast mode (MVP per GDD)
- [ ] Haptic feedback (Future)
- [ ] Tutorial flow (Version 1.1 — open design decision)
- [ ] App icon and launch screen (MVP for release)

### Phase 6 – Testing

- [ ] Validator test suite (MVP)
- [ ] Puzzle integrity tests (MVP)
- [ ] Game session / undo-redo tests (MVP)
- [ ] UI test: complete one puzzle (MVP)
- [ ] Accessibility audit (VoiceOver, Dynamic Type) (MVP)
- [ ] Device matrix testing (Version 1.1)

### Phase 7 – Deployment

- [ ] App Store Connect setup (Version 1.1)
- [ ] Privacy manifest (MVP if required by Apple)
- [ ] TestFlight beta (Version 1.1)
- [ ] App Store submission (Version 1.1)

---

## 4. Detailed Task List

Effort: **S** = Small (≤0.5 day), **M** = Medium (1–2 days), **L** = Large (3+ days)

### Models & Data

#### T-001: Define core Swift types

- **Description:** Implement `Position`, `CellState`, `Cell`, `Region`, `Puzzle`, `Difficulty`, `Theme` per Formal Rules spec.
- **Effort:** S
- **Dependencies:** None
- **Files:** `Models/Position.swift`, `Models/Cell.swift`, `Models/Region.swift`, `Models/Puzzle.swift`, `Models/Theme.swift`
- **Acceptance criteria:** Types compile; `Codable` where needed for JSON loading; unit test encodes/decodes sample puzzle.

#### T-002: Define GameAction and SaveGame

- **Description:** Action enum (place, remove, block, unblock, hint) and `SaveGame` struct.
- **Effort:** S
- **Dependencies:** T-001
- **Files:** `Models/GameAction.swift`, `Models/SaveGame.swift`
- **Acceptance criteria:** Actions are reversible for undo/redo; `SaveGame` round-trips via JSON.

#### T-003: Define puzzle JSON schema

- **Description:** Document and implement schema for bundled puzzles: `id`, `size`, `regions`, `solution`, `difficulty`. **GAP:** whether `regionColors` or layout metadata is included must be decided.
- **Effort:** S
- **Dependencies:** T-001
- **Files:** `Resources/Puzzles/*.json`, `Services/PuzzleLoader.swift`
- **Acceptance criteria:** At least one puzzle loads from bundle; regions cover all 64 cells exactly once.

#### T-004: Author MVP puzzle content

- **Description:** Create hand-crafted 8×8 puzzle(s) with verified single solution. **GAP:** puzzle count for MVP undefined — minimum 1 per docs' first milestone.
- **Effort:** M
- **Dependencies:** T-003, Validator (T-010)
- **Files:** `Resources/Puzzles/`
- **Acceptance criteria:** Validator confirms solution is valid; no other solution exists (manual or solver verification).

### Engine

#### T-010: Implement Validator — row/column/region uniqueness

- **Description:** Given board state, verify at most one animal per row, column, region.
- **Effort:** M
- **Dependencies:** T-001
- **Files:** `Engine/Validator.swift`
- **Acceptance criteria:** Unit tests cover valid/invalid cases from Formal Rules examples.

#### T-011: Implement Validator — no-touch rule

- **Description:** Verify no two animals are adjacent in 8 directions.
- **Effort:** M
- **Dependencies:** T-010
- **Files:** `Engine/Validator.swift`
- **Acceptance criteria:** Diagonal adjacency correctly flagged; edge cells handled.

#### T-012: Implement completion check

- **Description:** Puzzle solved iff exactly one animal per row/col/region AND no-touch AND all cells accounted for.
- **Effort:** S
- **Dependencies:** T-010, T-011
- **Files:** `Engine/Validator.swift`
- **Acceptance criteria:** Partial boards return incomplete; exact solution returns complete.

#### T-013: Implement violation feedback

- **Description:** Return which rules are violated and affected cells for UI highlighting. **GAP:** docs don't require error UI style — decide highlight vs. block placement.
- **Effort:** M
- **Dependencies:** T-010–T-012
- **Files:** `Engine/Validator.swift`, `Engine/ValidationResult.swift`
- **Acceptance criteria:** Invalid placement returns structured violations; behavior on invalid place is product decision.

### Game Session

#### T-020: Implement GameSession

- **Description:** Holds puzzle, current cells, move stacks, hint count, timer, completion state.
- **Effort:** M
- **Dependencies:** T-001, T-002
- **Files:** `Engine/GameSession.swift`
- **Acceptance criteria:** Session initializes from puzzle with all cells empty (**GAP:** pre-filled givens not mentioned in docs).

#### T-021: Implement place/remove/block actions

- **Description:** Mutate cell state through session; record history.
- **Effort:** M
- **Dependencies:** T-020, T-013
- **Files:** `Engine/GameSession.swift`
- **Acceptance criteria:** Place on blocked cell rejected; remove animal returns empty; toggle block on empty cell.

#### T-022: Implement undo

- **Description:** Pop last action and restore prior state.
- **Effort:** S
- **Dependencies:** T-021
- **Files:** `Engine/GameSession.swift`
- **Acceptance criteria:** Sequential undos restore exact prior states; undo on empty stack is no-op.

#### T-023: Implement redo

- **Description:** Reapply undone action.
- **Effort:** S
- **Dependencies:** T-022
- **Files:** `Engine/GameSession.swift`
- **Acceptance criteria:** Redo stack clears on new action after undo.

#### T-024: Implement reset

- **Description:** Restore board to initial state. **GAP:** whether hints/timer reset too.
- **Effort:** S
- **Dependencies:** T-020
- **Files:** `Engine/GameSession.swift`
- **Acceptance criteria:** All cells return to initial state; move history cleared.

#### T-025: Implement hint

- **Description:** **BLOCKED — hint behavior undefined.** Options to decide: reveal one correct cell, highlight valid cell, or show rule violation.
- **Effort:** M
- **Dependencies:** T-020, product decision
- **Files:** `Engine/HintService.swift`
- **Acceptance criteria:** Defined after product answers open question.

#### T-026: Implement timer

- **Description:** Track `elapsedSeconds`; handle app backgrounding. **GAP:** pause on background undefined.
- **Effort:** S
- **Dependencies:** T-020
- **Files:** `Engine/TimerService.swift`
- **Acceptance criteria:** Elapsed time increments during active play; behavior on background documented.

### UI Components

#### T-030: Design system tokens

- **Description:** Pastel palette, corner radii, spacing, minimum touch target size (≥44pt).
- **Effort:** S
- **Dependencies:** None
- **Files:** `UI/DesignSystem/Colors.swift`, `Spacing.swift`, `Typography.swift`
- **Acceptance criteria:** Tokens used consistently; high contrast variant defined.

#### T-031: CellView

- **Description:** Renders empty, blocked (X), animal states; supports selected/highlighted/violation states.
- **Effort:** M
- **Dependencies:** T-030
- **Files:** `UI/Components/CellView.swift`
- **Acceptance criteria:** All three `CellState` values render distinctly without color alone.

#### T-032: BoardView

- **Description:** N×N grid; region background colors/patterns; responsive sizing.
- **Effort:** M
- **Dependencies:** T-031
- **Files:** `UI/Components/BoardView.swift`
- **Acceptance criteria:** 8×8 board fits iPhone SE through Pro Max; regions visually distinct.

#### T-033: Region colorblind patterns

- **Description:** Overlay patterns or borders so regions are distinguishable without color.
- **Effort:** M
- **Dependencies:** T-032
- **Files:** `UI/Components/RegionPattern.swift`
- **Acceptance criteria:** Regions distinguishable in grayscale simulation.

#### T-034: Game toolbar

- **Description:** Undo, redo, reset, hint buttons.
- **Effort:** S
- **Dependencies:** T-022–T-025
- **Files:** `UI/Components/GameToolbar.swift`
- **Acceptance criteria:** Buttons disabled when action unavailable; VoiceOver labels present.

#### T-035: Theme switcher

- **Description:** UI to pick among 3 themes; updates icons/colors/sounds.
- **Effort:** M
- **Dependencies:** T-040
- **Files:** `UI/Components/ThemePicker.swift`
- **Acceptance criteria:** Switching theme does not alter puzzle logic or cell positions.

#### T-036: Win screen

- **Description:** Shown on completion. **GAP:** content undefined.
- **Effort:** M
- **Dependencies:** T-012
- **Files:** `UI/Screens/WinScreen.swift`
- **Acceptance criteria:** Appears only on valid completion; dismiss/replay action defined.

#### T-037: Settings sheet

- **Description:** Sound toggle, high contrast, theme selection.
- **Effort:** S
- **Dependencies:** T-035, T-050
- **Files:** `UI/Screens/SettingsView.swift`
- **Acceptance criteria:** Settings persist across launches.

### Themes & Assets

#### T-040: Define 3 themes

- **Description:** Per GDD MVP: 3 animal themes with icon, colors. Pick 3 from examples: frogs, dogs, foxes, birds, rabbits, bears.
- **Effort:** M
- **Dependencies:** T-001
- **Files:** `Themes/ThemeCatalog.swift`, `Assets.xcassets/`
- **Acceptance criteria:** 3 themes load; each has distinct primary/accent colors and animal icon.

#### T-041: Sound assets

- **Description:** Calm place/remove/win sounds.
- **Effort:** S
- **Dependencies:** T-050
- **Files:** `Resources/Sounds/`, `Services/SoundService.swift`
- **Acceptance criteria:** Sounds play on actions; respect mute toggle and silent mode.

### Services & Persistence

#### T-050: SettingsStore

- **Description:** Persist theme ID, sound enabled, high contrast via `UserDefaults` or `@AppStorage`.
- **Effort:** S
- **Dependencies:** None
- **Files:** `Services/SettingsStore.swift`
- **Acceptance criteria:** Settings survive app restart.

#### T-051: SaveGame persistence (v1.1)

- **Description:** Persist in-progress puzzle per `SaveGame` schema.
- **Effort:** M
- **Dependencies:** T-002, T-020
- **Files:** `Services/SaveGameStore.swift`
- **Acceptance criteria:** Kill app mid-puzzle; resume restores exact state.

### Screens & Navigation

#### T-060: App entry point

- **Description:** Wire `AnimalDokuApp` → root view. **GAP:** home vs. direct-to-game undefined.
- **Effort:** S
- **Dependencies:** T-061
- **Files:** `App/AnimalDokuApp.swift`
- **Acceptance criteria:** App launches without crash to playable or home screen.

#### T-061: GameView (primary screen)

- **Description:** Composes board, toolbar, settings access; binds to `GameViewModel`.
- **Effort:** M
- **Dependencies:** T-032, T-034, T-070
- **Files:** `UI/Screens/GameView.swift`
- **Acceptance criteria:** Full play loop works on device.

#### T-062: Home / puzzle select (v1.1)

- **Description:** List puzzles or pick difficulty. Not required for first playable milestone.
- **Effort:** M
- **Dependencies:** T-004, T-061
- **Files:** `UI/Screens/HomeView.swift`
- **Acceptance criteria:** User can start any bundled puzzle.

### ViewModel / State

#### T-070: GameViewModel

- **Description:** `@Observable` or `ObservableObject` bridge between `GameSession` and SwiftUI.
- **Effort:** M
- **Dependencies:** T-020–T-025
- **Files:** `ViewModels/GameViewModel.swift`
- **Acceptance criteria:** UI updates on every action; win state triggers navigation.

### Testing

#### T-080: Validator unit tests

- **Effort:** M | **Dependencies:** T-010–T-012 | **Files:** `Tests/ValidatorTests.swift`
- **Acceptance criteria:** >95% branch coverage on validator.

#### T-081: GameSession unit tests

- **Effort:** M | **Dependencies:** T-020–T-024 | **Files:** `Tests/GameSessionTests.swift`
- **Acceptance criteria:** Undo/redo/reset sequences tested.

#### T-082: UI test — play to win

- **Effort:** M | **Dependencies:** T-061 | **Files:** `UITests/GameplayUITests.swift`
- **Acceptance criteria:** Automated test completes known puzzle and sees win screen.

### Deployment

#### T-090: Xcode project scaffolding

- **Effort:** S | **Dependencies:** None | **Files:** `AnimalDoku.xcodeproj`
- **Acceptance criteria:** Builds and runs on simulator.

#### T-091: App icon + launch screen

- **Effort:** S | **Dependencies:** T-090 | **Files:** `Assets.xcassets/AppIcon`
- **Acceptance criteria:** Meets Apple icon requirements.

---

## 5. Suggested Architecture

### Recommended Stack

| Layer | Choice | Reasoning |
|-------|--------|-----------|
| Language | Swift 5.9+ | iOS native standard |
| UI | SwiftUI | GDD suggests small MVP; fast iteration; good animations |
| Architecture | MVVM | Simple; fits SwiftUI; separates testable engine from UI |
| State | `@Observable` (iOS 17+) | Modern SwiftUI; less boilerplate than Combine for local state |
| Persistence | `UserDefaults` + JSON files | Sufficient for MVP settings and bundled puzzles |
| Min iOS | **GAP — recommend iOS 17** | Enables `@Observable`; adjust if broader support needed |

### Folder Structure

```text
AnimalDoku/
├── App/
│   └── AnimalDokuApp.swift
├── Models/
│   ├── Position.swift
│   ├── Cell.swift
│   ├── Region.swift
│   ├── Puzzle.swift
│   ├── Theme.swift
│   ├── GameAction.swift
│   └── SaveGame.swift
├── Engine/
│   ├── Validator.swift
│   ├── ValidationResult.swift
│   ├── GameSession.swift
│   ├── HintService.swift          # after hint spec
│   └── TimerService.swift
├── Services/
│   ├── PuzzleLoader.swift
│   ├── SettingsStore.swift
│   ├── SoundService.swift
│   └── SaveGameStore.swift        # v1.1
├── ViewModels/
│   └── GameViewModel.swift
├── UI/
│   ├── DesignSystem/
│   ├── Components/
│   │   ├── BoardView.swift
│   │   ├── CellView.swift
│   │   ├── GameToolbar.swift
│   │   └── ThemePicker.swift
│   └── Screens/
│       ├── GameView.swift
│       ├── WinScreen.swift
│       └── SettingsView.swift
├── Themes/
│   └── ThemeCatalog.swift
├── Resources/
│   ├── Puzzles/
│   └── Sounds/
└── Tests/
    ├── ValidatorTests.swift
    └── GameSessionTests.swift
```

### Data Models

Align with Formal Rules spec. Key additions for implementation:

```swift
enum GameAction {
    case placeAnimal(Position)
    case removeAnimal(Position)
    case toggleBlocked(Position)
    case hint(Position)  // shape depends on hint spec
}

struct ValidationResult {
    let isValid: Bool
    let violations: [RuleViolation]
    let isComplete: Bool
}
```

### Database Schema

No server database for MVP. Local storage only:

| Store | Content | Mechanism |
|-------|---------|-----------|
| App bundle | Puzzle JSON, sounds, images | File system |
| UserDefaults | `selectedThemeId`, `soundEnabled`, `highContrastEnabled` | Key-value |
| File or UserDefaults (v1.1) | `SaveGame` JSON per puzzle | Codable persistence |

### API Design

No network API for MVP. Internal service protocols only:

```swift
protocol PuzzleLoading {
    func loadPuzzle(id: String) throws -> Puzzle
    func loadAllPuzzles() throws -> [Puzzle]
}

protocol Validating {
    func validate(board: [Cell]) -> ValidationResult
}
```

### State Management

- **GameSession** (engine layer): source of truth for board + history; pure Swift, fully unit-testable.
- **GameViewModel**: exposes session to SwiftUI, handles user intents.
- **SettingsStore**: app-wide preferences via `@AppStorage` or injected observable.
- **ThemeCatalog**: static theme definitions; selected theme ID in SettingsStore.

### Major Modules

| Module | Responsibility |
|--------|----------------|
| `Engine` | Rules, validation, session logic — no UI imports |
| `Models` | Value types, Codable structs |
| `Services` | I/O: load puzzles, persist settings/saves |
| `ViewModels` | UI adaptation layer |
| `UI` | SwiftUI views only |

### Shared Utilities

- `Position` arithmetic (neighbors, bounds checking)
- `BoardUtilities` (2D array indexing, region lookup)
- `Color+Theme` extensions

### Reusable Components

- `CellView`, `BoardView`, `GameToolbar`, `ThemePicker`, `IconButton`

---

## 6. Risks and Unknowns

### Missing Requirements

| # | Gap | Impact |
|---|-----|--------|
| 1 | **Hint behavior** — reveal cell? highlight? limit per puzzle? | Blocks T-025 |
| 2 | **Tutorial flow** — GDD open decision | Blocks onboarding |
| 3 | **Puzzle source for MVP** — hand-crafted count, generator, or single puzzle | Blocks content pipeline |
| 4 | **Home / navigation structure** | Blocks app shell design |
| 5 | **Win screen content** — stats, replay, next puzzle? | Blocks T-036 |
| 6 | **Invalid placement UX** — prevent vs. allow + highlight vs. mistake count | Blocks validator UX integration |
| 7 | **Pre-filled cells (givens)** — not mentioned; assume all empty? | Affects puzzle schema |
| 8 | **Region colors** — assigned in puzzle data or computed? | Affects puzzle JSON schema |
| 9 | **Timer UI** — show or hidden for MVP? | Scope decision |
| 10 | **iOS version target** | Affects API choices |
| 11 | **Monetization** — ads, IAP? | Not mentioned |
| 12 | **Mistake counting** — optional; rules for what counts | Optional feature scope |

### Ambiguities / Contradictions

| Issue | GDD | Formal Rules | Resolution Needed |
|-------|-----|--------------|-----------------|
| Redo in MVP | MVP lists undo, not redo | MVP lists undo/redo | Confirm for MVP |
| Mark blocked (X) | Not in MVP list | Player action + cell state | Confirm for MVP |
| Save progress | Future feature | `SaveGame` model defined | MVP ships without save; model ready for v1.1 |
| Board size | "One board size" | 8×8 explicit | Aligned — 8×8 |
| Difficulty in MVP | 4 levels defined | Difficulty on Puzzle model | Confirm if MVP ships one or many puzzles |
| Exact puzzle rules | Listed as open decision | Fully specified in Formal Rules | **Resolved** — use Formal Rules |
| Three themes | GDD MVP | Not in Formal Rules MVP | Use GDD (3 themes) |
| Puzzle generator | Future + open decision | Must be logically solvable, no guessing | MVP likely hand-crafted JSON |

### Technical Challenges

- **Region rendering:** irregular regions on a grid with both color and pattern overlays.
- **Puzzle authoring:** verifying single-solution and no-guess-solvability manually is labor-intensive.
- **Hint without spoiling:** must align with "logical deduction" philosophy once defined.
- **Accessibility:** colorblind + high contrast together need careful design tokens.

### Edge Cases

- Tap animal cell: remove vs. no-op?
- Tap blocked cell: remove X vs. place animal (should be rejected)?
- Undo after win — allowed?
- Reset after partial hint usage — hint count behavior?
- Theme switch mid-game — must not affect state (only visuals).
- Device rotation — lock portrait or support landscape?
- All cells filled but with violations — not a win.

### Game Balance

- Not applicable in traditional sense; difficulty scales by size (future) and constraint density.
- **GAP:** no guidance on how Easy vs. Expert differs beyond "size and constraint complexity" — MVP is fixed 8×8.

### Security

- Low risk for offline MVP.
- If cloud save added later: auth, data validation, tamper resistance for puzzle solutions.

### Scalability

- Bundled JSON puzzles scale to hundreds without issue.
- Puzzle generator (Future) is the hard scalability problem — must enforce unique solution + logical solvability.

### Questions to Answer Before Implementation

1. What does a hint do, and is there a per-puzzle hint limit?
2. Is mark-blocked (X) in MVP?
3. Is redo in MVP?
4. How many puzzles ship in MVP — one or more?
5. What happens on invalid placement — block or allow with feedback?
6. Is the timer visible in MVP?
7. What is on the win screen?
8. App opens directly to game or home screen?
9. How are region colors assigned?
10. Are any cells pre-filled at puzzle start?
11. Minimum supported iOS version?
12. Portrait only?

---

## 7. Recommended Development Order

```
1. Models + Puzzle JSON schema
2. Validator (with tests)          ← testable without UI
3. GameSession (with tests)        ← full logic without UI
4. One hand-crafted puzzle
5. BoardView + CellView              ← first visual milestone
6. GameView + interactions           ← PLAYABLE MILESTONE
7. Undo + Reset
8. Win screen
9. Themes (3) + switcher
10. Hint (after spec)
11. Redo + Mark-blocked (if confirmed)
12. Sound + settings
13. Accessibility polish
14. Save progress (v1.1)
15. Puzzle selection + more content (v1.1)
16. TestFlight / App Store (v1.1)
```

### Why This Order

| Principle | How |
|-----------|-----|
| Minimize rework | Engine-first; UI consumes stable interfaces |
| Playable milestones early | Step 6 = one full puzzle playable with one theme |
| Reduce technical debt | Validator tested before UI wiring |
| Frequent testing | Unit tests from step 2; UI test at step 6+ |
| Incremental delivery | Each step adds visible or testable value |

**First playable milestone:** After step 6 — one puzzle, place/remove, validation, win detection, one default theme. Matches both docs' "first milestone."

---

## 8. MVP vs. Future Enhancements

| Feature | Category | Rationale |
|---------|----------|-----------|
| 8×8 board + regions | **MVP** | Core game |
| All 4 validation rules | **MVP** | Core game |
| Place / remove animal | **MVP** | Core actions |
| Undo | **MVP** | GDD MVP |
| Reset | **MVP** | GDD MVP |
| Hint | **MVP** | GDD MVP — once behavior defined |
| Win screen | **MVP** | GDD MVP |
| Validation feedback | **MVP** | GDD MVP |
| 3 animal themes + switching | **MVP** | GDD MVP |
| Sound + toggle | **MVP** | GDD visual style + accessibility |
| Colorblind-friendly regions | **MVP** | GDD accessibility |
| High contrast | **MVP** | GDD accessibility |
| Large touch targets | **MVP** | GDD accessibility |
| One puzzle (minimum) | **MVP** | First milestone in both docs |
| Redo | **Version 1.1** | Formal Rules yes; GDD MVP omits — low cost to add soon after undo |
| Mark blocked (X) | **Version 1.1** | Formal Rules yes; GDD MVP omits — valuable for logic solving |
| Timer display | **Version 1.1** | In data model; UI not in GDD MVP |
| Save progress | **Version 1.1** | GDD Future; schema ready |
| Multiple puzzles / difficulty picker | **Version 1.1** | GDD has 4 difficulties; MVP is one board/mode |
| Tutorial | **Version 1.1** | Open design decision |
| Mistake count | **Version 1.1** | Optional in Formal Rules |
| VoiceOver / Dynamic Type | **Version 1.1** | iOS best practice; not explicit MVP but low effort |
| Daily puzzles | **Future** | GDD Future |
| Puzzle generator | **Future** | GDD Future + hard problem |
| Statistics | **Future** | GDD Future |
| Achievements | **Future** | GDD Future |
| More themes | **Future** | GDD Future |
| Cloud save | **Future** | Implied by save + no auth |
| TestFlight / App Store | **Version 1.1** | After MVP proven playable |

### Smallest Enjoyable MVP

- 1 hand-crafted 8×8 puzzle with regions
- Place, remove, validate, win
- Undo, reset, hint (once defined)
- 1 theme at launch; switch among 3 themes
- Win screen
- Sound toggle
- Basic accessibility (large targets, region patterns)

### Safe to Postpone

- Save progress, statistics, daily puzzles, generator, achievements, redo, X-marking, timer UI, tutorial, App Store release

### First Fully Playable Milestone

**After:** Validator + GameSession + BoardView + GameView + one puzzle + win screen + one theme.

User can complete a puzzle start-to-finish with rule feedback.

### Recommended Release Sequence

| Release | Contents |
|---------|----------|
| **MVP (internal)** | Playable single puzzle, 3 themes, undo/reset/hint, win screen, a11y basics |
| **v1.0 (App Store)** | + multiple puzzles, puzzle picker, redo, X-marking, timer, tutorial, polish, TestFlight QA |
| **v1.1** | Save progress, statistics |
| **v2.0** | Daily puzzles, puzzle generator, achievements, more themes |

---

## 9. Master Development Checklist

### Phase 1 – Project Setup

- [ ] **MVP** [S] Create Xcode project (SwiftUI, iOS 17+ target — confirm version)
  - Acceptance: builds and runs empty app on simulator
- [ ] **MVP** [S] Create folder structure per architecture (§5)
  - Acceptance: groups match `Models/`, `Engine/`, `UI/`, etc.
- [ ] **MVP** [S] Configure unit test + UI test targets
  - Acceptance: sample test runs green
- [ ] **MVP** [S] Add design system tokens (colors, spacing, typography)
  - Acceptance: pastel palette and ≥44pt touch constants defined

### Phase 2 – Core Architecture

- [ ] **MVP** [S] T-001: Core Swift types (`Position`, `Cell`, `Region`, `Puzzle`, `Theme`)
  - Acceptance: Codable round-trip test passes
- [ ] **MVP** [S] T-002: `GameAction` + `SaveGame` models
  - Acceptance: action types cover place/remove/block
- [ ] **MVP** [S] T-003: Puzzle JSON schema + `PuzzleLoader`
  - Acceptance: loads puzzle from bundle
- [ ] **MVP** [M] T-004: Author ≥1 valid 8×8 puzzle with regions + solution
  - Acceptance: single solution verified
- [ ] **MVP** [M] T-010: Validator — row/col/region uniqueness
  - Acceptance: unit tests pass
- [ ] **MVP** [M] T-011: Validator — no-touch (8-direction)
  - Acceptance: diagonal cases pass
- [ ] **MVP** [S] T-012: Completion check
  - Acceptance: full valid board → complete
- [ ] **MVP** [M] T-013: Structured violation feedback
  - Acceptance: returns affected cells per rule
- [ ] **MVP** [M] T-080: Validator unit test suite
  - Acceptance: high coverage on engine

### Phase 3 – Core Gameplay

- [ ] **MVP** [M] T-020: `GameSession` state container
  - Acceptance: initializes empty board from puzzle
- [ ] **MVP** [M] T-021: Place / remove / block actions
  - Acceptance: state mutations + history recorded
- [ ] **MVP** [S] T-022: Undo
  - Acceptance: restores previous state
- [ ] **Version 1.1** [S] T-023: Redo
  - Acceptance: replays undone actions
- [ ] **MVP** [S] T-024: Reset
  - Acceptance: board returns to initial state
- [ ] **MVP** [M] T-025: Hint system ⚠️ *blocked on product decision*
  - Acceptance: defined per spec
- [ ] **Version 1.1** [S] T-026: Timer service
  - Acceptance: tracks elapsed seconds
- [ ] **MVP** [M] T-081: GameSession unit tests
  - Acceptance: undo/reset sequences covered
- [ ] **MVP** [M] T-031: `CellView` component
  - Acceptance: 3 cell states render distinctly
- [ ] **MVP** [M] T-032: `BoardView` component
  - Acceptance: 8×8 grid with region colors
- [ ] **MVP** [M] T-033: Colorblind region patterns
  - Acceptance: regions distinct in grayscale
- [ ] **MVP** [S] T-034: Game toolbar (undo, reset, hint)
  - Acceptance: buttons wired and accessible
- [ ] **MVP** [M] T-070: `GameViewModel`
  - Acceptance: UI reflects session changes
- [ ] **MVP** [M] T-061: `GameView` screen
  - Acceptance: full tap-to-play loop works
- [ ] **MVP** [M] T-036: Win screen
  - Acceptance: shows on valid completion only

### Phase 4 – Supporting Features

- [ ] **MVP** [M] T-040: 3 theme definitions + assets
  - Acceptance: frogs/dogs/foxes (or chosen trio) complete
- [ ] **MVP** [M] T-035: Theme switcher UI
  - Acceptance: cosmetic-only switch mid-game
- [ ] **MVP** [S] T-050: `SettingsStore`
  - Acceptance: preferences persist
- [ ] **MVP** [S] T-037: Settings sheet (sound, contrast, theme)
  - Acceptance: toggles work
- [ ] **MVP** [S] T-041: Sound effects + `SoundService`
  - Acceptance: respects mute toggle
- [ ] **Version 1.1** [S] T-051: Save game persistence
  - Acceptance: resume after app kill
- [ ] **Version 1.1** [M] T-062: Home / puzzle selection screen
  - Acceptance: pick from bundled puzzles

### Phase 5 – Polish

- [ ] **MVP** [M] Placement + win animations
  - Acceptance: gentle, respects Reduce Motion
- [ ] **MVP** [M] High contrast mode
  - Acceptance: increased contrast when enabled
- [ ] **Version 1.1** [M] Tutorial flow ⚠️ *blocked on design decision*
  - Acceptance: new user can learn rules in <1 minute
- [ ] **MVP** [S] T-091: App icon + launch screen
  - Acceptance: meets Apple guidelines
- [ ] **Version 1.1** [S] Haptic feedback on place/win
  - Acceptance: subtle haptics, optional

### Phase 6 – Testing

- [ ] **MVP** [M] T-082: UI test — play puzzle to win
  - Acceptance: automated win flow passes
- [ ] **MVP** [M] Accessibility audit (VoiceOver, Dynamic Type, contrast)
  - Acceptance: no critical a11y blockers
- [ ] **Version 1.1** [M] Device matrix testing (SE, standard, Pro Max, iPad)
  - Acceptance: layout correct on all targets

### Phase 7 – Deployment

- [ ] **MVP** [S] Privacy manifest (if applicable)
  - Acceptance: meets Apple requirements
- [ ] **Version 1.1** [M] TestFlight beta
  - Acceptance: external testers can install
- [ ] **Version 1.1** [M] App Store Connect listing + submission
  - Acceptance: app approved (goal)

---

## Pre-Implementation Decision Log

Before Phase 3 hint work and final MVP scope lock, resolve:

| # | Question | Recommended Default (not assumed — needs your confirmation) |
|---|----------|--------------------------------------------------------------|
| 1 | Hint behavior? | Reveal one unsolved cell from solution; max 3 per puzzle |
| 2 | X-marking in MVP? | Yes — it's in Formal Rules cell states |
| 3 | Redo in MVP? | Yes — cheap once undo exists |
| 4 | Puzzle count in MVP? | 1 puzzle for first milestone; 5–10 for App Store |
| 5 | Invalid placement? | Allow placement; highlight violations (mistake count optional) |
| 6 | Timer in MVP UI? | Hidden for MVP; tracked in session for v1.1 |
| 7 | Win screen? | "Puzzle complete!" + time (if tracked) + Play Again |
| 8 | Entry screen? | Direct to game for MVP; home in v1.1 |
| 9 | Region colors? | Assigned in puzzle JSON per region |
| 10 | Pre-filled givens? | No — all cells start empty |
| 11 | iOS target? | iOS 17+ |
| 12 | Orientation? | Portrait only |

---

This roadmap is ready to use as the primary development guide. The highest-priority blocker is **hint behavior** — everything else in the engine and UI can proceed in parallel once the pre-implementation questions above are answered.
