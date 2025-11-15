//
//  MilestoneRow.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

// MARK: - MilestoneRow

struct MilestoneRow: View {
  // MARK: - Properties

  let title: String
  let icon: String
  let isCompleted: Bool
  let color: Color

  // MARK: - Body

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .foregroundColor(color)
        .frame(width: 16)

      Text(title)
        .font(.caption)
        .foregroundColor(.primary)

      Spacer()

      Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
        .foregroundColor(isCompleted ? .green : .gray)
        .font(.caption)
    }
  }
}

