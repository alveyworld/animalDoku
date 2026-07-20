import Foundation

/// Colored region on the board. See [Formal Rules §Region](AnimalDoku_Formal_Rules_and_Data_Model.md#region).
struct Region: Codable, Equatable, Hashable {
    let id: Int
    /// Hex color string, e.g. `#A8D8EA`. UI layer converts to `Color`.
    let color: String
    let cells: [Position]
}
