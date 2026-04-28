import Testing
@testable import AwesomeSwipeActions

@MainActor
@Suite("AwesomeSwipeCoordinator")
struct AwesomeSwipeCoordinatorTests {

    @Test("Initial state has no open row")
    func initialState() {
        let coord = AwesomeSwipeCoordinator()
        #expect(coord.activeKey == nil)
        #expect(coord.openRowID == nil)
    }

    @Test("Opening a key publishes both activeKey and openRowID")
    func opening() {
        let coord = AwesomeSwipeCoordinator()
        coord._open("k1", userID: "u1")

        #expect(coord.activeKey == AnyHashable("k1"))
        #expect(coord.openRowID == AnyHashable("u1"))
    }

    @Test("Opening a different key replaces the previous one")
    func replacing() {
        let coord = AwesomeSwipeCoordinator()
        coord._open("k1", userID: "u1")
        coord._open("k2", userID: "u2")

        #expect(coord.activeKey == AnyHashable("k2"))
        #expect(coord.openRowID == AnyHashable("u2"))
    }

    @Test("Re-opening the same key is a no-op")
    func reopeningSameKeyIsNoOp() {
        let coord = AwesomeSwipeCoordinator()
        coord._open("k1", userID: "u1")
        let snapshotKey = coord.activeKey
        let snapshotID = coord.openRowID

        coord._open("k1", userID: "u1")

        #expect(coord.activeKey == snapshotKey)
        #expect(coord.openRowID == snapshotID)
    }

    @Test("close() resets both activeKey and openRowID")
    func closeResetsState() {
        let coord = AwesomeSwipeCoordinator()
        coord._open("k1", userID: "u1")
        coord.close()

        #expect(coord.activeKey == nil)
        #expect(coord.openRowID == nil)
    }

    @Test("close() on an empty coordinator is a no-op")
    func closeWhenEmpty() {
        let coord = AwesomeSwipeCoordinator()
        coord.close()  // must not crash

        #expect(coord.activeKey == nil)
        #expect(coord.openRowID == nil)
    }

    @Test("_close(key) only closes when keys match")
    func closeWithKey() {
        let coord = AwesomeSwipeCoordinator()
        coord._open("k1", userID: "u1")

        // Mismatched key — must not close
        coord._close("kX")
        #expect(coord.activeKey == AnyHashable("k1"))
        #expect(coord.openRowID == AnyHashable("u1"))

        // Matching key — closes
        coord._close("k1")
        #expect(coord.activeKey == nil)
        #expect(coord.openRowID == nil)
    }

    @Test("Different user ids and keys flow through independently")
    func keyAndUserIDIndependence() {
        let coord = AwesomeSwipeCoordinator()
        // Simulate two modifiers (leading and trailing) on the same row id —
        // they share the user id but produce different internal keys.
        struct EdgeKey: Hashable { let id: Int; let edge: Int }
        let leadingKey: AnyHashable = AnyHashable(EdgeKey(id: 42, edge: 0))
        let trailingKey: AnyHashable = AnyHashable(EdgeKey(id: 42, edge: 1))
        let userID: AnyHashable = 42

        coord._open(leadingKey, userID: userID)
        #expect(coord.openRowID == userID)

        coord._open(trailingKey, userID: userID)
        #expect(coord.activeKey == trailingKey)
        #expect(coord.openRowID == userID)
    }

    @Test("Deprecated closeAll() still closes the open row")
    func deprecatedCloseAll() {
        let coord = AwesomeSwipeCoordinator()
        coord._open("k1", userID: "u1")

        // Suppress deprecation warning for the alias check
        let dynamicCoord = coord as AwesomeSwipeCoordinator
        @available(*, deprecated)
        func callDeprecated(_ c: AwesomeSwipeCoordinator) { c.closeAll() }
        callDeprecated(dynamicCoord)

        #expect(coord.activeKey == nil)
        #expect(coord.openRowID == nil)
    }
}
