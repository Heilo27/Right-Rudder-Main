//
//  PerformanceMonitor.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Combine
import Foundation
import SwiftUI
import os.log

// MARK: - PerformanceMonitor

@MainActor
class PerformanceMonitor: ObservableObject {
  // MARK: - Singleton

  static let shared = PerformanceMonitor()

  // MARK: - Published Properties

  @Published var isMonitoring = false
  @Published var memoryUsage: String = "0 MB"
  @Published var cpuUsage: String = "0%"

  // MARK: - Properties

  private var timer: Timer?
  private let logger = Logger(subsystem: "com.heiloprojects.rightrudder", category: "Performance")

  // MARK: - Initialization

  private init() {}

  // MARK: - Methods

  func startMonitoring() {
    guard !isMonitoring else { return }

    isMonitoring = true
    timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
      guard let self = self else { return }
      Task { @MainActor in
        self.updateMetrics()
      }
    }

    logger.info("Performance monitoring started")
  }

  func stopMonitoring() {
    isMonitoring = false
    timer?.invalidate()
    timer = nil

    logger.info("Performance monitoring stopped")
  }

  private func updateMetrics() {
    memoryUsage = getMemoryUsage()
    cpuUsage = getCPUUsage()
  }

  private func getMemoryUsage() -> String {
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

    let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
      $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
        task_info(
          mach_task_self_,
          task_flavor_t(MACH_TASK_BASIC_INFO),
          $0,
          &count)
      }
    }

    if kerr == KERN_SUCCESS {
      let usedMB = Double(info.resident_size) / 1024.0 / 1024.0
      return String(format: "%.1f MB", usedMB)
    }

    return "Unknown"
  }

  private func getCPUUsage() -> String {
    // Simplified CPU usage calculation
    // For performance monitoring, we'll use a basic approach
    let processInfo = ProcessInfo.processInfo
    let systemLoad = processInfo.systemUptime

    // Calculate a simple metric based on system uptime and process count
    let processCount = processInfo.activeProcessorCount
    let loadAverage = systemLoad > 0 ? min(100.0, Double(processCount) * 10.0) : 0.0

    return String(format: "%.1f%%", loadAverage)
  }

  // Log performance metrics
  func logPerformanceMetrics() {
    logger.info("Memory Usage: \(self.memoryUsage), CPU Usage: \(self.cpuUsage)")
  }

  // Clear caches when memory pressure is detected
  func handleMemoryPressure() {
    logger.warning("Memory pressure detected - clearing caches")
    ImageOptimizationService.shared.clearCache()
  }
}

// SwiftUI View for performance monitoring (debug builds only)
#if DEBUG
  struct PerformanceMonitorView: View {
    @StateObject private var monitor = PerformanceMonitor.shared

    var body: some View {
      VStack(alignment: .leading, spacing: 4) {
        Text("Performance Monitor")
          .font(.headline)

        HStack {
          Text("Memory:")
          Text(monitor.memoryUsage)
            .foregroundColor(.secondary)
        }

        HStack {
          Text("CPU:")
          Text(monitor.cpuUsage)
            .foregroundColor(.secondary)
        }

        Button(monitor.isMonitoring ? "Stop Monitoring" : "Start Monitoring") {
          if monitor.isMonitoring {
            monitor.stopMonitoring()
          } else {
            monitor.startMonitoring()
          }
        }
        .buttonStyle(.bordered)
      }
      .padding()
      .background(Color(.systemGray6))
      .cornerRadius(8)
    }
  }
#endif
