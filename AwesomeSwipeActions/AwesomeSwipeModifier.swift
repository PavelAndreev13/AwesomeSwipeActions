import Combine
import SwiftUI

/// Core ViewModifier that implements the swipe-to-reveal-actions behaviour.
/// Applied to rows inside a `ScrollView` via `View.awesomeSwipeActions(...)`.
///
/// ## How panel width is measured
/// `SwipeActionsPanel` always lives in the ZStack (even when the row is closed)
/// and reports its natural width via `SwipePanelWidthKey`. This allows the
/// modifier to know the correct snap target before the user even starts swiping.
///
/// ## How the panel stays hidden
/// The panel is offset **outside** the row bounds and given `zIndex(1)` so it
/// renders on top of the content — never behind it. The ZStack is clipped, so
/// the panel is invisible until the content slides and brings it into view,
/// exactly like the native `List` swipe actions.
struct AwesomeSwipeModifier<ID: Hashable & Sendable, ActionContent: View>: ViewModifier {

    // MARK: - Configuration (immutable, injected once)

    let id: ID
    /// Held as a plain `let` — NOT @ObservedObject.
    /// Body never reads `coordinator.activeKey` directly, preventing cross-cell
    /// body invalidation. Coordination happens only in `.onReceive`.
    let coordinator: AwesomeSwipeCoordinator
    let edge: HorizontalEdge
    let actionContent: ActionContent

    // MARK: - Local state (isolated per cell — no cross-cell coupling)

    /// Horizontal content offset in points. Negative = trailing swipe; positive = leading.
    @State private var offset: CGFloat = 0
    /// Whether this row is currently snapped open.
    @State private var isSwiped = false
    /// Natural (ideal) width of the action panel, measured via SwipePanelWidthKey.
    /// Starts at `0` and is replaced by the real measured value on the first
    /// layout pass — typically before the user can interact with the row.
    @State private var panelWidth: CGFloat = 0
    /// Row width tracked via `.onGeometryChange` for rubber-band calculations.
    @State private var rowWidth: CGFloat = 0
    /// Angle decision made on the first drag sample; reset after gesture ends.
    /// `nil` = undecided, `true` = vertical (ignored), `false` = horizontal (active).
    @State private var gestureIsVertical: Bool? = nil

    // MARK: - Computed helpers

    /// Combines the row id with edge so leading and trailing modifiers on the
    /// same row receive distinct coordinator keys.
    private struct EdgeID: Hashable {
        let id: AnyHashable
        let edge: HorizontalEdge
    }

    /// Internal key used by the coordinator (id + edge). Never exposed publicly.
    private var anyKey: AnyHashable {
        AnyHashable(EdgeID(id: AnyHashable(id), edge: edge))
    }

    /// User-supplied id, exposed publicly via `coordinator.openRowID`.
    private var anyID: AnyHashable { AnyHashable(id) }

    // MARK: - Body

