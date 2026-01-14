//
//  PouchPalWidget.swift
//  PouchPalWidget
//
//  Created by Lee Seaver on 1/13/26.
//

import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Widget Entry
struct PouchPalEntry: TimelineEntry {
    let date: Date
    let todayCount: Int
    let dailyLimit: Int?
    let unitLabel: String
}

// MARK: - Timeline Provider
struct PouchPalProvider: TimelineProvider {
    func placeholder(in context: Context) -> PouchPalEntry {
        PouchPalEntry(
            date: Date(),
            todayCount: 5,
            dailyLimit: 10,
            unitLabel: "pouches"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PouchPalEntry) -> Void) {
        let entry = createEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PouchPalEntry>) -> Void) {
        let entry = createEntry()
        
        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func createEntry() -> PouchPalEntry {
        let defaults = UserDefaults(suiteName: "group.com.pouchpal.shared") ?? .standard
        
        let todayCount = defaults.integer(forKey: "todayCount")
        let dailyLimitEnabled = defaults.bool(forKey: "dailyLimitEnabled")
        let dailyLimitValue = defaults.integer(forKey: "dailyLimitValue")
        let unitLabel = defaults.string(forKey: "unitLabelPlural") ?? "pouches"
        
        return PouchPalEntry(
            date: Date(),
            todayCount: todayCount,
            dailyLimit: dailyLimitEnabled ? dailyLimitValue : nil,
            unitLabel: unitLabel
        )
    }
}

// MARK: - Small Widget View
struct SmallWidgetView: View {
    let entry: PouchPalEntry
    
    private var progress: Double {
        guard let limit = entry.dailyLimit, limit > 0 else { return 0 }
        return min(Double(entry.todayCount) / Double(limit), 1.0)
    }
    
    private var isOverLimit: Bool {
        guard let limit = entry.dailyLimit else { return false }
        return entry.todayCount >= limit
    }
    
    var body: some View {
        VStack(spacing: 8) {
            if entry.dailyLimit != nil {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            isOverLimit ? Color.red : Color.blue,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 2) {
                        Text("\(entry.todayCount)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                        
                        if let limit = entry.dailyLimit {
                            Text("of \(limit)")
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(width: 70, height: 70)
            } else {
                Text("\(entry.todayCount)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                
                Text(entry.unitLabel)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            
            Text("today")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.tertiary)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Medium Widget View
struct MediumWidgetView: View {
    let entry: PouchPalEntry
    
    private var progress: Double {
        guard let limit = entry.dailyLimit, limit > 0 else { return 0 }
        return min(Double(entry.todayCount) / Double(limit), 1.0)
    }
    
    private var isOverLimit: Bool {
        guard let limit = entry.dailyLimit else { return false }
        return entry.todayCount >= limit
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Count display
            VStack(alignment: .leading, spacing: 4) {
                Text("\(entry.todayCount)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                
                Text("\(entry.unitLabel) today")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                
                if let limit = entry.dailyLimit {
                    Text("\(entry.todayCount) of \(limit)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(isOverLimit ? .red : .blue)
                }
            }
            
            Spacer()
            
            // Progress ring
            if entry.dailyLimit != nil {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            isOverLimit ? Color.red : Color.blue,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .frame(width: 60, height: 60)
            }
            
            // Add button
            Button(intent: LogPouchIntent()) {
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Accessory Circular (Lock Screen)
struct AccessoryCircularView: View {
    let entry: PouchPalEntry
    
    private var progress: Double {
        guard let limit = entry.dailyLimit, limit > 0 else { return 0 }
        return min(Double(entry.todayCount) / Double(limit), 1.0)
    }
    
    var body: some View {
        if entry.dailyLimit != nil {
            Gauge(value: progress) {
                Text("\(entry.todayCount)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .gaugeStyle(.accessoryCircularCapacity)
        } else {
            VStack(spacing: 0) {
                Text("\(entry.todayCount)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Text("today")
                    .font(.system(size: 8, weight: .medium))
            }
        }
    }
}

// MARK: - Accessory Rectangular (Lock Screen)
struct AccessoryRectangularView: View {
    let entry: PouchPalEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("PouchPal")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(entry.todayCount)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    
                    if let limit = entry.dailyLimit {
                        Text("/ \(limit)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                
                Text("\(entry.unitLabel) today")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Widget Configuration
struct PouchPalWidget: Widget {
    let kind: String = "PouchPalWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PouchPalProvider()) { entry in
            SmallWidgetView(entry: entry)
        }
        .configurationDisplayName("Today's Count")
        .description("See your daily pouch count at a glance.")
        .supportedFamilies([.systemSmall])
    }
}

struct PouchPalMediumWidget: Widget {
    let kind: String = "PouchPalMediumWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PouchPalProvider()) { entry in
            MediumWidgetView(entry: entry)
        }
        .configurationDisplayName("Today's Count + Quick Log")
        .description("See your count and quickly log a pouch.")
        .supportedFamilies([.systemMedium])
    }
}

struct PouchPalLockScreenWidget: Widget {
    let kind: String = "PouchPalLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PouchPalProvider()) { entry in
            AccessoryCircularView(entry: entry)
        }
        .configurationDisplayName("Count Circle")
        .description("Circular count display for lock screen.")
        .supportedFamilies([.accessoryCircular])
    }
}

struct PouchPalLockScreenRectWidget: Widget {
    let kind: String = "PouchPalLockScreenRectWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PouchPalProvider()) { entry in
            AccessoryRectangularView(entry: entry)
        }
        .configurationDisplayName("Count Rectangular")
        .description("Rectangular count display for lock screen.")
        .supportedFamilies([.accessoryRectangular])
    }
}

// MARK: - Widget Bundle
@main
struct PouchPalWidgetBundle: WidgetBundle {
    var body: some Widget {
        PouchPalWidget()
        PouchPalMediumWidget()
        PouchPalLockScreenWidget()
        PouchPalLockScreenRectWidget()
    }
}

// MARK: - Previews
#Preview("Small", as: .systemSmall) {
    PouchPalWidget()
} timeline: {
    PouchPalEntry(date: Date(), todayCount: 5, dailyLimit: 10, unitLabel: "pouches")
    PouchPalEntry(date: Date(), todayCount: 12, dailyLimit: 10, unitLabel: "pouches")
}

#Preview("Medium", as: .systemMedium) {
    PouchPalMediumWidget()
} timeline: {
    PouchPalEntry(date: Date(), todayCount: 7, dailyLimit: 10, unitLabel: "pouches")
}

#Preview("Lock Screen Circular", as: .accessoryCircular) {
    PouchPalLockScreenWidget()
} timeline: {
    PouchPalEntry(date: Date(), todayCount: 5, dailyLimit: 10, unitLabel: "pouches")
}

#Preview("Lock Screen Rect", as: .accessoryRectangular) {
    PouchPalLockScreenRectWidget()
} timeline: {
    PouchPalEntry(date: Date(), todayCount: 5, dailyLimit: 10, unitLabel: "pouches")
}
