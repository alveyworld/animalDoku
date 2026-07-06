import SwiftUI
import UIKit

/// Asset catalog naming for MVP animal themes.
///
/// Image sets live in `Assets.xcassets/Themes/`:
/// - `theme-frogs-icon`
/// - `theme-dogs-icon`
/// - `theme-foxes-icon`
///
/// Final artwork is added in P4.1 / P5.4. Until then, SF Symbol fallbacks are used.
enum ThemeAsset {
    static let frogsIcon = "theme-frogs-icon"
    static let dogsIcon = "theme-dogs-icon"
    static let foxesIcon = "theme-foxes-icon"

    static func iconName(for themeID: String) -> String {
        switch themeID {
        case "frogs": frogsIcon
        case "dogs": dogsIcon
        case "foxes": foxesIcon
        default: frogsIcon
        }
    }

    static func fallbackSymbol(for themeID: String) -> String {
        switch themeID {
        case "frogs": "leaf.fill"
        case "dogs": "pawprint.fill"
        case "foxes": "hare.fill"
        default: "leaf.fill"
        }
    }

    static func image(for themeID: String) -> Image {
        let name = iconName(for: themeID)
        if UIImage(named: name) != nil {
            return Image(name)
        }
        return Image(systemName: fallbackSymbol(for: themeID))
    }

    static var allIconNames: [String] {
        [frogsIcon, dogsIcon, foxesIcon]
    }
}
