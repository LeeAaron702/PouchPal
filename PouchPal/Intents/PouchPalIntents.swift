//
//  PouchPalIntents.swift
//  PouchPal
//
//  Created by Lee Seaver on 1/13/26.
//

import AppIntents
import SwiftData
import WidgetKit

// MARK: - Log Pouch Intent
struct LogPouchIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Pouch"
    static var description = IntentDescription("Log a pouch to your daily count")
    
    @Parameter(title: "Quantity", default: 1)
    var quantity: Int
    
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult {
        // Save to shared UserDefaults for widget access
        let currentCount = UserDefaults.appGroup.integer(forKey: "todayCount")
        let newCount = currentCount + quantity
        UserDefaults.appGroup.set(newCount, forKey: "todayCount")
        UserDefaults.appGroup.set(Date(), forKey: "lastUpdated")
        
        // Store pending log for main app to pick up
        var pendingLogs = UserDefaults.appGroup.array(forKey: "pendingLogs") as? [[String: Any]] ?? []
        pendingLogs.append([
            "timestamp": Date().timeIntervalSince1970,
            "quantity": quantity,
            "source": "widget"
        ])
        UserDefaults.appGroup.set(pendingLogs, forKey: "pendingLogs")
        
        // Reload widgets
        WidgetCenter.shared.reloadAllTimelines()
        
        return .result()
    }
}

// MARK: - App Shortcuts Provider
struct PouchPalShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogPouchIntent(),
            phrases: [
                "Log a pouch in \(.applicationName)",
                "Add a pouch with \(.applicationName)",
                "Track pouch in \(.applicationName)"
            ],
            shortTitle: "Log Pouch",
            systemImageName: "plus.circle.fill"
        )
    }
}
