import Foundation

/// Cell occupancy state. See [Formal Rules §Cell States](AnimalDoku_Formal_Rules_and_Data_Model.md#cell-states).
enum CellState: String, Codable, Equatable {
    case empty
    case blocked
    case animal
}

/// A single board cell. See [Formal Rules §Cell](AnimalDoku_Formal_Rules_and_Data_Model.md#cell).
struct Cell: Codable, Equatable {
    let row: Int
    let col: Int
    let regionId: Int
    var state: CellState
}
