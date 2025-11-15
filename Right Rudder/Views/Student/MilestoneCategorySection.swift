//
//  MilestoneCategorySection.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

// MARK: - MilestoneCategorySection

struct MilestoneCategorySection: View {
  // MARK: - Properties

  let title: String
  let icon: String
  let color: Color
  let groundSchoolCompleted: Bool
  let writtenTestCompleted: Bool

  // MARK: - Body

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: icon)
          .foregroundColor(color)
          .frame(width: 20)

        Text(title)
          .font(.subheadline)
          .fontWeight(.semibold)
          .foregroundColor(.primary)

        Spacer()
      }

      VStack(spacing: 8) {
        MilestoneRow(
          title: "Ground School Completed",
          icon: "graduationcap",
          isCompleted: groundSchoolCompleted,
          color: color
        )

        MilestoneRow(
          title: "Written Test Completed",
          icon: "pencil.and.outline",
          isCompleted: writtenTestCompleted,
          color: color
        )
      }
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 12)
    .background(color.opacity(0.1))
    .cornerRadius(8)
  }
}

