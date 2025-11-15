//
//  iPadListStyleModifier.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

// MARK: - iPadListStyleModifier

/// Helper modifier for iPad list styling
struct iPadListStyleModifier: ViewModifier {
  // MARK: - ViewModifier

  func body(content: Content) -> some View {
    #if os(iOS)
      if UIDevice.current.userInterfaceIdiom == .pad {
        return AnyView(content.listStyle(.insetGrouped))
      } else {
        return AnyView(content.listStyle(.plain))
      }
    #else
      return AnyView(content.listStyle(.plain))
    #endif
  }
}

