import SwiftUI

/// A single board cell. Presentation-only — no `GameSession` dependency.
///
/// Renders `CellState` (empty, blocked, animal) with optional selection and violation
/// overlays. Region background color is supplied by the parent (`BoardView`).
///
/// SwiftUI previews at the bottom demonstrate all visual states for design review.
struct CellView: View {
    let row: Int
    let col: Int
    let regionId: Int
    let state: CellState
    var isSelected: Bool = false
    var isViolating: Bool = false
    var animalIcon: Image = ThemeAsset.image(for: "frogs")
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            cellContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(minWidth: TouchTarget.minimum, minHeight: TouchTarget.minimum)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityLabel(CellViewAccessibility.label(
            row: row,
            col: col,
            regionId: regionId,
            state: state,
            isViolating: isViolating
        ))
        .accessibilityAddTraits(.isButton)
    }

    private var cellContent: some View {
        ZStack {
            if isViolating {
                RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusSmall)
                    .fill(AppColors.error.opacity(0.18))
            }

            stateContent

            RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusSmall)
                .strokeBorder(borderColor, lineWidth: borderWidth)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    @ViewBuilder
    private var stateContent: some View {
        switch state {
        case .empty:
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityHidden(true)
        case .blocked:
            BlockedMark()
        case .animal:
            animalIcon
                .resizable()
                .scaledToFit()
                .foregroundStyle(AppColors.primary)
                .padding(AppSpacing.xs)
                .accessibilityHidden(true)
        }
    }

    private var borderColor: Color {
        if isViolating {
            return AppColors.error
        }
        if isSelected {
            return AppColors.accent
        }
        return .clear
    }

    private var borderWidth: CGFloat {
        (isSelected || isViolating) ? 2 : 0
    }
}

// MARK: - Blocked X mark

/// Diagonal X stroke — shape-based, not color alone (GDD accessibility).
private struct BlockedMark: View {
    var body: some View {
        GeometryReader { geometry in
            let inset = geometry.size.width * 0.22
            let size = geometry.size

            Path { path in
                path.move(to: CGPoint(x: inset, y: inset))
                path.addLine(to: CGPoint(x: size.width - inset, y: size.height - inset))
                path.move(to: CGPoint(x: size.width - inset, y: inset))
                path.addLine(to: CGPoint(x: inset, y: size.height - inset))
            }
            .stroke(
                AppColors.primary,
                style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
            )
        }
        .padding(AppSpacing.xs)
        .accessibilityHidden(true)
    }
}

// MARK: - Accessibility

enum CellViewAccessibility {
    static func label(
        row: Int,
        col: Int,
        regionId: Int,
        state: CellState,
        isViolating: Bool
    ) -> String {
        let position = "Row \(row + 1), Column \(col + 1), Region \(regionId)"
        let stateName = stateLabel(for: state, isViolating: isViolating)
        return "\(position), \(stateName)"
    }

    private static func stateLabel(for state: CellState, isViolating: Bool) -> String {
        let base: String
        switch state {
        case .empty: base = "empty"
        case .blocked: base = "blocked"
        case .animal: base = "animal"
        }
        return isViolating ? "\(base), violation" : base
    }
}

// MARK: - Previews

#if DEBUG
private struct CellPreviewTile: View {
    let title: String
    let row: Int
    let col: Int
    let regionId: Int
    let state: CellState
    var isSelected: Bool = false
    var isViolating: Bool = false

    var body: some View {
        VStack(spacing: AppSpacing.xxs) {
            Text(title)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            CellView(
                row: row,
                col: col,
                regionId: regionId,
                state: state,
                isSelected: isSelected,
                isViolating: isViolating,
                animalIcon: ThemeAsset.image(for: "frogs")
            )
            .frame(width: TouchTarget.minimum, height: TouchTarget.minimum)
            .background(AppColors.regionColor(at: regionId))
        }
    }
}

#Preview("Cell States") {
    ScrollView {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: AppSpacing.sm), count: 3),
            spacing: AppSpacing.md
        ) {
            CellPreviewTile(title: "Empty", row: 0, col: 0, regionId: 0, state: .empty)
            CellPreviewTile(title: "Blocked", row: 0, col: 1, regionId: 1, state: .blocked)
            CellPreviewTile(title: "Animal", row: 0, col: 2, regionId: 2, state: .animal)

            CellPreviewTile(title: "Selected", row: 1, col: 0, regionId: 3, state: .empty, isSelected: true)
            CellPreviewTile(
                title: "Violation",
                row: 1,
                col: 1,
                regionId: 4,
                state: .animal,
                isViolating: true
            )
            CellPreviewTile(
                title: "Sel + Violation",
                row: 1,
                col: 2,
                regionId: 5,
                state: .blocked,
                isSelected: true,
                isViolating: true
            )
        }
        .padding(AppSpacing.md)
    }
    .background(AppColors.background)
}

#Preview("Region Contrast") {
    ScrollView {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: AppSpacing.xs), count: 4),
            spacing: AppSpacing.xs
        ) {
            ForEach(0..<8, id: \.self) { regionId in
                CellView(
                    row: 0,
                    col: regionId,
                    regionId: regionId,
                    state: regionId.isMultiple(of: 2) ? .blocked : .animal,
                    animalIcon: ThemeAsset.image(for: "frogs")
                )
                .frame(width: TouchTarget.minimum, height: TouchTarget.minimum)
                .background(AppColors.regionColor(at: regionId))
            }
        }
        .padding(AppSpacing.md)
    }
    .background(AppColors.background)
}
#endif
