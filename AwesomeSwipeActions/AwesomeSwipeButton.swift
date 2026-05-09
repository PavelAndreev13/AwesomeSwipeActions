import SwiftUI

/// A pre-styled button designed for use inside ``SwiftUI/View/awesomeSwipeActions(id:coordinator:from:content:)``.
///
/// `AwesomeSwipeButton` is simply a `Button` with a fixed cross-axis size
/// (74 pt by default), white foreground, and a tinted background. It's a
/// convenience — any standard SwiftUI `Button` with `.tint(_:)` works just
/// as well:
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
/// }
/// ```
///
/// The button reads the swipe axis from the environment (`\.swipeAxis`) and
/// chooses its fixed dimension automatically — width for horizontal panels,
/// height for vertical panels. Outside a swipe panel, the default is
/// horizontal sizing.
///
/// - Note: When using a plain `Button`, add `.tint(color)` so the underlying
///   button style can pick up the right background colour. For
///   `role: .destructive` you also need `.tint(.red)` explicitly, since
///   custom button styles don't inherit the role colour.
public struct AwesomeSwipeButton<Label: View>: View {

    private let tint: Color
    private let action: () -> Void
    @ViewBuilder private let label: Label
    @Environment(\.swipeCloseAction) private var closeAction
    @Environment(\.swipeAxis) private var axis

    private let crossSize: CGFloat = 74

    // MARK: - Init

    /// Creates a swipe action button with a custom label view.
    ///
    /// - Parameters:
    ///   - tint: The button's background colour. Defaults to `.gray`.
    ///   - role: An optional button role. When `.destructive`, the tint is
    ///     overridden with `.red`. Other roles are accepted but do not affect
    ///     appearance.
    ///   - action: The closure invoked when the button is tapped. The row is
    ///     automatically closed after the press is released.
    ///   - label: A `@ViewBuilder` producing the button's label content.
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
                .frame(width: axis == .horizontal ? crossSize : nil,
                       height: axis == .vertical ? crossSize : nil)
                .frame(maxWidth: axis == .vertical ? .infinity : nil,
                       maxHeight: axis == .horizontal ? .infinity : nil)
        }
        .tint(tint)
    }
}

// MARK: - Convenience initialisers

extension AwesomeSwipeButton where Label == Image {
    /// Creates a swipe action button labelled with an SF Symbol.
    ///
    /// ```swift
    /// AwesomeSwipeButton(tint: .blue, systemImage: "pencil") { edit(item) }
    /// AwesomeSwipeButton(tint: .red, role: .destructive, systemImage: "trash") { delete(item) }
    /// ```
    ///
    /// - Parameters:
    ///   - tint: The button's background colour. Defaults to `.gray`.
    ///   - role: An optional button role. When `.destructive`, the tint is
    ///     overridden with `.red`.
    ///   - systemImage: The name of the SF Symbol to display.
    ///   - action: The closure invoked when the button is tapped. The row is
    ///     automatically closed after the press is released.
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
    @Environment(\.swipeAxis) private var axis

    private let crossSize: CGFloat = 74

    var body: some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: axis == .horizontal ? crossSize : nil,
                   height: axis == .vertical ? crossSize : nil)
            .frame(maxWidth: axis == .vertical ? .infinity : nil,
                   maxHeight: axis == .horizontal ? .infinity : nil)
            .background(tint)
            .opacity(configuration.isPressed ? 0.75 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                if oldValue && !newValue { closeAction?() }
            }
    }
}

extension View {
    /// Applies the standard `AwesomeSwipeActions` button appearance to any
    /// SwiftUI `Button`.
    ///
    /// Use this when you prefer a plain `Button` over ``AwesomeSwipeButton``:
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
    ///
    /// Sets a fixed cross-axis size of `74 pt`, white foreground, medium font
    /// weight, and press-opacity feedback — identical to ``AwesomeSwipeButton``.
    /// The fixed dimension is `width` inside a horizontal panel and `height`
    /// inside a vertical panel (axis is read from `\.swipeAxis`).
    ///
    /// - Parameter tint: The background colour applied to the button.
    /// - Returns: A view that styles the button to match the swipe-action
    ///   appearance.
    public func awesomeButtonStyle(tint: Color) -> some View {
        buttonStyle(AwesomeExplicitButtonStyle(tint: tint))
    }
}
