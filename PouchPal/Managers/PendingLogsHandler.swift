//
//  PendingLogsHandler.swift
//  PouchPal
//
//  Created by Lee Seaver on 1/13/26.
//

import Foundation
import SwiftData

@MainActor
final class PendingLogsHandler {
    static let shared = PendingLogsHandler()
    
    private init() {}
    
    func processPendingLogs(modelContext: ModelContext) {
        let defaults = UserDefaults.appGroup
        guard let pendingLogs = defaults.array(forKey: "pendingLogs") as? [[String: Any]], !pendingLogs.isEmpty else {
            return
        }
        
        for logData in pendingLogs {
            guard let timestamp = logData["timestamp"] as? TimeInterval,
                  let quantity = logData["quantity"] as? Int,
                  let source = logData["source"] as? String else {
                continue
            }
            
            let entry = LogEntry(
                timestamp: Date(timeIntervalSince1970: timestamp),
                quantity: quantity,
                source: source
            )
            modelContext.insert(entry)
        }
        
        // Clear pending logs
        defaults.removeObject(forKey: "pendingLogs")
        
        // Save changes
        try? modelContext.save()
        
        // Update today count in shared defaults for widgets
        updateSharedTodayCount(modelContext: modelContext)
    }
    
    func updateSharedTodayCount(modelContext: ModelContext) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<LogEntry> { entry in
            entry.timestamp >= startOfDay && entry.timestamp < endOfDay
        }
        
        let descriptor = FetchDescriptor<LogEntry>(predicate: predicate)
        let entries = (try? modelContext.fetch(descriptor)) ?? []
        let todayCount = entries.reduce(0) { $0 + $1.quantity }
        
        UserDefaults.appGroup.set(todayCount, forKey: "todayCount")
        UserDefaults.appGroup.set(Date(), forKey: "lastUpdated")
    }
    
    func syncSettingsToAppGroup(settings: UserSettings) {
        let defaults = UserDefaults.appGroup
        defaults.set(settings.dailyLimitEnabled, forKey: "dailyLimitEnabled")
        defaults.set(settings.dailyLimitValue, forKey: "dailyLimitValue")
        defaults.set(settings.unitLabelPlural, forKey: "unitLabelPlural")
        defaults.set(settings.unitLabelSingular, forKey: "unitLabelSingular")
    }
}
