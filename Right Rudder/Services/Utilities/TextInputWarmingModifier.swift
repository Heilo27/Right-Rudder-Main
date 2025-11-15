//
//  TextInputWarmingModifier.swift
//  Right Rudder
//
//  Created by AI on 12/19/25.
//

import SwiftUI

// MARK: - TextInputWarmingModifier

/// View modifier to automatically warm text input when the view appears
struct TextInputWarmingModifier: ViewModifier {
  // MARK: - ViewModifier

  func body(content: Content) -> some View {
    content
      .onAppear {
        TextInputWarmingService.shared.warmTextInput()
      }
  }
}

// MARK: - View Extensions

extension View {
  /// Applies text input warming to prevent cold start delays
  func warmTextInput() -> some View {
    self.modifier(TextInputWarmingModifier())
  }
}

