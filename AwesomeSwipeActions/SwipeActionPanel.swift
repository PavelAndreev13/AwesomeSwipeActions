import SwiftUI

/// Renders the swipe action buttons provided by the user.
///
/// - `SwipeActionButtonStyle` is applied automatically so any button with a
///   `.tint()` modifier gets the correct coloured background.
/// - The panel's natural (ideal) size along the swipe axis is reported up to
///   `AwesomeSwipeModifier` via `SwipePanelDimensionKey`.
/// - `swipeCloseAction` is injected via environment so every button style
///   (including user-supplied ones) can close the row after the tap fires.
/// - `swipeAxis` is injected via environment so `AwesomeSwipeButton` and
///   `awesomeButtonStyle(tint:)` can pick the correct fixed dimension.
struct SwipeActionsPanel<Content: View>: View {
    let content: Content
    let axis: Axis
    let onActionTriggered: @Sendable @MainActor () -> Void

    var body: some View {
        Group {
            switch axis {
            case .horizontal:
                HStack(spacing: 0) { content }
            case .vertical:
                VStack(spacing: 0) { content }
            }
        }
        // Inject close callback so button styles can read it via @Environment
        .environment(\.swipeCloseAction, onActionTriggered)
        // Inject axis so AwesomeSwipeButton picks the right cross-axis size
        .environment(\.swipeAxis, axis)
        // Apply swipe-action visual style to all child buttons
        .buttonStyle(SwipeActionButtonStyle())
        // Use the content's natural (ideal) size on the swipe axis only —
        // stretch the cross axis to fill the row.
        .fixedSize(horizontal: axis == .horizontal,
                   vertical: axis == .vertical)
        .frame(maxWidth: axis == .vertical ? .infinity : nil,
               maxHeight: axis == .horizontal ? .infinity : nil)
        // Report measured dimension on the swipe axis to AwesomeSwipeModifier
        .background {
            GeometryReader { geo in
                Color.clear
                    .preference(
                        key: SwipePanelDimensionKey.self,
                        value: axis == .horizontal ? geo.size.width : geo.size.height
                    )
            }
        }
    }
}
