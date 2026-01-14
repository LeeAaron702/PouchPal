//
//  DataManagerTests.swift
//  PouchPalTests
//
//  Created by Lee Seaver on 1/13/26.
//

import XCTest
import SwiftData
@testable import PouchPal

@MainActor
final class DataManagerTests: XCTestCase {
    
    var sut: DataManager!
    var modelContext: ModelContext!
    var modelContainer: ModelContainer!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let schema = Schema([LogEntry.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(modelContainer)
        sut = DataManager(modelContext: modelContext)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        modelContext = nil
        modelContainer = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Logging Tests
    
    func testLogPouch() {
        sut.logPouch()
        
        XCTAssertEqual(sut.todayCount(), 1)
        XCTAssertNotNil(sut.lastLogEntry)
        XCTAssertNotNil(sut.lastLogTime)
    }
    
    func testLogPouchWithQuantity() {
        sut.logPouch(quantity: 3)
        
        XCTAssertEqual(sut.todayCount(), 3)
    }
    
    func testLogPouchWithSource() throws {
        sut.logPouch(source: "widget")
        
        let descriptor = FetchDescriptor<LogEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(entries.first?.source, "widget")
    }
    
    func testLogMultiplePouches() {
        sut.logPouch(quantity: 1)
        sut.logPouch(quantity: 2)
        sut.logPouch(quantity: 3)
        
        XCTAssertEqual(sut.todayCount(), 6)
    }
    
    func testLastLogEntryTracking() {
        sut.logPouch(quantity: 1)
        let firstEntry = sut.lastLogEntry
        
        sut.logPouch(quantity: 2)
        let secondEntry = sut.lastLogEntry
        
        XCTAssertNotEqual(firstEntry?.id, secondEntry?.id)
        XCTAssertEqual(secondEntry?.quantity, 2)
    }
    
    // MARK: - Undo Tests
    
    func testCanUndoAfterLogging() {
        sut.logPouch()
        
        XCTAssertTrue(sut.canUndo, "Should be able to undo immediately after logging")
    }
    
    func testCannotUndoInitially() {
        XCTAssertFalse(sut.canUndo, "Should not be able to undo without any logs")
    }
    
    func testUndoLastLog() {
        sut.logPouch(quantity: 3)
        XCTAssertEqual(sut.todayCount(), 3)
        
        sut.undoLastLog()
        
        XCTAssertEqual(sut.todayCount(), 0)
        XCTAssertNil(sut.lastLogEntry)
        XCTAssertNil(sut.lastLogTime)
    }
    
    func testUndoOnlyAffectsLastEntry() {
        sut.logPouch(quantity: 2)
        sut.logPouch(quantity: 3)
        XCTAssertEqual(sut.todayCount(), 5)
        
        sut.undoLastLog()
        
        XCTAssertEqual(sut.todayCount(), 2)
    }
    
    func testCannotUndoTwice() {
        sut.logPouch(quantity: 2)
        sut.logPouch(quantity: 3)
        
        sut.undoLastLog()
        XCTAssertFalse(sut.canUndo, "Should not be able to undo again")
        
        sut.undoLastLog() // Should do nothing
        XCTAssertEqual(sut.todayCount(), 2)
    }
    
    // MARK: - Delete Entry Tests
    
    func testDeleteEntry() throws {
        sut.logPouch(quantity: 1)
        sut.logPouch(quantity: 2)
        
        let descriptor = FetchDescriptor<LogEntry>()
        var entries = try modelContext.fetch(descriptor)
        let entryToDelete = entries.first!
        
        sut.deleteEntry(entryToDelete)
        
        entries = try modelContext.fetch(descriptor)
        XCTAssertEqual(entries.count, 1)
    }
    
    func testDeleteLastEntryResetsTracking() {
        sut.logPouch()
        let lastEntry = sut.lastLogEntry!
        
        sut.deleteEntry(lastEntry)
        
        XCTAssertNil(sut.lastLogEntry)
        XCTAssertNil(sut.lastLogTime)
    }
    
    func testDeleteNonLastEntryPreservesTracking() {
        sut.logPouch(quantity: 1)
        let firstEntry = sut.lastLogEntry!
        sut.logPouch(quantity: 2)
        let secondEntry = sut.lastLogEntry
        
        sut.deleteEntry(firstEntry)
        
        XCTAssertEqual(sut.lastLogEntry?.id, secondEntry?.id)
    }
    
    // MARK: - Update Entry Tests
    
    func testUpdateEntryTimestamp() {
        sut.logPouch()
        let entry = sut.lastLogEntry!
        let newTimestamp = Date(timeIntervalSince1970: 1000000)
        
        sut.updateEntryTimestamp(entry, to: newTimestamp)
        
        XCTAssertEqual(entry.timestamp, newTimestamp)
    }
    
    // MARK: - Today Count Tests
    
    func testTodayCountEmpty() {
        XCTAssertEqual(sut.todayCount(), 0)
    }
    
    func testTodayCountMultipleEntries() {
        sut.logPouch(quantity: 1)
        sut.logPouch(quantity: 2)
        sut.logPouch(quantity: 3)
        
        XCTAssertEqual(sut.todayCount(), 6)
    }
    
    func testTodayCountExcludesYesterday() throws {
        // Add entry for today
        sut.logPouch(quantity: 5)
        
        // Add entry for yesterday
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let yesterdayEntry = LogEntry(timestamp: yesterday, quantity: 10)
        modelContext.insert(yesterdayEntry)
        try modelContext.save()
        
        XCTAssertEqual(sut.todayCount(), 5)
    }
    
    // MARK: - Count For Date Tests
    
    func testCountForDateToday() {
        sut.logPouch(quantity: 3)
        
        XCTAssertEqual(sut.countForDate(Date()), 3)
    }
    
    func testCountForDateYesterday() throws {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let entry = LogEntry(timestamp: yesterday, quantity: 7)
        modelContext.insert(entry)
        try modelContext.save()
        
        XCTAssertEqual(sut.countForDate(yesterday), 7)
        XCTAssertEqual(sut.countForDate(Date()), 0)
    }
    
    func testCountForDateMultipleEntries() throws {
        let targetDate = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        
        // Add multiple entries for target date
        for _ in 1...3 {
            let entry = LogEntry(timestamp: targetDate, quantity: 2)
            modelContext.insert(entry)
        }
        try modelContext.save()
        
        XCTAssertEqual(sut.countForDate(targetDate), 6)
    }
    
    // MARK: - Entries For Date Tests
    
    func testEntriesForDateReturnsCorrectEntries() throws {
        sut.logPouch(quantity: 1, source: "source1")
        sut.logPouch(quantity: 2, source: "source2")
        
        let entries = sut.entriesForDate(Date())
        
        XCTAssertEqual(entries.count, 2)
    }
    
    func testEntriesForDateSortedByTimestampReverse() throws {
        // Create entries with known timestamps
        let calendar = Calendar.current
        let now = Date()
        
        let entry1 = LogEntry(timestamp: calendar.date(byAdding: .minute, value: -30, to: now)!, quantity: 1)
        let entry2 = LogEntry(timestamp: now, quantity: 2)
        let entry3 = LogEntry(timestamp: calendar.date(byAdding: .minute, value: -15, to: now)!, quantity: 3)
        
        modelContext.insert(entry1)
        modelContext.insert(entry2)
        modelContext.insert(entry3)
        try modelContext.save()
        
        let entries = sut.entriesForDate(Date())
        
        // Should be sorted newest first
        XCTAssertEqual(entries[0].quantity, 2)
        XCTAssertEqual(entries[1].quantity, 3)
        XCTAssertEqual(entries[2].quantity, 1)
    }
    
    func testEntriesForDateEmpty() {
        let entries = sut.entriesForDate(Date())
        XCTAssertTrue(entries.isEmpty)
    }
    
    // MARK: - Last 7 Days Counts Tests
    
    func testLast7DaysCountsReturns7Days() {
        let counts = sut.last7DaysCounts()
        XCTAssertEqual(counts.count, 7)
    }
    
    func testLast7DaysCountsOrder() {
        let counts = sut.last7DaysCounts()
        
        // Should be ordered oldest to newest
        for i in 0..<6 {
            XCTAssertTrue(counts[i].date < counts[i + 1].date)
        }
    }
    
    func testLast7DaysCountsIncludesToday() {
        sut.logPouch(quantity: 5)
        
        let counts = sut.last7DaysCounts()
        let todayCount = counts.last!
        
        XCTAssertEqual(todayCount.count, 5)
    }
    
    // MARK: - Last 30 Days Counts Tests
    
    func testLast30DaysCountsReturns30Days() {
        let counts = sut.last30DaysCounts()
        XCTAssertEqual(counts.count, 30)
    }
    
    func testLast30DaysCountsOrder() {
        let counts = sut.last30DaysCounts()
        
        // Should be ordered oldest to newest
        for i in 0..<29 {
            XCTAssertTrue(counts[i].date < counts[i + 1].date)
        }
    }
    
    // MARK: - Weekly Average Tests
    
    func testWeeklyAverageEmpty() {
        let average = sut.weeklyAverage()
        XCTAssertEqual(average, 0, accuracy: 0.001)
    }
    
    func testWeeklyAverageCalculation() throws {
        let calendar = Calendar.current
        
        // Add 14 entries across 7 days (2 per day)
        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date())!
            let entry = LogEntry(timestamp: date, quantity: 2)
            modelContext.insert(entry)
        }
        try modelContext.save()
        
        let average = sut.weeklyAverage()
        XCTAssertEqual(average, 2.0, accuracy: 0.001)
    }
    
