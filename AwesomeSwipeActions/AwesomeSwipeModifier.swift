import Combine
import SwiftUI

/// Core ViewModifier that implements the swipe-to-reveal-actions behaviour.
/// Applied to rows inside a `ScrollView` via `View.awesomeSwipeActions(...)`.
///
/// ## How panel size is measured
/// `SwipeActionsPanel` always lives in the ZStack (even when the row is closed)
/// and reports its natural size along the swipe axis via
/// `SwipePanelDimensionKey`. This allows the modifier to know the correct snap
/// target before the user even starts swiping.
///
/// ## How the panel stays hidden
/// The panel is offset **outside** the row bounds and given `zIndex(1)` so it
/// renders on top of the content — never behind it. The ZStack is clipped, so
/// the panel is invisible until the content slides and brings it into view,
/// exactly like the native `List` swipe actions.
///
/// ## Vertical edges
/// All geometry is mediated through ``SwipeAxisStrategy`` so the same
/// implementation works for horizontal (`.leading`/`.trailing`) and vertical
/// (`.top`/`.bottom`) edges. The only axis-conditional spots in this file
/// are the `.offset(x:)` / `.offset(y:)` choice and the `proxy.size.width` /
/// `proxy.size.height` choice, both routed through `strategy`.
struct AwesomeSwipeModifier<ID: Hashable & Sendable, ActionContent: View>: ViewModifier {

    // MARK: - Configuration (immutable, injected once)

    let id: ID
    /// Held as a plain `let` — NOT @ObservedObject.
    /// Body never reads `coordinator.activeKey` directly, preventing cross-cell
    /// body invalidation. Coordination happens only in `.onReceive`.
    let coordinator: AwesomeSwipeCoordinator
    let edge: Edge
    /// Optional explicit hint about the axis of the enclosing scroll view.
    /// `nil` = no validation. When set, in DEBUG builds the modifier emits a
    /// one-time console warning if it matches the swipe edge's axis (a
    /// well-known unsupported combination because the swipe gesture and the
    /// scroll gesture both want the same drag).
    let containerAxis: Axis?
    let actionContent: ActionContent

    /// Concentrates all axis-conditional decisions in one place. Constructed
    /// once on demand from `edge`.
    private var strategy: SwipeAxisStrategy { SwipeAxisStrategy(edge: edge) }

    // MARK: - Local state (isolated per cell — no cross-cell coupling)

    /// Content offset in points along the swipe axis. The sign convention is
    /// shared between horizontal and vertical: an offset whose sign matches
    /// `strategy.openSign × panelDimension` is fully open.
    @State private var offset: CGFloat = 0
    /// Whether this row is currently snapped open.
    @State private var isSwiped = false
    /// Natural (ideal) size of the action panel along the swipe axis,
    /// measured via `SwipePanelDimensionKey`. Starts at `0` and is replaced
    /// by the real measured value on the first layout pass — typically before
    /// the user can interact with the row.
    @State private var panelDimension: CGFloat = 0
    /// Row size along the swipe axis, tracked via `.onGeometryChange` for
    /// rubber-band calculations.
    @State private var rowDimension: CGFloat = 0
    /// Cross-axis decision made on the first drag sample; reset after gesture
    /// ends. `nil` = undecided, `true` = cross-axis (ignored, scroll wins),
    /// `false` = on-axis (active).
    @State private var gestureIsCrossAxis: Bool? = nil
    /// Single-shot flag so axis-conflict console hints are emitted only once
    /// per modifier instance, even if `onAppear` fires multiple times due to
    /// scroll-recycling or layout updates. DEBUG-only.
    @State private var didEmitAxisWarning = false

    // MARK: - Accessibility

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Snap animation honoring `accessibilityReduceMotion` — falls back to a
    /// short linear curve when reduced-motion is requested.
    private var snapAnimation: Animation {
        reduceMotion
            ? .linear(duration: 0.15)
            : .spring(response: 0.3, dampingFraction: 0.8)
    }

    // MARK: - Computed helpers

    /// Internal key used by the coordinator (id + edge). Never exposed
    /// publicly. Built from the shared internal ``SwipeEdgeKey`` type so
    /// that ``AwesomeSwipeCoordinator/open(id:from:)`` can construct the
    /// same shape from outside the modifier.
    private var anyKey: AnyHashable {
        AnyHashable(SwipeEdgeKey(id: AnyHashable(id), edge: edge))
    }

    /// User-supplied id, exposed publicly via `coordinator.openRowID`.
    private var anyID: AnyHashable { AnyHashable(id) }

    // MARK: - Body

