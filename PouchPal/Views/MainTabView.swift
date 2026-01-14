//
//  MainTabView.swift
//  PouchPal
//
//  Created by Lee Seaver on 1/13/26.
//

import SwiftUI

struct MainTabView: View {
    @State var settings: UserSettings
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(settings: settings)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            HistoryView(settings: settings)
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(1)
            
            InsightsView(settings: settings)
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            SettingsView(settings: settings)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(Color.ppPrimaryFallback)
    }
}

#Preview {
    MainTabView(settings: UserSettings())
        .modelContainer(for: LogEntry.self, inMemory: true)
}
