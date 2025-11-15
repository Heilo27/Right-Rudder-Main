//
//  TextInputWarmingOnlyModifier.swift
//  Right Rudder
//
//  Created by AI on 12/19/25.
//

import SwiftUI

// MARK: - TextInputWarmingOnlyModifier

/// Text input warming modifier that doesn't interfere with existing focus states
struct TextInputWarmingOnlyModifier: ViewModifier {
  // MARK: - ViewModifier

  func body(content: Content) -> some View {
    content
      .onTapGesture {
        // Ensure text input system is warmed before focusing
        TextInputWarmingService.shared.warmTextInput()
      }
  }
}

// MARK: - TextField Extensions

extension TextField {
  /// Adds text input warming without interfering with existing focus state
  func warmTextInput() -> some View {
    self.modifier(TextInputWarmingOnlyModifier())
  }
}

// MARK: - TextEditor Extensions

extension TextEditor {
  /// Adds text input warming without interfering with existing focus state
  func warmTextInput() -> some View {
    self.modifier(TextInputWarmingOnlyModifier())
  }
}

