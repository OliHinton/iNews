//
//  NotificationsViewModel.swift
//  iNews
//
//  Created by Oli Hinton on 08/08/2026.
//

import Foundation
import Observation

@MainActor
@Observable
class NotificationsViewModel {
    var notificationsEnabled = false
    var selectedTime = Date()
    var showingPermissionAlert = false

    private let notificationManager: NotificationManagerProtocol

    init(notificationManager: NotificationManagerProtocol = NotificationManager.shared) {
        self.notificationManager = notificationManager
    }

    func handleToggle(_ enabled: Bool) async {
        if enabled {
            await notificationManager.requestPermission()
            if notificationManager.isAuthorized {
                notificationManager.scheduleDailyNotifications(at: selectedTime)
            } else {
                notificationsEnabled = false
                showingPermissionAlert = true
            }
        } else {
            notificationManager.cancelNotifications()
        }
    }
    
    func rescheduleNotifications(at date: Date) {
        notificationManager.scheduleDailyNotifications(at: date)
    }

    func refreshAuthorizationStatus() async {
        await notificationManager.checkAuthorizationStatus()
        notificationsEnabled = notificationManager.isAuthorized
    }
}