    func body(content: Content) -> some View {
        // Capture axis as a plain `Sendable` value so `.onGeometryChange`'s
        // closures don't reach back into the @MainActor-isolated modifier.
        let axis = strategy.axis

        return ZStack(alignment: strategy.panelAlignment) {

            // MARK: Row content
            strategy.offsetView(content, by: offset)
                .zIndex(0)
                // Track the row's swipe-axis size reactively
                .onGeometryChange(for: CGFloat.self) { proxy in
                    axis == .horizontal ? proxy.size.width : proxy.size.height
                } action: { newDimension in
                    rowDimension = newDimension
                }
                // Tap overlay: closes row when user taps the content while open.
                // contentShape is offset along the swipe axis to match the visual
                // position so taps in the revealed panel area pass through to the
                // buttons below.
                .overlay {
                    if isSwiped {
                        strategy.contentShapeOffsetView(Color.clear, by: offset)
                            .onTapGesture { closeAnimated() }
                    }
                }
                .modifier(ContentShapeOffsetModifier(strategy: strategy, amount: offset))
                .simultaneousGesture(swipeGesture)

            // MARK: Action panel
            // Positioned outside the row bounds via offset, slides in with the content.
            // zIndex(1) keeps it above the content so semi-transparent rows are not an issue.
            strategy.offsetView(
                SwipeActionsPanel(
                    content: actionContent,
                    axis: strategy.axis,
                    onActionTriggered: { closeAnimated() }
                ),
                by: strategy.openSign * panelDimension * -1 + offset
            )
            .zIndex(1)
            .allowsHitTesting(offset != 0)
        }
        .clipped()
        // Expose buttons inside the panel as VoiceOver rotor actions, matching
        // the accessibility behaviour of the native `swipeActions` modifier.
        .accessibilityActions { actionContent }
        // Read the panel's natural size along the swipe axis
        .onPreferenceChange(SwipePanelDimensionKey.self) { d in
            Task { @MainActor in
                if d > 0 { panelDimension = d }
            }
        }
        // Reset the preference so it doesn't leak to a parent modifier
        // when two awesomeSwipeActions are stacked on the same row.
        .transformPreference(SwipePanelDimensionKey.self) { $0 = 0 }
        // React to coordinator changes imperatively (NOT during body evaluation)
        .onReceive(coordinator.$activeKey) { newActiveKey in
            if newActiveKey == anyKey {
                if !isSwiped {
                    // Externally requested open — animate this row open.
                    withAnimation(snapAnimation) { openSnapped() }
                }
            } else if isSwiped {
                // Some other row took over (or nil). Close ours.
                closeAnimated()
            }
        }
        .onAppear { warnIfAxisConflictIfNeeded() }
    }

    // MARK: - Axis conflict diagnostics (DEBUG-only)

    /// Emits a one-time console warning when the modifier is configured in a
    /// known unsupported way:
    /// - **Case A:** `containerAxis` was provided and equals the swipe-edge
    ///   axis (e.g. `from: .top` + `containerAxis: .vertical`). Both gestures
    ///   want the same drag; scroll and swipe will fight.
    /// - **Case B:** `containerAxis` was *not* provided and the swipe edge is
    ///   vertical (`.top` / `.bottom`). Vertical edges are the rarer, more
    ///   error-prone variant — print a generic hint reminding the developer
    ///   to verify the enclosing scroll axis.
    ///
    /// All output is gated by `#if DEBUG` and absent in release builds.
    private func warnIfAxisConflictIfNeeded() {
        #if DEBUG
        guard !didEmitAxisWarning else { return }
        let edgeAxis = strategy.axis

        if let container = containerAxis, container == edgeAxis {
            didEmitAxisWarning = true
            print("""
            [AwesomeSwipeActions] axis conflict on row id=\(id):
              edge .\(edge) has axis .\(edgeAxis)
              containerAxis is also .\(container)
            Vertical edges (.top/.bottom) require horizontal-scrolling or \
            non-scrolling containers; horizontal edges (.leading/.trailing) \
            require vertical-scrolling or non-scrolling containers. Place \
            this modifier in a perpendicular-axis container, or use a \
            different edge. See: Choosing-Edges DocC article.
            """)
            return
        }

        if containerAxis == nil, edgeAxis == .vertical {
            didEmitAxisWarning = true
            print("""
            [AwesomeSwipeActions] hint on row id=\(id): vertical edge .\(edge) \
            works only inside a horizontal-scrolling container or a \
            non-scrolling layout. Inside a vertical ScrollView the swipe \
            gesture conflicts with scroll. Add `containerAxis: .horizontal` \
            to silence this hint, or switch to .leading/.trailing for \
            vertical lists.
            """)
        }
        #endif
    }

    // MARK: - Gesture

