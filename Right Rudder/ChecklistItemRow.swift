//
//  ChecklistItemRow.swift
//  Right Rudder
//
//  Created by AI on 10/5/25.
//

import SwiftData
import SwiftUI

// MARK: - ChecklistItemRow

struct ChecklistItemRow: View {
  // MARK: - Properties

  let displayItem: DisplayChecklistItem
  let onToggle: (Bool) -> Void
  let displayTitle: ((String) -> String)?
  @State private var dragOffset: CGFloat = 0
  @State private var isDragging = false

  // MARK: - Initialization

  init(
    displayItem: DisplayChecklistItem, onToggle: @escaping (Bool) -> Void,
    displayTitle: ((String) -> String)? = nil
  ) {
    self.displayItem = displayItem
    self.onToggle = onToggle
    self.displayTitle = displayTitle
  }

  // MARK: - Body

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: displayItem.isComplete ? "checkmark.circle.fill" : "circle")
        .foregroundColor(displayItem.isComplete ? .green : .gray)
        .font(.title2)

      VStack(alignment: .leading, spacing: 4) {
        Text(displayTitle?(displayItem.title) ?? displayItem.title)
          .strikethrough(displayItem.isComplete)
          .foregroundColor(displayItem.isComplete ? .secondary : .primary)
          .multilineTextAlignment(.leading)
          .font(.body)

        // Display notes underneath the main item
        if let itemNotes = displayItem.studentNotes ?? displayItem.notes, !itemNotes.isEmpty {
          Text(itemNotes)
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.leading)
        }

        if displayItem.isComplete, let completedAt = displayItem.completedAt {
          Text("Completed: \(completedAt, style: .date)")
            .font(.caption2)
            .foregroundColor(.secondary)
        }
      }

      Spacer()
    }
    .padding(.vertical, 8)
    .offset(x: dragOffset)
    .contentShape(Rectangle())  // Make the entire area tappable
    .onTapGesture {
      // Only allow checking (not unchecking) with tap
      if !displayItem.isComplete {
        onToggle(true)
      }
    }
    .gesture(
      DragGesture(minimumDistance: 30)
        .onChanged { value in
          let horizontalMovement = value.translation.width
          let verticalMovement = abs(value.translation.height)

          // Only respond to VERY clearly horizontal swipes
          // Require horizontal movement to be at least 4x greater than vertical
          // AND minimum 50 points horizontal movement
          if abs(horizontalMovement) > 50 && abs(horizontalMovement) > verticalMovement * 4.0 {
            isDragging = true
            // Only allow left swipes (negative values) and only if displayItem is complete
            if horizontalMovement < 0 && displayItem.isComplete {
              // Smooth drag animation that follows finger
              withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8)) {
                dragOffset = max(horizontalMovement, -120)  // Limit drag distance
              }
            }
          }
        }
        .onEnded { value in
          let horizontalMovement = value.translation.width
          let verticalMovement = abs(value.translation.height)

          print(
            "DEBUG: Swipe ended - horizontal: \(horizontalMovement), vertical: \(verticalMovement)")
          print(
            "DEBUG: isComplete: \(displayItem.isComplete), ratio: \(abs(horizontalMovement) / max(verticalMovement, 1))"
          )

          // Check if this was a valid left swipe for unchecking
          let isValidSwipe =
            horizontalMovement < -60 && verticalMovement < 40
            && abs(horizontalMovement) > verticalMovement * 2.0 && displayItem.isComplete

          if isValidSwipe {
            // Perform the uncheck action
            onToggle(false)
          }

          // Always animate back to original position
          withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            dragOffset = 0
            isDragging = false
          }
        }
    )
  }
}