    func body(content: Content) -> some View {
        let alignment: Alignment = edge == .trailing ? .trailing : .leading

        ZStack(alignment: alignment) {

            // MARK: Row content
            content
                .offset(x: offset)
                .zIndex(0)
                // Track row width reactively (handles rotation, split-view, dynamic type)
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.width
                } action: { newWidth in
                    rowWidth = newWidth
                }
                // Tap overlay: closes row when user taps the content while open.
                // contentShape is offset to match the visual position so taps in the
                // revealed panel area pass through to the buttons below.
                .overlay {
                    if isSwiped {
                        Color.clear
                            .contentShape(Rectangle().offset(x: offset))
                            .onTapGesture { closeAnimated() }
                    }
                }
                .contentShape(Rectangle().offset(x: offset))
                .simultaneousGesture(swipeGesture)

            // MARK: Action panel
            // Positioned outside the row bounds via offset, slides in with the content.
            // zIndex(1) keeps it above the content so semi-transparent rows are not an issue.
            SwipeActionsPanel(content: actionContent, onActionTriggered: { closeAnimated() })
                .offset(x: (edge == .trailing ? panelWidth : -panelWidth) + offset)
                .zIndex(1)
                .allowsHitTesting(offset != 0)
        }
        .clipped()
        // Expose buttons inside the panel as VoiceOver rotor actions, matching
        // the accessibility behaviour of the native `swipeActions` modifier.
        .accessibilityActions { actionContent }
        // Read the panel's natural width reported by SwipeActionsPanel
        .onPreferenceChange(SwipePanelWidthKey.self) { w in
            Task { @MainActor in
                if w > 0 { panelWidth = w }
            }
        }
        // Reset the preference so it doesn't leak to a parent modifier
        // when two awesomeSwipeActions are stacked on the same row.
        .transformPreference(SwipePanelWidthKey.self) { $0 = 0 }
        // React to coordinator changes imperatively (NOT during body evaluation)
        .onReceive(coordinator.$activeKey) { newActiveKey in
            guard isSwiped, newActiveKey != anyKey else { return }
            closeAnimated()
        }
    }

    // MARK: - Gesture

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged(handleDragChanged)
            .onEnded(handleDragEnded)
    }

    private func handleDragChanged(_ value: DragGesture.Value) {
        // Determine gesture axis on the first sample and lock it for the duration
        if gestureIsVertical == nil {
            let dx = abs(value.translation.width)
            let dy = abs(value.translation.height)
            // Angles > 50° from horizontal are treated as vertical scroll
            gestureIsVertical = atan2(dy, dx) * 180 / .pi > 50

            // If horizontal but the wrong direction for this edge (and the row
            // is not already open), mark as ignored so the other edge's modifier
            // that is stacked on the same row can handle it instead.
            if gestureIsVertical == false && !isSwiped {
                let isWrongDirection =
                    (edge == .trailing && value.translation.width > 0) ||
                    (edge == .leading  && value.translation.width < 0)
                if isWrongDirection {
                    gestureIsVertical = true
                }
            }
        }

        guard gestureIsVertical == false else { return }
        // Wait for the panel to be measured before responding to drags. The
        // panel sits in the ZStack from the start, so this typically clears
        // on the first layout pass.
        guard panelWidth > 0 else { return }

        // Signal to coordinator that this cell is the active one
        coordinator._open(anyKey, userID: anyID)

        // Translation relative to the current rest position (open or closed)
        let baseOffset: CGFloat = isSwiped
            ? (edge == .trailing ? -panelWidth : panelWidth)
            : 0
        let raw = value.translation.width + baseOffset

        // Apply rubber banding when dragging past the panel boundary
        switch edge {
        case .trailing:
            if raw > 0 {
                // Wrong direction from closed: light resistance
                offset = rubberBand(raw, dimension: rowWidth)
            } else if raw < -panelWidth {
                let excess = abs(raw) - panelWidth
                offset = -(panelWidth + rubberBand(excess, dimension: rowWidth))
            } else {
                offset = raw
            }
        case .leading:
            if raw < 0 {
                offset = -rubberBand(abs(raw), dimension: rowWidth)
            } else if raw > panelWidth {
                let excess = raw - panelWidth
                offset = panelWidth + rubberBand(excess, dimension: rowWidth)
            } else {
                offset = raw
            }
        @unknown default:
            offset = raw
        }
    }

    private func handleDragEnded(_ value: DragGesture.Value) {
        defer { gestureIsVertical = nil }
        guard gestureIsVertical == false else { return }

        let magnitude = abs(offset)
        let velocityX = value.predictedEndTranslation.width - value.translation.width
        let isCorrectDirection: Bool

        switch edge {
        case .trailing: isCorrectDirection = value.translation.width < 0
        case .leading:  isCorrectDirection = value.translation.width > 0
        @unknown default: isCorrectDirection = false
        }

        // Fast swipe in the correct direction opens regardless of position
        let isHighVelocity = abs(velocityX) > 300 && isCorrectDirection

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if isHighVelocity || (magnitude > panelWidth / 2 && isCorrectDirection) {
                openSnapped()
            } else {
                closeSnapped()
            }
        }
    }

    // MARK: - State transitions

    private func openSnapped() {
        switch edge {
        case .trailing: offset = -panelWidth
        case .leading:  offset = panelWidth
        @unknown default: offset = 0
        }
        isSwiped = true
        coordinator._open(anyKey, userID: anyID)
    }

    private func closeSnapped() {
        offset = 0
        isSwiped = false
        coordinator._close(anyKey)
    }

    private func closeAnimated() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
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
