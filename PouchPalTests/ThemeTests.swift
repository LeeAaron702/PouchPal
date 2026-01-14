//
//  ThemeTests.swift
//  PouchPalTests
//
//  Created by Lee Seaver on 1/13/26.
//

import XCTest
import SwiftUI
@testable import PouchPal

final class ThemeTests: XCTestCase {
    
    // MARK: - Color Tests
    
    func testPrimaryFallbackColorExists() {
        let color = Color.ppPrimaryFallback
        XCTAssertNotNil(color)
    }
    
    func testSecondaryFallbackColorExists() {
        let color = Color.ppSecondaryFallback
        XCTAssertNotNil(color)
    }
    
    func testAccentFallbackColorExists() {
        let color = Color.ppAccentFallback
        XCTAssertNotNil(color)
    }
    
    func testSuccessFallbackColorExists() {
        let color = Color.ppSuccessFallback
        XCTAssertNotNil(color)
    }
    
    func testWarningFallbackColorExists() {
        let color = Color.ppWarningFallback
        XCTAssertNotNil(color)
    }
    
    func testDangerFallbackColorExists() {
        let color = Color.ppDangerFallback
        XCTAssertNotNil(color)
    }
    
    func testBackgroundFallbackColorExists() {
        let color = Color.ppBackgroundFallback
        XCTAssertNotNil(color)
    }
    
    func testCardBackgroundFallbackColorExists() {
        let color = Color.ppCardBackgroundFallback
        XCTAssertNotNil(color)
    }
    
    // MARK: - Font Tests
    
    func testLargeTitleFont() {
        let font = PPFont.largeTitle()
        XCTAssertNotNil(font)
    }
    
    func testLargeTitleFontWithWeight() {
        let fontBold = PPFont.largeTitle(.bold)
        let fontRegular = PPFont.largeTitle(.regular)
        XCTAssertNotNil(fontBold)
        XCTAssertNotNil(fontRegular)
    }
    
    func testTitleFont() {
        let font = PPFont.title()
        XCTAssertNotNil(font)
    }
    
    func testTitleFontWithWeight() {
        let fontBold = PPFont.title(.bold)
        let fontSemibold = PPFont.title(.semibold)
        XCTAssertNotNil(fontBold)
        XCTAssertNotNil(fontSemibold)
    }
    
    func testHeadlineFont() {
        let font = PPFont.headline()
        XCTAssertNotNil(font)
    }
    
    func testHeadlineFontWithWeight() {
        let fontBold = PPFont.headline(.bold)
        let fontMedium = PPFont.headline(.medium)
        XCTAssertNotNil(fontBold)
        XCTAssertNotNil(fontMedium)
    }
    
    func testBodyFont() {
        let font = PPFont.body()
        XCTAssertNotNil(font)
    }
    
    func testBodyFontWithWeight() {
        let fontMedium = PPFont.body(.medium)
        let fontSemibold = PPFont.body(.semibold)
        XCTAssertNotNil(fontMedium)
        XCTAssertNotNil(fontSemibold)
    }
    
    func testCaptionFont() {
        let font = PPFont.caption()
        XCTAssertNotNil(font)
    }
    
    func testCaptionFontWithWeight() {
        let fontMedium = PPFont.caption(.medium)
        let fontSemibold = PPFont.caption(.semibold)
        XCTAssertNotNil(fontMedium)
        XCTAssertNotNil(fontSemibold)
    }
    
    func testSmallFont() {
        let font = PPFont.small()
        XCTAssertNotNil(font)
    }
    
    func testSmallFontWithWeight() {
        let fontSemibold = PPFont.small(.semibold)
        let fontRegular = PPFont.small(.regular)
        XCTAssertNotNil(fontSemibold)
        XCTAssertNotNil(fontRegular)
    }
    
    // MARK: - Spacing Tests
    
    func testSpacingXS() {
        XCTAssertEqual(PPSpacing.xs, 4)
    }
    
    func testSpacingSM() {
        XCTAssertEqual(PPSpacing.sm, 8)
    }
    
    func testSpacingMD() {
        XCTAssertEqual(PPSpacing.md, 16)
    }
    
    func testSpacingLG() {
        XCTAssertEqual(PPSpacing.lg, 24)
    }
    
