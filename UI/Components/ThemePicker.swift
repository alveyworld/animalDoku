import SwiftUI

/// Horizontal theme selector bound to `SettingsStore.selectedThemeId` (P4.2).
///
/// Cosmetic only — changing theme does not mutate `GameSession` state.
struct ThemePicker: View {
    @Binding var selectedThemeId: String
    /// When embedded in a Form section, hide the inline caption (P4.4).
    var showsSectionLabel: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            if showsSectionLabel {
                Text("Theme")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondary)
                    .accessibilityAddTraits(.isHeader)
            }

            HStack(spacing: AppSpacing.sm) {
                ForEach(ThemeCatalog.all) { theme in
                    ThemePickerOption(
                        theme: theme,
                        isSelected: selectedThemeId == theme.id,
                        onSelect: { selectedThemeId = theme.id }
                    )
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Animal theme")
        }
    }
}

// MARK: - Option

private struct ThemePickerOption: View {
    let theme: Theme
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: AppSpacing.xxs) {
                ThemeAsset.image(for: theme)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(theme.resolvedPrimaryColor)

                Text(theme.displayName)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.sm)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusSmall))
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusSmall)
                    .strokeBorder(
                        isSelected ? theme.resolvedAccentColor : AppColors.border,
                        lineWidth: isSelected ? 2 : AppSpacing.borderWeight
                    )
            )
        }
        .buttonStyle(.plain)
        .frame(minHeight: TouchTarget.minimum)
        .accessibilityLabel(ThemePickerAccessibility.label(for: theme, isSelected: isSelected))
        .accessibilityIdentifier("themeOption_\(theme.id)")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

// MARK: - Accessibility

enum ThemePickerAccessibility {
    static func label(for theme: Theme, isSelected: Bool) -> String {
        if isSelected {
            "\(theme.displayName), selected"
        } else {
            theme.displayName
        }
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Theme Picker") {
    ThemePickerPreview(initialThemeId: ThemeCatalog.defaultThemeID)
}

#Preview("Dogs Selected") {
    ThemePickerPreview(initialThemeId: "dogs")
}

private struct ThemePickerPreview: View {
    @State private var selectedThemeId: String

    init(initialThemeId: String) {
        _selectedThemeId = State(initialValue: initialThemeId)
    }

    var body: some View {
        ThemePicker(selectedThemeId: $selectedThemeId)
            .padding(AppSpacing.md)
            .background(AppColors.background)
    }
}
#endif
