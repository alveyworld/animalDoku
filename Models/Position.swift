import Foundation

/// Board coordinate. See [Formal Rules §Position](AnimalDoku_Formal_Rules_and_Data_Model.md#position).
struct Position: Codable, Equatable, Hashable {
    let row: Int
    let col: Int
}
