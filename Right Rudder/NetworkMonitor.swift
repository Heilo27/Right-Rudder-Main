//
//  NetworkMonitor.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Combine
import Foundation
import Network

// MARK: - NetworkMonitor

/// Monitors network connectivity
class NetworkMonitor: ObservableObject {
  // MARK: - Published Properties

  @Published var isConnected = true

  // MARK: - Properties

  var onConnectivityChange: ((Bool) -> Void)?

  private let monitor = NWPathMonitor()
  private let queue = DispatchQueue(label: "NetworkMonitor")

  // MARK: - Initialization

  init() {
    monitor.pathUpdateHandler = { [weak self] path in
      DispatchQueue.main.async {
        let wasConnected = self?.isConnected ?? false
        self?.isConnected = path.status == .satisfied

        if wasConnected != self?.isConnected {
          self?.onConnectivityChange?(self?.isConnected ?? false)
        }
      }
    }
    monitor.start(queue: queue)
  }

  deinit {
    monitor.cancel()
  }
}

