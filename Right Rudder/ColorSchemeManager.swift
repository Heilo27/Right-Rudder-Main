//
//  ColorSchemeManager.swift
//  Right Rudder
//
//  Created by AI on 10/5/25.
//

import SwiftUI

enum AppColorScheme: String, CaseIterable, Identifiable {
    case skyBlue = "Sky Blue"
    case aviation = "Aviation Orange"
    case professional = "Professional Navy"
    case forest = "Forest Green"
    case planePrincess = "Plane Princess"
    case highContrast = "High Contrast"
    
    var id: String { self.rawValue }
    
    // Primary color - used for main UI elements, buttons, navigation
    var primaryColor: Color {
        switch self {
        case .skyBlue:
            return Color(red: 0.0, green: 0.48, blue: 0.8) // #007ACC - Clear sky blue
        case .aviation:
            return Color(red: 0.95, green: 0.45, blue: 0.0) // #F27300 - Aviation orange
        case .professional:
            return Color(red: 0.11, green: 0.25, blue: 0.44) // #1C3F70 - Navy blue
        case .forest:
            return Color(red: 0.13, green: 0.55, blue: 0.13) // #228B22 - Forest green
        case .planePrincess:
            return Color(red: 0.84, green: 0.38, blue: 0.62) // #D6619E - Rose pink
        case .highContrast:
            return Color(red: 0.17, green: 0.17, blue: 0.17) // #2B2B2B - Dark gray
        }
    }
    
    // Secondary color - used for accents, highlights
    var secondaryColor: Color {
        switch self {
        case .skyBlue:
            return Color(red: 0.0, green: 0.67, blue: 0.93) // #00ABEE - Lighter blue
        case .aviation:
            return Color(red: 1.0, green: 0.6, blue: 0.0) // #FF9900 - Lighter orange
        case .professional:
            return Color(red: 0.25, green: 0.41, blue: 0.58) // #406894 - Lighter navy
        case .forest:
            return Color(red: 0.2, green: 0.7, blue: 0.2) // #33B333 - Lighter green
        case .planePrincess:
            return Color(red: 0.78, green: 0.57, blue: 0.85) // #C791D9 - Soft lavender
        case .highContrast:
            return Color(red: 0.4, green: 0.4, blue: 0.4) // #666666 - Medium gray
        }
    }
    
    // Accent color - used for important actions, completion states
    var accentColor: Color {
        switch self {
        case .skyBlue:
            return Color(red: 0.0, green: 0.78, blue: 0.55) // #00C78C - Teal
        case .aviation:
            return Color(red: 0.0, green: 0.45, blue: 0.81) // #0073CF - Blue contrast
        case .professional:
            return Color(red: 0.85, green: 0.65, blue: 0.13) // #D9A521 - Gold
        case .forest:
            return Color(red: 0.4, green: 0.65, blue: 0.12) // #66A61E - Lime
        case .planePrincess:
            return Color(red: 1.0, green: 0.42, blue: 0.62) // #FF6B9D - Coral pink
        case .highContrast:
            return Color(red: 1.0, green: 0.65, blue: 0.0) // #FFA500 - High contrast orange
        }
    }
    
    // Background color - used for cards, sections
    var backgroundColor: Color {
        switch self {
        case .skyBlue:
            return Color(red: 0.95, green: 0.97, blue: 0.99) // #F2F7FC - Light blue-grey
        case .aviation:
            return Color(red: 0.99, green: 0.96, blue: 0.93) // #FCF5ED - Warm cream
        case .professional:
            return Color(red: 0.94, green: 0.95, blue: 0.97) // #F0F2F5 - Cool grey
        case .forest:
            return Color(red: 0.95, green: 0.98, blue: 0.95) // #F2FAF2 - Light mint
        case .planePrincess:
            return Color(red: 1.0, green: 0.94, blue: 0.96) // #FFF0F5 - Lavender blush
        case .highContrast:
            return Color(red: 0.96, green: 0.96, blue: 0.96) // #F5F5F5 - Light gray
        }
    }
    
