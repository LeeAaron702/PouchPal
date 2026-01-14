//
//  UserSettingsTests.swift
//  PouchPalTests
//
//  Created by Lee Seaver on 1/13/26.
//

import XCTest
@testable import PouchPal

final class UserSettingsTests: XCTestCase {
    
    var sut: UserSettings!
    var mockDefaults: UserDefaults!
    var mockDefaultsSuiteName: String!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        // Create a unique UserDefaults suite for each test
        mockDefaultsSuiteName = "com.pouchpal.tests.\(UUID().uuidString)"
        mockDefaults = UserDefaults(suiteName: mockDefaultsSuiteName)!
        sut = UserSettings(defaults: mockDefaults)
    }
    
    override func tearDownWithError() throws {
        // Clean up the mock defaults
        mockDefaults.removePersistentDomain(forName: mockDefaultsSuiteName)
        mockDefaultsSuiteName = nil
        mockDefaults = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Default Values Tests
    
    func testDefaultValues() {
        XCTAssertFalse(sut.hasCompletedOnboarding, "hasCompletedOnboarding should default to false")
        XCTAssertFalse(sut.dailyLimitEnabled, "dailyLimitEnabled should default to false")
        XCTAssertEqual(sut.dailyLimitValue, 10, "dailyLimitValue should default to 10")
        XCTAssertEqual(sut.approachThreshold, 0.8, accuracy: 0.001, "approachThreshold should default to 0.8")
        XCTAssertEqual(sut.unitLabelSingular, "pouch", "unitLabelSingular should default to 'pouch'")
        XCTAssertEqual(sut.unitLabelPlural, "pouches", "unitLabelPlural should default to 'pouches'")
        XCTAssertNil(sut.strengthMg, "strengthMg should default to nil")
        XCTAssertFalse(sut.notificationsEnabled, "notificationsEnabled should default to false")
        XCTAssertFalse(sut.approachingLimitNotification, "approachingLimitNotification should default to false")
        XCTAssertFalse(sut.limitReachedNotification, "limitReachedNotification should default to false")
        XCTAssertFalse(sut.dailySummaryEnabled, "dailySummaryEnabled should default to false")
        XCTAssertEqual(sut.dailySummaryHour, 20, "dailySummaryHour should default to 20")
        XCTAssertEqual(sut.dailySummaryMinute, 0, "dailySummaryMinute should default to 0")
    }
    
    // MARK: - Persistence Tests
    
    func testHasCompletedOnboardingPersistence() {
        sut.hasCompletedOnboarding = true
        
        let newSettings = UserSettings(defaults: mockDefaults)
        XCTAssertTrue(newSettings.hasCompletedOnboarding)
    }
    
    func testDailyLimitEnabledPersistence() {
        sut.dailyLimitEnabled = true
        
        let newSettings = UserSettings(defaults: mockDefaults)
        XCTAssertTrue(newSettings.dailyLimitEnabled)
    }
    
    func testDailyLimitValuePersistence() {
        sut.dailyLimitValue = 15
        
        let newSettings = UserSettings(defaults: mockDefaults)
        XCTAssertEqual(newSettings.dailyLimitValue, 15)
    }
    
    func testApproachThresholdPersistence() {
        sut.approachThreshold = 0.75
        
        let newSettings = UserSettings(defaults: mockDefaults)
        XCTAssertEqual(newSettings.approachThreshold, 0.75, accuracy: 0.001)
    }
    
    func testUnitLabelSingularPersistence() {
        sut.unitLabelSingular = "nicotine pouch"
        
        let newSettings = UserSettings(defaults: mockDefaults)
        XCTAssertEqual(newSettings.unitLabelSingular, "nicotine pouch")
    }
    
    func testUnitLabelPluralPersistence() {
        sut.unitLabelPlural = "nicotine pouches"
        
        let newSettings = UserSettings(defaults: mockDefaults)
        XCTAssertEqual(newSettings.unitLabelPlural, "nicotine pouches")
    }
    
    func testStrengthMgPersistence() {
        sut.strengthMg = 6
        
        let newSettings = UserSettings(defaults: mockDefaults)
        XCTAssertEqual(newSettings.strengthMg, 6)
    }
    
    func testNotificationsEnabledPersistence() {
        sut.notificationsEnabled = true
        
        let newSettings = UserSettings(defaults: mockDefaults)
        XCTAssertTrue(newSettings.notificationsEnabled)
    }
    
    func testApproachingLimitNotificationPersistence() {
        sut.approachingLimitNotification = true
        
        let newSettings = UserSettings(defaults: mockDefaults)
        XCTAssertTrue(newSettings.approachingLimitNotification)
    }
    
    func testLimitReachedNotificationPersistence() {
        sut.limitReachedNotification = true
        
        let newSettings = UserSettings(defaults: mockDefaults)
        XCTAssertTrue(newSettings.limitReachedNotification)
    }
    
    func testDailySummaryEnabledPersistence() {
        sut.dailySummaryEnabled = true
        
        let newSettings = UserSettings(defaults: mockDefaults)
        XCTAssertTrue(newSettings.dailySummaryEnabled)
    }
    
    func testDailySummaryTimePersistence() {
        sut.dailySummaryHour = 18
        sut.dailySummaryMinute = 30
        
        let newSettings = UserSettings(defaults: mockDefaults)
        XCTAssertEqual(newSettings.dailySummaryHour, 18)
        XCTAssertEqual(newSettings.dailySummaryMinute, 30)
    }
    
    // MARK: - Unit Label Helper Tests
    
    func testUnitLabelForCountOne() {
        sut.unitLabelSingular = "pouch"
        sut.unitLabelPlural = "pouches"
        
        let result = sut.unitLabel(for: 1)
        
        XCTAssertEqual(result, "pouch", "Should return singular for count of 1")
    }
    
    func testUnitLabelForCountZero() {
        sut.unitLabelSingular = "pouch"
        sut.unitLabelPlural = "pouches"
        
        let result = sut.unitLabel(for: 0)
        
        XCTAssertEqual(result, "pouches", "Should return plural for count of 0")
    }
    
    func testUnitLabelForCountMultiple() {
        sut.unitLabelSingular = "pouch"
        sut.unitLabelPlural = "pouches"
        
        let result = sut.unitLabel(for: 5)
        
        XCTAssertEqual(result, "pouches", "Should return plural for count > 1")
    }
    
    func testUnitLabelWithCustomLabels() {
        sut.unitLabelSingular = "cigarette"
        sut.unitLabelPlural = "cigarettes"
        
        XCTAssertEqual(sut.unitLabel(for: 1), "cigarette")
        XCTAssertEqual(sut.unitLabel(for: 3), "cigarettes")
    }
    
    // MARK: - Progress Percentage Tests
    
    func testProgressPercentageWhenLimitDisabled() {
        sut.dailyLimitEnabled = false
        sut.dailyLimitValue = 10
        
        let result = sut.progressPercentage(for: 5)
        
        XCTAssertEqual(result, 0, "Progress should be 0 when limit is disabled")
    }
    
    func testProgressPercentageWhenLimitIsZero() {
        sut.dailyLimitEnabled = true
        sut.dailyLimitValue = 0
        
        let result = sut.progressPercentage(for: 5)
        
        XCTAssertEqual(result, 0, "Progress should be 0 when limit is zero")
    }
    
    func testProgressPercentageHalfway() {
        sut.dailyLimitEnabled = true
        sut.dailyLimitValue = 10
        
        let result = sut.progressPercentage(for: 5)
        
        XCTAssertEqual(result, 0.5, accuracy: 0.001, "Progress should be 50%")
    }
    
    func testProgressPercentageAtLimit() {
        sut.dailyLimitEnabled = true
        sut.dailyLimitValue = 10
        
        let result = sut.progressPercentage(for: 10)
        
        XCTAssertEqual(result, 1.0, accuracy: 0.001, "Progress should be 100%")
    }
    
    func testProgressPercentageOverLimit() {
        sut.dailyLimitEnabled = true
        sut.dailyLimitValue = 10
        
        let result = sut.progressPercentage(for: 15)
        
        XCTAssertEqual(result, 1.0, accuracy: 0.001, "Progress should cap at 100%")
    }
    
    func testProgressPercentageWithZeroCount() {
        sut.dailyLimitEnabled = true
        sut.dailyLimitValue = 10
        
        let result = sut.progressPercentage(for: 0)
        
        XCTAssertEqual(result, 0, "Progress should be 0 for zero count")
    }
    
    // MARK: - Approaching Limit Tests
    
    func testIsApproachingLimitWhenDisabled() {
        sut.dailyLimitEnabled = false
        sut.dailyLimitValue = 10
        sut.approachThreshold = 0.8
        
        let result = sut.isApproachingLimit(count: 8)
        
        XCTAssertFalse(result, "Should return false when limit is disabled")
    }
    
    func testIsApproachingLimitBelowThreshold() {
        sut.dailyLimitEnabled = true
        sut.dailyLimitValue = 10
        sut.approachThreshold = 0.8
        
        let result = sut.isApproachingLimit(count: 5)
        
        XCTAssertFalse(result, "Should return false when below threshold")
    }
    
    func testIsApproachingLimitAtThreshold() {
        sut.dailyLimitEnabled = true
        sut.dailyLimitValue = 10
        sut.approachThreshold = 0.8
        
        let result = sut.isApproachingLimit(count: 8)
        
        XCTAssertTrue(result, "Should return true at 80% threshold")
    }
    
    func testIsApproachingLimitAboveThresholdBelowLimit() {
        sut.dailyLimitEnabled = true
        sut.dailyLimitValue = 10
        sut.approachThreshold = 0.8
        
        let result = sut.isApproachingLimit(count: 9)
        
        XCTAssertTrue(result, "Should return true when above threshold but below limit")
    }
    
    func testIsApproachingLimitAtLimit() {
        sut.dailyLimitEnabled = true
        sut.dailyLimitValue = 10
        sut.approachThreshold = 0.8
        
        let result = sut.isApproachingLimit(count: 10)
        
        XCTAssertFalse(result, "Should return false when at limit (no longer approaching)")
    }
    
    func testIsApproachingLimitOverLimit() {
        sut.dailyLimitEnabled = true
        sut.dailyLimitValue = 10
        sut.approachThreshold = 0.8
        
        let result = sut.isApproachingLimit(count: 15)
        
        XCTAssertFalse(result, "Should return false when over limit")
    }
    
    // MARK: - At Or Over Limit Tests
    
    func testIsAtOrOverLimitWhenDisabled() {
        sut.dailyLimitEnabled = false
        sut.dailyLimitValue = 10
        
        let result = sut.isAtOrOverLimit(count: 10)
        
        XCTAssertFalse(result, "Should return false when limit is disabled")
    }
    
    func testIsAtOrOverLimitBelowLimit() {
        sut.dailyLimitEnabled = true
        sut.dailyLimitValue = 10
        
        let result = sut.isAtOrOverLimit(count: 5)
        
        XCTAssertFalse(result, "Should return false when below limit")
    }
    
    func testIsAtOrOverLimitAtLimit() {
        sut.dailyLimitEnabled = true
        sut.dailyLimitValue = 10
        
        let result = sut.isAtOrOverLimit(count: 10)
        
        XCTAssertTrue(result, "Should return true when at limit")
    }
    
    func testIsAtOrOverLimitOverLimit() {
        sut.dailyLimitEnabled = true
        sut.dailyLimitValue = 10
        
        let result = sut.isAtOrOverLimit(count: 15)
        
        XCTAssertTrue(result, "Should return true when over limit")
    }
    
    // MARK: - Daily Summary Time Tests
    
    func testDailySummaryTimeGetter() {
        sut.dailySummaryHour = 18
        sut.dailySummaryMinute = 30
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: sut.dailySummaryTime)
        
        XCTAssertEqual(components.hour, 18)
        XCTAssertEqual(components.minute, 30)
    }
    
    func testDailySummaryTimeSetter() {
        var components = DateComponents()
        components.hour = 21
        components.minute = 45
        let testDate = Calendar.current.date(from: components)!
        
        sut.dailySummaryTime = testDate
        
        XCTAssertEqual(sut.dailySummaryHour, 21)
        XCTAssertEqual(sut.dailySummaryMinute, 45)
    }
    
    // MARK: - Edge Case Tests
    
    func testVeryHighDailyLimit() {
        sut.dailyLimitEnabled = true
        sut.dailyLimitValue = 1000
        
        XCTAssertEqual(sut.progressPercentage(for: 100), 0.1, accuracy: 0.001)
        XCTAssertFalse(sut.isAtOrOverLimit(count: 100))
    }
    
    func testApproachThresholdEdgeCases() {
        sut.dailyLimitEnabled = true
        sut.dailyLimitValue = 10
        
        // Test with 50% threshold
        sut.approachThreshold = 0.5
        XCTAssertTrue(sut.isApproachingLimit(count: 5))
        XCTAssertFalse(sut.isApproachingLimit(count: 4))
        
        // Test with 95% threshold
        sut.approachThreshold = 0.95
        XCTAssertFalse(sut.isApproachingLimit(count: 9))
    }
    
    func testEmptyUnitLabels() {
        sut.unitLabelSingular = ""
        sut.unitLabelPlural = ""
        
        XCTAssertEqual(sut.unitLabel(for: 1), "")
        XCTAssertEqual(sut.unitLabel(for: 5), "")
    }
    
    func testAllSettingsCanBeModifiedTogether() {
        sut.hasCompletedOnboarding = true
        sut.dailyLimitEnabled = true
        sut.dailyLimitValue = 20
        sut.approachThreshold = 0.7
        sut.unitLabelSingular = "item"
        sut.unitLabelPlural = "items"
        sut.strengthMg = 8
        sut.notificationsEnabled = true
        sut.approachingLimitNotification = true
        sut.limitReachedNotification = true
        sut.dailySummaryEnabled = true
        sut.dailySummaryHour = 19
        sut.dailySummaryMinute = 15
        
        // Verify all values persist
        let newSettings = UserSettings(defaults: mockDefaults)
        XCTAssertTrue(newSettings.hasCompletedOnboarding)
        XCTAssertTrue(newSettings.dailyLimitEnabled)
        XCTAssertEqual(newSettings.dailyLimitValue, 20)
        XCTAssertEqual(newSettings.approachThreshold, 0.7, accuracy: 0.001)
        XCTAssertEqual(newSettings.unitLabelSingular, "item")
        XCTAssertEqual(newSettings.unitLabelPlural, "items")
        XCTAssertEqual(newSettings.strengthMg, 8)
        XCTAssertTrue(newSettings.notificationsEnabled)
        XCTAssertTrue(newSettings.approachingLimitNotification)
        XCTAssertTrue(newSettings.limitReachedNotification)
        XCTAssertTrue(newSettings.dailySummaryEnabled)
        XCTAssertEqual(newSettings.dailySummaryHour, 19)
        XCTAssertEqual(newSettings.dailySummaryMinute, 15)
    }
}
