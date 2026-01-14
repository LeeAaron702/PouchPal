//
//  LogEntryTests.swift
//  PouchPalTests
//
//  Created by Lee Seaver on 1/13/26.
//

import XCTest
import SwiftData
@testable import PouchPal

final class LogEntryTests: XCTestCase {
    
    var modelContext: ModelContext!
    var modelContainer: ModelContainer!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let schema = Schema([LogEntry.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(modelContainer)
    }
    
    override func tearDownWithError() throws {
        modelContext = nil
        modelContainer = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Initialization Tests
    
    func testDefaultInitialization() {
        let entry = LogEntry()
        
        XCTAssertNotNil(entry.id)
        XCTAssertNotNil(entry.timestamp)
        XCTAssertEqual(entry.quantity, 1)
        XCTAssertNil(entry.source)
        XCTAssertNil(entry.note)
    }
    
    func testCustomInitialization() {
        let customId = UUID()
        let customDate = Date(timeIntervalSince1970: 1000000)
        let customQuantity = 3
        let customSource = "widget"
        let customNote = "Morning pouch"
        
        let entry = LogEntry(
            id: customId,
            timestamp: customDate,
            quantity: customQuantity,
            source: customSource,
            note: customNote
        )
        
        XCTAssertEqual(entry.id, customId)
        XCTAssertEqual(entry.timestamp, customDate)
        XCTAssertEqual(entry.quantity, customQuantity)
        XCTAssertEqual(entry.source, customSource)
        XCTAssertEqual(entry.note, customNote)
    }
    
    func testPartialCustomInitialization() {
        let entry = LogEntry(quantity: 5, source: "shortcut")
        
        XCTAssertEqual(entry.quantity, 5)
        XCTAssertEqual(entry.source, "shortcut")
        XCTAssertNil(entry.note)
    }
    
    // MARK: - SwiftData Persistence Tests
    
    func testInsertAndFetch() throws {
        let entry = LogEntry(quantity: 2, source: "test")
        modelContext.insert(entry)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<LogEntry>()
        let fetched = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.quantity, 2)
        XCTAssertEqual(fetched.first?.source, "test")
    }
    
    func testMultipleInserts() throws {
        for i in 1...5 {
            let entry = LogEntry(quantity: i, source: "test_\(i)")
            modelContext.insert(entry)
        }
        try modelContext.save()
        
        let descriptor = FetchDescriptor<LogEntry>()
        let fetched = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(fetched.count, 5)
    }
    
    func testDelete() throws {
        let entry = LogEntry(quantity: 1, source: "test")
        modelContext.insert(entry)
        try modelContext.save()
        
        modelContext.delete(entry)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<LogEntry>()
        let fetched = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(fetched.count, 0)
    }
    
    func testUpdate() throws {
        let entry = LogEntry(quantity: 1, source: "test")
        modelContext.insert(entry)
        try modelContext.save()
        
        entry.quantity = 5
        entry.note = "Updated"
        try modelContext.save()
        
        let descriptor = FetchDescriptor<LogEntry>()
        let fetched = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(fetched.first?.quantity, 5)
        XCTAssertEqual(fetched.first?.note, "Updated")
    }
    
    // MARK: - Computed Properties Tests
    
    func testDayString() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let testDate = formatter.date(from: "2026-01-13")!
        
        let entry = LogEntry(timestamp: testDate)
        
        // dayString uses abbreviated format
        XCTAssertFalse(entry.dayString.isEmpty)
        XCTAssertTrue(entry.dayString.contains("Jan") || entry.dayString.contains("13"))
    }
    
    func testTimeString() {
        var components = DateComponents()
        components.year = 2026
        components.month = 1
        components.day = 13
        components.hour = 14
        components.minute = 30
        
        let testDate = Calendar.current.date(from: components)!
        let entry = LogEntry(timestamp: testDate)
        
        // timeString uses shortened time format
        XCTAssertFalse(entry.timeString.isEmpty)
        // Should contain time information
        XCTAssertTrue(entry.timeString.contains(":") || entry.timeString.contains("PM") || entry.timeString.contains("AM"))
    }
    
    func testDayStringConsistency() {
        let date1 = Date(timeIntervalSince1970: 1000000)
        let date2 = Date(timeIntervalSince1970: 1000000 + 3600) // 1 hour later
        
        let entry1 = LogEntry(timestamp: date1)
        let entry2 = LogEntry(timestamp: date2)
        
        XCTAssertEqual(entry1.dayString, entry2.dayString, "Same day entries should have same dayString")
    }
    
