//
//  MockNotficationsManager.swift
//  iNews
//
//  Created by Oli Hinton on 21/08/2026.
//

import Foundation

final class MockNotificationManager: NotificationManagerProtocol {
    var isAuthorized: Bool = false
    var shouldGrantPermission: Bool = false
    
    private(set) var requestPermissionCallCount = 0
    private(set) var scheduleCallCount = 0
    private(set) var cancelCallCount = 0
    private(set) var lastScheduledDate: Date?
    
    func requestPermission() async {
        requestPermissionCallCount += 1
        isAuthorized = shouldGrantPermission
    }
    
    func scheduleDailyNotifications(at time: Date) {
        scheduleCallCount += 1
        lastScheduledDate = time
    }
    
    func cancelNotifications() {
        cancelCallCount += 1
    }
    
    func checkAuthorizationStatus() async {
        
    }
}
