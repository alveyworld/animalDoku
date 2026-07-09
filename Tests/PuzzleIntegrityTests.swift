import XCTest
@testable import AnimalDoku

final class PuzzleIntegrityTests: XCTestCase {
    private let loader = PuzzleLoader()
    private let validator = Validator()

    // MARK: - Data-driven bundled puzzles

    func testAllBundledPuzzlesHaveValidStructure() throws {
        for puzzle in try sortedBundledPuzzles() {
            assertRegionsPartitionBoard(puzzle)
            assertContiguousRegionIDs(puzzle)
            assertUniqueRegionColors(puzzle)
            assertDistinctPatternIndices(puzzle)
            assertSolutionLengthMatchesSize(puzzle)
            assertInitialPlacementsEmpty(puzzle)
        }
    }

    func testAllBundledPuzzleSolutionsAreValidAndComplete() throws {
        for puzzle in try sortedBundledPuzzles() {
            let cells = BoardBuilder.cells(for: puzzle, solution: puzzle.solution)
            let result = validator.validate(cells: cells, puzzle: puzzle)

            XCTAssertTrue(
                result.isValid,
                "Puzzle \(puzzle.id): declared solution violates rules"
            )
            XCTAssertTrue(
                result.isComplete,
                "Puzzle \(puzzle.id): declared solution is not complete"
            )
            XCTAssertTrue(
                result.violations.isEmpty,
                "Puzzle \(puzzle.id): unexpected violations \(result.violations)"
            )
        }
    }

    func testAllBundledPuzzlesHaveUniqueSolution() throws {
        for puzzle in try sortedBundledPuzzles() {
            let enumerated = PuzzleSolver.solutions(for: puzzle, limit: 2)
            let declared = Set(puzzle.solution)

            XCTAssertEqual(
                enumerated.count,
                1,
                "Puzzle \(puzzle.id): expected exactly one solution, found \(enumerated.count)"
            )
            XCTAssertEqual(
                Set(enumerated[0]),
                declared,
                "Puzzle \(puzzle.id): solver solution does not match declared solution"
            )
        }
    }

    // MARK: - Negative fixtures (AC-6)

