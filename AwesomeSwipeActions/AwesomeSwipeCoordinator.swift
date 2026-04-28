import Combine
import SwiftUI

/// Coordinates swipe state across all rows in a scroll view, ensuring only
/// one row is open at any moment.
///
/// Create one instance per scroll view using `@State` and pass it to each
/// row's `awesomeSwipeActions(...)` modifier:
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
/// Subscribe to ``openRowID`` to react to opens and closes:
/// ```swift
/// .onReceive(coordinator.$openRowID) { id in
///     print("Open row: \(String(describing: id))")
/// }
/// ```
///
/// ## Why ObservableObject instead of @Observable
///
/// `AwesomeSwipeModifier` holds the coordinator as a plain `let` — **not**
/// as `@ObservedObject` — so the modifier's `body` never establishes an
/// observation dependency on the active row. Cross-cell coordination is done
/// via `.onReceive(coordinator.$activeKey)`, an imperative side-effect that
/// fires outside body evaluation. This ensures only the opening and the
/// closing cell re-render on each swipe interaction — **O(1)** instead of O(n).
///
/// `@Observable` does not expose a Combine publisher for individual properties,
/// making this pattern impossible with the `@Observable` macro.
@MainActor
public final class AwesomeSwipeCoordinator: ObservableObject {

    /// Internal edge-aware key. Wraps the user-supplied id together with the
    /// swipe edge so leading and trailing modifiers on the same row receive
    /// distinct identities. Internal so consumers don't see implementation
    /// details — they read ``openRowID`` instead.
    @Published internal var activeKey: AnyHashable?

    /// The user-supplied identifier of the currently open row, or `nil` when
    /// no row is open.
    ///
    /// This is the value you originally passed as `id:` to
    /// ``SwiftUI/View/awesomeSwipeActions(id:coordinator:edge:content:)``,
    /// not an internal wrapper, so equality with your own ids works as expected:
    ///
    /// ```swift
    /// if coordinator.openRowID == AnyHashable(item.id) {
    ///     // this row is open
    /// }
    /// ```
    @Published public private(set) var openRowID: AnyHashable?

    public init() {}

    // MARK: - Internal API (used by AwesomeSwipeModifier)

    /// Marks the row identified by `key` as open, replacing whatever was open
    /// before. `userID` is the unwrapped value exposed via ``openRowID``.
    func _open(_ key: AnyHashable, userID: AnyHashable) {
        guard activeKey != key else { return }
        activeKey = key
        openRowID = userID
    }

    /// Closes the open row regardless of its key.
    func _close() {
        guard activeKey != nil else { return }
        activeKey = nil
        openRowID = nil
    }

    /// Closes the open row only if its key matches `key`.
    func _close(_ key: AnyHashable) {
        guard activeKey == key else { return }
        activeKey = nil
        openRowID = nil
    }

    // MARK: - Public API

    /// Programmatically closes the open row, if any.
    ///
    /// Useful after an asynchronous action completes:
    ///
    /// ```swift
    /// Button("Delete") {
    ///     Task {
    ///         await performDelete()
    ///         coordinator.close()
    ///     }
    /// }
    /// ```
    public func close() {
        _close()
    }

    /// Programmatically closes the open row, if any.
    ///
    /// - Note: Prefer ``close()``. This name is kept for source-compatibility
    ///   with pre-1.0 betas and may be removed in a future major version.
    @available(*, deprecated, renamed: "close()", message: "Use close() instead.")
    public func closeAll() {
        close()
    }
}
