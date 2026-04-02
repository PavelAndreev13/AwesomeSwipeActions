import SwiftUI

extension View {

    /// Adds custom swipe actions to a row inside a `ScrollView` — the drop-in
    /// alternative to SwiftUI's `swipeActions`, which only works with `List`.
    ///
    /// Apply this modifier to each row inside `LazyVStack` or `LazyHStack`.
    /// Provide a shared `AwesomeSwipeCoordinator` to ensure only one row is
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
    ///   - id: A unique identifier for this row, used to coordinate open/close state.
    ///   - coordinator: A shared coordinator instance created with `@State`.
    ///   - edge: The edge from which actions slide in. Default: `.trailing`.
    ///   - content: A `@ViewBuilder` closure containing `AwesomeSwipeButton` views.
    public func awesomeSwipeActions<ID: Hashable, ActionContent: View>(
        id: ID,
        coordinator: AwesomeSwipeCoordinator,
        edge: SwipeActionEdge = .trailing,
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
}
