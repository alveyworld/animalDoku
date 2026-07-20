import SwiftUI
import UIKit

/// Asset catalog naming for MVP animal themes.
///
/// Image sets live in `Assets.xcassets/Themes/`:
/// - `theme-frogs-icon`
/// - `theme-dogs-icon`
/// - `theme-foxes-icon`
///
/// Metadata (names, colors) lives in `ThemeCatalog` (P4.1).
/// Final artwork is added in P5.4. Until then, SF Symbol fallbacks are used.
enum ThemeAsset {
    static let frogsIcon = ThemeCatalog.frogs.icon
    static let dogsIcon = ThemeCatalog.dogs.icon
    static let foxesIcon = ThemeCatalog.foxes.icon

    static func iconName(for themeID: String) -> String {
        ThemeCatalog.theme(id: themeID).icon
    }

    static func fallbackSymbol(for themeID: String) -> String {
        switch themeID {
        case ThemeCatalog.dogs.id: "pawprint.fill"
        case ThemeCatalog.foxes.id: "hare.fill"
        default: "leaf.fill"
        }
    }

    static func image(for themeID: String) -> Image {
        image(for: ThemeCatalog.theme(id: themeID))
    }

    static func image(for theme: Theme) -> Image {
        if UIImage(named: theme.icon) != nil {
            return Image(theme.icon)
        }
        return Image(systemName: fallbackSymbol(for: theme.id))
    }

    static var allIconNames: [String] {
        ThemeCatalog.all.map(\.icon)
    }
}
