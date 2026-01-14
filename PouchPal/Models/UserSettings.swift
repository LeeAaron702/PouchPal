//
//  UserSettings.swift
//  PouchPal
//
//  Created by Lee Seaver on 1/13/26.
//

import Foundation
import SwiftUI

@Observable
final class UserSettings {
    // MARK: - Keys
    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let dailyLimitEnabled = "dailyLimitEnabled"
        static let dailyLimitValue = "dailyLimitValue"
        static let approachThreshold = "approachThreshold"
        static let unitLabelSingular = "unitLabelSingular"
        static let unitLabelPlural = "unitLabelPlural"
        static let strengthMg = "strengthMg"
        static let notificationsEnabled = "notificationsEnabled"
        static let approachingLimitNotification = "approachingLimitNotification"
        static let limitReachedNotification = "limitReachedNotification"
        static let dailySummaryEnabled = "dailySummaryEnabled"
        static let dailySummaryHour = "dailySummaryHour"
        static let dailySummaryMinute = "dailySummaryMinute"
    }
    
    // MARK: - UserDefaults
    private let defaults: UserDefaults
    
    // MARK: - Properties
    var hasCompletedOnboarding: Bool {
        didSet { defaults.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding) }
    }
    
    var dailyLimitEnabled: Bool {
        didSet { defaults.set(dailyLimitEnabled, forKey: Keys.dailyLimitEnabled) }
    }
    
    var dailyLimitValue: Int {
        didSet { defaults.set(dailyLimitValue, forKey: Keys.dailyLimitValue) }
    }
    
    var approachThreshold: Double {
        didSet { defaults.set(approachThreshold, forKey: Keys.approachThreshold) }
    }
    
    var unitLabelSingular: String {
        didSet { defaults.set(unitLabelSingular, forKey: Keys.unitLabelSingular) }
    }
    
    var unitLabelPlural: String {
        didSet { defaults.set(unitLabelPlural, forKey: Keys.unitLabelPlural) }
    }
    
    var strengthMg: Int? {
        didSet { defaults.set(strengthMg, forKey: Keys.strengthMg) }
    }
    
    var notificationsEnabled: Bool {
        didSet { defaults.set(notificationsEnabled, forKey: Keys.notificationsEnabled) }
    }
    
    var approachingLimitNotification: Bool {
        didSet { defaults.set(approachingLimitNotification, forKey: Keys.approachingLimitNotification) }
    }
    
    var limitReachedNotification: Bool {
        didSet { defaults.set(limitReachedNotification, forKey: Keys.limitReachedNotification) }
    }
    
    var dailySummaryEnabled: Bool {
        didSet { defaults.set(dailySummaryEnabled, forKey: Keys.dailySummaryEnabled) }
    }
    
    var dailySummaryHour: Int {
        didSet { defaults.set(dailySummaryHour, forKey: Keys.dailySummaryHour) }
    }
    
    var dailySummaryMinute: Int {
        didSet { defaults.set(dailySummaryMinute, forKey: Keys.dailySummaryMinute) }
    }
    
    // MARK: - Computed Properties
    var dailySummaryTime: Date {
        get {
            var components = DateComponents()
            components.hour = dailySummaryHour
            components.minute = dailySummaryMinute
            return Calendar.current.date(from: components) ?? Date()
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            dailySummaryHour = components.hour ?? 20
            dailySummaryMinute = components.minute ?? 0
        }
    }
    
    // MARK: - Init
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        
        // Load values from UserDefaults
        self.hasCompletedOnboarding = defaults.bool(forKey: Keys.hasCompletedOnboarding)
        self.dailyLimitEnabled = defaults.bool(forKey: Keys.dailyLimitEnabled)
        self.dailyLimitValue = defaults.object(forKey: Keys.dailyLimitValue) as? Int ?? 10
        self.approachThreshold = defaults.object(forKey: Keys.approachThreshold) as? Double ?? 0.8
        self.unitLabelSingular = defaults.string(forKey: Keys.unitLabelSingular) ?? "pouch"
        self.unitLabelPlural = defaults.string(forKey: Keys.unitLabelPlural) ?? "pouches"
        self.strengthMg = defaults.object(forKey: Keys.strengthMg) as? Int
        self.notificationsEnabled = defaults.bool(forKey: Keys.notificationsEnabled)
        self.approachingLimitNotification = defaults.bool(forKey: Keys.approachingLimitNotification)
        self.limitReachedNotification = defaults.bool(forKey: Keys.limitReachedNotification)
        self.dailySummaryEnabled = defaults.bool(forKey: Keys.dailySummaryEnabled)
        self.dailySummaryHour = defaults.object(forKey: Keys.dailySummaryHour) as? Int ?? 20
        self.dailySummaryMinute = defaults.object(forKey: Keys.dailySummaryMinute) as? Int ?? 0
    }
    
    // MARK: - Helper Methods
    func unitLabel(for count: Int) -> String {
        count == 1 ? unitLabelSingular : unitLabelPlural
    }
    
    func progressPercentage(for count: Int) -> Double {
        guard dailyLimitEnabled, dailyLimitValue > 0 else { return 0 }
        return min(Double(count) / Double(dailyLimitValue), 1.0)
    }
    
    func isApproachingLimit(count: Int) -> Bool {
        guard dailyLimitEnabled else { return false }
        return progressPercentage(for: count) >= approachThreshold && count < dailyLimitValue
    }
    
    func isAtOrOverLimit(count: Int) -> Bool {
        guard dailyLimitEnabled else { return false }
        return count >= dailyLimitValue
    }
}

// MARK: - App Group Support for Widgets
// Note: To enable widget support, add App Group capability in Xcode:
// 1. Select target → Signing & Capabilities → + Capability → App Groups
// 2. Add: group.com.leeaaronsoftware.pouchpal.shared
// 3. Add the same App Group to the Widget extension target
extension UserDefaults {
    static let appGroup = UserDefaults(suiteName: "group.com.leeaaronsoftware.pouchpal.shared") ?? .standard
}