    /// Minimum drag distance before our gesture fires. On iOS 26 Apple raised
    /// `ScrollView`'s internal pan threshold and changed simultaneous-gesture
    /// resolution — a 10pt threshold here causes our `DragGesture` to win
    /// against the scroll pan, so the list refuses to scroll vertically. Bump
    /// to 30pt only on iOS 26+ so the ScrollView's scroll pan starts first;
    /// keeps iOS 17/18 untouched (still 10pt, where the original snappy feel
    /// is correct).
    private var dragMinimumDistance: CGFloat {
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
            return 30
        } else {
            return 10
        }
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: dragMinimumDistance)
            .onChanged(handleDragChanged)
            .onEnded(handleDragEnded)
    }

    private func handleDragChanged(_ value: DragGesture.Value) {
        // Determine whether this drag is on-axis or cross-axis on the first
        // sample and lock the decision for the rest of the gesture.
        if gestureIsCrossAxis == nil {
            gestureIsCrossAxis = strategy.isCrossAxisGesture(value)

            // If on-axis but the wrong direction for this edge (and the row
            // is not already open), mark as ignored so a stacked-edge modifier
            // (e.g. another edge on the same row) can handle it instead.
            if gestureIsCrossAxis == false && !isSwiped {
                let signedTranslation = strategy.translation(value) * strategy.openSign
                if signedTranslation < 0 {
                    gestureIsCrossAxis = true
                }
            }
        }

        guard gestureIsCrossAxis == false else { return }
        // Wait for the panel to be measured before responding to drags. The
        // panel sits in the ZStack from the start, so this typically clears
        // on the first layout pass.
        guard panelDimension > 0 else { return }

        // Signal to coordinator that this cell is the active one
        coordinator._open(anyKey, userID: anyID)

        // Translation relative to the current rest position (open or closed),
        // expressed in raw axis coordinates.
        let baseOffset: CGFloat = isSwiped ? strategy.openSign * panelDimension : 0
        let raw = strategy.translation(value) + baseOffset

        // Convert into "open distance": positive = more open, negative = past closed.
        let signedRaw = raw * strategy.openSign

        if signedRaw < 0 {
            // Wrong direction from closed: light resistance.
            offset = -rubberBand(abs(signedRaw), dimension: rowDimension) * strategy.openSign
        } else if signedRaw > panelDimension {
            // Past the open boundary: rubber-band the excess.
            let excess = signedRaw - panelDimension
            offset = (panelDimension + rubberBand(excess, dimension: rowDimension)) * strategy.openSign
        } else {
            offset = raw
        }
    }

    private func handleDragEnded(_ value: DragGesture.Value) {
        defer { gestureIsCrossAxis = nil }
        guard gestureIsCrossAxis == false else { return }

        let magnitude = abs(offset)
        let signedTranslation = strategy.translation(value) * strategy.openSign
        let isCorrectDirection = signedTranslation > 0
        let velocityScalar = strategy.predictedEndTranslation(value) - strategy.translation(value)

        // Fast swipe in the correct direction opens regardless of position
        let isHighVelocity = abs(velocityScalar) > 300 && isCorrectDirection

        withAnimation(snapAnimation) {
            if isHighVelocity || (magnitude > panelDimension / 2 && isCorrectDirection) {
                openSnapped()
            } else {
                closeSnapped()
            }
        }
    }

    // MARK: - State transitions

    private func openSnapped() {
        offset = strategy.openSign * panelDimension
        isSwiped = true
        coordinator._open(anyKey, userID: anyID)
    }

    private func closeSnapped() {
        offset = 0
        isSwiped = false
        coordinator._close(anyKey)
    }

    private func closeAnimated() {
        withAnimation(snapAnimation) {
            closeSnapped()
        }
    }

    // MARK: - Rubber band

    /// Standard iOS rubber-band formula: `f(x) = (1 - 1 / ((x·c/d) + 1)) · d`.
    /// Provides progressively increasing resistance past the boundary.
    /// Internal so the helper is testable.
    func rubberBand(_ offset: CGFloat, dimension: CGFloat, constant: CGFloat = 0.55) -> CGFloat {
        guard dimension > 0 else { return offset }
        return (1.0 - 1.0 / ((offset * constant / dimension) + 1.0)) * dimension
    }
}

// MARK: - Helpers

/// Applies an axis-correct content-shape offset to a view. Used for the
/// modifier's gesture-target shape so taps land on the visually-shifted
/// content rather than its layout rectangle.
private struct ContentShapeOffsetModifier: ViewModifier {
    let strategy: SwipeAxisStrategy
    let amount: CGFloat

    func body(content: Content) -> some View {
        switch strategy.axis {
        case .horizontal:
            content.contentShape(Rectangle().offset(x: amount))
        case .vertical:
            content.contentShape(Rectangle().offset(y: amount))
        }
    }
}
