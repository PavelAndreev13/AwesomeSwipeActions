import SwiftUI

/// Renders the swipe action buttons provided by the user directly.
///
/// - `SwipeActionButtonStyle` is applied automatically so any button
///   with a `.tint()` modifier gets the correct coloured background.
/// - The panel's natural (ideal) width is reported up to
///   `AwesomeSwipeModifier` via `SwipePanelWidthKey`.
/// - `swipeCloseAction` is injected via environment so every button style
///   (including user-supplied ones) can close the row after the tap fires.
struct SwipeActionsPanel<Content: View>: View {
    let content: Content
    let onActionTriggered: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            content
        }
        // Inject close callback so button styles can read it via @Environment
        .environment(\.swipeCloseAction, onActionTriggered)
        // Apply swipe-action visual style to all child buttons
        .buttonStyle(SwipeActionButtonStyle())
        // Use the content's natural (ideal) horizontal size so the
        // GeometryReader below measures the real panel width
        .fixedSize(horizontal: true, vertical: false)
        .frame(maxHeight: .infinity)
        // Report measured width to AwesomeSwipeModifier
        .background {
            GeometryReader { geo in
                Color.clear
                    .preference(key: SwipePanelWidthKey.self, value: geo.size.width)
            }
        }
    }
}

