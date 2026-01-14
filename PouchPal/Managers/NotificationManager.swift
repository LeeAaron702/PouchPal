//
//  NotificationManager.swift
//  PouchPal
//
//  Created by Lee Seaver on 1/13/26.
//

import Foundation
import UserNotifications

@MainActor
final class NotificationManager: NSObject {
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        // Set delegate to show notifications even when app is in foreground
        UNUserNotificationCenter.current().delegate = self
    }
    
    // MARK: - Permission
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }
    
    func checkPermissionStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
    
    // MARK: - Scheduling
    func scheduleApproachingLimitNotification(currentCount: Int, limit: Int, threshold: Double) {
        guard Double(currentCount) / Double(limit) >= threshold else { return }
        
        // Remove any existing approaching limit notification first
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["approachingLimit"]
        )
        
        let content = UNMutableNotificationContent()
        content.title = "Approaching Daily Limit"
        content.body = "You've used \(currentCount) of \(limit) pouches today."
        content.sound = .default
        
        // Trigger after 1 second delay so it shows properly
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "approachingLimit",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling approaching limit notification: \(error)")
            }
        }
    }
    
    func scheduleLimitReachedNotification(limit: Int) {
        // Remove any existing limit reached notification first
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["limitReached"]
        )
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Limit Reached"
        content.body = "You've reached your daily limit of \(limit) pouches."
        content.sound = .default
        
        // Trigger after 1 second delay so it shows properly
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "limitReached",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling limit reached notification: \(error)")
            }
        }
    }
    
    func scheduleDailySummary(hour: Int, minute: Int) {
        // Cancel existing daily summary
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["dailySummary"]
        )
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Summary"
        content.body = "Tap to see your daily pouch count."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "dailySummary",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily summary: \(error)")
            }
        }
    }
    
    func cancelDailySummary() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["dailySummary"]
        )
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [identifier]
        )
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    // Show notifications even when app is in foreground
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
    
    // Handle notification tap
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}
