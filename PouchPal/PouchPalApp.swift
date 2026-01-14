//
//  PouchPalApp.swift
//  PouchPal
//
//  Created by Lee Seaver on 1/13/26.
//

import SwiftUI
import SwiftData

@main
struct PouchPalApp: App {
    @State private var settings = UserSettings()
    
    // Initialize notification manager early to set delegate
    private let notificationManager = NotificationManager.shared
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LogEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView(settings: settings)
                .onAppear {
                    // Sync settings to app group for widgets
                    PendingLogsHandler.shared.syncSettingsToAppGroup(settings: settings)
                    
                    // Re-schedule daily summary if enabled
                    if settings.dailySummaryEnabled {
                        NotificationManager.shared.scheduleDailySummary(
                            hour: settings.dailySummaryHour,
                            minute: settings.dailySummaryMinute
                        )
                    }
                }
                .task {
                    // Process any pending logs from widgets
                    let context = sharedModelContainer.mainContext
                    PendingLogsHandler.shared.processPendingLogs(modelContext: context)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
