//
//  IntentTests.swift
//  PouchPalTests
//
//  Created by Lee Seaver on 1/13/26.
//

import XCTest
import AppIntents
@testable import PouchPal

final class IntentTests: XCTestCase {
    
    var mockDefaults: UserDefaults!
    var mockDefaultsSuiteName: String!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockDefaultsSuiteName = "com.pouchpal.tests.intents.\(UUID().uuidString)"
        mockDefaults = UserDefaults(suiteName: mockDefaultsSuiteName)!
        
        // Clear any existing data
        UserDefaults.appGroup.removeObject(forKey: "todayCount")
        UserDefaults.appGroup.removeObject(forKey: "pendingLogs")
    }
    
    override func tearDownWithError() throws {
        mockDefaults.removePersistentDomain(forName: mockDefaultsSuiteName)
        mockDefaultsSuiteName = nil
        mockDefaults = nil
        UserDefaults.appGroup.removeObject(forKey: "todayCount")
        UserDefaults.appGroup.removeObject(forKey: "pendingLogs")
        try super.tearDownWithError()
    }
    
    // MARK: - LogPouchIntent Tests
    
    func testLogPouchIntentTitle() {
        XCTAssertEqual(LogPouchIntent.title.key, "Log Pouch")
    }
    
    func testLogPouchIntentDescription() {
        // AppIntent description is an IntentDescription, we can verify it exists
        let intentDescription: IntentDescription = LogPouchIntent.description
        XCTAssertNotNil(intentDescription)
    }
    
    func testLogPouchIntentDoesNotOpenApp() {
        XCTAssertFalse(LogPouchIntent.openAppWhenRun)
    }
    
    func testLogPouchIntentDefaultQuantity() {
        let intent = LogPouchIntent()
        XCTAssertEqual(intent.quantity, 1)
    }
    
    func testLogPouchIntentPerform() async throws {
        // Set initial count
        UserDefaults.appGroup.set(5, forKey: "todayCount")
        
        let intent = LogPouchIntent()
        intent.quantity = 1
        
        _ = try await intent.perform()
        
        // Check count was updated
        let newCount = UserDefaults.appGroup.integer(forKey: "todayCount")
        XCTAssertEqual(newCount, 6)
    }
    
    func testLogPouchIntentPerformWithQuantity() async throws {
        UserDefaults.appGroup.set(3, forKey: "todayCount")
        
        let intent = LogPouchIntent()
        intent.quantity = 5
        
        _ = try await intent.perform()
        
        let newCount = UserDefaults.appGroup.integer(forKey: "todayCount")
        XCTAssertEqual(newCount, 8)
    }
    
    func testLogPouchIntentCreatesPendingLog() async throws {
        UserDefaults.appGroup.set(0, forKey: "todayCount")
        
        let intent = LogPouchIntent()
        intent.quantity = 2
        
        _ = try await intent.perform()
        
        let pendingLogs = UserDefaults.appGroup.array(forKey: "pendingLogs") as? [[String: Any]]
        XCTAssertNotNil(pendingLogs)
        XCTAssertEqual(pendingLogs?.count, 1)
        
        let firstLog = pendingLogs?.first
        XCTAssertEqual(firstLog?["quantity"] as? Int, 2)
        XCTAssertEqual(firstLog?["source"] as? String, "widget")
        XCTAssertNotNil(firstLog?["timestamp"])
    }
    
    func testLogPouchIntentAppendsToPendingLogs() async throws {
        // Set up existing pending log
        let existingLogs: [[String: Any]] = [
            ["timestamp": Date().timeIntervalSince1970, "quantity": 1, "source": "widget"]
        ]
        UserDefaults.appGroup.set(existingLogs, forKey: "pendingLogs")
        UserDefaults.appGroup.set(1, forKey: "todayCount")
        
        let intent = LogPouchIntent()
        intent.quantity = 2
        
        _ = try await intent.perform()
        
        let pendingLogs = UserDefaults.appGroup.array(forKey: "pendingLogs") as? [[String: Any]]
        XCTAssertEqual(pendingLogs?.count, 2)
    }
    
    func testLogPouchIntentUpdatesLastUpdated() async throws {
        let beforePerform = Date()
        
        let intent = LogPouchIntent()
        _ = try await intent.perform()
        
        let lastUpdated = UserDefaults.appGroup.object(forKey: "lastUpdated") as? Date
        XCTAssertNotNil(lastUpdated)
        XCTAssertGreaterThanOrEqual(lastUpdated ?? Date.distantPast, beforePerform)
    }
    
    func testLogPouchIntentWithZeroQuantity() async throws {
        UserDefaults.appGroup.set(5, forKey: "todayCount")
        
        let intent = LogPouchIntent()
        intent.quantity = 0
        
        _ = try await intent.perform()
        
        let newCount = UserDefaults.appGroup.integer(forKey: "todayCount")
        XCTAssertEqual(newCount, 5) // Should remain the same
    }
    
    func testLogPouchIntentWithLargeQuantity() async throws {
        UserDefaults.appGroup.set(0, forKey: "todayCount")
        
        let intent = LogPouchIntent()
        intent.quantity = 100
        
        _ = try await intent.perform()
        
        let newCount = UserDefaults.appGroup.integer(forKey: "todayCount")
        XCTAssertEqual(newCount, 100)
    }
    
    // MARK: - PouchPalShortcuts Tests
    
    func testPouchPalShortcutsHasAppShortcuts() {
        let shortcuts = PouchPalShortcuts.appShortcuts
        XCTAssertFalse(shortcuts.isEmpty)
    }
    
    func testPouchPalShortcutsHasLogPouchShortcut() {
        let shortcuts = PouchPalShortcuts.appShortcuts
        XCTAssertEqual(shortcuts.count, 1)
    }
    
    // MARK: - Edge Case Tests
    
    func testLogPouchIntentFromEmptyState() async throws {
        // Ensure no previous data
        UserDefaults.appGroup.removeObject(forKey: "todayCount")
        UserDefaults.appGroup.removeObject(forKey: "pendingLogs")
        
        let intent = LogPouchIntent()
        intent.quantity = 3
        
        _ = try await intent.perform()
        
        let newCount = UserDefaults.appGroup.integer(forKey: "todayCount")
        XCTAssertEqual(newCount, 3)
    }
    
    func testMultipleIntentPerformances() async throws {
        UserDefaults.appGroup.set(0, forKey: "todayCount")
        
        for _ in 1...5 {
            let intent = LogPouchIntent()
            intent.quantity = 1
            _ = try await intent.perform()
        }
        
        let finalCount = UserDefaults.appGroup.integer(forKey: "todayCount")
        XCTAssertEqual(finalCount, 5)
        
        let pendingLogs = UserDefaults.appGroup.array(forKey: "pendingLogs") as? [[String: Any]]
        XCTAssertEqual(pendingLogs?.count, 5)
    }
    
    func testLogPouchIntentTimestampAccuracy() async throws {
        let beforePerform = Date()
        
        let intent = LogPouchIntent()
        intent.quantity = 1
        _ = try await intent.perform()
        
        let afterPerform = Date()
        
        let pendingLogs = UserDefaults.appGroup.array(forKey: "pendingLogs") as? [[String: Any]]
        guard let timestamp = pendingLogs?.first?["timestamp"] as? TimeInterval else {
            XCTFail("Timestamp not found")
            return
        }
        
        let logDate = Date(timeIntervalSince1970: timestamp)
        
        XCTAssertGreaterThanOrEqual(logDate, beforePerform)
        XCTAssertLessThanOrEqual(logDate, afterPerform)
    }
}
