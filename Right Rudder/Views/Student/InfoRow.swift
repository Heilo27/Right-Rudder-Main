//
//  InfoRow.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

// MARK: - InfoRow

struct InfoRow: View {
  // MARK: - Properties

  let icon: String
  let title: String
  let description: String

  // MARK: - Body

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Image(systemName: icon)
        .font(.title3)
        .foregroundColor(.blue)
        .frame(width: 30)

      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.subheadline)
          .fontWeight(.semibold)
        Text(description)
          .font(.caption)
          .foregroundColor(.secondary)
      }
    }
  }
}

