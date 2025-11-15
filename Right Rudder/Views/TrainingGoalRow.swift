//
//  TrainingGoalRow.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

// MARK: - TrainingGoalRow

struct TrainingGoalRow: View {
  // MARK: - Properties

  let title: String
  let icon: String
  let isSelected: Bool
  let color: Color

  // MARK: - Body

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .foregroundColor(color)
        .frame(width: 20)

      Text(title)
        .font(.subheadline)
        .foregroundColor(.primary)

      Spacer()

      Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
        .foregroundColor(isSelected ? color : .gray)
        .font(.title3)
    }
    .padding(.vertical, 4)
  }
}

