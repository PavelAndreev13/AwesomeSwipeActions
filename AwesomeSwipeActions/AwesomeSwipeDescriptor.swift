import SwiftUI

// MARK: - Environment keys

private struct SwipeCloseActionKey: EnvironmentKey {
    static let defaultValue: (@Sendable @MainActor () -> Void)? = nil
}

private struct SwipeAxisKey: EnvironmentKey {
    /// Buttons used outside a swipe panel default to horizontal sizing —
    /// matches v1 behaviour for any consumer of `AwesomeSwipeButton` placed
    /// in a non-swipe context.
    static let defaultValue: Axis = .horizontal
}

extension EnvironmentValues {
    /// Closes the open swipe row. Injected by `SwipeActionsPanel` so that
    /// every button style (built-in or user-supplied) can close the row
    /// after its action fires.
    var swipeCloseAction: (@Sendable @MainActor () -> Void)? {
        get { self[SwipeCloseActionKey.self] }
        set { self[SwipeCloseActionKey.self] = newValue }
    }

    /// Swipe axis of the enclosing panel. `AwesomeSwipeButton` and
    /// `awesomeButtonStyle(tint:)` read this value to choose the correct
    /// fixed dimension (width for horizontal, height for vertical).
    var swipeAxis: Axis {
        get { self[SwipeAxisKey.self] }
        set { self[SwipeAxisKey.self] = newValue }
    }
}

// MARK: - Button style

/// Applied automatically to every button inside `awesomeSwipeActions`.
///
/// Gives each button a tinted background, a subtle press-opacity feedback,
/// and triggers the row close after the press is released — without
/// requiring users to apply any explicit style themselves.
struct SwipeActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        _SwipeActionButton(configuration: configuration)
    }
}

private struct _SwipeActionButton: View {
    let configuration: ButtonStyleConfiguration
    @Environment(\.swipeCloseAction) private var closeAction

    var body: some View {
        configuration.label
            .background(.tint)
            .opacity(configuration.isPressed ? 0.75 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                if oldValue && !newValue { closeAction?() }
            }
    }
}

// MARK: - Preference key

/// Reports the action panel's natural (measured) size along the swipe axis
/// up to `AwesomeSwipeModifier` via SwiftUI's preference system.
///
/// Each modifier instance has exactly one swipe axis, so a single
/// dimension-typed key covers both horizontal (width) and vertical (height)
/// use cases — there is no chance of mixed values up the same chain because
/// the modifier scopes its preference reads to its own subtree.
struct SwipePanelDimensionKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
