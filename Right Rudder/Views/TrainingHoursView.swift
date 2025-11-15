//
//  TrainingHoursView.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

// MARK: - TrainingHoursView

struct TrainingHoursView: View {
  // MARK: - Properties

  @Environment(\.dismiss) private var dismiss

  @Binding var totalHours: String
  @Binding var dualHours: String
  @Binding var soloHours: String
  @Binding var xcDualHours: String
  @Binding var xcSoloHours: String
  @Binding var nightDualHours: String
  @Binding var nightSoloHours: String
  @Binding var nightLandings: String
  @Binding var instrumentHours: String
  @Binding var previousInstructorName: String

  // MARK: - Body

  var body: some View {
    NavigationView {
      Form {
        Section("Flight Training Hours") {
          HStack {
            Text("Total Hours")
            Spacer()
            TextField("0.0", text: $totalHours)
              .keyboardType(.decimalPad)
              .multilineTextAlignment(.trailing)
          }

          HStack {
            Text("Dual Hours")
            Spacer()
            TextField("0.0", text: $dualHours)
              .keyboardType(.decimalPad)
              .multilineTextAlignment(.trailing)
          }

          HStack {
            Text("Solo Hours")
            Spacer()
            TextField("0.0", text: $soloHours)
              .keyboardType(.decimalPad)
              .multilineTextAlignment(.trailing)
          }

          HStack {
            Text("X/C Dual Hours")
            Spacer()
            TextField("0.0", text: $xcDualHours)
              .keyboardType(.decimalPad)
              .multilineTextAlignment(.trailing)
          }

          HStack {
            Text("X/C Solo Hours")
            Spacer()
            TextField("0.0", text: $xcSoloHours)
              .keyboardType(.decimalPad)
              .multilineTextAlignment(.trailing)
          }

          HStack {
            Text("Night Dual Hours")
            Spacer()
            TextField("0.0", text: $nightDualHours)
              .keyboardType(.decimalPad)
              .multilineTextAlignment(.trailing)
          }

          HStack {
            Text("Night Solo Hours")
            Spacer()
            TextField("0.0", text: $nightSoloHours)
              .keyboardType(.decimalPad)
              .multilineTextAlignment(.trailing)
          }

          HStack {
            Text("Night Landings")
            Spacer()
            TextField("0", text: $nightLandings)
              .keyboardType(.numberPad)
              .multilineTextAlignment(.trailing)
          }

          HStack {
            Text("Instrument Hours")
            Spacer()
            TextField("0.0", text: $instrumentHours)
              .keyboardType(.decimalPad)
              .multilineTextAlignment(.trailing)
          }
        }

        Section("Previous Instructor") {
          TextField("Previous Instructor Name", text: $previousInstructorName)
        }
      }
      .navigationTitle("Training Hours")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            dismiss()
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Save") {
            dismiss()
          }
        }
      }
    }
  }
}

