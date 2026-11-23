//
//  MockNewsMonitor.swift
//  iNews
//
//  Created by Oli Hinton on 21/08/2026.
//

import Foundation

@MainActor
class MockNetworkMonitor: NetworkMonitorProtocol {
    var isConnected: Bool
    
    init(isConnected: Bool = true) {
        self.isConnected = isConnected
    }
}
