//
//  IntegrationTests.swift
//  PouchPalTests
//
//  Created by Lee Seaver on 1/13/26.
//

import XCTest
import SwiftData
@testable import PouchPal

@MainActor
final class IntegrationTests: XCTestCase {
    
    var modelContext: ModelContext!
    var modelContainer: ModelContainer!
    var settings: UserSettings!
    var dataManager: DataManager!
    var mockDefaults: UserDefaults!
    var mockDefaultsSuiteName: String!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let schema = Schema([LogEntry.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(modelContainer)
        
        mockDefaultsSuiteName = "com.pouchpal.tests.integration.\(UUID().uuidString)"
        mockDefaults = UserDefaults(suiteName: mockDefaultsSuiteName)!
        settings = UserSettings(defaults: mockDefaults)
        dataManager = DataManager(modelContext: modelContext)
    }
    
    override func tearDownWithError() throws {
        mockDefaults.removePersistentDomain(forName: mockDefaultsSuiteName)
        mockDefaultsSuiteName = nil
        mockDefaults = nil
        settings = nil
        dataManager = nil
        modelContext = nil
        modelContainer = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Full User Flow Tests
    
    func testNewUserOnboardingFlow() {
        // New user starts with onboarding not completed
        XCTAssertFalse(settings.hasCompletedOnboarding)
        
        // User completes onboarding
        settings.hasCompletedOnboarding = true
        settings.dailyLimitEnabled = true
        settings.dailyLimitValue = 10
        settings.unitLabelSingular = "pouch"
        settings.unitLabelPlural = "pouches"
        
        // Verify settings persisted
        let newSettings = UserSettings(defaults: mockDefaults)
        XCTAssertTrue(newSettings.hasCompletedOnboarding)
        XCTAssertTrue(newSettings.dailyLimitEnabled)
        XCTAssertEqual(newSettings.dailyLimitValue, 10)
    }
    
    func testDailyLoggingFlow() {
        // Set up settings
        settings.dailyLimitEnabled = true
        settings.dailyLimitValue = 10
        settings.approachThreshold = 0.8
        
        // Log throughout the day
        dataManager.logPouch(quantity: 2, source: "home_button")
        XCTAssertEqual(dataManager.todayCount(), 2)
        
        dataManager.logPouch(quantity: 3, source: "widget")
        XCTAssertEqual(dataManager.todayCount(), 5)
        
        // Check progress
        XCTAssertEqual(settings.progressPercentage(for: 5), 0.5, accuracy: 0.001)
        XCTAssertFalse(settings.isApproachingLimit(count: 5))
        
        // Log more to approach limit
        dataManager.logPouch(quantity: 3, source: "home_button")
        XCTAssertEqual(dataManager.todayCount(), 8)
        XCTAssertTrue(settings.isApproachingLimit(count: 8))
        
        // Hit limit
        dataManager.logPouch(quantity: 2, source: "home_button")
        XCTAssertEqual(dataManager.todayCount(), 10)
        XCTAssertTrue(settings.isAtOrOverLimit(count: 10))
    }
    
    func testUndoFlow() {
        // Log and then undo
        dataManager.logPouch(quantity: 3)
        XCTAssertEqual(dataManager.todayCount(), 3)
        XCTAssertTrue(dataManager.canUndo)
        
        dataManager.undoLastLog()
        XCTAssertEqual(dataManager.todayCount(), 0)
        XCTAssertFalse(dataManager.canUndo)
    }
    
    func testHistoryFlow() throws {
        let calendar = Calendar.current
        
        // Log entries over multiple days
        dataManager.logPouch(quantity: 5, source: "home_button") // Today
        
        // Yesterday
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        let entry1 = LogEntry(timestamp: yesterday, quantity: 3, source: "widget")
        modelContext.insert(entry1)
        
        // 3 days ago
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: Date())!
        let entry2 = LogEntry(timestamp: threeDaysAgo, quantity: 7, source: "home_button")
        modelContext.insert(entry2)
        
        try modelContext.save()
        
        // Check counts
        XCTAssertEqual(dataManager.countForDate(Date()), 5)
        XCTAssertEqual(dataManager.countForDate(yesterday), 3)
        XCTAssertEqual(dataManager.countForDate(threeDaysAgo), 7)
        
        // Check 7-day data
        let weeklyData = dataManager.last7DaysCounts()
        XCTAssertEqual(weeklyData.count, 7)
        
        let todayData = weeklyData.last!
        XCTAssertEqual(todayData.count, 5)
    }
    
    func testInsightsCalculations() throws {
        let calendar = Calendar.current
        
        // Create consistent data for 7 days (2 per day = 14 total)
        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date())!
            let entry = LogEntry(timestamp: date, quantity: 2, source: "test")
            modelContext.insert(entry)
        }
        try modelContext.save()
        
