//
//  PendingLogsHandlerTests.swift
//  PouchPalTests
//
//  Created by Lee Seaver on 1/13/26.
//

import XCTest
import SwiftData
@testable import PouchPal

@MainActor
final class PendingLogsHandlerTests: XCTestCase {
    
    var sut: PendingLogsHandler!
    var modelContext: ModelContext!
    var modelContainer: ModelContainer!
    var mockDefaults: UserDefaults!
    var mockDefaultsSuiteName: String!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let schema = Schema([LogEntry.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(modelContainer)
        sut = PendingLogsHandler.shared
        
        // Create a unique UserDefaults suite for each test
        mockDefaultsSuiteName = "com.pouchpal.tests.pending.\(UUID().uuidString)"
        mockDefaults = UserDefaults(suiteName: mockDefaultsSuiteName)!
    }
    
    override func tearDownWithError() throws {
        mockDefaults.removePersistentDomain(forName: mockDefaultsSuiteName)
        mockDefaultsSuiteName = nil
        mockDefaults = nil
        modelContext = nil
        modelContainer = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Singleton Tests
    
    func testSharedInstanceIsSingleton() {
        let instance1 = PendingLogsHandler.shared
        let instance2 = PendingLogsHandler.shared
        
        XCTAssertTrue(instance1 === instance2, "Should return the same instance")
    }
    
    // MARK: - Process Pending Logs Tests
    
    func testProcessPendingLogsWithNoPending() throws {
        // Ensure no pending logs exist
        UserDefaults.appGroup.removeObject(forKey: "pendingLogs")
        
        sut.processPendingLogs(modelContext: modelContext)
        
        let descriptor = FetchDescriptor<LogEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertTrue(entries.isEmpty, "Should have no entries when no pending logs")
    }
    
    func testProcessPendingLogsWithEmptyArray() throws {
        UserDefaults.appGroup.set([], forKey: "pendingLogs")
        
        sut.processPendingLogs(modelContext: modelContext)
        
        let descriptor = FetchDescriptor<LogEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertTrue(entries.isEmpty, "Should have no entries with empty pending logs")
    }
    
    func testProcessPendingLogsCreatesEntries() throws {
        let timestamp = Date().timeIntervalSince1970
        let pendingLogs: [[String: Any]] = [
            ["timestamp": timestamp, "quantity": 1, "source": "widget"]
        ]
        UserDefaults.appGroup.set(pendingLogs, forKey: "pendingLogs")
        
        sut.processPendingLogs(modelContext: modelContext)
        
        let descriptor = FetchDescriptor<LogEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.quantity, 1)
        XCTAssertEqual(entries.first?.source, "widget")
    }
    
    func testProcessPendingLogsMultipleEntries() throws {
        let timestamp = Date().timeIntervalSince1970
        let pendingLogs: [[String: Any]] = [
            ["timestamp": timestamp, "quantity": 1, "source": "widget"],
            ["timestamp": timestamp - 60, "quantity": 2, "source": "shortcut"],
            ["timestamp": timestamp - 120, "quantity": 3, "source": "widget"]
        ]
        UserDefaults.appGroup.set(pendingLogs, forKey: "pendingLogs")
        
        sut.processPendingLogs(modelContext: modelContext)
        
        let descriptor = FetchDescriptor<LogEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(entries.count, 3)
    }
    
    func testProcessPendingLogsClearsPendingAfterProcessing() throws {
        let timestamp = Date().timeIntervalSince1970
        let pendingLogs: [[String: Any]] = [
            ["timestamp": timestamp, "quantity": 1, "source": "widget"]
        ]
        UserDefaults.appGroup.set(pendingLogs, forKey: "pendingLogs")
        
        sut.processPendingLogs(modelContext: modelContext)
        
        let remainingLogs = UserDefaults.appGroup.array(forKey: "pendingLogs")
        XCTAssertNil(remainingLogs, "Pending logs should be cleared after processing")
    }
    
    func testProcessPendingLogsSkipsInvalidEntries() throws {
        let timestamp = Date().timeIntervalSince1970
        let pendingLogs: [[String: Any]] = [
            ["timestamp": timestamp, "quantity": 1, "source": "widget"],      // Valid
            ["timestamp": timestamp, "quantity": 2],                           // Missing source
            ["quantity": 3, "source": "widget"],                               // Missing timestamp
            ["timestamp": timestamp, "source": "widget"],                      // Missing quantity
            ["timestamp": timestamp, "quantity": 4, "source": "shortcut"]     // Valid
        ]
        UserDefaults.appGroup.set(pendingLogs, forKey: "pendingLogs")
        
        sut.processPendingLogs(modelContext: modelContext)
        
        let descriptor = FetchDescriptor<LogEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(entries.count, 2, "Should only process valid entries")
    }
    
    func testProcessPendingLogsCorrectTimestamp() throws {
        let expectedTimestamp = Date(timeIntervalSince1970: 1700000000)
        let pendingLogs: [[String: Any]] = [
            ["timestamp": expectedTimestamp.timeIntervalSince1970, "quantity": 1, "source": "widget"]
        ]
        UserDefaults.appGroup.set(pendingLogs, forKey: "pendingLogs")
        
        sut.processPendingLogs(modelContext: modelContext)
        
        let descriptor = FetchDescriptor<LogEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(entries.first?.timestamp, expectedTimestamp)
    }
    
    // MARK: - Update Shared Today Count Tests
    
    func testUpdateSharedTodayCountEmpty() throws {
        sut.updateSharedTodayCount(modelContext: modelContext)
        
        let todayCount = UserDefaults.appGroup.integer(forKey: "todayCount")
        XCTAssertEqual(todayCount, 0)
    }
    
    func testUpdateSharedTodayCountWithEntries() throws {
        // Add entries for today
        let entry1 = LogEntry(timestamp: Date(), quantity: 3)
        let entry2 = LogEntry(timestamp: Date(), quantity: 2)
        modelContext.insert(entry1)
        modelContext.insert(entry2)
        try modelContext.save()
        
        sut.updateSharedTodayCount(modelContext: modelContext)
        
        let todayCount = UserDefaults.appGroup.integer(forKey: "todayCount")
        XCTAssertEqual(todayCount, 5)
    }
    
    func testUpdateSharedTodayCountExcludesYesterday() throws {
        // Add entry for today
        let todayEntry = LogEntry(timestamp: Date(), quantity: 5)
        modelContext.insert(todayEntry)
        
        // Add entry for yesterday
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let yesterdayEntry = LogEntry(timestamp: yesterday, quantity: 10)
        modelContext.insert(yesterdayEntry)
        
        try modelContext.save()
        
        sut.updateSharedTodayCount(modelContext: modelContext)
        
        let todayCount = UserDefaults.appGroup.integer(forKey: "todayCount")
        XCTAssertEqual(todayCount, 5, "Should only count today's entries")
    }
    
    func testUpdateSharedTodayCountUpdatesLastUpdated() throws {
        let beforeUpdate = Date()
        
        sut.updateSharedTodayCount(modelContext: modelContext)
        
        let lastUpdated = UserDefaults.appGroup.object(forKey: "lastUpdated") as? Date
        XCTAssertNotNil(lastUpdated)
        XCTAssertGreaterThanOrEqual(lastUpdated ?? Date.distantPast, beforeUpdate)
    }
    
    // MARK: - Sync Settings to App Group Tests
    
    func testSyncSettingsToAppGroup() {
        let settings = UserSettings()
        settings.dailyLimitEnabled = true
        settings.dailyLimitValue = 15
        settings.unitLabelPlural = "items"
        settings.unitLabelSingular = "item"
        
        sut.syncSettingsToAppGroup(settings: settings)
        
        let defaults = UserDefaults.appGroup
        XCTAssertTrue(defaults.bool(forKey: "dailyLimitEnabled"))
        XCTAssertEqual(defaults.integer(forKey: "dailyLimitValue"), 15)
        XCTAssertEqual(defaults.string(forKey: "unitLabelPlural"), "items")
        XCTAssertEqual(defaults.string(forKey: "unitLabelSingular"), "item")
    }
    
    func testSyncSettingsToAppGroupWithDefaultValues() {
        // Clear any existing values in app group first
        let defaults = UserDefaults.appGroup
        defaults.removeObject(forKey: "dailyLimitEnabled")
        defaults.removeObject(forKey: "dailyLimitValue")
        defaults.removeObject(forKey: "unitLabelPlural")
        defaults.removeObject(forKey: "unitLabelSingular")
        
        // Create settings with fresh mock defaults to get default values
        let freshSuiteName = "com.pouchpal.tests.fresh.\(UUID().uuidString)"
        let freshDefaults = UserDefaults(suiteName: freshSuiteName)!
        let settings = UserSettings(defaults: freshDefaults)
        
        sut.syncSettingsToAppGroup(settings: settings)
        
        XCTAssertFalse(defaults.bool(forKey: "dailyLimitEnabled"))
        XCTAssertEqual(defaults.integer(forKey: "dailyLimitValue"), 10)
        XCTAssertEqual(defaults.string(forKey: "unitLabelPlural"), "pouches")
        XCTAssertEqual(defaults.string(forKey: "unitLabelSingular"), "pouch")
        
        // Cleanup
        freshDefaults.removePersistentDomain(forName: freshSuiteName)
    }
    
    func testSyncSettingsToAppGroupUpdatesExisting() {
        let defaults = UserDefaults.appGroup
        
        // Set initial values
        defaults.set(true, forKey: "dailyLimitEnabled")
        defaults.set(20, forKey: "dailyLimitValue")
        
        // Update with new settings
        let settings = UserSettings()
        settings.dailyLimitEnabled = false
        settings.dailyLimitValue = 5
        
        sut.syncSettingsToAppGroup(settings: settings)
        
        XCTAssertFalse(defaults.bool(forKey: "dailyLimitEnabled"))
        XCTAssertEqual(defaults.integer(forKey: "dailyLimitValue"), 5)
    }
    
    // MARK: - Edge Case Tests
    
    func testProcessPendingLogsWithWrongTypes() throws {
        let pendingLogs: [[String: Any]] = [
            ["timestamp": "not a number", "quantity": 1, "source": "widget"],  // Wrong timestamp type
            ["timestamp": 1700000000.0, "quantity": "two", "source": "widget"], // Wrong quantity type
            ["timestamp": 1700000000.0, "quantity": 1, "source": 123]           // Wrong source type
        ]
        UserDefaults.appGroup.set(pendingLogs, forKey: "pendingLogs")
        
        sut.processPendingLogs(modelContext: modelContext)
        
        let descriptor = FetchDescriptor<LogEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        // All should be skipped due to type mismatches
        XCTAssertEqual(entries.count, 0)
    }
    
    func testProcessPendingLogsWithExtraFields() throws {
        let timestamp = Date().timeIntervalSince1970
        let pendingLogs: [[String: Any]] = [
            [
                "timestamp": timestamp,
                "quantity": 1,
                "source": "widget",
                "extraField": "should be ignored",
                "anotherExtra": 123
            ]
        ]
        UserDefaults.appGroup.set(pendingLogs, forKey: "pendingLogs")
        
        sut.processPendingLogs(modelContext: modelContext)
        
        let descriptor = FetchDescriptor<LogEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(entries.count, 1, "Should process entries with extra fields")
        XCTAssertEqual(entries.first?.quantity, 1)
    }
    
    func testProcessPendingLogsWithLargeQuantity() throws {
        let timestamp = Date().timeIntervalSince1970
        let pendingLogs: [[String: Any]] = [
            ["timestamp": timestamp, "quantity": 999999, "source": "widget"]
        ]
        UserDefaults.appGroup.set(pendingLogs, forKey: "pendingLogs")
        
        sut.processPendingLogs(modelContext: modelContext)
        
        let descriptor = FetchDescriptor<LogEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(entries.first?.quantity, 999999)
    }
    
    func testProcessPendingLogsWithOldTimestamp() throws {
        // Very old timestamp (year 2000)
        let oldTimestamp: TimeInterval = 946684800
        let pendingLogs: [[String: Any]] = [
            ["timestamp": oldTimestamp, "quantity": 1, "source": "widget"]
        ]
        UserDefaults.appGroup.set(pendingLogs, forKey: "pendingLogs")
        
        sut.processPendingLogs(modelContext: modelContext)
        
        let descriptor = FetchDescriptor<LogEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.timestamp, Date(timeIntervalSince1970: oldTimestamp))
    }
    
    func testProcessPendingLogsWithFutureTimestamp() throws {
        // Future timestamp
        let futureTimestamp = Date().timeIntervalSince1970 + 86400 * 365 // One year from now
        let pendingLogs: [[String: Any]] = [
            ["timestamp": futureTimestamp, "quantity": 1, "source": "widget"]
        ]
        UserDefaults.appGroup.set(pendingLogs, forKey: "pendingLogs")
        
        sut.processPendingLogs(modelContext: modelContext)
        
        let descriptor = FetchDescriptor<LogEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(entries.count, 1)
    }
}
