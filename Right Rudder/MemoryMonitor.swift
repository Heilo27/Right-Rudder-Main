//
//  MemoryMonitor.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation
import UIKit

class MemoryMonitor {
  static let shared = MemoryMonitor()

  private var memoryWarningCount = 0
  private let maxMemoryWarnings = 3

  private init() {
    setupMemoryMonitoring()
  }

  private func setupMemoryMonitoring() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleMemoryWarning),
      name: UIApplication.didReceiveMemoryWarningNotification,
      object: nil
    )
  }

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
