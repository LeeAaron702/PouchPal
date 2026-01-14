//
//  ContentView.swift
//  PouchPal
//
//  Created by Lee Seaver on 1/13/26.
//

import SwiftUI
import SwiftData

// MARK: - Root View (handles onboarding flow)
struct RootView: View {
    @State var settings: UserSettings
    @State private var showOnboarding: Bool
    
    init(settings: UserSettings) {
        self._settings = State(initialValue: settings)
        self._showOnboarding = State(initialValue: !settings.hasCompletedOnboarding)
    }
    
    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView(settings: settings) {
                    withAnimation(PPAnimation.smooth) {
                        showOnboarding = false
                    }
                }
            } else {
                MainTabView(settings: settings)
            }
        }
        .animation(PPAnimation.smooth, value: showOnboarding)
    }
}

// MARK: - Legacy ContentView (kept for compatibility)
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [LogEntry]
    @State private var settings = UserSettings()

    var body: some View {
        RootView(settings: settings)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: LogEntry.self, inMemory: true)
}
