import SwiftUI

/// Visual pattern styles for colorblind-friendly region distinction (GDD accessibility).
///
/// Mapping (deterministic by `regionId % count`):
/// | regionId | Pattern            |
/// |----------|--------------------|
/// | 0        | Dots               |
/// | 1        | Horizontal stripes |
/// | 2        | Vertical stripes   |
/// | 3        | Diagonal stripes ↗ |
/// | 4        | Crosshatch         |
/// | 5        | Grid               |
/// | 6        | Chevrons           |
/// | 7        | Concentric circles |
enum RegionPatternStyle: CaseIterable, Equatable {
    case dots
    case horizontalStripes
    case verticalStripes
    case diagonalStripes
    case crosshatch
    case grid
    case chevrons
    case circles

    static func forRegion(_ regionId: Int) -> RegionPatternStyle {
        let styles = allCases
        guard !styles.isEmpty else { return .dots }
        return styles[regionId % styles.count]
    }
}

/// Low-opacity pattern overlay clipped to a single board cell.
struct RegionPattern: View {
    let regionId: Int
    var opacity: Double? = nil
    var highContrast: Bool = false

    private var style: RegionPatternStyle {
        RegionPatternStyle.forRegion(regionId)
    }

    private var resolvedOpacity: Double {
        opacity ?? (highContrast ? 0.35 : 0.2)
    }

    var body: some View {
        Canvas { context, size in
            RegionPatternRenderer.draw(
                style: style,
                in: &context,
                size: size,
                highContrast: highContrast
            )
        }
        .opacity(resolvedOpacity)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Drawing

enum RegionPatternRenderer {
    static func draw(
        style: RegionPatternStyle,
        in context: inout GraphicsContext,
        size: CGSize,
        highContrast: Bool = false
    ) {
        let stroke = AppColors.resolvedPatternOverlay(highContrast: highContrast)
        let width: CGFloat = highContrast ? 1.75 : 1.25
        switch style {
        case .dots:
            drawDots(in: &context, size: size, stroke: stroke)
        case .horizontalStripes:
            drawStripes(in: &context, size: size, vertical: false, stroke: stroke, lineWidth: width)
        case .verticalStripes:
            drawStripes(in: &context, size: size, vertical: true, stroke: stroke, lineWidth: width)
        case .diagonalStripes:
            drawDiagonalStripes(in: &context, size: size, reverse: false, stroke: stroke, lineWidth: width)
        case .crosshatch:
            drawDiagonalStripes(in: &context, size: size, reverse: false, stroke: stroke, lineWidth: width)
            drawDiagonalStripes(in: &context, size: size, reverse: true, stroke: stroke, lineWidth: width)
        case .grid:
            drawStripes(in: &context, size: size, vertical: false, stroke: stroke, lineWidth: width)
            drawStripes(in: &context, size: size, vertical: true, stroke: stroke, lineWidth: width)
        case .chevrons:
            drawChevrons(in: &context, size: size, stroke: stroke, lineWidth: width)
        case .circles:
            drawCircles(in: &context, size: size, stroke: stroke, lineWidth: width)
        }
    }

    private static let spacing: CGFloat = 8

    private static func drawDots(in context: inout GraphicsContext, size: CGSize, stroke: Color) {
        let radius: CGFloat = 1.6
        var y = spacing / 2
        while y < size.height {
            var x = spacing / 2
            while x < size.width {
                let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
                context.fill(Path(ellipseIn: rect), with: .color(stroke))
                x += spacing
            }
            y += spacing
        }
    }

    private static func drawStripes(
        in context: inout GraphicsContext,
        size: CGSize,
        vertical: Bool,
        stroke: Color,
        lineWidth: CGFloat
    ) {
        var path = Path()
        if vertical {
            var x = spacing
            while x < size.width {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                x += spacing
            }
        } else {
            var y = spacing
            while y < size.height {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                y += spacing
            }
        }
        context.stroke(path, with: .color(stroke), lineWidth: lineWidth)
    }

    private static func drawDiagonalStripes(
        in context: inout GraphicsContext,
        size: CGSize,
        reverse: Bool,
        stroke: Color,
        lineWidth: CGFloat
    ) {
        var path = Path()
        let extent = size.width + size.height
        var offset: CGFloat = -size.height
        while offset < extent {
            if reverse {
                path.move(to: CGPoint(x: offset, y: 0))
                path.addLine(to: CGPoint(x: offset - size.height, y: size.height))
            } else {
                path.move(to: CGPoint(x: offset, y: 0))
                path.addLine(to: CGPoint(x: offset + size.height, y: size.height))
            }
            offset += spacing
        }
        context.stroke(path, with: .color(stroke), lineWidth: lineWidth)
    }

    private static func drawChevrons(
        in context: inout GraphicsContext,
        size: CGSize,
        stroke: Color,
        lineWidth: CGFloat
    ) {
        var path = Path()
        let amplitude = spacing * 0.75
        var y = spacing
        while y < size.height {
            var x: CGFloat = 0
            var peakUp = true
            while x < size.width {
                let nextX = min(x + spacing, size.width)
                let midX = (x + nextX) / 2
                let peakY = peakUp ? y - amplitude : y + amplitude
                path.move(to: CGPoint(x: x, y: y))
                path.addLine(to: CGPoint(x: midX, y: peakY))
                path.addLine(to: CGPoint(x: nextX, y: y))
                x = nextX
                peakUp.toggle()
            }
            y += spacing * 1.5
        }
        context.stroke(path, with: .color(stroke), lineWidth: lineWidth)
    }

    private static func drawCircles(
        in context: inout GraphicsContext,
        size: CGSize,
        stroke: Color,
        lineWidth: CGFloat
    ) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let maxRadius = max(size.width, size.height) * 0.55
        var radius = spacing
        while radius < maxRadius {
            let rect = CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            )
            context.stroke(Path(ellipseIn: rect), with: .color(stroke), lineWidth: lineWidth)
            radius += spacing
        }
    }
}

// MARK: - Previews

#if DEBUG
#Preview("All Patterns") {
    ScrollView {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: AppSpacing.sm), count: 4),
            spacing: AppSpacing.sm
        ) {
            ForEach(0..<8, id: \.self) { regionId in
                VStack(spacing: AppSpacing.xxs) {
                    Text("Region \(regionId)")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.secondary)

                    ZStack {
                        AppColors.regionColor(at: regionId)
                        RegionPattern(regionId: regionId)
                    }
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusSmall))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusSmall)
                            .strokeBorder(AppColors.border, lineWidth: 1)
                    )
                }
            }
        }
        .padding(AppSpacing.md)
    }
    .background(AppColors.background)
}

#Preview("Legibility") {
    HStack(spacing: AppSpacing.md) {
        ZStack {
            AppColors.regionColor(at: 4)
            RegionPattern(regionId: 4)
            CellView(row: 0, col: 0, regionId: 4, state: .animal)
        }
        .frame(width: TouchTarget.minimum, height: TouchTarget.minimum)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusSmall))

        ZStack {
            AppColors.regionColor(at: 5)
            RegionPattern(regionId: 5)
            CellView(row: 0, col: 1, regionId: 5, state: .blocked)
        }
        .frame(width: TouchTarget.minimum, height: TouchTarget.minimum)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusSmall))
    }
    .padding(AppSpacing.md)
    .background(AppColors.background)
}
#endif
