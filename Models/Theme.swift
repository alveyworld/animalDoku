import Foundation

/// Cosmetic theme metadata. See [Formal Rules §Theme](AnimalDoku_Formal_Rules_and_Data_Model.md#theme).
struct Theme: Identifiable, Equatable {
    let id: String
    let name: String
    let animal: String
    /// Asset catalog image name, e.g. `theme-frogs-icon`.
    let icon: String
    /// Hex color string for primary UI elements.
    let primaryColor: String
    /// Hex color string for accent UI elements.
    let accentColor: String
}
