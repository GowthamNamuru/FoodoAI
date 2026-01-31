//
//  NetworkingMonitor.swift
//  FoodoAI
//
//  Created by Gowtham Namuru on 31/01/26.
//

import Foundation
import Network

protocol NetworkMonitoring {
    var isReachable: Bool { get }
}

final class NetworkMonitor: NetworkMonitoring {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    private var reachable = true

    var isReachable: Bool { reachable }

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.reachable = (path.status == .satisfied)
        }
        monitor.start(queue: queue)
    }

    deinit { monitor.cancel() }
}
