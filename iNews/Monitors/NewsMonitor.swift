//
//  NewsMonitor.swift
//  iNews
//
//  Created by Oli Hinton on 22/07/2026.
//

import Network
import Observation

@MainActor
@Observable
final class NetworkMonitor: NetworkMonitorProtocol {
    static let shared = NetworkMonitor()
    
    private(set) var isConnected = true
    
    private let monitor = NWPathMonitor()
    
    private init() {
        Task {
            for await path in pathUpdates() {
                isConnected = path.status == .satisfied
            }
        }
    }
    
    private func pathUpdates() -> AsyncStream<NWPath> {
        AsyncStream { continuation in
            monitor.pathUpdateHandler = { path in
                continuation.yield(path)
            }
            monitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
            
            continuation.onTermination = { [monitor] _ in
                monitor.cancel()
            }
        }
    }
}

