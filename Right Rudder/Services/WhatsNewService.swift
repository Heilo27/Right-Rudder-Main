//
//  WhatsNewService.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation

// MARK: - WhatsNewService

class WhatsNewService {
  // MARK: - Properties

  private static let currentAppVersion = "1.6.0"
  private static let lastShownVersionKey = "lastShownWhatsNewVersion"

  // MARK: - Methods

  /// Determines if the "What's New" screen should be shown
  static func shouldShowWhatsNew() -> Bool {
    let userDefaults = UserDefaults.standard
    let lastShownVersion = userDefaults.string(forKey: lastShownVersionKey)

    // Show if we haven't shown it for this version yet
    if lastShownVersion != currentAppVersion {
      return true
    }

    return false
  }

  /// Marks the "What's New" screen as shown for the current version
  static func markAsShown() {
    let userDefaults = UserDefaults.standard
    userDefaults.set(currentAppVersion, forKey: lastShownVersionKey)
    print("What's New screen marked as shown for version \(currentAppVersion)")
  }

  /// Gets the current app version
  static func getCurrentVersion() -> String {
    return currentAppVersion
  }

  /// Resets the "What's New" screen (for testing purposes)
  static func reset() {
    let userDefaults = UserDefaults.standard
    userDefaults.removeObject(forKey: lastShownVersionKey)
    print("What's New screen reset - will show on next launch")
  }
}
