import Foundation

/// Which rule was violated. See [Formal Rules §Validation](AnimalDoku_Formal_Rules_and_Data_Model.md#validation).
enum RuleType: String, Codable, Equatable {
    case row
    case column
    case region
    case adjacency
}

/// A single rule violation with the affected board positions.
struct RuleViolation: Equatable {
    let rule: RuleType
    let positions: [Position]
}

/// Aggregated validation output for the current board state.
/// Invalid placements are allowed; the validator reports violations for highlighting.
/// See [Formal Rules §ValidationResult](AnimalDoku_Formal_Rules_and_Data_Model.md#validationresult).
struct ValidationResult: Equatable {
    let isValid: Bool
    let isComplete: Bool
    let violations: [RuleViolation]
}
