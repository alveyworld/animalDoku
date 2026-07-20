import Foundation
import SwiftUI

/// Static catalog of animal themes (GDD §Animal Themes + expanded catalog).
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

    static let bears = Theme(
        id: "bears",
        name: "theme.bears.name",
        animal: "bear",
        icon: "theme-bears-icon",
        primaryColor: "#5C4033",
        accentColor: "#C4A484"
    )

    static let tigers = Theme(
        id: "tigers",
        name: "theme.tigers.name",
        animal: "tiger",
        icon: "theme-tigers-icon",
        primaryColor: "#C45C26",
        accentColor: "#F4A261"
    )

    static let camels = Theme(
        id: "camels",
        name: "theme.camels.name",
        animal: "camel",
        icon: "theme-camels-icon",
        primaryColor: "#C4A35A",
        accentColor: "#E8D5A3"
    )

    static let elephants = Theme(
        id: "elephants",
        name: "theme.elephants.name",
        animal: "elephant",
        icon: "theme-elephants-icon",
        primaryColor: "#6B7280",
        accentColor: "#B0B7C3"
    )

    static let rhinos = Theme(
        id: "rhinos",
        name: "theme.rhinos.name",
        animal: "rhino",
        icon: "theme-rhinos-icon",
        primaryColor: "#7B8A8B",
        accentColor: "#A8B5B8"
    )

    static let monkeys = Theme(
        id: "monkeys",
        name: "theme.monkeys.name",
        animal: "monkey",
        icon: "theme-monkeys-icon",
        primaryColor: "#8B5E3C",
        accentColor: "#D4A574"
    )

    static let parrots = Theme(
        id: "parrots",
        name: "theme.parrots.name",
        animal: "parrot",
        icon: "theme-parrots-icon",
        primaryColor: "#2D8F4E",
        accentColor: "#E85D4C"
    )

    static let penguins = Theme(
        id: "penguins",
        name: "theme.penguins.name",
        animal: "penguin",
        icon: "theme-penguins-icon",
        primaryColor: "#1F2937",
        accentColor: "#F59E0B"
    )

    static let gorillas = Theme(
        id: "gorillas",
        name: "theme.gorillas.name",
        animal: "gorilla",
        icon: "theme-gorillas-icon",
        primaryColor: "#374151",
        accentColor: "#9CA3AF"
    )

    static let zebras = Theme(
        id: "zebras",
        name: "theme.zebras.name",
        animal: "zebra",
        icon: "theme-zebras-icon",
        primaryColor: "#111827",
        accentColor: "#E5E7EB"
    )

    static let cows = Theme(
        id: "cows",
        name: "theme.cows.name",
        animal: "cow",
        icon: "theme-cows-icon",
        primaryColor: "#92400E",
        accentColor: "#FCD34D"
    )

    static let alligators = Theme(
        id: "alligators",
        name: "theme.alligators.name",
        animal: "alligator",
        icon: "theme-alligators-icon",
        primaryColor: "#3F6212",
        accentColor: "#84CC16"
    )

    /// All themes in stable display order.
    static let all: [Theme] = [
        frogs, dogs, foxes,
        bears, tigers, camels, elephants, rhinos, monkeys,
        parrots, penguins, gorillas, zebras, cows, alligators,
    ]

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
        case ThemeCatalog.bears.id:
            String(localized: "theme.bears.name", defaultValue: "Bears", comment: "Bear theme name")
        case ThemeCatalog.tigers.id:
            String(localized: "theme.tigers.name", defaultValue: "Tigers", comment: "Tiger theme name")
        case ThemeCatalog.camels.id:
            String(localized: "theme.camels.name", defaultValue: "Camels", comment: "Camel theme name")
        case ThemeCatalog.elephants.id:
            String(localized: "theme.elephants.name", defaultValue: "Elephants", comment: "Elephant theme name")
        case ThemeCatalog.rhinos.id:
            String(localized: "theme.rhinos.name", defaultValue: "Rhinos", comment: "Rhino theme name")
        case ThemeCatalog.monkeys.id:
            String(localized: "theme.monkeys.name", defaultValue: "Monkeys", comment: "Monkey theme name")
        case ThemeCatalog.parrots.id:
            String(localized: "theme.parrots.name", defaultValue: "Parrots", comment: "Parrot theme name")
        case ThemeCatalog.penguins.id:
            String(localized: "theme.penguins.name", defaultValue: "Penguins", comment: "Penguin theme name")
        case ThemeCatalog.gorillas.id:
            String(localized: "theme.gorillas.name", defaultValue: "Gorillas", comment: "Gorilla theme name")
        case ThemeCatalog.zebras.id:
            String(localized: "theme.zebras.name", defaultValue: "Zebras", comment: "Zebra theme name")
        case ThemeCatalog.cows.id:
            String(localized: "theme.cows.name", defaultValue: "Cows", comment: "Cow theme name")
        case ThemeCatalog.alligators.id:
            String(localized: "theme.alligators.name", defaultValue: "Alligators", comment: "Alligator theme name")
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
