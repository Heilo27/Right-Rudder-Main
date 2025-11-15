//
//  TrainingItemView.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

// MARK: - TrainingItemView

struct TrainingItemView: View {
  // MARK: - Properties

  let trainingDisplayItem: DisplayChecklistItem
  let bufferedState: Bool
  let onToggle: (Bool) -> Void
  @Binding var showingTrainingHours: Bool

  // MARK: - Body

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Button(action: {
          // Toggle the state
          onToggle(!bufferedState)
        }) {
          Image(systemName: bufferedState ? "checkmark.circle.fill" : "circle")
            .foregroundColor(bufferedState ? .green : .gray)
            .font(.title2)
        }
        .buttonStyle(.noHaptic)

        Text(trainingDisplayItem.title)
          .strikethrough(bufferedState)
          .foregroundColor(bufferedState ? .secondary : .primary)
      }

      if bufferedState {
        Button("Enter Training Hours") {
          showingTrainingHours = true
        }
        .buttonStyle(.rounded)
      }
    }
  }
}

