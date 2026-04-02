import SwiftUI

/// Renders the swipe action buttons provided by the user directly.
///
/// - `SwipeActionButtonStyle` is applied automatically so any button
///   with a `.tint()` modifier gets the correct coloured background.
/// - The panel's natural (ideal) width is reported up to
///   `AwesomeSwipeModifier` via `SwipePanelWidthKey`.
/// - A `.simultaneousGesture` closes the row whenever any button is tapped,
///   without interfering with the button's own action.
struct SwipeActionsPanel<Content: View>: View {
    let content: Content
    let onActionTriggered: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            content
        }
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
        // Close the row after any button tap without consuming the tap
        .simultaneousGesture(TapGesture().onEnded { onActionTriggered() })
    }
}

