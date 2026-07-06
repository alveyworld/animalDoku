import SwiftUI

/// Font styles for Animal Doku.
/// GDD: soft, minimal UI with readable hierarchy.
enum AppTypography {
    static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let title = Font.system(.title2, design: .rounded).weight(.semibold)
    static let headline = Font.system(.headline, design: .rounded).weight(.semibold)
    static let body = Font.system(.body, design: .rounded)
    static let caption = Font.system(.caption, design: .rounded)
    static let toolbar = Font.system(.subheadline, design: .rounded).weight(.medium)

    /// High-contrast variant uses heavier weight for ≥4.5:1 contrast (GDD accessibility).
    static func body(highContrast: Bool) -> Font {
        highContrast
            ? Font.system(.body, design: .rounded).weight(.semibold)
            : body
    }

    static func toolbar(highContrast: Bool) -> Font {
        highContrast
            ? Font.system(.subheadline, design: .rounded).weight(.bold)
            : toolbar
    }
}