        // Weekly average should be 2.0
        XCTAssertEqual(dataManager.weeklyAverage(), 2.0, accuracy: 0.001)
    }
    
    func testExportFlow() throws {
        // Create some entries
        dataManager.logPouch(quantity: 1, source: "home_button")
        dataManager.logPouch(quantity: 2, source: "widget")
        
        // Export CSV
        let csv = dataManager.exportCSV()
        
        // Verify CSV content
        XCTAssertTrue(csv.contains("timestamp,quantity,source,note"))
        XCTAssertTrue(csv.contains("home_button"))
        XCTAssertTrue(csv.contains("widget"))
    }
    
    // MARK: - Settings and Notification Integration
    
    func testSettingsNotificationIntegration() async {
        settings.notificationsEnabled = true
        settings.dailyLimitEnabled = true
        settings.dailyLimitValue = 10
        settings.approachingLimitNotification = true
        settings.limitReachedNotification = true
        
        // Check limit status triggers
        let count = 8
        XCTAssertTrue(settings.isApproachingLimit(count: count))
        
        // At limit
        let atLimit = 10
        XCTAssertTrue(settings.isAtOrOverLimit(count: atLimit))
        
        // Over limit
        let overLimit = 12
        XCTAssertTrue(settings.isAtOrOverLimit(count: overLimit))
    }
    
    func testDailySummaryScheduling() {
        settings.dailySummaryEnabled = true
        settings.dailySummaryHour = 20
        settings.dailySummaryMinute = 0
        
        // Schedule notification
        NotificationManager.shared.scheduleDailySummary(
            hour: settings.dailySummaryHour,
            minute: settings.dailySummaryMinute
        )
        
        // Change time
        settings.dailySummaryHour = 18
        settings.dailySummaryMinute = 30
        
        NotificationManager.shared.scheduleDailySummary(
            hour: settings.dailySummaryHour,
            minute: settings.dailySummaryMinute
        )
        
        // Cleanup
        NotificationManager.shared.cancelDailySummary()
    }
    
    // MARK: - Widget Integration Tests
    
    func testWidgetDataSync() {
        // Simulate widget logging
        let timestamp = Date().timeIntervalSince1970
        let pendingLogs: [[String: Any]] = [
            ["timestamp": timestamp, "quantity": 2, "source": "widget"]
        ]
        UserDefaults.appGroup.set(pendingLogs, forKey: "pendingLogs")
        
        // Process pending logs
        PendingLogsHandler.shared.processPendingLogs(modelContext: modelContext)
        
        // Verify entry was created
        XCTAssertEqual(dataManager.todayCount(), 2)
        
        // Verify pending logs were cleared
        let remainingLogs = UserDefaults.appGroup.array(forKey: "pendingLogs")
        XCTAssertNil(remainingLogs)
    }
    
    func testSettingsSyncToWidget() {
        settings.dailyLimitEnabled = true
        settings.dailyLimitValue = 15
        settings.unitLabelPlural = "items"
        settings.unitLabelSingular = "item"
        
        PendingLogsHandler.shared.syncSettingsToAppGroup(settings: settings)
        
        let defaults = UserDefaults.appGroup
        XCTAssertTrue(defaults.bool(forKey: "dailyLimitEnabled"))
        XCTAssertEqual(defaults.integer(forKey: "dailyLimitValue"), 15)
        XCTAssertEqual(defaults.string(forKey: "unitLabelPlural"), "items")
    }
    
    // MARK: - Multi-Day Usage Simulation
    
    func testWeekOfUsage() throws {
        let calendar = Calendar.current
        
        // Simulate a week of varying usage
        let dailyCounts = [3, 5, 2, 8, 4, 10, 6]
        
        for (dayOffset, count) in dailyCounts.enumerated() {
            let date = calendar.date(byAdding: .day, value: -(6 - dayOffset), to: Date())!
            let entry = LogEntry(timestamp: date, quantity: count, source: "test")
            modelContext.insert(entry)
        }
        try modelContext.save()
        
        // Verify data
        let weeklyData = dataManager.last7DaysCounts()
        XCTAssertEqual(weeklyData.count, 7)
        
        // Check totals
        let expectedTotal = dailyCounts.reduce(0, +) // 38
        let actualTotal = weeklyData.reduce(0) { $0 + $1.count }
        XCTAssertEqual(actualTotal, expectedTotal)
        
        // Check average
        let expectedAverage = Double(expectedTotal) / 7.0 // ~5.43
        XCTAssertEqual(dataManager.weeklyAverage(), expectedAverage, accuracy: 0.01)
    }
    
    // MARK: - Data Deletion Flow
    
    func testDeleteAllDataFlow() throws {
        // Create several entries
        for _ in 1...10 {
            dataManager.logPouch(quantity: 1)
        }
        XCTAssertEqual(dataManager.todayCount(), 10)
        
        // Delete all
        let entries = dataManager.allEntries()
        for entry in entries {
            dataManager.deleteEntry(entry)
        }
        
        XCTAssertEqual(dataManager.todayCount(), 0)
        XCTAssertTrue(dataManager.allEntries().isEmpty)
    }
    
    // MARK: - Edge Cases
    
    func testCrossDayBoundary() throws {
        let calendar = Calendar.current
        
        // Entry just before midnight yesterday
        let yesterdayLate = calendar.date(byAdding: .second, value: -1, to: calendar.startOfDay(for: Date()))!
        let yesterdayEntry = LogEntry(timestamp: yesterdayLate, quantity: 5)
        modelContext.insert(yesterdayEntry)
        
        // Entry at midnight today
        let todayEarly = calendar.startOfDay(for: Date())
        let todayEntry = LogEntry(timestamp: todayEarly, quantity: 3)
        modelContext.insert(todayEntry)
        
        try modelContext.save()
        
        XCTAssertEqual(dataManager.countForDate(yesterdayLate), 5)
        XCTAssertEqual(dataManager.countForDate(todayEarly), 3)
        XCTAssertEqual(dataManager.todayCount(), 3)
    }
    
    func testSettingsChangeAffectsCalculations() {
        dataManager.logPouch(quantity: 8)
        
        // Initially no limit
        settings.dailyLimitEnabled = false
        XCTAssertEqual(settings.progressPercentage(for: 8), 0)
        XCTAssertFalse(settings.isApproachingLimit(count: 8))
        
        // Enable limit of 10
        settings.dailyLimitEnabled = true
        settings.dailyLimitValue = 10
        settings.approachThreshold = 0.8
        
        XCTAssertEqual(settings.progressPercentage(for: 8), 0.8, accuracy: 0.001)
        XCTAssertTrue(settings.isApproachingLimit(count: 8))
        
        // Change limit to 20
        settings.dailyLimitValue = 20
        XCTAssertEqual(settings.progressPercentage(for: 8), 0.4, accuracy: 0.001)
        XCTAssertFalse(settings.isApproachingLimit(count: 8))
    }
    
    func testRapidLogging() {
        // Simulate rapid button presses
        for _ in 1...20 {
            dataManager.logPouch(quantity: 1)
        }
        
        XCTAssertEqual(dataManager.todayCount(), 20)
    }
    
    func testConcurrentEntryDeletion() throws {
        // Create entries
        for i in 1...5 {
            dataManager.logPouch(quantity: i)
        }
        XCTAssertEqual(dataManager.todayCount(), 15) // 1+2+3+4+5
        
        // Delete entries one by one
        while let entry = dataManager.allEntries().first {
            dataManager.deleteEntry(entry)
        }
        
        XCTAssertEqual(dataManager.todayCount(), 0)
    }
}
