import Foundation
import SwiftUI

/// Static catalog of MVP animal themes (GDD §Animal Themes).
///
/// Themes are cosmetic only — they do not affect puzzle logic, regions, or validation.
/// See [Formal Rules §Theme](../AnimalDoku_Formal_Rules_and_Data_Model.md#theme).
enum ThemeCatalog {
    static let frogs = Theme(
        id: "frogs",
        name: "theme.frogs.name",
        animal: "frog",
        icon: "theme-frogs-icon",
        primaryColor: "#4A7C59",
        accentColor: "#85C88A"
    )

    static let dogs = Theme(
        id: "dogs",
        name: "theme.dogs.name",
        animal: "dog",
        icon: "theme-dogs-icon",
        primaryColor: "#6B4E3D",
        accentColor: "#C9A66B"
    )

    static let foxes = Theme(
        id: "foxes",
        name: "theme.foxes.name",
        animal: "fox",
        icon: "theme-foxes-icon",
        primaryColor: "#9B4518",
        accentColor: "#E8A87C"
    )

    /// All MVP themes in stable display order.
    static let all: [Theme] = [frogs, dogs, foxes]

    /// Default theme for v0.1 / fresh installs (GDD).
    static let defaultTheme: Theme = frogs

    static let defaultThemeID: String = frogs.id

    /// Returns the theme for `id`, or `defaultTheme` when unknown.
    static func theme(id: String) -> Theme {
        all.first { $0.id == id } ?? defaultTheme
    }
}

extension Theme {
    /// Localized display name for pickers and VoiceOver (P4.2).
    var displayName: String {
        switch id {
        case ThemeCatalog.frogs.id:
            String(localized: "theme.frogs.name", defaultValue: "Frogs", comment: "Frog theme name")
        case ThemeCatalog.dogs.id:
            String(localized: "theme.dogs.name", defaultValue: "Dogs", comment: "Dog theme name")
        case ThemeCatalog.foxes.id:
            String(localized: "theme.foxes.name", defaultValue: "Foxes", comment: "Fox theme name")
        default:
            id.capitalized
        }
    }

    /// Resolved SwiftUI color for theme primary elements (animal icons, marks).
    var resolvedPrimaryColor: Color {
        ThemeColorResolver.color(fromHex: primaryColor) ?? AppColors.primary
    }

    /// Resolved SwiftUI color for theme accents (selection borders).
    var resolvedAccentColor: Color {
        ThemeColorResolver.color(fromHex: accentColor) ?? AppColors.accent
    }
}

enum ThemeColorResolver {
    static func color(fromHex hex: String) -> Color? {
        RegionColorMap.parseHex(hex)
    }
}

#if DEBUG

#Preview("Theme Catalog") {
    ScrollView {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 120), spacing: AppSpacing.md)],
            spacing: AppSpacing.md
        ) {
            ForEach(ThemeCatalog.all) { theme in
                VStack(spacing: AppSpacing.xs) {
                    ThemeAsset.image(for: theme.id)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .foregroundStyle(ThemeCatalogPreview.color(from: theme.primaryColor))

                    Text(theme.displayName)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.primary)

                    HStack(spacing: AppSpacing.xxs) {
                        ThemeCatalogPreview.swatch(theme.primaryColor)
                        ThemeCatalogPreview.swatch(theme.accentColor)
                    }
                }
                .padding(AppSpacing.sm)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusSmall))
            }
        }
        .padding(AppSpacing.md)
    }
    .background(AppColors.background)
}

private enum ThemeCatalogPreview {
    static func swatch(_ hex: String) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(color(from: hex))
            .frame(width: 28, height: 28)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(AppColors.border, lineWidth: 1)
            )
    }

    static func color(from hex: String) -> Color {
        ThemeColorResolver.color(fromHex: hex) ?? AppColors.primary
    }
}
#endif
