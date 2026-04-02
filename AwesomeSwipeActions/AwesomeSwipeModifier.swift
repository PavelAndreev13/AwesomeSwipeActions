import Combine
import SwiftUI

/// Core ViewModifier that implements the swipe-to-reveal-actions behaviour.
/// Applied to rows inside a `ScrollView` via `View.awesomeSwipeActions(...)`.
///
/// ## How panel width is measured
/// `SwipeActionsPanel` always lives in the ZStack (even when the row is closed)
/// and reports its natural width via `SwipePanelWidthKey`. This allows the
/// modifier to know the correct snap target before the user even starts swiping,
/// with zero cost: when the row is closed the panel is fully covered by the
/// content layer and receives no hit tests.
struct AwesomeSwipeModifier<ID: Hashable, ActionContent: View>: ViewModifier {

    // MARK: - Configuration (immutable, injected once)

    let id: ID
    /// Held as a plain `let` — NOT @ObservedObject.
    /// Body never reads `coordinator.activeID` directly, preventing cross-cell
    /// body invalidation. Coordination happens only in `.onReceive`.
    let coordinator: AwesomeSwipeCoordinator
    let edge: SwipeActionEdge
    let actionContent: ActionContent

    // MARK: - Local state (isolated per cell — no cross-cell coupling)

    /// Horizontal content offset in points. Negative = trailing swipe; positive = leading.
    @State private var offset: CGFloat = 0
    /// Whether this row is currently snapped open.
    @State private var isSwiped = false
    /// Natural (ideal) width of the action panel, measured via SwipePanelWidthKey.
    /// Defaults to 74 (one button) as a safe pre-measurement fallback.
    @State private var panelWidth: CGFloat = 74
    /// Row width captured via GeometryReader for rubber-band calculations.
    @State private var rowWidth: CGFloat = 0
    /// Angle decision made on the first drag sample; reset after gesture ends.
    /// `nil` = undecided, `true` = vertical (ignored), `false` = horizontal (active).
    @State private var gestureIsVertical: Bool? = nil

    // MARK: - Computed helpers

    private var anyID: AnyHashable { AnyHashable(id) }

    // MARK: - Body

    func body(content: Content) -> some View {
        let alignment: Alignment = edge == .trailing ? .trailing : .leading

        ZStack(alignment: alignment) {

            // MARK: Action panel
            // Always present so SwipePanelWidthKey is reported immediately on first render.
            // When offset == 0 the panel is fully covered by the content layer above it
            // and receives no hit tests — effectively free.
            SwipeActionsPanel(content: actionContent, onActionTriggered: closeAnimated)
                .allowsHitTesting(offset != 0)

            // MARK: Row content
            content
                .offset(x: offset)
                // Capture row width once on appear
                .background {
                    GeometryReader { geo in
                        Color.clear.onAppear { rowWidth = geo.size.width }
                    }
                }
                // Tap overlay: closes row when user taps the content while open
                .overlay {
                    if isSwiped {
                        Color.clear
                            .contentShape(.rect)
                            .onTapGesture { closeAnimated() }
                    }
                }
                .gesture(swipeGesture)
        }
        // Read the panel's natural width reported by SwipeActionsPanel
        .onPreferenceChange(SwipePanelWidthKey.self) { w in
            if w > 0 { panelWidth = w }
        }
        // React to coordinator changes imperatively (NOT during body evaluation)
        .onReceive(coordinator.$activeID) { newActiveID in
            guard isSwiped, newActiveID != anyID else { return }
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
        }

        guard gestureIsVertical == false else { return }

        // Signal to coordinator that this cell is the active one
        coordinator.open(anyID)

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
        offset = edge == .trailing ? -panelWidth : panelWidth
        isSwiped = true
        coordinator.open(anyID)
    }

    private func closeSnapped() {
        offset = 0
        isSwiped = false
        coordinator.close(anyID)
    }

    private func closeAnimated() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            closeSnapped()
        }
    }

    // MARK: - Rubber band

    /// Standard iOS rubber-band formula: f(x) = (1 - 1 / ((x·c/d) + 1)) · d
    /// Provides progressively increasing resistance past the boundary.
    private func rubberBand(_ offset: CGFloat, dimension: CGFloat, constant: CGFloat = 0.55) -> CGFloat {
        guard dimension > 0 else { return offset }
        return (1.0 - 1.0 / ((offset * constant / dimension) + 1.0)) * dimension
    }
}

