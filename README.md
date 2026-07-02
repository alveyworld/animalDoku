# Game Design Document --- Animal Doku

## Product Vision

Create a relaxing mobile logic puzzle inspired by the feel of
**meowDoku**, but with interchangeable animal themes instead of being
cat-focused.

## Design Goals

-   Easy to learn in under a minute.
-   Calm, polished, satisfying gameplay.
-   Cosmetic animal themes that don't affect gameplay.
-   Small MVP suitable for building in Cursor.

## Core Gameplay

-   Square grid-based logic puzzle.
-   Players place animal icons into cells according to puzzle
    constraints.
-   One unique solution per puzzle.
-   Tap to place/remove animals.
-   Undo, redo, reset, and hints.

## Win Condition

The puzzle is solved when every cell is correct and all constraints are
satisfied.

## Difficulty

-   Easy
-   Medium
-   Hard
-   Expert

Difficulty scales by puzzle size and constraint complexity.

## Animal Themes

Examples: - Frogs - Dogs - Foxes - Birds - Rabbits - Bears

Themes only change visuals, sounds, and colors.

## Visual Style

-   Soft, minimal UI
-   Rounded corners
-   Pastel colors
-   Gentle animations
-   Calm sound effects

## Accessibility

-   Colorblind-friendly
-   High contrast
-   Large touch targets
-   Sound toggle

## MVP

-   One puzzle mode
-   One board size
-   Three animal themes
-   Validation
-   Undo
-   Hint
-   Reset
-   Win screen

## Suggested Project Structure

    models/
    rules/
    ui/
    screens/
    assets/

## Development Order

1.  Puzzle data model
2.  Board rendering
3.  Placement interactions
4.  Validation
5.  Theme switching
6.  Hints and undo
7.  Polish

## Future Features

-   Daily puzzles
-   Puzzle generator
-   Save progress
-   Statistics
-   More themes
-   Achievements

## Open Design Decisions

-   Exact puzzle rules
-   Tutorial flow
-   Puzzle generation strategy

## First Milestone

Build one fully playable puzzle with one theme, validation, and a win
screen before expanding the game.
