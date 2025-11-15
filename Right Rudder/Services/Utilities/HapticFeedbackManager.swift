//
//  HapticFeedbackManager.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import SwiftUI
import UIKit

// MARK: - HapticFeedbackManager

class HapticFeedbackManager {
  // MARK: - Singleton

  static let shared = HapticFeedbackManager()

  private init() {}

  // MARK: - Methods

  // Disable haptic feedback globally
  func disableHapticFeedback() {
    // This is a temporary workaround to prevent haptic feedback errors
    // We'll override the haptic feedback behavior
  }
}
