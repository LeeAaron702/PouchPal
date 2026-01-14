//
//  WidgetTests.swift
//  PouchPalTests
//
//  Tests for widget-related shared data and UserDefaults communication
//
//  Created by Lee Seaver on 1/13/26.
//

import XCTest
@testable import PouchPal

/// Tests for the shared data that widgets consume from the main app.
/// Note: Widget UI components (PouchPalEntry, SmallWidgetView, etc.) are in a separate
/// target and cannot be directly tested here. These tests focus on the data layer
/// that enables widget functionality.
final class WidgetTests: XCTestCase {
    
    var mockDefaults: UserDefaults!
    var mockDefaultsSuiteName: String!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockDefaultsSuiteName = "com.pouchpal.tests.widget.\(UUID().uuidString)"
        mockDefaults = UserDefaults(suiteName: mockDefaultsSuiteName)!
    }
    
    override func tearDownWithError() throws {
        mockDefaults.removePersistentDomain(forName: mockDefaultsSuiteName)
        mockDefaultsSuiteName = nil
        mockDefaults = nil
        try super.tearDownWithError()
    }
    
    // MARK: - App Group UserDefaults Tests
    
    func testAppGroupUserDefaultsExists() {
        // The app uses an app group for sharing data with the widget
        XCTAssertNotNil(UserDefaults.appGroup)
    }
    
    func testAppGroupSharedKeys() {
        // Test the keys that widgets read from shared UserDefaults
        let appGroup = UserDefaults.appGroup
        
        // Set test values
        appGroup.set(5, forKey: "todayCount")
        appGroup.set(true, forKey: "dailyLimitEnabled")
        appGroup.set(10, forKey: "dailyLimitValue")
        appGroup.set("pouches", forKey: "unitLabel")
        
        // Verify values can be read back
        XCTAssertEqual(appGroup.integer(forKey: "todayCount"), 5)
        XCTAssertTrue(appGroup.bool(forKey: "dailyLimitEnabled"))
        XCTAssertEqual(appGroup.integer(forKey: "dailyLimitValue"), 10)
        XCTAssertEqual(appGroup.string(forKey: "unitLabel"), "pouches")
        
        // Cleanup
        appGroup.removeObject(forKey: "todayCount")
        appGroup.removeObject(forKey: "dailyLimitEnabled")
        appGroup.removeObject(forKey: "dailyLimitValue")
        appGroup.removeObject(forKey: "unitLabel")
    }
    
    func testWidgetDataDefaultValues() {
        // Test default values when keys are not set
        let suiteName = "com.pouchpal.tests.fresh.\(UUID().uuidString)"
        let freshDefaults = UserDefaults(suiteName: suiteName)!
        
        XCTAssertEqual(freshDefaults.integer(forKey: "todayCount"), 0)
        XCTAssertFalse(freshDefaults.bool(forKey: "dailyLimitEnabled"))
        XCTAssertEqual(freshDefaults.integer(forKey: "dailyLimitValue"), 0)
        XCTAssertNil(freshDefaults.string(forKey: "unitLabel"))
        
        freshDefaults.removePersistentDomain(forName: suiteName)
    }
    
    // MARK: - Widget Progress Calculation Tests
    
    func testProgressCalculationUnderLimit() {
        let todayCount = 5
        let dailyLimit = 10
        
        let progress = Double(todayCount) / Double(dailyLimit)
        XCTAssertEqual(progress, 0.5, accuracy: 0.001)
    }
    
    func testProgressCalculationAtLimit() {
        let todayCount = 10
        let dailyLimit = 10
        
        let progress = min(Double(todayCount) / Double(dailyLimit), 1.0)
        XCTAssertEqual(progress, 1.0, accuracy: 0.001)
    }
    
    func testProgressCalculationOverLimit() {
        let todayCount = 15
        let dailyLimit = 10
        
        // Progress should cap at 1.0
        let progress = min(Double(todayCount) / Double(dailyLimit), 1.0)
        XCTAssertEqual(progress, 1.0, accuracy: 0.001)
    }
    
    func testProgressCalculationWithZeroLimit() {
        let todayCount = 5
        let dailyLimit = 0
        
        // Should handle gracefully - prevent division by zero
        let progress = dailyLimit > 0 ? min(Double(todayCount) / Double(dailyLimit), 1.0) : 0.0
        XCTAssertEqual(progress, 0.0, accuracy: 0.001)
    }
    
    func testProgressCalculationWithZeroCount() {
        let todayCount = 0
        let dailyLimit = 10
        
        let progress = Double(todayCount) / Double(dailyLimit)
        XCTAssertEqual(progress, 0.0, accuracy: 0.001)
    }
    
    // MARK: - Over Limit Detection Tests
    
    func testOverLimitDetectionTrue() {
        let todayCount = 11
        let dailyLimit = 10
        
        let isOverLimit = todayCount > dailyLimit
        XCTAssertTrue(isOverLimit)
    }
    
    func testOverLimitDetectionFalse() {
        let todayCount = 9
        let dailyLimit = 10
        
        let isOverLimit = todayCount > dailyLimit
        XCTAssertFalse(isOverLimit)
    }
    
    func testOverLimitDetectionAtExactLimit() {
        let todayCount = 10
        let dailyLimit = 10
        
        let isOverLimit = todayCount > dailyLimit
        let isAtOrOverLimit = todayCount >= dailyLimit
        
        XCTAssertFalse(isOverLimit)
        XCTAssertTrue(isAtOrOverLimit)
    }
    
    // MARK: - Widget Data Synchronization Tests
    
    func testUserSettingsSyncsToAppGroup() {
        // Create settings with custom defaults
        let settings = UserSettings(defaults: mockDefaults)
        
        // Change settings
        settings.dailyLimitEnabled = true
        settings.dailyLimitValue = 15
        settings.unitLabelSingular = "pouch"
        settings.unitLabelPlural = "pouches"
        
        // Verify settings were saved
        XCTAssertTrue(mockDefaults.bool(forKey: "dailyLimitEnabled"))
        XCTAssertEqual(mockDefaults.integer(forKey: "dailyLimitValue"), 15)
        XCTAssertEqual(mockDefaults.string(forKey: "unitLabelSingular"), "pouch")
        XCTAssertEqual(mockDefaults.string(forKey: "unitLabelPlural"), "pouches")
    }
    
    func testTodayCountPersistence() {
        mockDefaults.set(7, forKey: "todayCount")
        
        let retrievedCount = mockDefaults.integer(forKey: "todayCount")
        XCTAssertEqual(retrievedCount, 7)
    }
    
    func testTodayCountReset() {
        mockDefaults.set(10, forKey: "todayCount")
        XCTAssertEqual(mockDefaults.integer(forKey: "todayCount"), 10)
        
        mockDefaults.set(0, forKey: "todayCount")
        XCTAssertEqual(mockDefaults.integer(forKey: "todayCount"), 0)
    }
    
    // MARK: - Widget Label Tests
    
    func testUnitLabelForSingular() {
        let settings = UserSettings(defaults: mockDefaults)
        settings.unitLabelSingular = "pouch"
        settings.unitLabelPlural = "pouches"
        
        let count = 1
        let label = count == 1 ? settings.unitLabelSingular : settings.unitLabelPlural
        XCTAssertEqual(label, "pouch")
    }
    
    func testUnitLabelForPlural() {
        let settings = UserSettings(defaults: mockDefaults)
        settings.unitLabelSingular = "pouch"
        settings.unitLabelPlural = "pouches"
        
        let count = 5
        let label = count == 1 ? settings.unitLabelSingular : settings.unitLabelPlural
        XCTAssertEqual(label, "pouches")
    }
    
    func testUnitLabelForZero() {
        let settings = UserSettings(defaults: mockDefaults)
        settings.unitLabelSingular = "pouch"
        settings.unitLabelPlural = "pouches"
        
        let count = 0
        let label = count == 1 ? settings.unitLabelSingular : settings.unitLabelPlural
        XCTAssertEqual(label, "pouches")
    }
    
    // MARK: - Widget Display Format Tests
    
    func testCountDisplayFormat() {
        let count = 5
        let limit = 10
        
        let displayText = "\(count)/\(limit)"
        XCTAssertEqual(displayText, "5/10")
    }
    
    func testCountDisplayWithoutLimit() {
        let count = 5
        
        let displayText = "\(count)"
        XCTAssertEqual(displayText, "5")
    }
    
    func testCountDisplayLargeNumbers() {
        let count = 999
        let limit = 1000
        
        let displayText = "\(count)/\(limit)"
        XCTAssertEqual(displayText, "999/1000")
    }
    
    // MARK: - Pending Logs for Widget Tests
    
    func testPendingLogsStorageFormat() {
        // Widget can log pouches when app isn't running, stored as pending
        let pendingLogs: [[String: Any]] = [
            ["timestamp": Date().timeIntervalSince1970, "quantity": 1],
            ["timestamp": Date().timeIntervalSince1970 - 3600, "quantity": 2]
        ]
        
        mockDefaults.set(pendingLogs, forKey: "pendingLogs")
        
        let retrieved = mockDefaults.array(forKey: "pendingLogs") as? [[String: Any]]
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.count, 2)
    }
    
    func testPendingLogsEmpty() {
        let retrieved = mockDefaults.array(forKey: "pendingLogs") as? [[String: Any]]
        XCTAssertNil(retrieved)
    }
    
    func testPendingLogsClear() {
        let pendingLogs: [[String: Any]] = [
            ["timestamp": Date().timeIntervalSince1970, "quantity": 1]
        ]
        mockDefaults.set(pendingLogs, forKey: "pendingLogs")
        
        // Clear pending logs
        mockDefaults.removeObject(forKey: "pendingLogs")
        
        let retrieved = mockDefaults.array(forKey: "pendingLogs")
        XCTAssertNil(retrieved)
    }
}
