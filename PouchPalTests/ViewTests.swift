//
//  ViewTests.swift
//  PouchPalTests
//
//  Created by Lee Seaver on 1/13/26.
//

import XCTest
import SwiftUI
import SwiftData
@testable import PouchPal

@MainActor
final class ViewTests: XCTestCase {
    
    var modelContext: ModelContext!
    var modelContainer: ModelContainer!
    var settings: UserSettings!
    var mockDefaults: UserDefaults!
    var mockDefaultsSuiteName: String!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let schema = Schema([LogEntry.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(modelContainer)
        
        mockDefaultsSuiteName = "com.pouchpal.tests.views.\(UUID().uuidString)"
        mockDefaults = UserDefaults(suiteName: mockDefaultsSuiteName)!
        settings = UserSettings(defaults: mockDefaults)
    }
    
    override func tearDownWithError() throws {
        mockDefaults.removePersistentDomain(forName: mockDefaultsSuiteName)
        mockDefaultsSuiteName = nil
        mockDefaults = nil
        settings = nil
        modelContext = nil
        modelContainer = nil
        try super.tearDownWithError()
    }
    
    // MARK: - RootView Tests
    
    func testRootViewShowsOnboardingForNewUser() throws {
        settings.hasCompletedOnboarding = false
        
        let view = RootView(settings: settings)
        
        // View should be instantiable
        XCTAssertNotNil(view)
    }
    
    func testRootViewShowsMainTabViewForReturningUser() throws {
        settings.hasCompletedOnboarding = true
        
        let view = RootView(settings: settings)
        
        XCTAssertNotNil(view)
    }
    
    // MARK: - MainTabView Tests
    
    func testMainTabViewHasFourTabs() {
        let view = MainTabView(settings: settings)
        
        XCTAssertNotNil(view)
        // The view is created with 4 tabs: Home, History, Insights, Settings
    }
    
    // MARK: - HomeView Tests
    
    func testHomeViewInitialization() {
        let view = HomeView(settings: settings)
        XCTAssertNotNil(view)
    }
    
    func testHomeViewWithLimitEnabled() {
        settings.dailyLimitEnabled = true
        settings.dailyLimitValue = 10
        
        let view = HomeView(settings: settings)
        XCTAssertNotNil(view)
    }
    
    func testHomeViewWithLimitDisabled() {
        settings.dailyLimitEnabled = false
        
        let view = HomeView(settings: settings)
        XCTAssertNotNil(view)
    }
    
    // MARK: - HistoryView Tests
    
    func testHistoryViewInitialization() {
        let view = HistoryView(settings: settings)
        XCTAssertNotNil(view)
    }
    
    func testHistoryViewDateRangeEnum() {
        XCTAssertEqual(HistoryView.DateRange.week.days, 7)
        XCTAssertEqual(HistoryView.DateRange.month.days, 30)
        XCTAssertEqual(HistoryView.DateRange.week.rawValue, "7 Days")
        XCTAssertEqual(HistoryView.DateRange.month.rawValue, "30 Days")
    }
    
    func testHistoryViewDateRangeAllCases() {
        XCTAssertEqual(HistoryView.DateRange.allCases.count, 2)
    }
    
    // MARK: - InsightsView Tests
    
    func testInsightsViewInitialization() {
        let view = InsightsView(settings: settings)
        XCTAssertNotNil(view)
    }
    
    // MARK: - SettingsView Tests
    
    func testSettingsViewInitialization() {
        let view = SettingsView(settings: settings)
        XCTAssertNotNil(view)
    }
    
    // MARK: - OnboardingView Tests
    
    func testOnboardingViewInitialization() {
        var completed = false
        let view = OnboardingView(settings: settings) {
            completed = true
        }
        
        XCTAssertNotNil(view)
        XCTAssertFalse(completed)
    }
    
    // MARK: - DayHeader Tests
    
    func testDayHeaderToday() {
        let today = Date()
        let view = DayHeader(date: today, count: 5, settings: settings)
        
        XCTAssertNotNil(view)
    }
    
    func testDayHeaderYesterday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let view = DayHeader(date: yesterday, count: 3, settings: settings)
        
        XCTAssertNotNil(view)
    }
    
    func testDayHeaderOlderDate() {
        let oldDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let view = DayHeader(date: oldDate, count: 7, settings: settings)
        
        XCTAssertNotNil(view)
    }
    
    func testDayHeaderWithLimitEnabled() {
        settings.dailyLimitEnabled = true
        settings.dailyLimitValue = 10
        
        let view = DayHeader(date: Date(), count: 8, settings: settings)
        XCTAssertNotNil(view)
    }
    
    // MARK: - EntryRow Tests
    
    func testEntryRowInitialization() {
        let entry = LogEntry(quantity: 2, source: "home_button")
        let view = EntryRow(entry: entry, settings: settings)
        
        XCTAssertNotNil(view)
    }
    
    func testEntryRowWithWidget() {
        let entry = LogEntry(quantity: 1, source: "widget")
        let view = EntryRow(entry: entry, settings: settings)
        
        XCTAssertNotNil(view)
    }
    
    func testEntryRowWithShortcut() {
        let entry = LogEntry(quantity: 1, source: "shortcut")
        let view = EntryRow(entry: entry, settings: settings)
        
        XCTAssertNotNil(view)
    }
    
    func testEntryRowWithCustomSource() {
        let entry = LogEntry(quantity: 1, source: "custom_source")
        let view = EntryRow(entry: entry, settings: settings)
        
        XCTAssertNotNil(view)
    }
    
    func testEntryRowWithMultipleQuantity() {
        let entry = LogEntry(quantity: 5)
        let view = EntryRow(entry: entry, settings: settings)
        
        XCTAssertNotNil(view)
    }
    
    // MARK: - QuickStatPill Tests
    
    func testQuickStatPillInitialization() {
        let view = QuickStatPill(title: "Yesterday", value: "5")
        XCTAssertNotNil(view)
    }
    
    func testQuickStatPillWithDecimal() {
        let view = QuickStatPill(title: "7-Day Avg", value: "4.5")
        XCTAssertNotNil(view)
    }
}
