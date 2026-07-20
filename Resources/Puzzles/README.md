# Bundled Puzzle JSON

Hand-authored puzzle files for Animal Doku. See [Formal Rules §Puzzle JSON Schema](../../AnimalDoku_Formal_Rules_and_Data_Model.md#puzzle-json-schema).

## Required keys

| Key | Type | Description |
|-----|------|-------------|
| `id` | string | Unique puzzle identifier |
| `size` | int | Board dimension (8 for playable catalog) |
| `difficulty` | string | `easy`, `medium`, `hard`, or `expert` |
| `initialPlacements` | array | Pre-filled cells; always `[]` for MVP |
| `regions` | array | Colored regions partitioning the board |
| `solution` | array | Exactly `size` `{row, col}` positions |

## Region object

| Key | Type | Description |
|-----|------|-------------|
| `id` | int | Contiguous `0 … size - 1` |
| `color` | string | Hex color, e.g. `#A8D8EA` |
| `cells` | array | All `{row, col}` cells in this region |

## Structural invariants (checked by `PuzzleLoader`)

1. Regions partition all `size × size` cells exactly once.
2. Region IDs are contiguous from `0` to `size - 1`.
3. `solution.length == size`.
4. Rule validation (uniqueness, adjacency) is **not** checked at load time — see `Validator` (P2.4+).

## Authoring notes

- Regions **may** have unequal cell counts; variable sizes are preferred for interest.
- Regions should stay orthogonally contiguous.
- Every puzzle MUST have exactly one valid solution (gated by `PuzzleIntegrityTests` / `PuzzleSolver`).
- Home lists **8×8** puzzles only; smaller files are fixtures for tests.

## Catalog (P4.9)

| ID | Difficulty | Notes |
|----|------------|-------|
| `puzzle-001` | easy | Original MVP puzzle |
| `puzzle-002` | easy | Variable region sizes |
| `puzzle-003` | easy | Variable region sizes |
| `puzzle-004` | medium | Variable region sizes |
| `puzzle-005` | medium | Variable region sizes |
| `puzzle-006` | hard | Variable region sizes |
| `puzzle-007` | hard | Variable region sizes |
| `puzzle-008` | expert | Variable region sizes |
| `puzzle-009` | expert | Variable region sizes |
| `puzzle-valid-4x4` | easy | **Test / UI-test fixture** (not shown on Home) |

## Loading

```swift
let puzzle = try PuzzleLoader().load(named: "puzzle-001")
```

Files in this folder are copied into the app bundle under `Puzzles/`.
