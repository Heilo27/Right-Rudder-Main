//
//  MemoryMonitor.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation
import UIKit

// MARK: - MemoryMonitor

class MemoryMonitor {
  // MARK: - Singleton

  static let shared = MemoryMonitor()

  // MARK: - Properties

  private var memoryWarningCount = 0
  private let maxMemoryWarnings = 3

  // MARK: - Initialization

  private init() {
    setupMemoryMonitoring()
  }

  // MARK: - Setup

  private func setupMemoryMonitoring() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleMemoryWarning),
      name: UIApplication.didReceiveMemoryWarningNotification,
      object: nil
    )
  }

  // MARK: - Memory Warning Handling

  @objc private func handleMemoryWarning() {
    memoryWarningCount += 1
    print("Memory warning #\(memoryWarningCount) received")

    // Clear all caches aggressively
    ImageOptimizationService.shared.clearCache()

    // If we're getting too many warnings, take more drastic measures
    if memoryWarningCount >= maxMemoryWarnings {
      print("Multiple memory warnings detected - implementing aggressive cleanup")
      performAggressiveCleanup()
    }
  }

  private func performAggressiveCleanup() {
    // Clear all image caches
    ImageOptimizationService.shared.clearCache()

    // Force garbage collection
    DispatchQueue.main.async {
      autoreleasepool {
        // This will help clean up any lingering references
      }
    }

    // Reset warning count
    memoryWarningCount = 0
  }

  // MARK: - Memory Usage

  func getMemoryUsage() -> String {
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
      let usedMB = info.resident_size / 1024 / 1024
      return "Memory usage: \(usedMB) MB"
    } else {
      return "Memory usage: Unable to determine"
    }
  }
}
