//
//  NoHapticButtonStyle.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

// MARK: - NoHapticButtonStyle

/// Custom button style that completely disables haptic feedback
struct NoHapticButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
      .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
  }
}

// MARK: - ButtonStyle Extensions

extension ButtonStyle where Self == NoHapticButtonStyle {
  static var noHaptic: NoHapticButtonStyle {
    NoHapticButtonStyle()
  }
}

