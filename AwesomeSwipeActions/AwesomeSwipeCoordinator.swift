import Combine
import SwiftUI

/// Coordinates swipe state across all rows in a list, ensuring only one
/// row is open at a time.
///
/// Create one instance per scroll view with `@State` and pass it to each row's
/// `awesomeSwipeActions` modifier:
///
/// ```swift
/// @State private var coordinator = AwesomeSwipeCoordinator()
///
/// ScrollView {
///     LazyVStack(spacing: 0) {
///         ForEach(items) { item in
///             Row(item)
///                 .awesomeSwipeActions(id: item.id, coordinator: coordinator) { ... }
///         }
///     }
/// }
/// ```
///
/// ## Why ObservableObject instead of @Observable
///
/// `AwesomeSwipeModifier` holds the coordinator as a plain `let` — **not** as
/// `@ObservedObject` — so the modifier's `body` never establishes an
/// observation dependency on `activeID`. Coordination is done via
/// `.onReceive(coordinator.$activeID)`, an imperative side-effect that fires
/// outside body evaluation. This ensures only the opening and the closing cell
/// re-render on each swipe interaction — **O(1)** instead of O(n).
///
/// `@Observable` does not expose a Combine publisher for individual properties,
/// making this pattern impossible with the `@Observable` macro.
public final class AwesomeSwipeCoordinator: ObservableObject {

    /// The ID of the currently open row. `nil` when all rows are closed.
    ///
    /// You can subscribe to this value to react whenever a row opens or closes:
    /// ```swift
    /// coordinator.$activeID.sink { id in ... }.store(in: &cancellables)
    /// ```
    @Published public var activeID: AnyHashable?

    public init() {}

    // MARK: - Internal API (used by AwesomeSwipeModifier)

    /// Marks the row with the given ID as open, closing any previously open row.
    func open(_ id: AnyHashable) {
        guard activeID != id else { return }
        activeID = id
    }

    /// Closes the currently open row regardless of which row it is.
    func close() {
        guard activeID != nil else { return }
        activeID = nil
    }

    /// Closes the row only if it matches the given ID.
    func close(_ id: AnyHashable) {
        guard activeID == id else { return }
        activeID = nil
    }

    // MARK: - Public API

    /// Programmatically closes whichever row is currently open.
    public func closeAll() {
        close()
    }
}