    func testWeeklyAverageWithVaryingCounts() throws {
        let calendar = Calendar.current
        
        // Add entries: 1 today, 2 yesterday, 3 two days ago = 6 total / 7 days
        modelContext.insert(LogEntry(timestamp: Date(), quantity: 1))
        modelContext.insert(LogEntry(timestamp: calendar.date(byAdding: .day, value: -1, to: Date())!, quantity: 2))
        modelContext.insert(LogEntry(timestamp: calendar.date(byAdding: .day, value: -2, to: Date())!, quantity: 3))
        try modelContext.save()
        
        let average = sut.weeklyAverage()
        XCTAssertEqual(average, 6.0 / 7.0, accuracy: 0.001)
    }
    
    // MARK: - Monthly Average Tests
    
    func testMonthlyAverageEmpty() {
        let average = sut.monthlyAverage()
        XCTAssertEqual(average, 0, accuracy: 0.001)
    }
    
    func testMonthlyAverageCalculation() throws {
        let calendar = Calendar.current
        
        // Add 30 entries (1 per day for 30 days)
        for dayOffset in 0..<30 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date())!
            let entry = LogEntry(timestamp: date, quantity: 1)
            modelContext.insert(entry)
        }
        try modelContext.save()
        
        let average = sut.monthlyAverage()
        XCTAssertEqual(average, 1.0, accuracy: 0.001)
    }
    
    // MARK: - All Entries Tests
    
    func testAllEntriesEmpty() {
        let entries = sut.allEntries()
        XCTAssertTrue(entries.isEmpty)
    }
    
    func testAllEntriesReturnsAll() throws {
        for i in 1...10 {
            modelContext.insert(LogEntry(quantity: i))
        }
        try modelContext.save()
        
        let entries = sut.allEntries()
        XCTAssertEqual(entries.count, 10)
    }
    
    func testAllEntriesSortedByTimestampReverse() throws {
        let calendar = Calendar.current
        let now = Date()
        
        let entry1 = LogEntry(timestamp: calendar.date(byAdding: .hour, value: -2, to: now)!, quantity: 1)
        let entry2 = LogEntry(timestamp: now, quantity: 2)
        let entry3 = LogEntry(timestamp: calendar.date(byAdding: .hour, value: -1, to: now)!, quantity: 3)
        
        modelContext.insert(entry1)
        modelContext.insert(entry2)
        modelContext.insert(entry3)
        try modelContext.save()
        
        let entries = sut.allEntries()
        
        XCTAssertEqual(entries[0].quantity, 2) // Newest
        XCTAssertEqual(entries[1].quantity, 3)
        XCTAssertEqual(entries[2].quantity, 1) // Oldest
    }
    
    // MARK: - Export CSV Tests
    
    func testExportCSVHeader() {
        let csv = sut.exportCSV()
        
        XCTAssertTrue(csv.hasPrefix("timestamp,quantity,source,note\n"))
    }
    
    func testExportCSVWithEntries() throws {
        modelContext.insert(LogEntry(quantity: 1, source: "home_button", note: "First"))
        modelContext.insert(LogEntry(quantity: 2, source: "widget", note: "Second"))
        try modelContext.save()
        
        let csv = sut.exportCSV()
        let lines = csv.split(separator: "\n")
        
        XCTAssertEqual(lines.count, 3) // Header + 2 entries
        XCTAssertTrue(csv.contains("home_button"))
        XCTAssertTrue(csv.contains("widget"))
    }
    
    func testExportCSVEmpty() {
        let csv = sut.exportCSV()
        
        XCTAssertEqual(csv, "timestamp,quantity,source,note\n")
    }
    
    func testExportCSVFormat() throws {
        let entry = LogEntry(quantity: 3, source: "test", note: "Test note")
        modelContext.insert(entry)
        try modelContext.save()
        
        let csv = sut.exportCSV()
        let lines = csv.split(separator: "\n")
        
        // Check that the data line has correct format
        let dataLine = String(lines[1])
        XCTAssertTrue(dataLine.contains(",3,test,\"Test note\""))
    }
    
    func testExportCSVChronologicalOrder() throws {
        let calendar = Calendar.current
        let now = Date()
        
        // Insert in reverse chronological order
        modelContext.insert(LogEntry(timestamp: now, quantity: 3))
        modelContext.insert(LogEntry(timestamp: calendar.date(byAdding: .hour, value: -2, to: now)!, quantity: 1))
        modelContext.insert(LogEntry(timestamp: calendar.date(byAdding: .hour, value: -1, to: now)!, quantity: 2))
        try modelContext.save()
        
        let csv = sut.exportCSV()
        let lines = csv.split(separator: "\n").dropFirst() // Remove header
        
        // CSV should be in chronological order (oldest first)
        // The export calls .reversed() on allEntries which are sorted newest first
        let quantities = lines.compactMap { line -> Int? in
            let components = line.split(separator: ",")
            return components.count > 1 ? Int(components[1]) : nil
        }
        
        XCTAssertEqual(quantities, [1, 2, 3])
    }
    
    func testExportCSVHandlesNilValues() throws {
        let entry = LogEntry(quantity: 1)
        entry.source = nil
        entry.note = nil
        modelContext.insert(entry)
        try modelContext.save()
        
        let csv = sut.exportCSV()
        
        // Should have empty strings for nil values
        XCTAssertTrue(csv.contains(",1,,\"\""))
    }
    
    // MARK: - Edge Case Tests
    
    func testLargeQuantityLog() {
        sut.logPouch(quantity: 1000)
        XCTAssertEqual(sut.todayCount(), 1000)
    }
    
    func testManyEntriesPerformance() throws {
        // Insert many entries
        for _ in 1...100 {
            sut.logPouch(quantity: 1)
        }
        
        XCTAssertEqual(sut.todayCount(), 100)
        XCTAssertEqual(sut.allEntries().count, 100)
    }
    
    func testConcurrentDayBoundary() throws {
        let calendar = Calendar.current
        
        // Entry at 23:59:59 yesterday
        let yesterdayLate = calendar.date(byAdding: .second, value: -1, to: calendar.startOfDay(for: Date()))!
        let entry1 = LogEntry(timestamp: yesterdayLate, quantity: 5)
        
        // Entry at 00:00:00 today
        let todayEarly = calendar.startOfDay(for: Date())
        let entry2 = LogEntry(timestamp: todayEarly, quantity: 3)
        
        modelContext.insert(entry1)
        modelContext.insert(entry2)
        try modelContext.save()
        
        XCTAssertEqual(sut.countForDate(yesterdayLate), 5)
        XCTAssertEqual(sut.countForDate(todayEarly), 3)
    }
}