    func testSpacingXL() {
        XCTAssertEqual(PPSpacing.xl, 32)
    }
    
    func testSpacingXXL() {
        XCTAssertEqual(PPSpacing.xxl, 48)
    }
    
    func testSpacingValuesAreIncreasing() {
        XCTAssertLessThan(PPSpacing.xs, PPSpacing.sm)
        XCTAssertLessThan(PPSpacing.sm, PPSpacing.md)
        XCTAssertLessThan(PPSpacing.md, PPSpacing.lg)
        XCTAssertLessThan(PPSpacing.lg, PPSpacing.xl)
        XCTAssertLessThan(PPSpacing.xl, PPSpacing.xxl)
    }
    
    // MARK: - Radius Tests
    
    func testRadiusSM() {
        XCTAssertEqual(PPRadius.sm, 8)
    }
    
    func testRadiusMD() {
        XCTAssertEqual(PPRadius.md, 12)
    }
    
    func testRadiusLG() {
        XCTAssertEqual(PPRadius.lg, 16)
    }
    
    func testRadiusXL() {
        XCTAssertEqual(PPRadius.xl, 24)
    }
    
    func testRadiusFull() {
        XCTAssertEqual(PPRadius.full, 100)
    }
    
    func testRadiusValuesAreIncreasing() {
        XCTAssertLessThan(PPRadius.sm, PPRadius.md)
        XCTAssertLessThan(PPRadius.md, PPRadius.lg)
        XCTAssertLessThan(PPRadius.lg, PPRadius.xl)
        XCTAssertLessThan(PPRadius.xl, PPRadius.full)
    }
    
    // MARK: - Animation Tests
    
    func testQuickAnimationExists() {
        let animation = PPAnimation.quick
        XCTAssertNotNil(animation)
    }
    
    func testStandardAnimationExists() {
        let animation = PPAnimation.standard
        XCTAssertNotNil(animation)
    }
    
    func testSmoothAnimationExists() {
        let animation = PPAnimation.smooth
        XCTAssertNotNil(animation)
    }
    
    func testBounceAnimationExists() {
        let animation = PPAnimation.bounce
        XCTAssertNotNil(animation)
    }
    
    // MARK: - Haptics Tests
    
    func testImpactHapticsCanBeTriggered() {
        // This test mainly verifies the function doesn't crash
        // In a real device, this would produce haptic feedback
        PPHaptics.impact(.light)
        PPHaptics.impact(.medium)
        PPHaptics.impact(.heavy)
        PPHaptics.impact(.soft)
        PPHaptics.impact(.rigid)
        // If we get here without crashing, the test passes
        XCTAssertTrue(true)
    }
    
    func testNotificationHapticsCanBeTriggered() {
        PPHaptics.notification(.success)
        PPHaptics.notification(.warning)
        PPHaptics.notification(.error)
        XCTAssertTrue(true)
    }
    
    func testSelectionHapticsCanBeTriggered() {
        PPHaptics.selection()
        XCTAssertTrue(true)
    }
    
    // MARK: - Design System Consistency Tests
    
    func testSpacingIsMultipleOf4() {
        XCTAssertEqual(PPSpacing.xs.truncatingRemainder(dividingBy: 4), 0)
        XCTAssertEqual(PPSpacing.sm.truncatingRemainder(dividingBy: 4), 0)
        XCTAssertEqual(PPSpacing.md.truncatingRemainder(dividingBy: 4), 0)
        XCTAssertEqual(PPSpacing.lg.truncatingRemainder(dividingBy: 4), 0)
        XCTAssertEqual(PPSpacing.xl.truncatingRemainder(dividingBy: 4), 0)
        XCTAssertEqual(PPSpacing.xxl.truncatingRemainder(dividingBy: 4), 0)
    }
    
    func testRadiusIsMultipleOf4() {
        XCTAssertEqual(PPRadius.sm.truncatingRemainder(dividingBy: 4), 0)
        XCTAssertEqual(PPRadius.md.truncatingRemainder(dividingBy: 4), 0)
        XCTAssertEqual(PPRadius.lg.truncatingRemainder(dividingBy: 4), 0)
        XCTAssertEqual(PPRadius.xl.truncatingRemainder(dividingBy: 4), 0)
        XCTAssertEqual(PPRadius.full.truncatingRemainder(dividingBy: 4), 0)
    }
}
