import SwiftUI

/// Resolves a swipe `Edge` into a small set of axis-parameterised primitives
/// that the modifier and panel use to express their geometry without
/// branching on the edge inside every gesture sample.
///
/// Constructed once per modifier instance from the user-supplied `Edge`.
/// All four cases of `Edge` (`.top`, `.leading`, `.bottom`, `.trailing`) map
/// deterministically to a single `axis` plus an `openSign` that controls the
/// rest of the geometry:
///
/// | Edge | axis | openSign | panelAlignment | offset application |
/// |---|---|---|---|---|
/// | `.leading` | `.horizontal` | +1 | `.leading` | `.offset(x:)` |
/// | `.trailing` | `.horizontal` | −1 | `.trailing` | `.offset(x:)` |
/// | `.top` | `.vertical` | +1 | `.top` | `.offset(y:)` |
/// | `.bottom` | `.vertical` | −1 | `.bottom` | `.offset(y:)` |
///
/// `openSign` is the sign of the offset value when the row is fully open —
/// `.leading` and `.top` slide the content **toward** the positive axis
/// (so the panel comes into view from the negative side), while `.trailing`
/// and `.bottom` do the opposite. Most callers use `openSign` to decide the
/// "snap target" offset and to detect whether the user dragged in the open
/// direction or the close direction.
struct SwipeAxisStrategy: Hashable {

    let edge: Edge

    var axis: Axis {
        switch edge {
        case .leading, .trailing: .horizontal
        case .top, .bottom:       .vertical
        }
    }

    /// `+1` when dragging in the "open" direction is positive on the relevant
    /// axis (`.leading`, `.top`), `−1` when it is negative (`.trailing`,
    /// `.bottom`).
    var openSign: CGFloat {
        switch edge {
        case .leading, .top:      +1
        case .trailing, .bottom:  -1
        }
    }

    /// SwiftUI alignment that pins the action panel to the correct edge of
    /// the row's `ZStack`.
    var panelAlignment: Alignment {
        switch edge {
        case .leading:  .leading
        case .trailing: .trailing
        case .top:      .top
        case .bottom:   .bottom
        }
    }

    // MARK: - DragGesture component selection

    /// Reads the relevant scalar component of a drag's translation.
    func translation(_ value: DragGesture.Value) -> CGFloat {
        dimension(of: value.translation)
    }

    /// Reads the relevant scalar component of a drag's predicted-end translation.
    /// Used to derive an end-of-gesture velocity scalar.
    func predictedEndTranslation(_ value: DragGesture.Value) -> CGFloat {
        dimension(of: value.predictedEndTranslation)
    }

    // MARK: - Cross-axis filtering

    /// Returns `true` when the drag is more than `thresholdDegrees` off the
    /// strategy's axis — meaning it should be treated as a cross-axis gesture
    /// and ignored (let the enclosing scroll view take over).
    ///
    /// For horizontal strategies this triggers when the gesture is too
    /// vertical; for vertical strategies, when it is too horizontal. The
    /// formula inverts naturally based on `axis`.
    func isCrossAxisGesture(_ value: DragGesture.Value, thresholdDegrees: CGFloat = 50) -> Bool {
        isCrossAxisGesture(translation: value.translation, thresholdDegrees: thresholdDegrees)
    }

    /// Pure-arithmetic overload used by tests (a `DragGesture.Value` cannot be
    /// constructed outside SwiftUI's gesture pipeline).
    func isCrossAxisGesture(translation: CGSize, thresholdDegrees: CGFloat = 50) -> Bool {
        let dx = abs(translation.width)
        let dy = abs(translation.height)
        let angle: CGFloat
        switch axis {
        case .horizontal:
            // angle from the horizontal axis — large values are vertical-y
            angle = atan2(dy, dx) * 180 / .pi
        case .vertical:
            // angle from the vertical axis — large values are horizontal-y
            angle = atan2(dx, dy) * 180 / .pi
        }
        return angle > thresholdDegrees
    }

    // MARK: - View helpers

    /// Applies an axis-correct `.offset` to the given view.
    @ViewBuilder
    func offsetView<V: View>(_ view: V, by amount: CGFloat) -> some View {
        switch axis {
        case .horizontal: view.offset(x: amount)
        case .vertical:   view.offset(y: amount)
        }
    }

    /// Applies an axis-correct content-shape offset (used for the tap overlay
    /// and gesture-area shape inside the modifier).
    @ViewBuilder
    func contentShapeOffsetView<V: View>(_ view: V, by amount: CGFloat) -> some View {
        switch axis {
        case .horizontal: view.contentShape(Rectangle().offset(x: amount))
        case .vertical:   view.contentShape(Rectangle().offset(y: amount))
        }
    }

    /// Selects the relevant size component from a `CGSize`.
    func dimension(of size: CGSize) -> CGFloat {
        axis == .horizontal ? size.width : size.height
    }
}
