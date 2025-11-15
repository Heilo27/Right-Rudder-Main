//
//  InfoField.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

// MARK: - InfoField

struct InfoField: View {
  // MARK: - Properties

  let label: String
  let value: String

  // MARK: - Body

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(label)
        .font(.caption)
        .foregroundColor(.secondary)
      Text(value)
        .font(.body)
    }
  }
}