    func testTimeStringDifferent() {
        var components1 = DateComponents()
        components1.year = 2026
        components1.month = 1
        components1.day = 13
        components1.hour = 10
        components1.minute = 0
        
        var components2 = DateComponents()
        components2.year = 2026
        components2.month = 1
        components2.day = 13
        components2.hour = 15
        components2.minute = 30
        
        let date1 = Calendar.current.date(from: components1)!
        let date2 = Calendar.current.date(from: components2)!
        
        let entry1 = LogEntry(timestamp: date1)
        let entry2 = LogEntry(timestamp: date2)
        
        XCTAssertNotEqual(entry1.timeString, entry2.timeString, "Different times should have different timeStrings")
    }
    
    // MARK: - Sorting Tests
    
    func testSortByTimestamp() throws {
        let now = Date()
        let oneHourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: now)!
        let twoHoursAgo = Calendar.current.date(byAdding: .hour, value: -2, to: now)!
        
        modelContext.insert(LogEntry(timestamp: oneHourAgo, quantity: 2))
        modelContext.insert(LogEntry(timestamp: now, quantity: 1))
        modelContext.insert(LogEntry(timestamp: twoHoursAgo, quantity: 3))
        try modelContext.save()
        
        var descriptor = FetchDescriptor<LogEntry>()
        descriptor.sortBy = [SortDescriptor(\.timestamp, order: .reverse)]
        let fetched = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(fetched[0].quantity, 1) // Most recent
        XCTAssertEqual(fetched[1].quantity, 2)
        XCTAssertEqual(fetched[2].quantity, 3) // Oldest
    }
    
    // MARK: - Predicate Tests
    
    func testPredicateBySource() throws {
        modelContext.insert(LogEntry(source: "home_button"))
        modelContext.insert(LogEntry(source: "widget"))
        modelContext.insert(LogEntry(source: "home_button"))
        try modelContext.save()
        
        let predicate = #Predicate<LogEntry> { entry in
            entry.source == "home_button"
        }
        let descriptor = FetchDescriptor<LogEntry>(predicate: predicate)
        let fetched = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(fetched.count, 2)
    }
    
    func testPredicateByQuantity() throws {
        modelContext.insert(LogEntry(quantity: 1))
        modelContext.insert(LogEntry(quantity: 2))
        modelContext.insert(LogEntry(quantity: 3))
        modelContext.insert(LogEntry(quantity: 2))
        try modelContext.save()
        
        let predicate = #Predicate<LogEntry> { entry in
            entry.quantity >= 2
        }
        let descriptor = FetchDescriptor<LogEntry>(predicate: predicate)
        let fetched = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(fetched.count, 3)
    }
    
    func testPredicateByDateRange() throws {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
        
        // Today
        modelContext.insert(LogEntry(timestamp: now, quantity: 1))
        // Yesterday
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        modelContext.insert(LogEntry(timestamp: yesterday, quantity: 2))
        try modelContext.save()
        
        let predicate = #Predicate<LogEntry> { entry in
            entry.timestamp >= startOfToday && entry.timestamp < endOfToday
        }
        let descriptor = FetchDescriptor<LogEntry>(predicate: predicate)
        let fetched = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.quantity, 1)
    }
    
    // MARK: - Edge Case Tests
    
    func testZeroQuantity() {
        let entry = LogEntry(quantity: 0)
        XCTAssertEqual(entry.quantity, 0)
    }
    
    func testNegativeQuantity() {
        let entry = LogEntry(quantity: -5)
        XCTAssertEqual(entry.quantity, -5)
    }
    
    func testVeryLargeQuantity() {
        let entry = LogEntry(quantity: Int.max)
        XCTAssertEqual(entry.quantity, Int.max)
    }
    
    func testEmptySource() {
        let entry = LogEntry(source: "")
        XCTAssertEqual(entry.source, "")
    }
    
    func testVeryLongNote() {
        let longNote = String(repeating: "a", count: 10000)
        let entry = LogEntry(note: longNote)
        XCTAssertEqual(entry.note?.count, 10000)
    }
    
    func testSpecialCharactersInNote() {
        let specialNote = "Test 🍃 with emoji & <special> \"characters\" 'and' symbols: @#$%^&*()"
        let entry = LogEntry(note: specialNote)
        XCTAssertEqual(entry.note, specialNote)
    }
    
    func testUnicodeInSource() {
        let unicodeSource = "测试来源"
        let entry = LogEntry(source: unicodeSource)
        XCTAssertEqual(entry.source, unicodeSource)
    }
    
    // MARK: - Identity Tests
    
    func testUniqueIds() {
        let entries = (0..<100).map { _ in LogEntry() }
        let uniqueIds = Set(entries.map { $0.id })
        
        XCTAssertEqual(uniqueIds.count, 100, "All entries should have unique IDs")
    }
    
    func testIdPersistence() throws {
        let originalId = UUID()
        let entry = LogEntry(id: originalId)
        modelContext.insert(entry)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<LogEntry>()
        let fetched = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(fetched.first?.id, originalId)
    }
}
