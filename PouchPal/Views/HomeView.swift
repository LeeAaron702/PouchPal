//
//  HomeView.swift
//  PouchPal
//
//  Created by Lee Seaver on 1/13/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LogEntry.timestamp, order: .reverse) private var entries: [LogEntry]
    
    @State private var dataManager: DataManager?
    @State private var showUndoToast = false
    @State private var todayCount = 0
    @State private var animateCount = false
    
    let settings: UserSettings
    
    // MARK: - Computed Properties
    private var progress: Double {
        settings.progressPercentage(for: todayCount)
    }
    
    private var progressColor: Color {
        if settings.isAtOrOverLimit(count: todayCount) {
            return .ppDangerFallback
        } else if settings.isApproachingLimit(count: todayCount) {
            return .ppWarningFallback
        }
        return .ppPrimaryFallback
    }
    
    private var limitText: String? {
        guard settings.dailyLimitEnabled else { return nil }
        return "\(todayCount) of \(settings.dailyLimitValue)"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(UIColor.systemBackground),
                        Color(UIColor.systemBackground).opacity(0.95)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: PPSpacing.lg) {
                    Spacer()
                        .frame(maxHeight: PPSpacing.xl)
                    
                    // Main stat display
                    mainStatSection
                    
                    Spacer()
                        .frame(maxHeight: PPSpacing.xxl)
                    
                    // Add button
                    addButtonSection
                    
                    Spacer()
                        .frame(maxHeight: PPSpacing.xl)
                    
                    // Quick stats
                    quickStatsSection
                    
                    Spacer()
                        .frame(maxHeight: PPSpacing.lg)
                }
                .padding(.horizontal, PPSpacing.lg)
                .padding(.bottom, PPSpacing.lg)
                
                // Undo toast
                if showUndoToast {
                    undoToast
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationTitle("PouchPal")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                setupDataManager()
                updateTodayCount()
            }
            .onChange(of: entries.count) {
                updateTodayCount()
            }
        }
    }
    
    // MARK: - Sections
    private var mainStatSection: some View {
        VStack(spacing: PPSpacing.md) {
            ZStack {
                // Progress ring (if limit enabled)
                if settings.dailyLimitEnabled {
                    ProgressRing(
                        progress: progress,
                        lineWidth: 16,
                        size: 220,
                        gradientColors: [progressColor, progressColor.opacity(0.6)]
                    )
                }
                
                // Count display
                VStack(spacing: PPSpacing.xs) {
                    Text("\(todayCount)")
                        .font(PPFont.largeTitle())
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                        .scaleEffect(animateCount ? 1.1 : 1.0)
                        .animation(PPAnimation.bounce, value: animateCount)
                    
                    Text(settings.unitLabel(for: todayCount))
                        .font(PPFont.headline())
                        .foregroundStyle(.secondary)
                    
                    Text("today")
                        .font(PPFont.caption())
                        .foregroundStyle(.tertiary)
                }
            }
            
            // Limit status
            if let limitText {
                HStack(spacing: PPSpacing.sm) {
                    if settings.isAtOrOverLimit(count: todayCount) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(Color.ppDangerFallback)
                    } else if settings.isApproachingLimit(count: todayCount) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(Color.ppWarningFallback)
                    }
                    
                    Text(limitText)
                        .font(PPFont.body(.medium))
                        .foregroundStyle(progressColor)
                }
                .padding(.horizontal, PPSpacing.md)
                .padding(.vertical, PPSpacing.sm)
                .background(
                    Capsule()
                        .fill(progressColor.opacity(0.1))
                )
            }
        }
    }
    
    private var addButtonSection: some View {
        VStack(spacing: PPSpacing.md) {
            AddPouchButton(
                action: {
                    logPouch(quantity: 1)
                },
                quickAddAction: { quantity in
                    logPouch(quantity: quantity)
                }
            )
            
            Text("Tap to log • Hold for options")
                .font(PPFont.small())
                .foregroundStyle(.tertiary)
        }
    }
    
    private var quickStatsSection: some View {
        HStack(spacing: PPSpacing.md) {
            if let dm = dataManager {
                let yesterdayCount = dm.countForDate(Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
                
                QuickStatPill(title: "Yesterday", value: "\(yesterdayCount)")
                
                QuickStatPill(title: "7-Day Avg", value: String(format: "%.1f", dm.weeklyAverage()))
            }
        }
    }
    
    private var undoToast: some View {
        VStack {
            Spacer()
            
            HStack(spacing: PPSpacing.md) {
                Text("Pouch logged")
                    .font(PPFont.body(.medium))
                
                Spacer()
                
                Button("Undo") {
                    undoLastLog()
                }
                .font(PPFont.body(.semibold))
                .foregroundStyle(Color.ppPrimaryFallback)
            }
            .padding(PPSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: PPRadius.lg)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
            )
            .padding(.horizontal, PPSpacing.lg)
            .padding(.bottom, PPSpacing.xl)
        }
    }
    
    // MARK: - Actions
    private func setupDataManager() {
        if dataManager == nil {
            dataManager = DataManager(modelContext: modelContext)
        }
    }
    
    private func updateTodayCount() {
        guard let dm = dataManager else { return }
        todayCount = dm.todayCount()
    }
    
    private func logPouch(quantity: Int) {
        guard let dm = dataManager else { return }
        
        PPHaptics.notification(.success)
        
        withAnimation(PPAnimation.bounce) {
            animateCount = true
        }
        
        dm.logPouch(quantity: quantity, source: "home_button")
        updateTodayCount()
        
        // Check for limit notifications
        checkLimitNotifications()
        
        // Show undo toast
        withAnimation(PPAnimation.smooth) {
            showUndoToast = true
        }
        
        // Reset animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            animateCount = false
        }
        
        // Hide toast after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(PPAnimation.smooth) {
                if showUndoToast {
                    showUndoToast = false
                }
            }
        }
    }
    
    private func undoLastLog() {
        guard let dm = dataManager, dm.canUndo else { return }
        
        PPHaptics.notification(.warning)
        
        dm.undoLastLog()
        updateTodayCount()
        
        withAnimation(PPAnimation.smooth) {
            showUndoToast = false
        }
    }
    
    private func checkLimitNotifications() {
        guard settings.dailyLimitEnabled && settings.notificationsEnabled else { return }
        
        Task {
            // Check permission first
            let status = await NotificationManager.shared.checkPermissionStatus()
            guard status == .authorized else { return }
            
            if settings.approachingLimitNotification && settings.isApproachingLimit(count: todayCount) {
                NotificationManager.shared.scheduleApproachingLimitNotification(
                    currentCount: todayCount,
                    limit: settings.dailyLimitValue,
                    threshold: settings.approachThreshold
                )
            }
            
            if settings.limitReachedNotification && todayCount == settings.dailyLimitValue {
                NotificationManager.shared.scheduleLimitReachedNotification(
                    limit: settings.dailyLimitValue
                )
            }
        }
    }
}

// MARK: - Quick Stat Pill
struct QuickStatPill: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: PPSpacing.xs) {
            Text(value)
                .font(PPFont.headline(.bold))
                .foregroundStyle(.primary)
            
            Text(title)
                .font(PPFont.small())
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, PPSpacing.lg)
        .padding(.vertical, PPSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: PPRadius.lg)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

#Preview {
    HomeView(settings: UserSettings())
        .modelContainer(for: LogEntry.self, inMemory: true)
}
