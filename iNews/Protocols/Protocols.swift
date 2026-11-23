//
//  Protocols.swift
//  iNews
//
//  Created by Oli Hinton on 22/07/2026.
//

import Foundation

protocol NewsServiceProtocol {
    func fetchTopHeadlines(category: Category) async throws -> [Article]
    func fetchSearchResults(query: String, category: Category) async throws -> [Article]
    func clearCache() async
}

@MainActor
protocol NetworkMonitorProtocol {
    var isConnected: Bool { get }
}

protocol NotificationManagerProtocol {
    var isAuthorized: Bool { get }
    func requestPermission() async
    func scheduleDailyNotifications(at time: Date)
    func cancelNotifications()
    func checkAuthorizationStatus() async
}
