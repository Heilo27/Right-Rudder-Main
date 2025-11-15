//
//  RoundedButtonStyle.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

// MARK: - RoundedButtonStyle

/// Custom button style with dynamic color scheme, white text, and rounded corners
struct RoundedButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundColor(.white)
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
      .background(Color.appPrimary)
      .cornerRadius(12)
      .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
      .opacity(configuration.isPressed ? 0.9 : 1.0)
      .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
  }
}

// MARK: - ButtonStyle Extensions

extension ButtonStyle where Self == RoundedButtonStyle {
  static var rounded: RoundedButtonStyle {
    RoundedButtonStyle()
  }
}

