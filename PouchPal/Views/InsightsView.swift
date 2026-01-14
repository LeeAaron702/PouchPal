//
//  InsightsView.swift
//  PouchPal
//
//  Created by Lee Seaver on 1/13/26.
//

import SwiftUI
import SwiftData

struct InsightsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LogEntry.timestamp, order: .reverse) private var allEntries: [LogEntry]
    
    @State private var dataManager: DataManager?
    @State private var weeklyData: [(date: Date, count: Int)] = []
    @State private var monthlyData: [(date: Date, count: Int)] = []
    @State private var weeklyAverage: Double = 0
    @State private var monthlyAverage: Double = 0
    @State private var totalAllTime: Int = 0
    
    let settings: UserSettings
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: PPSpacing.lg) {
                    // Summary stats
                    summarySection
                    
                    // Weekly chart
                    if !weeklyData.isEmpty {
                        WeeklyChart(
                            data: weeklyData,
                            limit: settings.dailyLimitEnabled ? settings.dailyLimitValue : nil,
                            showLimit: settings.dailyLimitEnabled
                        )
                    }
                    
                    // Monthly chart
                    if !monthlyData.isEmpty {
                        MonthlyMiniChart(data: monthlyData)
                    }
                    
                    // Detailed stats
                    detailedStatsSection
                }
                .padding(PPSpacing.md)
            }
            .navigationTitle("Insights")
            .onAppear {
                setupDataManager()
                refreshData()
            }
            .onChange(of: allEntries.count) {
                refreshData()
            }
        }
    }
    
    // MARK: - Summary Section
    private var summarySection: some View {
        HStack(spacing: PPSpacing.md) {
            StatCard(
                title: "7-Day Average",
                value: String(format: "%.1f", weeklyAverage),
                subtitle: "\(settings.unitLabel(for: Int(weeklyAverage)))/day",
                icon: "chart.bar.fill",
                color: .ppPrimaryFallback
            )
            
            StatCard(
                title: "30-Day Average",
                value: String(format: "%.1f", monthlyAverage),
                subtitle: "\(settings.unitLabel(for: Int(monthlyAverage)))/day",
                icon: "calendar",
                color: .ppSecondaryFallback
            )
        }
    }
    
    // MARK: - Detailed Stats Section
    private var detailedStatsSection: some View {
        VStack(alignment: .leading, spacing: PPSpacing.md) {
            Text("Statistics")
                .font(PPFont.headline())
                .foregroundStyle(.primary)
            
            VStack(spacing: 0) {
                InlineStat(
                    title: "Total (All Time)",
                    value: "\(totalAllTime) \(settings.unitLabel(for: totalAllTime))"
                )
                
                Divider()
                
                InlineStat(
                    title: "This Week",
                    value: "\(weeklyTotal) \(settings.unitLabel(for: weeklyTotal))"
                )
                
                Divider()
                
                InlineStat(
                    title: "This Month",
                    value: "\(monthlyTotal) \(settings.unitLabel(for: monthlyTotal))"
                )
                
                if settings.dailyLimitEnabled {
                    Divider()
                    
                    InlineStat(
                        title: "Days Under Limit",
                        value: "\(daysUnderLimit) of \(weeklyData.count)"
                    )
                }
                
                Divider()
                
                InlineStat(
                    title: "Highest Day",
                    value: "\(highestDay) \(settings.unitLabel(for: highestDay))"
                )
                
                Divider()
                
                InlineStat(
                    title: "Lowest Day",
                    value: "\(lowestDay) \(settings.unitLabel(for: lowestDay))"
                )
            }
            .padding(PPSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: PPRadius.lg)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            
            // Disclaimer
            Text("This data is for personal reference only and is not medical advice.")
                .font(PPFont.small())
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    // MARK: - Computed Stats
    private var weeklyTotal: Int {
        weeklyData.reduce(0) { $0 + $1.count }
    }
    
    private var monthlyTotal: Int {
        monthlyData.reduce(0) { $0 + $1.count }
    }
    
    private var daysUnderLimit: Int {
        guard settings.dailyLimitEnabled else { return 0 }
        return weeklyData.filter { $0.count <= settings.dailyLimitValue }.count
    }
    
    private var highestDay: Int {
        monthlyData.map(\.count).max() ?? 0
    }
    
    private var lowestDay: Int {
        let nonZeroDays = monthlyData.filter { $0.count > 0 }
        return nonZeroDays.map(\.count).min() ?? 0
    }
    
    // MARK: - Data Management
    private func setupDataManager() {
        if dataManager == nil {
            dataManager = DataManager(modelContext: modelContext)
        }
    }
    
    private func refreshData() {
        guard let dm = dataManager else { return }
        
        weeklyData = dm.last7DaysCounts()
        monthlyData = dm.last30DaysCounts()
        weeklyAverage = dm.weeklyAverage()
        monthlyAverage = dm.monthlyAverage()
        totalAllTime = allEntries.reduce(0) { $0 + $1.quantity }
    }
}

#Preview {
    InsightsView(settings: UserSettings())
        .modelContainer(for: LogEntry.self, inMemory: true)
}
