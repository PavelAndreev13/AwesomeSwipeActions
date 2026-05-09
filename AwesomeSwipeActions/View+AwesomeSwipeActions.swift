import SwiftUI

extension View {

    // MARK: - v2 API (from: Edge)

    /// Adds custom swipe actions revealed by dragging from one of the four
    /// edges (`.top`, `.leading`, `.bottom`, `.trailing`) — a pure-SwiftUI
    /// alternative to native `swipeActions`, which only works inside `List`
    /// and only supports horizontal edges.
    ///
    /// Apply this modifier to each row inside `LazyVStack`, `LazyHStack`, or
    /// any custom container. Provide a shared ``AwesomeSwipeCoordinator`` to
    /// ensure only one row is open at a time.
    ///
    /// ```swift
    /// @State private var coordinator = AwesomeSwipeCoordinator()
    ///
    /// ScrollView {
    ///     LazyVStack(spacing: 0) {
    ///         ForEach(items) { item in
    ///             Text(item.title)
    ///                 .awesomeSwipeActions(id: item.id, coordinator: coordinator) {
    ///                     AwesomeSwipeButton(tint: .blue, systemImage: "pencil") {
    ///                         edit(item)
    ///                     }
    ///                     AwesomeSwipeButton(tint: .red, role: .destructive, systemImage: "trash") {
    ///                         delete(item)
    ///                     }
    ///                 }
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - id: A unique identifier for this row, used to coordinate open/close
    ///     state. Must be `Hashable` and `Sendable`.
    ///   - coordinator: A shared coordinator instance created with `@State`.
    ///   - edge: The edge from which actions slide in. Default: `.trailing`.
    ///     Use `.leading` / `.trailing` for horizontal swipes (typical inside
    ///     a vertical `ScrollView`) or `.top` / `.bottom` for vertical swipes
    ///     (works best inside a horizontal scroll axis or non-scrolling
    ///     containers — see the *Choosing edges* article in the DocC).
    ///   - content: A `@ViewBuilder` closure containing action buttons —
    ///     ``AwesomeSwipeButton``, or any SwiftUI `Button`.
    /// - Returns: A view that responds to swipes from the given edge by
    ///   revealing the provided action buttons.
    public func awesomeSwipeActions<ID: Hashable & Sendable, ActionContent: View>(
        id: ID,
        coordinator: AwesomeSwipeCoordinator,
        from edge: Edge = .trailing,
        @ViewBuilder content: () -> ActionContent
    ) -> some View {
        let builtContent = content()
        return modifier(
            AwesomeSwipeModifier(
                id: id,
                coordinator: coordinator,
                edge: edge,
                actionContent: builtContent
            )
        )
    }

    /// Convenience overload that takes any `Identifiable` item and uses its
    /// `id` automatically.
    ///
    /// ```swift
    /// ForEach(items) { item in
    ///     Row(item)
    ///         .awesomeSwipeActions(for: item, coordinator: coordinator, from: .top) {
    ///             AwesomeSwipeButton(tint: .red, role: .destructive, systemImage: "trash") {
    ///                 delete(item)
    ///             }
    ///         }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - item: The row's source item. Its `.id` is used as the coordination key.
    ///   - coordinator: A shared coordinator instance created with `@State`.
    ///   - edge: The edge from which actions slide in. Default: `.trailing`.
    ///   - content: A `@ViewBuilder` closure containing action buttons.
    /// - Returns: A view that responds to swipes from the given edge by
    ///   revealing the provided action buttons.
    public func awesomeSwipeActions<Item: Identifiable, ActionContent: View>(
        for item: Item,
        coordinator: AwesomeSwipeCoordinator,
        from edge: Edge = .trailing,
        @ViewBuilder content: () -> ActionContent
    ) -> some View where Item.ID: Hashable & Sendable {
        awesomeSwipeActions(
            id: item.id,
            coordinator: coordinator,
            from: edge,
            content: content
        )
    }

    // MARK: - v1 deprecated bridges

    /// v1 source-compat overload accepting `edge: HorizontalEdge`. Forwards to
    /// the new `from: Edge` overload by mapping `.leading` / `.trailing`
    /// 1-to-1 onto the corresponding `Edge` cases. Retained for the v1 → v2
    /// migration window; will be removed in 3.0.
    @available(*, deprecated,
               renamed: "awesomeSwipeActions(id:coordinator:from:content:)",
               message: "Use 'from:' with SwiftUI.Edge — accepts .top, .leading, .bottom, .trailing.")
    public func awesomeSwipeActions<ID: Hashable & Sendable, ActionContent: View>(
        id: ID,
        coordinator: AwesomeSwipeCoordinator,
        edge: HorizontalEdge,
        @ViewBuilder content: () -> ActionContent
    ) -> some View {
        awesomeSwipeActions(
            id: id,
            coordinator: coordinator,
            from: edge == .leading ? .leading : .trailing,
            content: content
        )
    }

    /// v1 source-compat overload accepting `edge: HorizontalEdge` for
    /// `Identifiable` items.
    @available(*, deprecated,
               renamed: "awesomeSwipeActions(for:coordinator:from:content:)",
               message: "Use 'from:' with SwiftUI.Edge — accepts .top, .leading, .bottom, .trailing.")
    public func awesomeSwipeActions<Item: Identifiable, ActionContent: View>(
        for item: Item,
        coordinator: AwesomeSwipeCoordinator,
        edge: HorizontalEdge,
        @ViewBuilder content: () -> ActionContent
    ) -> some View where Item.ID: Hashable & Sendable {
        awesomeSwipeActions(
            for: item,
            coordinator: coordinator,
            from: edge == .leading ? .leading : .trailing,
            content: content
        )
    }
}
