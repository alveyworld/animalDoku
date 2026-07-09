import XCTest
@testable import AnimalDoku

final class PuzzleLoaderTests: XCTestCase {
    private let loader = PuzzleLoader()

    func testLoadsValidBundledPuzzle() throws {
        let puzzle = try loader.load(named: "puzzle-valid-4x4")

        XCTAssertEqual(puzzle.id, "puzzle-valid-4x4")
        XCTAssertEqual(puzzle.size, 4)
        XCTAssertEqual(puzzle.difficulty, .easy)
        XCTAssertEqual(puzzle.regions.count, 4)
        XCTAssertEqual(puzzle.solution.count, 4)
        XCTAssertEqual(puzzle.solution[0], Position(row: 0, col: 2))
    }

    func testValidPuzzlePassesPartitionValidation() throws {
        let puzzle = try loader.load(named: "puzzle-valid-4x4")
        XCTAssertNoThrow(try PuzzleLoader.validate(puzzle))
    }

    func testOverlappingRegionsThrowPartitionError() throws {
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

    func testMissingCellsThrowPartitionError() throws {
        let json = """
        {
          "id": "missing-cells",
          "size": 2,
          "difficulty": "easy",
          "initialPlacements": [],
          "regions": [
            {
              "id": 0,
              "color": "#A8D8EA",
              "cells": [
                { "row": 0, "col": 0 }
              ]
            },
            {
              "id": 1,
              "color": "#B8E0D2",
              "cells": [
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

    func testSolutionLengthMismatchThrows() throws {
        let json = """
        {
          "id": "bad-solution",
          "size": 4,
          "difficulty": "easy",
          "initialPlacements": [],
          "regions": [
            { "id": 0, "color": "#A8D8EA", "cells": [
                { "row": 0, "col": 0 }, { "row": 0, "col": 1 }, { "row": 1, "col": 0 }, { "row": 1, "col": 1 }
            ]},
            { "id": 1, "color": "#B8E0D2", "cells": [
                { "row": 0, "col": 2 }, { "row": 0, "col": 3 }, { "row": 1, "col": 2 }, { "row": 1, "col": 3 }
            ]},
            { "id": 2, "color": "#D4A5C9", "cells": [
                { "row": 2, "col": 0 }, { "row": 2, "col": 1 }, { "row": 3, "col": 0 }, { "row": 3, "col": 1 }
            ]},
            { "id": 3, "color": "#FFD4A3", "cells": [
                { "row": 2, "col": 2 }, { "row": 2, "col": 3 }, { "row": 3, "col": 2 }, { "row": 3, "col": 3 }
            ]}
          ],
          "solution": [
            { "row": 0, "col": 1 },
            { "row": 1, "col": 3 }
          ]
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try loader.load(from: json)) { error in
            XCTAssertEqual(
                error as? PuzzleLoaderError,
                .solutionLengthMismatch(expected: 4, got: 2)
            )
        }
    }

    func testMissingFileThrowsFileNotFound() {
        XCTAssertThrowsError(try loader.load(named: "does-not-exist")) { error in
            XCTAssertEqual(error as? PuzzleLoaderError, .fileNotFound("does-not-exist"))
        }
    }

    func testMalformedJSONThrowsDecodingFailed() {
        let data = Data("{ not valid json".utf8)

        XCTAssertThrowsError(try loader.load(from: data)) { error in
            guard case .decodingFailed = error as? PuzzleLoaderError else {
                return XCTFail("Expected decodingFailed, got \(error)")
            }
        }
    }

    func testNonContiguousRegionIdsThrow() throws {
        let json = """
        {
          "id": "bad-ids",
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
              "id": 2,
              "color": "#B8E0D2",
              "cells": [
                { "row": 1, "col": 0 },
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
            XCTAssertEqual(error as? PuzzleLoaderError, .nonContiguousRegionIds)
        }
    }

    func testLoadsMVPBundledPuzzle() throws {
        let puzzle = try loader.load(named: "puzzle-001")

        XCTAssertEqual(puzzle.id, "puzzle-001")
        XCTAssertEqual(puzzle.size, 8)
        XCTAssertEqual(puzzle.difficulty, .easy)
        XCTAssertEqual(puzzle.regions.count, 8)
        XCTAssertEqual(puzzle.solution.count, 8)
        XCTAssertTrue(puzzle.initialPlacements.isEmpty)
    }

    func testAvailablePuzzleNamesIncludesBundledFixture() throws {
        let names = loader.availablePuzzleNames()
        XCTAssertTrue(names.contains("puzzle-valid-4x4"))
        XCTAssertTrue(names.contains("puzzle-001"))
    }
}
