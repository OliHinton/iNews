//
//  NotificationsManager.swift
//  iNews
//
//  Created by Oli Hinton on 20/07/2026.
//
import Foundation
import UserNotifications
import Observation

@Observable
class NotificationManager: NotificationManagerProtocol {
    
    static let shared = NotificationManager()

    var isAuthorized = false

    private init() {}

    func requestPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            await MainActor.run {
                isAuthorized = granted
            }
        } catch {
            print("Notification permission error: \(error)")
        }
    }

    func scheduleDailyNotifications(at date: Date) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyNews"])

        let content = UNMutableNotificationContent()
        content.title = "Your Daily News Updates"
        content.body = "Catch up on today's top stories"
        content.sound = .default
        content.badge = 1

        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: "dailyNews", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Scheduling error: \(error)")
            }
        }
    }

    func cancelNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyNews"])
    }

    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        await MainActor.run {
            isAuthorized = settings.authorizationStatus == .authorized
        }
    }
}

