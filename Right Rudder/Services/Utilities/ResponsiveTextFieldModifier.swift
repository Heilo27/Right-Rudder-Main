//
//  ResponsiveTextFieldModifier.swift
//  Right Rudder
//
//  Created by AI on 12/19/25.
//

import SwiftUI

// MARK: - ResponsiveTextFieldModifier

/// Enhanced TextField modifier for immediate keyboard response
struct ResponsiveTextFieldModifier: ViewModifier {
  // MARK: - Properties

  @FocusState private var isFocused: Bool

  // MARK: - ViewModifier

  func body(content: Content) -> some View {
    content
      .focused($isFocused)
      .onTapGesture {
        // Ensure text input system is warmed before focusing
        TextInputWarmingService.shared.warmTextInput()

        // Multiple focus attempts for better reliability
        isFocused = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
          isFocused = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
          isFocused = true
        }
      }
  }
}

// MARK: - TextField Extensions

extension TextField {
  /// Makes TextField immediately responsive to taps with pre-warmed keyboard
  func responsive() -> some View {
    self.modifier(ResponsiveTextFieldModifier())
  }
}

// MARK: - TextEditor Extensions

extension TextEditor {
  /// Makes TextEditor immediately responsive to taps with pre-warmed keyboard
  func responsive() -> some View {
    self.modifier(ResponsiveTextFieldModifier())
  }
}

