import SwiftUI

extension View {

    /// Adds custom swipe actions to a row inside a `ScrollView` — the drop-in
    /// alternative to SwiftUI's `swipeActions`, which only works with `List`.
    ///
    /// Apply this modifier to each row inside `LazyVStack` or `LazyHStack`.
    /// Provide a shared ``AwesomeSwipeCoordinator`` to ensure only one row is
    /// open at a time across the entire scroll view.
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
    ///   - edge: The horizontal edge from which actions slide in.
    ///     Default: `.trailing`.
    ///   - content: A `@ViewBuilder` closure containing action buttons —
    ///     `AwesomeSwipeButton`, or any SwiftUI `Button`.
    /// - Returns: A view that responds to horizontal swipes by revealing the
    ///   provided action buttons.
    public func awesomeSwipeActions<ID: Hashable & Sendable, ActionContent: View>(
        id: ID,
        coordinator: AwesomeSwipeCoordinator,
        edge: HorizontalEdge = .trailing,
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
    ///         .awesomeSwipeActions(for: item, coordinator: coordinator) {
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
    ///   - edge: The horizontal edge from which actions slide in.
    ///     Default: `.trailing`.
    ///   - content: A `@ViewBuilder` closure containing action buttons.
    /// - Returns: A view that responds to horizontal swipes by revealing the
    ///   provided action buttons.
    public func awesomeSwipeActions<Item: Identifiable, ActionContent: View>(
        for item: Item,
        coordinator: AwesomeSwipeCoordinator,
        edge: HorizontalEdge = .trailing,
        @ViewBuilder content: () -> ActionContent
    ) -> some View where Item.ID: Hashable & Sendable {
        awesomeSwipeActions(
            id: item.id,
            coordinator: coordinator,
            edge: edge,
            content: content
        )
    }
}
