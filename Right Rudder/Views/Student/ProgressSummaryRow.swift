//
//  ProgressSummaryRow.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

// MARK: - ProgressSummaryRow

struct ProgressSummaryRow: View {
  // MARK: - Properties

  let title: String
  let value: Int
  let total: Int
  let icon: String
  let color: Color

  // MARK: - Body

  var body: some View {
    HStack {
      Image(systemName: icon)
        .foregroundColor(color)
        .frame(width: 20)

      Text(title)
        .font(.subheadline)
        .foregroundColor(.primary)

      Spacer()

      Text("\(value)/\(total)")
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundColor(value == total ? .green : .secondary)
    }
  }
}

