import XCTest
@testable import AnimalDoku

final class CoreTypesTests: XCTestCase {
  private let samplePuzzleJSON = """
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
    """.data(using: .utf8)!

  func testDecodesSamplePuzzleJSON() throws {
    let puzzle = try JSONDecoder().decode(Puzzle.self, from: samplePuzzleJSON)

    XCTAssertEqual(puzzle.id, "puzzle-001")
    XCTAssertEqual(puzzle.size, 8)
    XCTAssertEqual(puzzle.difficulty, .easy)
    XCTAssertEqual(puzzle.initialPlacements, [])
    XCTAssertEqual(puzzle.regions.count, 1)
    XCTAssertEqual(puzzle.regions[0].id, 0)
    XCTAssertEqual(puzzle.regions[0].color, "#A8D8EA")
    XCTAssertEqual(puzzle.regions[0].cells, [Position(row: 0, col: 0), Position(row: 0, col: 1)])
    XCTAssertEqual(puzzle.solution, [Position(row: 0, col: 3), Position(row: 1, col: 7)])
  }

  func testPuzzleRoundTripEncoding() throws {
    let original = try JSONDecoder().decode(Puzzle.self, from: samplePuzzleJSON)
    let data = try JSONEncoder().encode(original)
    let roundTripped = try JSONDecoder().decode(Puzzle.self, from: data)
    XCTAssertEqual(roundTripped, original)
  }

  func testPositionEquality() {
    XCTAssertEqual(Position(row: 2, col: 3), Position(row: 2, col: 3))
    XCTAssertNotEqual(Position(row: 2, col: 3), Position(row: 3, col: 2))
  }

  func testCellStateRawValueDecoding() throws {
    let decoder = JSONDecoder()

    XCTAssertEqual(try decoder.decode(CellState.self, from: Data("\"empty\"".utf8)), .empty)
    XCTAssertEqual(try decoder.decode(CellState.self, from: Data("\"blocked\"".utf8)), .blocked)
    XCTAssertEqual(try decoder.decode(CellState.self, from: Data("\"animal\"".utf8)), .animal)
  }

  func testThemeIsIdentifiableWithoutUIImports() {
    let theme = Theme(
      id: "frogs",
      name: "Frogs",
      animal: "frog",
      icon: ThemeAsset.frogsIcon,
      primaryColor: "#4A7C59",
      accentColor: "#85C88A"
    )
    XCTAssertEqual(theme.id, "frogs")
  }
}
