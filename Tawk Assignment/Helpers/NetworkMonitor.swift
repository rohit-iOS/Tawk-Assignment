//
//  NetworkMonitor.swift
//  Tawk Assignment
//
//  Created by Rohit Karyappa on 10/04/2022.
//

import Foundation
import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()

    let monitor = NWPathMonitor()
    private var status: NWPath.Status = .requiresConnection
    var isReachable: Bool { status == .satisfied }

        
    public func startMonitoring(completed: @escaping (Bool) -> Void) {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.status = path.status

            if path.status == .satisfied {
                print("We're connected!")
                // post connected notification
                completed(true)
            } else {
                print("No connection.")
                // post disconnected notification
                completed(false)
            }
        }

        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}
