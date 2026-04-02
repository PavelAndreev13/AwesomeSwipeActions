import SwiftUI

/// A convenience button for use inside `awesomeSwipeActions`.
///
/// `AwesomeSwipeButton` is simply a pre-styled `Button`: it sets a fixed
/// width, white foreground, and the correct tint. Using it is optional —
/// any standard SwiftUI `Button` with a `.tint()` modifier works just as well:
///
/// ```swift
/// // Option A — convenience wrapper (recommended)
/// .awesomeSwipeActions(id: item.id, coordinator: coordinator) {
///     AwesomeSwipeButton(tint: .blue, systemImage: "pencil") { edit(item) }
///     AwesomeSwipeButton(tint: .red, role: .destructive, systemImage: "trash") { delete(item) }
/// }
///
/// // Option B — standard SwiftUI Button (full control)
/// .awesomeSwipeActions(id: item.id, coordinator: coordinator) {
///     Button { edit(item) } label: {
///         Label("Edit", systemImage: "pencil")
///             .frame(width: 74)
///             .frame(maxHeight: .infinity)
///     }
///     .tint(.blue)
///
///     Button(role: .destructive) { delete(item) } label: {
///         Label("Delete", systemImage: "trash")
///             .frame(width: 74)
///             .frame(maxHeight: .infinity)
///     }
///     .tint(.red)
/// }
/// ```
///
/// - Note: When using a plain `Button`, add `.tint(color)` so `SwipeActionButtonStyle`
///   can pick up the right background colour. For `role: .destructive` you also need
///   `.tint(.red)` explicitly, since custom button styles don't inherit the role colour.
public struct AwesomeSwipeButton<Label: View>: View {

    private let tint: Color
    private let action: () -> Void
    @ViewBuilder private let label: Label
    @Environment(\.swipeCloseAction) private var closeAction

    // MARK: - Init

    /// Creates a swipe action button with a custom label view.
    public init(
        tint: Color = .gray,
        role: ButtonRole? = nil,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.tint = (role == .destructive) ? .red : tint
        self.action = action
        self.label = label()
    }

    // MARK: - Body

    public var body: some View {
        Button {
            action()
            closeAction?()
        } label: {
            label
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 74)
                .frame(maxHeight: .infinity)
        }
        .tint(tint)
    }
}

// MARK: - Convenience initialisers

extension AwesomeSwipeButton where Label == Image {
    /// Creates a swipe action button with an SF Symbol icon.
    public init(
        tint: Color = .gray,
        role: ButtonRole? = nil,
        systemImage: String,
        action: @escaping () -> Void
    ) {
        self.init(tint: tint, role: role, action: action) {
            Image(systemName: systemImage)
        }
    }
}
// MARK: - .awesomeButtonStyle modifier

/// Internal `ButtonStyle` that applies the full AwesomeSwipeActions button appearance.
/// Applied to individual buttons via `.awesomeButtonStyle(tint:)`.
private struct AwesomeExplicitButtonStyle: ButtonStyle {
    let tint: Color

    func makeBody(configuration: Configuration) -> some View {
        _AwesomeExplicitButton(configuration: configuration, tint: tint)
    }
}

private struct _AwesomeExplicitButton: View {
    let configuration: ButtonStyleConfiguration
    let tint: Color
    @Environment(\.swipeCloseAction) private var closeAction

    var body: some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: 74)
            .frame(maxHeight: .infinity)
            .background(tint)
            .opacity(configuration.isPressed ? 0.75 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                if oldValue && !newValue { closeAction?() }
            }
    }
}

extension View {
    /// Applies the standard AwesomeSwipeActions button appearance to any SwiftUI `Button`.
    ///
    /// Use this when you prefer a plain `Button` over `AwesomeSwipeButton`:
    ///
    /// ```swift
    /// .awesomeSwipeActions(id: item.id, coordinator: coordinator) {
    ///     Button { archive(item) } label: {
    ///         Label("Archive", systemImage: "archivebox")
    ///     }
    ///     .awesomeButtonStyle(tint: .orange)
    ///
    ///     Button { delete(item) } label: {
    ///         Label("Delete", systemImage: "trash")
    ///     }
    ///     .awesomeButtonStyle(tint: .red)
    /// }
    /// ```
    public func awesomeButtonStyle(tint: Color) -> some View {
        buttonStyle(AwesomeExplicitButtonStyle(tint: tint))
    }
}


