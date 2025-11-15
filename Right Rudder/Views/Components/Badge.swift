//
//  Badge.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

// MARK: - Badge

struct Badge: View {
  // MARK: - Properties

  let count: Int
  let color: Color

  // MARK: - Body

  var body: some View {
    Text("\(count)")
      .font(.caption)
      .fontWeight(.bold)
      .foregroundColor(.white)
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(color)
      .cornerRadius(12)
  }
}

