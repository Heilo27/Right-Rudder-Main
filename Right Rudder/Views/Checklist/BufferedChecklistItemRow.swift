//
//  BufferedChecklistItemRow.swift
//  Right Rudder
//
//  Created by AI on 10/5/25.
//

import SwiftUI

// MARK: - BufferedChecklistItemRow

struct BufferedChecklistItemRow: View {
  // MARK: - Properties

  let displayItem: DisplayChecklistItem
  let bufferedState: Bool
  let onToggle: (Bool) -> Void
  let displayTitle: ((String) -> String)?
  @State private var dragOffset: CGFloat = 0
  @State private var isDragging = false

  // MARK: - Initialization

  init(
    displayItem: DisplayChecklistItem, bufferedState: Bool, onToggle: @escaping (Bool) -> Void,
    displayTitle: ((String) -> String)? = nil
  ) {
    self.displayItem = displayItem
    self.bufferedState = bufferedState
    self.onToggle = onToggle
    self.displayTitle = displayTitle
  }

  // MARK: - Body

  var body: some View {
    HStack {
      Image(systemName: bufferedState ? "checkmark.circle.fill" : "circle")
        .foregroundColor(bufferedState ? .green : .gray)
        .font(.title2)

      VStack(alignment: .leading, spacing: 2) {
        Text(displayTitle?(displayItem.title) ?? displayItem.title)
          .strikethrough(bufferedState)
          .foregroundColor(bufferedState ? .secondary : .primary)
          .multilineTextAlignment(.leading)

        // Display notes underneath the main item
        if let itemNotes = displayItem.studentNotes ?? displayItem.notes, !itemNotes.isEmpty {
          Text(itemNotes)
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.leading)
        }

        if bufferedState, let completedAt = displayItem.completedAt {
          Text("Completed: \(completedAt, style: .date)")
            .font(.caption2)
            .foregroundColor(.secondary)
        }
      }

      Spacer()
    }
    .offset(x: dragOffset)
    .contentShape(Rectangle())  // Make the entire area tappable
    .onTapGesture {
      // Only allow checking (not unchecking) with tap
      if !bufferedState {
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
            // Only allow left swipes (negative values) and only if item is complete
            if horizontalMovement < 0 && bufferedState {
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
            "DEBUG: isComplete: \(bufferedState), ratio: \(abs(horizontalMovement) / max(verticalMovement, 1))"
          )

          // Check if this was a valid left swipe for unchecking
          let isValidSwipe =
            horizontalMovement < -60 && verticalMovement < 40
            && abs(horizontalMovement) > verticalMovement * 2.0 && bufferedState

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

