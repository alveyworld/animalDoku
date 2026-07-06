import CoreGraphics

/// Layout spacing, corner radii, and border constants.
/// GDD: rounded corners, soft minimal UI.
enum AppSpacing {
    // MARK: - Spacing scale

    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32

    // MARK: - Corner radius

    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16

    // MARK: - Board layout

    /// Outer padding around the game board.
    static let boardPadding: CGFloat = 16

    /// Gap between adjacent cells.
    static let cellGap: CGFloat = 2

    // MARK: - Borders

    /// Default border stroke for cells and regions.
    static let borderWeight: CGFloat = 1.0
}
