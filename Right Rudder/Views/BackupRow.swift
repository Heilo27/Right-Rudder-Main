//
//  BackupRow.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

// MARK: - BackupRow

struct BackupRow: View {
  // MARK: - Properties

  let backup: BackupSnapshot
  let isSelected: Bool

  // MARK: - Body

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text(backup.date, style: .date)
          .font(.headline)
        Text("\(backup.studentCount) students, \(backup.templateCount) templates")
          .font(.caption)
          .foregroundColor(.secondary)
      }
      Spacer()
      if isSelected {
        Image(systemName: "checkmark.circle.fill")
          .foregroundColor(.blue)
      }
    }
    .padding(.vertical, 4)
  }
}

