import SwiftUI
import UIKit

/// Asset catalog naming for animal themes.
///
/// Image sets live in `Assets.xcassets/Themes/` as `theme-<plural>-icon`
/// (cartoon heads). Metadata (names, colors) lives in `ThemeCatalog`.
/// SF Symbol fallbacks apply only when a raster asset is missing.
enum ThemeAsset {
    static let frogsIcon = ThemeCatalog.frogs.icon
    static let dogsIcon = ThemeCatalog.dogs.icon
    static let foxesIcon = ThemeCatalog.foxes.icon

    static func iconName(for themeID: String) -> String {
        ThemeCatalog.theme(id: themeID).icon
    }

    static func fallbackSymbol(for themeID: String) -> String {
        switch themeID {
        case ThemeCatalog.dogs.id, ThemeCatalog.bears.id, ThemeCatalog.tigers.id,
             ThemeCatalog.monkeys.id, ThemeCatalog.gorillas.id,
             ThemeCatalog.elephants.id, ThemeCatalog.rhinos.id,
             ThemeCatalog.camels.id, ThemeCatalog.zebras.id,
             ThemeCatalog.cows.id, ThemeCatalog.alligators.id:
            "pawprint.fill"
        case ThemeCatalog.foxes.id:
            "hare.fill"
        case ThemeCatalog.parrots.id, ThemeCatalog.penguins.id:
            "bird.fill"
        default:
            "leaf.fill"
        }
    }

    /// True when the theme has a full-color cartoon head in the asset catalog.
    static func hasRasterIcon(for theme: Theme) -> Bool {
        UIImage(named: theme.icon) != nil
    }

    static func hasRasterIcon(for themeID: String) -> Bool {
        hasRasterIcon(for: ThemeCatalog.theme(id: themeID))
    }

    static func image(for themeID: String) -> Image {
        image(for: ThemeCatalog.theme(id: themeID))
    }

    static func image(for theme: Theme) -> Image {
        if hasRasterIcon(for: theme) {
            return Image(theme.icon)
        }
        return Image(systemName: fallbackSymbol(for: theme.id))
    }

    static var allIconNames: [String] {
        ThemeCatalog.all.map(\.icon)
    }
}
