import SwiftUI

// MARK: - Environment key

private struct SwipeCloseActionKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

extension EnvironmentValues {
    var swipeCloseAction: (() -> Void)? {
        get { self[SwipeCloseActionKey.self] }
        set { self[SwipeCloseActionKey.self] = newValue }
    }
}

// MARK: - Button style

/// Applied automatically to every button inside `awesomeSwipeActions`.
///
/// Gives each button a tinted background, white foreground,
/// and a subtle press-opacity feedback — without requiring users
/// to apply any explicit style themselves.
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

/// Reports the action panel's natural (measured) width up to `AwesomeSwipeModifier`
/// via SwiftUI's preference system.
struct SwipePanelWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

