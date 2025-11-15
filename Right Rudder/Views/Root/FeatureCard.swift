//
//  FeatureCard.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

// MARK: - FeatureCard

struct FeatureCard: View {
  // MARK: - Properties

  let feature: FeatureItem

  // MARK: - Body

  var body: some View {
    VStack(spacing: 20) {
      // Icon
      Image(systemName: feature.icon)
        .font(.system(size: 50))
        .foregroundColor(feature.color)
        .padding(.top, 20)

      // Title
      Text(feature.title)
        .font(.title2)
        .fontWeight(.bold)
        .foregroundColor(.primary)
        .multilineTextAlignment(.center)

      // Description
      Text(feature.description)
        .font(.body)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
        .lineLimit(nil)
        .padding(.horizontal, 20)

      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 20)
        .fill(Color(.systemBackground))
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    )
    .padding(.horizontal, 10)
  }
}

