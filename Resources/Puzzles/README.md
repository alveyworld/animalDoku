# Bundled Puzzle JSON

Hand-authored puzzle files for Animal Doku. See [Formal Rules §Puzzle JSON Schema](../../AnimalDoku_Formal_Rules_and_Data_Model.md#puzzle-json-schema).

## Required keys

| Key | Type | Description |
|-----|------|-------------|
| `id` | string | Unique puzzle identifier |
| `size` | int | Board dimension (8 for MVP) |
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

## Loading

```swift
let puzzle = try PuzzleLoader().load(named: "puzzle-valid-4x4")
```

Files in this folder are copied into the app bundle under `Puzzles/`.