    // Muted box color - used for content boxes, text editor backgrounds
    var mutedBoxColor: Color {
        switch self {
        case .skyBlue:
            return Color(red: 0.88, green: 0.93, blue: 0.98) // Muted blue
        case .aviation:
            return Color(red: 0.98, green: 0.92, blue: 0.86) // Muted orange/peach
        case .professional:
            return Color(red: 0.88, green: 0.90, blue: 0.94) // Muted navy grey
        case .forest:
            return Color(red: 0.90, green: 0.95, blue: 0.90) // Muted green
        case .planePrincess:
            return Color(red: 0.98, green: 0.88, blue: 0.92) // Muted pink
        case .highContrast:
            return Color(red: 0.9, green: 0.9, blue: 0.9) // Muted light gray
        }
    }
    
    // Text color - primary text on light backgrounds
    var textColor: Color {
        switch self {
        case .skyBlue:
            return Color(red: 0.13, green: 0.13, blue: 0.13) // #212121 - Almost black
        case .aviation:
            return Color(red: 0.2, green: 0.15, blue: 0.1) // #33261A - Warm dark
        case .professional:
            return Color(red: 0.11, green: 0.13, blue: 0.16) // #1C2128 - Cool dark
        case .forest:
            return Color(red: 0.1, green: 0.2, blue: 0.1) // #1A331A - Dark green-grey
        case .planePrincess:
            return Color(red: 0.36, green: 0.22, blue: 0.33) // #5D3954 - Deep plum
        case .highContrast:
            return Color(red: 0.1, green: 0.1, blue: 0.1) // Very dark text for high contrast
        }
    }
    
    // Description for the settings UI
    var description: String {
        switch self {
        case .skyBlue:
            return "Clear skies and bright horizons"
        case .aviation:
            return "Classic aviation warmth"
        case .professional:
            return "Professional and trustworthy"
        case .forest:
            return "Natural and grounded"
        case .planePrincess:
            return "Elegant and soothing"
        case .highContrast:
            return "High contrast for accessibility"
        }
    }
    
    // Preview colors for the settings picker
    var previewGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [primaryColor, secondaryColor, accentColor]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// Extension to make colors accessible throughout the app
extension Color {
    static var appPrimary: Color {
        let scheme = AppColorScheme(rawValue: UserDefaults.standard.string(forKey: "selectedColorScheme") ?? AppColorScheme.skyBlue.rawValue) ?? .skyBlue
        return scheme.primaryColor
    }
    
    static var appSecondary: Color {
        let scheme = AppColorScheme(rawValue: UserDefaults.standard.string(forKey: "selectedColorScheme") ?? AppColorScheme.skyBlue.rawValue) ?? .skyBlue
        return scheme.secondaryColor
    }
    
    static var appAccent: Color {
        let scheme = AppColorScheme(rawValue: UserDefaults.standard.string(forKey: "selectedColorScheme") ?? AppColorScheme.skyBlue.rawValue) ?? .skyBlue
        return scheme.accentColor
    }
    
    static var appBackground: Color {
        let scheme = AppColorScheme(rawValue: UserDefaults.standard.string(forKey: "selectedColorScheme") ?? AppColorScheme.skyBlue.rawValue) ?? .skyBlue
        return scheme.backgroundColor
    }
    
    static var appText: Color {
        let scheme = AppColorScheme(rawValue: UserDefaults.standard.string(forKey: "selectedColorScheme") ?? AppColorScheme.skyBlue.rawValue) ?? .skyBlue
        return scheme.textColor
    }
    
    static var appMutedBox: Color {
        let scheme = AppColorScheme(rawValue: UserDefaults.standard.string(forKey: "selectedColorScheme") ?? AppColorScheme.skyBlue.rawValue) ?? .skyBlue
        return scheme.mutedBoxColor
    }
}

// Custom button style that uses the app color scheme
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

extension ButtonStyle where Self == AppButtonStyle {
    static var app: AppButtonStyle { AppButtonStyle() }
}

