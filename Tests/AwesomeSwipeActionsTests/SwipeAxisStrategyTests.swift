import SwiftUI
import Testing
@testable import AwesomeSwipeActions

@Suite("SwipeAxisStrategy")
struct SwipeAxisStrategyTests {

    // MARK: - Axis classification

    @Test("Horizontal edges resolve to .horizontal axis")
    func horizontalEdgesAxis() {
        #expect(SwipeAxisStrategy(edge: .leading).axis == .horizontal)
        #expect(SwipeAxisStrategy(edge: .trailing).axis == .horizontal)
    }

    @Test("Vertical edges resolve to .vertical axis")
    func verticalEdgesAxis() {
        #expect(SwipeAxisStrategy(edge: .top).axis == .vertical)
        #expect(SwipeAxisStrategy(edge: .bottom).axis == .vertical)
    }

    // MARK: - Open sign

    @Test(".leading and .top have positive openSign")
    func positiveOpenSign() {
        #expect(SwipeAxisStrategy(edge: .leading).openSign == +1)
        #expect(SwipeAxisStrategy(edge: .top).openSign == +1)
    }

    @Test(".trailing and .bottom have negative openSign")
    func negativeOpenSign() {
        #expect(SwipeAxisStrategy(edge: .trailing).openSign == -1)
        #expect(SwipeAxisStrategy(edge: .bottom).openSign == -1)
    }

    // MARK: - Panel alignment

    @Test("Each edge maps to its matching alignment")
    func panelAlignment() {
        #expect(SwipeAxisStrategy(edge: .leading).panelAlignment == .leading)
        #expect(SwipeAxisStrategy(edge: .trailing).panelAlignment == .trailing)
        #expect(SwipeAxisStrategy(edge: .top).panelAlignment == .top)
        #expect(SwipeAxisStrategy(edge: .bottom).panelAlignment == .bottom)
    }

    // MARK: - Dimension selection

    @Test("Horizontal strategies select width")
    func horizontalDimensionSelectsWidth() {
        let s = SwipeAxisStrategy(edge: .trailing)
        #expect(s.dimension(of: CGSize(width: 100, height: 50)) == 100)
        #expect(s.dimension(of: CGSize(width: 0, height: 999)) == 0)
    }

    @Test("Vertical strategies select height")
    func verticalDimensionSelectsHeight() {
        let s = SwipeAxisStrategy(edge: .top)
        #expect(s.dimension(of: CGSize(width: 100, height: 50)) == 50)
        #expect(s.dimension(of: CGSize(width: 999, height: 0)) == 0)
    }

    // MARK: - Cross-axis gesture detection

    @Test("Horizontal: pure-horizontal drag is on-axis")
    func horizontalPureHorizontal() {
        let s = SwipeAxisStrategy(edge: .trailing)
        #expect(s.isCrossAxisGesture(translation: CGSize(width: 100, height: 0)) == false)
        #expect(s.isCrossAxisGesture(translation: CGSize(width: -100, height: 5)) == false)
    }

    @Test("Horizontal: pure-vertical drag is cross-axis")
    func horizontalPureVertical() {
        let s = SwipeAxisStrategy(edge: .leading)
        #expect(s.isCrossAxisGesture(translation: CGSize(width: 0, height: 100)) == true)
        #expect(s.isCrossAxisGesture(translation: CGSize(width: 5, height: -100)) == true)
    }

    @Test("Vertical: pure-vertical drag is on-axis")
    func verticalPureVertical() {
        let s = SwipeAxisStrategy(edge: .top)
        #expect(s.isCrossAxisGesture(translation: CGSize(width: 0, height: 100)) == false)
        #expect(s.isCrossAxisGesture(translation: CGSize(width: 5, height: -100)) == false)
    }

    @Test("Vertical: pure-horizontal drag is cross-axis")
    func verticalPureHorizontal() {
        let s = SwipeAxisStrategy(edge: .bottom)
        #expect(s.isCrossAxisGesture(translation: CGSize(width: 100, height: 0)) == true)
        #expect(s.isCrossAxisGesture(translation: CGSize(width: -100, height: 5)) == true)
    }

    @Test("Threshold of 50° classifies a 45°/45° drag as on-axis for horizontal")
    func diagonalAtFortyFive_horizontal() {
        let s = SwipeAxisStrategy(edge: .trailing)
        // exact 45° → angle == 45, not > 50, so on-axis
        #expect(s.isCrossAxisGesture(translation: CGSize(width: 100, height: 100)) == false)
    }

    @Test("Threshold of 50° classifies a 45°/45° drag as on-axis for vertical")
    func diagonalAtFortyFive_vertical() {
        let s = SwipeAxisStrategy(edge: .top)
        // exact 45° → angle == 45 from vertical, also not > 50, so on-axis
        #expect(s.isCrossAxisGesture(translation: CGSize(width: 100, height: 100)) == false)
    }

    @Test("60° drag from horizontal axis is treated as cross-axis")
    func sixtyDegreesFromHorizontal() {
        // tan(60°) ≈ 1.732, so dy/dx ≈ 1.732
        let s = SwipeAxisStrategy(edge: .trailing)
        #expect(s.isCrossAxisGesture(translation: CGSize(width: 10, height: 18)) == true)
    }

    @Test("60° drag from vertical axis is treated as cross-axis")
    func sixtyDegreesFromVertical() {
        // dx/dy ≈ 1.732 → 60° from vertical
        let s = SwipeAxisStrategy(edge: .bottom)
        #expect(s.isCrossAxisGesture(translation: CGSize(width: 18, height: 10)) == true)
    }
}
