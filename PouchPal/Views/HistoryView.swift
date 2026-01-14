//
//  HistoryView.swift
//  PouchPal
//
//  Created by Lee Seaver on 1/13/26.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LogEntry.timestamp, order: .reverse) private var allEntries: [LogEntry]
    
    @State private var dataManager: DataManager?
    @State private var selectedDate: Date?
    @State private var showingDatePicker = false
    @State private var dateRange: DateRange = .week
    
    let settings: UserSettings
    
    enum DateRange: String, CaseIterable {
        case week = "7 Days"
        case month = "30 Days"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            }
        }
    }
    
    // MARK: - Computed Properties
    private var groupedEntries: [(date: Date, count: Int, entries: [LogEntry])] {
        let calendar = Calendar.current
        let cutoffDate = calendar.date(byAdding: .day, value: -dateRange.days, to: Date())!
        
        let filtered = allEntries.filter { $0.timestamp >= cutoffDate }
        
        let grouped = Dictionary(grouping: filtered) { entry in
            calendar.startOfDay(for: entry.timestamp)
        }
        
        return grouped.map { (date: $0.key, count: $0.value.reduce(0) { $0 + $1.quantity }, entries: $0.value.sorted { $0.timestamp > $1.timestamp }) }
            .sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Date range picker
                Picker("Range", selection: $dateRange) {
                    ForEach(DateRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, PPSpacing.md)
                .padding(.vertical, PPSpacing.sm)
                
                if groupedEntries.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(groupedEntries, id: \.date) { dayData in
                            Section {
                                ForEach(dayData.entries) { entry in
                                    EntryRow(entry: entry, settings: settings)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                deleteEntry(entry)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            } header: {
                                DayHeader(date: dayData.date, count: dayData.count, settings: settings)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("History")
            .onAppear {
                setupDataManager()
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: PPSpacing.lg) {
            Spacer()
            
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No entries yet")
                .font(PPFont.title())
                .foregroundStyle(.primary)
            
            Text("Your logged pouches will appear here")
                .font(PPFont.body())
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(PPSpacing.xl)
    }
    
    // MARK: - Actions
    private func setupDataManager() {
        if dataManager == nil {
            dataManager = DataManager(modelContext: modelContext)
        }
    }
    
    private func deleteEntry(_ entry: LogEntry) {
        guard let dm = dataManager else { return }
        PPHaptics.notification(.warning)
        withAnimation {
            dm.deleteEntry(entry)
        }
    }
}

// MARK: - Day Header
struct DayHeader: View {
    let date: Date
    let count: Int
    let settings: UserSettings
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private var isYesterday: Bool {
        Calendar.current.isDateInYesterday(date)
    }
    
    private var dateLabel: String {
        if isToday { return "Today" }
        if isYesterday { return "Yesterday" }
        return date.formatted(date: .abbreviated, time: .omitted)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(dateLabel)
                    .font(PPFont.headline())
                    .foregroundStyle(isToday ? Color.ppPrimaryFallback : .primary)
                
                if !isToday && !isYesterday {
                    Text(date.formatted(.dateTime.weekday(.wide)))
                        .font(PPFont.small())
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            HStack(spacing: PPSpacing.sm) {
                Text("\(count)")
                    .font(PPFont.headline(.bold))
                    .foregroundStyle(isToday ? Color.ppPrimaryFallback : .secondary)
                
                Text(settings.unitLabel(for: count))
                    .font(PPFont.caption())
                    .foregroundStyle(.secondary)
                
                if settings.dailyLimitEnabled {
                    MiniProgressRing(
                        progress: settings.progressPercentage(for: count),
                        isOverLimit: settings.isAtOrOverLimit(count: count)
                    )
                }
            }
        }
        .padding(.vertical, PPSpacing.xs)
    }
}

// MARK: - Entry Row
struct EntryRow: View {
    let entry: LogEntry
    let settings: UserSettings
    
    var body: some View {
        HStack(spacing: PPSpacing.md) {
            // Time indicator
            Circle()
                .fill(Color.ppPrimaryFallback.opacity(0.2))
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.timeString)
                    .font(PPFont.body(.medium))
                    .foregroundStyle(.primary)
                
                if let source = entry.source {
                    Text(sourceLabel(source))
                        .font(PPFont.small())
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
            
            if entry.quantity > 1 {
                Text("×\(entry.quantity)")
                    .font(PPFont.caption(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, PPSpacing.sm)
                    .padding(.vertical, PPSpacing.xs)
                    .background(
                        Capsule()
                            .fill(Color.ppPrimaryFallback.opacity(0.1))
                    )
            }
        }
        .padding(.vertical, PPSpacing.xs)
    }
    
    private func sourceLabel(_ source: String) -> String {
        switch source {
        case "home_button": return "Home"
        case "widget": return "Widget"
        case "shortcut": return "Shortcut"
        default: return source.capitalized
        }
    }
}

#Preview {
    HistoryView(settings: UserSettings())
        .modelContainer(for: LogEntry.self, inMemory: true)
}
