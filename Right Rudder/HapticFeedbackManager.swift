//
//  HapticFeedbackManager.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import SwiftUI
import UIKit

class HapticFeedbackManager {
    static let shared = HapticFeedbackManager()
    
    private init() {}
    
    // Disable haptic feedback globally
    func disableHapticFeedback() {
        // This is a temporary workaround to prevent haptic feedback errors
        // We'll override the haptic feedback behavior
    }
}

// Custom button style that completely disables haptic feedback
struct NoHapticButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Custom button style with dynamic color scheme, white text, and rounded corners
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

// Extension to provide a no-haptic button style
extension ButtonStyle where Self == NoHapticButtonStyle {
    static var noHaptic: NoHapticButtonStyle {
        NoHapticButtonStyle()
    }
}

// Extension to provide a rounded button style
extension ButtonStyle where Self == RoundedButtonStyle {
    static var rounded: RoundedButtonStyle {
        RoundedButtonStyle()
    }
}
