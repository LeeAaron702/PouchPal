//
//  WeeklyChart.swift
//  PouchPal
//
//  Created by Lee Seaver on 1/13/26.
//

import SwiftUI
import Charts

struct DayData: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
    
    var dayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    var shortDayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}

struct WeeklyChart: View {
    let data: [(date: Date, count: Int)]
    let limit: Int?
    let showLimit: Bool
    
    private var chartData: [DayData] {
        data.map { DayData(date: $0.date, count: $0.count) }
    }
    
    private var maxValue: Int {
        let dataMax = data.map(\.count).max() ?? 0
        let limitValue = showLimit ? (limit ?? 0) : 0
        return max(dataMax, limitValue, 1)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: PPSpacing.md) {
            Text("Last 7 Days")
                .font(PPFont.headline())
                .foregroundStyle(.primary)
            
            Chart(chartData) { item in
                BarMark(
                    x: .value("Day", item.dayLabel),
                    y: .value("Count", item.count)
                )
                .foregroundStyle(
                    item.isToday
                        ? Color.ppPrimaryFallback
                        : Color.ppPrimaryFallback.opacity(0.5)
                )
                .cornerRadius(6)
                .annotation(position: .top, spacing: 4) {
                    if item.count > 0 {
                        Text("\(item.count)")
                            .font(PPFont.small(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                
                if showLimit, let limit {
                    RuleMark(y: .value("Limit", limit))
                        .foregroundStyle(Color.ppWarningFallback.opacity(0.7))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .annotation(position: .trailing, alignment: .trailing) {
                            Text("Limit")
                                .font(PPFont.small())
                                .foregroundStyle(Color.ppWarningFallback)
                        }
                }
            }
            .chartYScale(domain: 0...(maxValue + 2))
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel()
                        .font(PPFont.small())
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel()
                        .font(PPFont.small(.medium))
                }
            }
            .frame(height: 200)
        }
        .padding(PPSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: PPRadius.lg)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

// MARK: - Monthly Mini Chart
struct MonthlyMiniChart: View {
    let data: [(date: Date, count: Int)]
    
    private var chartData: [DayData] {
        data.map { DayData(date: $0.date, count: $0.count) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: PPSpacing.sm) {
            Text("Last 30 Days")
                .font(PPFont.headline())
                .foregroundStyle(.primary)
            
            Chart(chartData) { item in
                BarMark(
                    x: .value("Day", item.date, unit: .day),
                    y: .value("Count", item.count)
                )
                .foregroundStyle(Color.ppSecondaryFallback.opacity(0.7))
                .cornerRadius(2)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { value in
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                        .font(PPFont.small())
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel()
                        .font(PPFont.small())
                }
            }
            .frame(height: 150)
        }
        .padding(PPSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: PPRadius.lg)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

#Preview {
    let sampleData: [(date: Date, count: Int)] = (0..<7).map { offset in
        let date = Calendar.current.date(byAdding: .day, value: -offset, to: Date())!
        return (date, Int.random(in: 3...12))
    }.reversed()
    
    return VStack(spacing: 20) {
        WeeklyChart(data: sampleData, limit: 8, showLimit: true)
        MonthlyMiniChart(data: sampleData)
    }
    .padding()
}