    func testOverlappingRegionsFailPartitionInvariant() throws {
        let json = """
        {
          "id": "bad-partition",
          "size": 2,
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
            },
            {
              "id": 1,
              "color": "#B8E0D2",
              "cells": [
                { "row": 0, "col": 0 },
                { "row": 1, "col": 1 }
              ]
            }
          ],
          "solution": [
            { "row": 0, "col": 1 },
            { "row": 1, "col": 0 }
          ]
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try loader.load(from: json)) { error in
            XCTAssertEqual(error as? PuzzleLoaderError, .regionsDoNotPartition)
        }
    }

    func testMultipleSolutionsFailUniquenessCheck() {
        let puzzle = PuzzleIntegrityFixtures.multipleSolutionPuzzle
        let enumerated = PuzzleSolver.solutions(for: puzzle, limit: 2)

        XCTAssertGreaterThanOrEqual(
            enumerated.count,
            2,
            "Fixture multiple-solution puzzle should have at least two valid solutions"
        )
        XCTAssertNotEqual(
            Set(enumerated[0]),
            Set(enumerated[1]),
            "Fixture should produce two distinct solutions"
        )
    }

    // MARK: - Helpers

    private func sortedBundledPuzzles() throws -> [Puzzle] {
        try loader.loadAllPuzzles().sorted { $0.id < $1.id }
    }

    private func assertRegionsPartitionBoard(_ puzzle: Puzzle, file: StaticString = #filePath, line: UInt = #line) {
        var seen = Set<String>()
        for region in puzzle.regions {
            for position in region.cells {
                XCTAssertTrue(
                    (0..<puzzle.size).contains(position.row),
                    "Puzzle \(puzzle.id): cell out of bounds at row \(position.row)",
                    file: file,
                    line: line
                )
                XCTAssertTrue(
                    (0..<puzzle.size).contains(position.col),
                    "Puzzle \(puzzle.id): cell out of bounds at col \(position.col)",
                    file: file,
                    line: line
                )

                let key = "\(position.row),\(position.col)"
                XCTAssertTrue(
                    seen.insert(key).inserted,
                    "Puzzle \(puzzle.id): cell \(key) appears in multiple regions",
                    file: file,
                    line: line
                )
            }
        }

        XCTAssertEqual(
            seen.count,
            puzzle.size * puzzle.size,
            "Puzzle \(puzzle.id): regions do not cover all \(puzzle.size)×\(puzzle.size) cells",
            file: file,
            line: line
        )
    }

    private func assertContiguousRegionIDs(_ puzzle: Puzzle, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(
            Set(puzzle.regions.map(\.id)),
            Set(0..<puzzle.size),
            "Puzzle \(puzzle.id): region IDs must be contiguous 0…\(puzzle.size - 1)",
            file: file,
            line: line
        )
    }

    private func assertUniqueRegionColors(_ puzzle: Puzzle, file: StaticString = #filePath, line: UInt = #line) {
        let colors = puzzle.regions.map(\.color)
        XCTAssertEqual(
            Set(colors).count,
            puzzle.size,
            "Puzzle \(puzzle.id): region colors must be unique",
            file: file,
            line: line
        )
    }

    private func assertDistinctPatternIndices(_ puzzle: Puzzle, file: StaticString = #filePath, line: UInt = #line) {
        // MVP derives pattern from region id; contiguous unique IDs imply distinct patterns.
        XCTAssertEqual(
            puzzle.regions.map(\.id).sorted(),
            Array(0..<puzzle.size),
            "Puzzle \(puzzle.id): pattern indices (region ids) must be distinct",
            file: file,
            line: line
        )
    }

    private func assertSolutionLengthMatchesSize(_ puzzle: Puzzle, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(
            puzzle.solution.count,
            puzzle.size,
            "Puzzle \(puzzle.id): solution.count must equal size",
            file: file,
            line: line
        )
    }

    private func assertInitialPlacementsEmpty(_ puzzle: Puzzle, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(
            puzzle.initialPlacements.isEmpty,
            "Puzzle \(puzzle.id): initialPlacements must be empty for MVP",
            file: file,
            line: line
        )
    }
}

/// Inline puzzles for negative integrity cases (not shipped in the app bundle).
private enum PuzzleIntegrityFixtures {
    /// 4×4 quad-block layout with two valid solutions (verifies uniqueness detection).
    static let multipleSolutionPuzzle = Puzzle(
        id: "fixture-two-solutions-4x4",
        size: 4,
        regions: [
            Region(id: 0, color: "#A8D8EA", cells: [
                Position(row: 0, col: 0), Position(row: 0, col: 1),
                Position(row: 1, col: 0), Position(row: 1, col: 1),
            ]),
            Region(id: 1, color: "#B8E0D2", cells: [
                Position(row: 0, col: 2), Position(row: 0, col: 3),
                Position(row: 1, col: 2), Position(row: 1, col: 3),
            ]),
            Region(id: 2, color: "#D4A5C9", cells: [
                Position(row: 2, col: 0), Position(row: 2, col: 1),
                Position(row: 3, col: 0), Position(row: 3, col: 1),
            ]),
            Region(id: 3, color: "#FFD4A3", cells: [
                Position(row: 2, col: 2), Position(row: 2, col: 3),
                Position(row: 3, col: 2), Position(row: 3, col: 3),
            ]),
        ],
        solution: [
            Position(row: 0, col: 1),
            Position(row: 1, col: 3),
            Position(row: 2, col: 0),
            Position(row: 3, col: 2),
        ],
        difficulty: .easy,
        initialPlacements: []
    )
}
