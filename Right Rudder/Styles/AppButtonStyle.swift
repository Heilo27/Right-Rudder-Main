//
//  AppButtonStyle.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

// MARK: - AppButtonStyle

/// Custom button style that uses the app color scheme
struct AppButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding(.horizontal, 16)
      .padding(.vertical, 10)
      .background(Color.appPrimary)
      .foregroundColor(.white)
      .cornerRadius(8)
      .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
  }
}

// MARK: - ButtonStyle Extension

extension ButtonStyle where Self == AppButtonStyle {
  static var app: AppButtonStyle { AppButtonStyle() }
}

