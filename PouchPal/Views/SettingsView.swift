//
//  SettingsView.swift
//  PouchPal
//
//  Created by Lee Seaver on 1/13/26.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var settings: UserSettings
    
    @State private var dataManager: DataManager?
    @State private var showExportSheet = false
    @State private var exportURL: URL?
    @State private var showResetAlert = false
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    
    var body: some View {
        NavigationStack {
            List {
                // Daily Limit Section
                Section {
                    Toggle("Enable Daily Limit", isOn: $settings.dailyLimitEnabled)
                    
                    if settings.dailyLimitEnabled {
                        Stepper(value: $settings.dailyLimitValue, in: 1...50) {
                            HStack {
                                Text("Daily Limit")
                                Spacer()
                                Text("\(settings.dailyLimitValue)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: PPSpacing.sm) {
                            Text("Approach Warning")
                            Text("Notify when reaching \(Int(settings.approachThreshold * 100))% of limit")
                                .font(PPFont.small())
                                .foregroundStyle(.secondary)
                            
                            Slider(value: $settings.approachThreshold, in: 0.5...0.95, step: 0.05)
                        }
                    }
                } header: {
                    Text("Limits")
                } footer: {
                    Text("Set a daily limit to track your progress throughout the day.")
                }
                
                // Notifications Section
                Section {
                    if notificationStatus == .denied {
                        HStack {
                            Text("Notifications Disabled")
                            Spacer()
                            Button("Settings") {
                                openAppSettings()
                            }
                            .font(PPFont.caption(.semibold))
                        }
                    } else {
                        Toggle("Enable Notifications", isOn: $settings.notificationsEnabled)
                            .onChange(of: settings.notificationsEnabled) { _, newValue in
                                if newValue {
                                    requestNotificationPermission()
                                }
                            }
                        
                        if settings.notificationsEnabled && settings.dailyLimitEnabled {
                            Toggle("Approaching Limit", isOn: $settings.approachingLimitNotification)
                            Toggle("Limit Reached", isOn: $settings.limitReachedNotification)
                        }
                        
                        if settings.notificationsEnabled {
                            Toggle("Daily Summary", isOn: $settings.dailySummaryEnabled)
                                .onChange(of: settings.dailySummaryEnabled) { _, newValue in
                                    if newValue {
                                        scheduleDailySummaryNotification()
                                    } else {
                                        NotificationManager.shared.cancelDailySummary()
                                    }
                                }
                            
                            if settings.dailySummaryEnabled {
                                DatePicker(
                                    "Summary Time",
                                    selection: $settings.dailySummaryTime,
                                    displayedComponents: .hourAndMinute
                                )
                                .onChange(of: settings.dailySummaryTime) { _, _ in
                                    scheduleDailySummaryNotification()
                                }
                            }
                        }
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Notifications are optional and require your permission.")
                }
                
                // Customization Section
                Section {
                    HStack {
                        Text("Singular")
                        Spacer()
                        TextField("pouch", text: $settings.unitLabelSingular)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 120)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Plural")
                        Spacer()
                        TextField("pouches", text: $settings.unitLabelPlural)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 120)
                            .multilineTextAlignment(.trailing)
                    }
                } header: {
                    Text("Unit Labels")
                } footer: {
                    Text("Customize how your entries are labeled.")
                }
                
                // Data Section
                Section {
                    Button(action: exportData) {
                        HStack {
                            Label("Export Data (CSV)", systemImage: "square.and.arrow.up")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .foregroundStyle(.primary)
                    
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Label("Delete All Data", systemImage: "trash")
                    }
                } header: {
                    Text("Data")
                } footer: {
                    Text("Export your data as a CSV file or delete all entries. This action cannot be undone.")
                }
                
                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://apple.com")!) {
                        HStack {
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .foregroundStyle(.primary)
                } header: {
                    Text("About")
                } footer: {
                    VStack(spacing: PPSpacing.sm) {
                        Text("PouchPal stores all data locally on your device.")
                        Text("No accounts, no cloud sync, no data sharing.")
                    }
                    .padding(.top, PPSpacing.sm)
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                setupDataManager()
                checkNotificationStatus()
            }
            .sheet(isPresented: $showExportSheet) {
                if let url = exportURL {
                    ShareSheet(activityItems: [url])
                }
            }
            .alert("Delete All Data", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text("This will permanently delete all your logged entries. This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Actions
    private func setupDataManager() {
        if dataManager == nil {
            dataManager = DataManager(modelContext: modelContext)
        }
    }
    
    private func checkNotificationStatus() {
        Task {
            notificationStatus = await NotificationManager.shared.checkPermissionStatus()
        }
    }
    
    private func requestNotificationPermission() {
        Task {
            let granted = await NotificationManager.shared.requestPermission()
            if !granted {
                settings.notificationsEnabled = false
            }
            await MainActor.run {
                checkNotificationStatus()
            }
        }
    }
    
    private func scheduleDailySummaryNotification() {
        NotificationManager.shared.scheduleDailySummary(
            hour: settings.dailySummaryHour,
            minute: settings.dailySummaryMinute
        )
    }
    
    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func exportData() {
        guard let dm = dataManager else { return }
        
        let csvContent = dm.exportCSV()
        let fileName = "pouchpal_export_\(Date().formatted(.iso8601.year().month().day())).csv"
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
            exportURL = tempURL
            showExportSheet = true
        } catch {
            print("Export error: \(error)")
        }
    }
    
    private func deleteAllData() {
        guard let dm = dataManager else { return }
        
        let entries = dm.allEntries()
        for entry in entries {
            dm.deleteEntry(entry)
        }
        
        PPHaptics.notification(.success)
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView(settings: UserSettings())
        .modelContainer(for: LogEntry.self, inMemory: true)
}
