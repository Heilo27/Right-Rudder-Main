//
//  ConflictRow.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

// MARK: - ConflictRow

struct ConflictRow: View {
  // MARK: - Properties

  let conflict: DataConflict
  @Binding var selectedValue: String

  // MARK: - Body

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Field Name
      Text(conflict.displayName)
        .font(.headline)
        .foregroundColor(.primary)

      // Value Comparison
      HStack(spacing: 16) {
        // Instructor Value
        VStack(alignment: .leading, spacing: 8) {
          HStack {
            Image(systemName: "person.circle")
              .foregroundColor(.blue)
            Text("Your Value")
              .font(.subheadline)
              .fontWeight(.medium)
              .foregroundColor(.blue)
          }

          Text(conflict.instructorValue)
            .font(.body)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            .overlay(
              RoundedRectangle(cornerRadius: 8)
                .stroke(
                  selectedValue == conflict.instructorValue ? Color.blue : Color.clear, lineWidth: 2
                )
            )
            .onTapGesture {
              selectedValue = conflict.instructorValue
            }
        }

        // Student Value
        VStack(alignment: .leading, spacing: 8) {
          HStack {
            Image(systemName: "person.circle.fill")
              .foregroundColor(.green)
            Text("Student's Value")
              .font(.subheadline)
              .fontWeight(.medium)
              .foregroundColor(.green)
          }

          Text(conflict.studentValue)
            .font(.body)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
            .overlay(
              RoundedRectangle(cornerRadius: 8)
                .stroke(
                  selectedValue == conflict.studentValue ? Color.green : Color.clear, lineWidth: 2)
            )
            .onTapGesture {
              selectedValue = conflict.studentValue
            }
        }
      }

      // Timestamp
      HStack {
        Image(systemName: "clock")
          .foregroundColor(.secondary)
        Text("Student changed this on \(conflict.studentModifiedDate, style: .date)")
          .font(.caption)
          .foregroundColor(.secondary)
      }
    }
    .padding()
    .background(Color.appAdaptiveBackground)
    .cornerRadius(12)
    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
  }
}

