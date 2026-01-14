//
//  DataManager.swift
//  PouchPal
//
//  Created by Lee Seaver on 1/13/26.
//

import Foundation
import SwiftData
import WidgetKit

@MainActor
@Observable
final class DataManager {
    // MARK: - Properties
    private let modelContext: ModelContext
    private(set) var lastLogEntry: LogEntry?
    private(set) var lastLogTime: Date?
    
    var canUndo: Bool {
        guard let lastLogTime else { return false }
        return Date().timeIntervalSince(lastLogTime) < 30
    }
    
    // MARK: - Init
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Logging
    func logPouch(quantity: Int = 1, source: String = "home_button") {
        let entry = LogEntry(quantity: quantity, source: source)
        modelContext.insert(entry)
        lastLogEntry = entry
        lastLogTime = Date()
        
        try? modelContext.save()
        updateWidgets()
    }
    
    func undoLastLog() {
        guard canUndo, let lastEntry = lastLogEntry else { return }
        modelContext.delete(lastEntry)
        lastLogEntry = nil
        lastLogTime = nil
        
        try? modelContext.save()
        updateWidgets()
    }
    
    func deleteEntry(_ entry: LogEntry) {
        if entry.id == lastLogEntry?.id {
            lastLogEntry = nil
            lastLogTime = nil
        }
        modelContext.delete(entry)
        
        try? modelContext.save()
        updateWidgets()
    }
    
    func updateEntryTimestamp(_ entry: LogEntry, to newTimestamp: Date) {
        entry.timestamp = newTimestamp
        
        try? modelContext.save()
        updateWidgets()
    }
    
    // MARK: - Queries
    func todayCount() -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<LogEntry> { entry in
            entry.timestamp >= startOfDay && entry.timestamp < endOfDay
        }
        
        let descriptor = FetchDescriptor<LogEntry>(predicate: predicate)
        let entries = (try? modelContext.fetch(descriptor)) ?? []
        return entries.reduce(0) { $0 + $1.quantity }
    }
    
    func countForDate(_ date: Date) -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<LogEntry> { entry in
            entry.timestamp >= startOfDay && entry.timestamp < endOfDay
        }
        
        let descriptor = FetchDescriptor<LogEntry>(predicate: predicate)
        let entries = (try? modelContext.fetch(descriptor)) ?? []
        return entries.reduce(0) { $0 + $1.quantity }
    }
    
    func entriesForDate(_ date: Date) -> [LogEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<LogEntry> { entry in
            entry.timestamp >= startOfDay && entry.timestamp < endOfDay
        }
        
        var descriptor = FetchDescriptor<LogEntry>(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.timestamp, order: .reverse)]
        
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func last7DaysCounts() -> [(date: Date, count: Int)] {
        let calendar = Calendar.current
        var results: [(Date, Int)] = []
        
        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date())!
            let count = countForDate(date)
            results.append((date, count))
        }
        
        return results.reversed()
    }
    
    func last30DaysCounts() -> [(date: Date, count: Int)] {
        let calendar = Calendar.current
        var results: [(Date, Int)] = []
        
        for dayOffset in 0..<30 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date())!
            let count = countForDate(date)
            results.append((date, count))
        }
        
        return results.reversed()
    }
    
    func weeklyAverage() -> Double {
        let counts = last7DaysCounts()
        let total = counts.reduce(0) { $0 + $1.count }
        return Double(total) / 7.0
    }
    
    func monthlyAverage() -> Double {
        let counts = last30DaysCounts()
        let total = counts.reduce(0) { $0 + $1.count }
        return Double(total) / 30.0
    }
    
    func allEntries() -> [LogEntry] {
        var descriptor = FetchDescriptor<LogEntry>()
        descriptor.sortBy = [SortDescriptor(\.timestamp, order: .reverse)]
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    // MARK: - Export
    func exportCSV() -> String {
        let entries = allEntries().reversed()
        var csv = "timestamp,quantity,source,note\n"
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        for entry in entries {
            let timestamp = formatter.string(from: entry.timestamp)
            let quantity = entry.quantity
            let source = entry.source ?? ""
            let note = entry.note ?? ""
            csv += "\(timestamp),\(quantity),\(source),\"\(note)\"\n"
        }
        
        return csv
    }
    
    // MARK: - Widget Updates
    private func updateWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
        
        // Also save to shared UserDefaults for widgets
        let todayTotal = todayCount()
        UserDefaults.appGroup.set(todayTotal, forKey: "todayCount")
        UserDefaults.appGroup.set(Date(), forKey: "lastUpdated")
    }
}
