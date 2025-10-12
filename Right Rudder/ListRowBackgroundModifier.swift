//
//  ListRowBackgroundModifier.swift
//  Right Rudder
//
//  Created by AI on 12/19/25.
//

import SwiftUI

// MARK: - Adaptive Row Background Extension

extension View {
    /// Applies adaptive row background that's much darker in dark mode for better text readability
    /// - Parameter index: The index of the current row
    /// - Returns: A view with the appropriate row background applied
    func adaptiveRowBackground(for index: Int) -> some View {
        self.listRowBackground(index.isMultiple(of: 2) ? adaptiveRowBackgroundColor : Color.clear)
    }
}

// MARK: - Adaptive Row Background Color

private var adaptiveRowBackgroundColor: Color {
    @Environment(\.colorScheme) var colorScheme
    
    if colorScheme == .dark {
        // Make the muted box color much darker in dark mode for all color schemes
        return Color.appMutedBox.opacity(0.15)
    } else {
        // Make the muted box color much darker in light mode too for better readability
        return Color.appMutedBox.opacity(0.25)
    }
}

// MARK: - Alternative: Environment-based approach

struct AdaptiveRowBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @State private var currentColorScheme: AppColorScheme = .skyBlue
    let index: Int
    
    func body(content: Content) -> some View {
        content
            .listRowBackground(index.isMultiple(of: 2) ? adaptiveBackgroundColor : Color.clear)
            .onAppear {
                updateColorScheme()
            }
            .onChange(of: UserDefaults.standard.string(forKey: "selectedColorScheme")) { _, _ in
                updateColorScheme()
            }
    }
    
    private func updateColorScheme() {
        currentColorScheme = AppColorScheme(rawValue: UserDefaults.standard.string(forKey: "selectedColorScheme") ?? AppColorScheme.skyBlue.rawValue) ?? .skyBlue
    }
    
    private var adaptiveBackgroundColor: Color {
        if colorScheme == .dark {
            if currentColorScheme == .highContrast {
                // Keep very dark for High Contrast scheme
                return Color.appMutedBox.opacity(0.15)
            } else {
                // Use the primary color scheme colors directly for better color visibility
                return currentColorScheme.primaryColor.opacity(0.2)
            }
        } else {
            // Light mode: Use vibrant primary colors for better color visibility
            if currentColorScheme == .highContrast {
                // Keep muted for High Contrast scheme in light mode
                return Color.appMutedBox.opacity(0.25)
            } else {
                // Use vibrant primary colors in light mode
                return currentColorScheme.primaryColor.opacity(0.15)
            }
        }
    }
}

extension View {
    /// Applies adaptive row background using the modifier approach
    /// - Parameter index: The index of the current row
    /// - Returns: A view with the appropriate row background applied
    func adaptiveRowBackgroundModifier(for index: Int) -> some View {
        self.modifier(AdaptiveRowBackgroundModifier(index: index))
    }
}
