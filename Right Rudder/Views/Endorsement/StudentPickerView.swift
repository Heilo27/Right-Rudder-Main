//
//  StudentPickerView.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftData
import SwiftUI

// MARK: - StudentPickerView

struct StudentPickerView: View {
  // MARK: - Properties

  @Binding var selectedStudent: Student?
  let students: [Student]
  @Environment(\.dismiss) private var dismiss

  // MARK: - Body

  var body: some View {
    NavigationView {
      List(students, id: \.id) { student in
        Button(action: {
          selectedStudent = student
          dismiss()
        }) {
          HStack {
            VStack(alignment: .leading) {
              Text("\(student.firstName) \(student.lastName)")
                .font(.headline)
              Text(student.email)
                .font(.caption)
                .foregroundColor(.secondary)
            }
            Spacer()
          }
        }
        .buttonStyle(.plain)
      }
      .navigationTitle("Select Student")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Cancel") {
            dismiss()
          }
        }
      }
    }
  }
}

