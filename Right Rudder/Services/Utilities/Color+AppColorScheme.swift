//
//  Color+AppColorScheme.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

// MARK: - Color Extensions

// Extension to make colors accessible throughout the app
extension Color {
  static var appPrimary: Color {
    let scheme =
      AppColorScheme(
        rawValue: UserDefaults.standard.string(forKey: "selectedColorScheme")
          ?? AppColorScheme.skyBlue.rawValue) ?? .skyBlue
    return scheme.primaryColor
  }

  static var appSecondary: Color {
    let scheme =
      AppColorScheme(
        rawValue: UserDefaults.standard.string(forKey: "selectedColorScheme")
          ?? AppColorScheme.skyBlue.rawValue) ?? .skyBlue
    return scheme.secondaryColor
  }

  static var appAccent: Color {
    let scheme =
      AppColorScheme(
        rawValue: UserDefaults.standard.string(forKey: "selectedColorScheme")
          ?? AppColorScheme.skyBlue.rawValue) ?? .skyBlue
    return scheme.accentColor
  }

  static var appBackground: Color {
    let scheme =
      AppColorScheme(
        rawValue: UserDefaults.standard.string(forKey: "selectedColorScheme")
          ?? AppColorScheme.skyBlue.rawValue) ?? .skyBlue
    return scheme.backgroundColor
  }

  static var appText: Color {
    let scheme =
      AppColorScheme(
        rawValue: UserDefaults.standard.string(forKey: "selectedColorScheme")
          ?? AppColorScheme.skyBlue.rawValue) ?? .skyBlue
    return scheme.textColor
  }

  static var appMutedBox: Color {
    let scheme =
      AppColorScheme(
        rawValue: UserDefaults.standard.string(forKey: "selectedColorScheme")
          ?? AppColorScheme.skyBlue.rawValue) ?? .skyBlue
    return scheme.mutedBoxColor
  }

  static var appDarkModeBackground: Color {
    let scheme =
      AppColorScheme(
        rawValue: UserDefaults.standard.string(forKey: "selectedColorScheme")
          ?? AppColorScheme.skyBlue.rawValue) ?? .skyBlue
    return scheme.darkModeBackgroundColor
  }

  static var appDarkModeMutedBox: Color {
    let scheme =
      AppColorScheme(
        rawValue: UserDefaults.standard.string(forKey: "selectedColorScheme")
          ?? AppColorScheme.skyBlue.rawValue) ?? .skyBlue
    return scheme.darkModeMutedBoxColor
  }
}

// MARK: - Adaptive Color Extensions

// Adaptive Color Extensions (automatically switch between light/dark mode)
extension Color {
  /// Adaptive background color that automatically switches between light and dark mode
  static var appAdaptiveBackground: Color {
    let scheme =
      AppColorScheme(
        rawValue: UserDefaults.standard.string(forKey: "selectedColorScheme")
          ?? AppColorScheme.skyBlue.rawValue) ?? .skyBlue

    // Check if we're in dark mode by looking at the current color scheme
    if UITraitCollection.current.userInterfaceStyle == .dark {
      return scheme.darkModeBackgroundColor
    } else {
      return scheme.backgroundColor
    }
  }

  /// Adaptive muted box color that automatically switches between light and dark mode
  static var appAdaptiveMutedBox: Color {
    let scheme =
      AppColorScheme(
        rawValue: UserDefaults.standard.string(forKey: "selectedColorScheme")
          ?? AppColorScheme.skyBlue.rawValue) ?? .skyBlue

    // Check if we're in dark mode by looking at the current color scheme
    if UITraitCollection.current.userInterfaceStyle == .dark {
      return scheme.darkModeMutedBoxColor
    } else {
      return scheme.mutedBoxColor
    }
  }
}

