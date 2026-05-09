import SwiftUI
import Testing
@testable import AwesomeSwipeActions

/// Tests for the rubber-band formula `f(x) = (1 - 1/((x·c/d) + 1)) · d`.
///
/// The function lives as an instance method on `AwesomeSwipeModifier`. The
/// modifier is generic over `ID` and `ActionContent`; we instantiate it with
/// an `EmptyView` content to access the helper. The function only consumes
/// its scalar arguments — the surrounding ViewModifier state is irrelevant.
@MainActor
@Suite("Rubber band")
struct RubberBandTests {

    /// Convenience helper that builds a modifier instance solely to call its
    /// rubber-band method. Coordinator and id are arbitrary placeholders.
    private func make() -> AwesomeSwipeModifier<String, EmptyView> {
        AwesomeSwipeModifier(
            id: "test",
            coordinator: AwesomeSwipeCoordinator(),
            edge: .trailing,
            containerAxis: nil,
            actionContent: EmptyView()
        )
    }

    @Test("rubberBand(0) is 0")
    func zeroOffsetIsZero() {
        let m = make()
        #expect(m.rubberBand(0, dimension: 100) == 0)
    }

    @Test("dimension == 0 short-circuits to the input")
    func dimensionZeroPassThrough() {
        let m = make()
        #expect(m.rubberBand(50, dimension: 0) == 50)
        #expect(m.rubberBand(-30, dimension: 0) == -30)
    }

    @Test("Output is monotonically non-decreasing as offset grows (positive)")
    func monotonic() {
        let m = make()
        let dim: CGFloat = 200
        let outputs = stride(from: 0.0 as CGFloat, through: 500.0, by: 25.0)
            .map { m.rubberBand($0, dimension: dim) }
        for i in 1..<outputs.count {
            #expect(outputs[i] >= outputs[i - 1])
        }
    }

    @Test("Output stays below dimension as a cap (asymptote)")
    func boundedByDimension() {
        let m = make()
        let dim: CGFloat = 200
        // Even at very large offsets, the formula approaches but never reaches `dim`.
        let huge = m.rubberBand(100_000, dimension: dim)
        #expect(huge < dim)
        #expect(huge > 0)
    }

    @Test("Resistance grows: doubling offset less than doubles output")
    func diminishingReturns() {
        let m = make()
        let dim: CGFloat = 100
        let small = m.rubberBand(50, dimension: dim)
        let big = m.rubberBand(100, dimension: dim)
        // Linear would give big == 2 · small; rubber-band gives big < 2 · small.
        #expect(big < 2 * small)
    }

    @Test("Default constant of 0.55 produces ~25 pt for offset 50, dim 100")
    func knownValue() {
        let m = make()
        // f(50, 100, 0.55) = (1 - 1 / ((50·0.55/100)+1)) · 100
        //                 = (1 - 1 / 1.275) · 100
        //                 = (1 - 0.7843…) · 100
        //                 ≈ 21.57 pt
        let result = m.rubberBand(50, dimension: 100)
        #expect(abs(result - 21.57) < 0.1)
    }
}
