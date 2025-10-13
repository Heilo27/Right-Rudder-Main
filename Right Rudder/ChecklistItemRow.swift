//
//  ChecklistItemRow.swift
//  Right Rudder
//
//  Created by AI on 10/5/25.
//

import SwiftUI
import SwiftData

struct ChecklistItemRow: View {
    let item: StudentChecklistItem
    let onToggle: (Bool) -> Void
    let displayTitle: ((String) -> String)?
    @State private var showingNotes = false
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    init(item: StudentChecklistItem, onToggle: @escaping (Bool) -> Void, displayTitle: ((String) -> String)? = nil) {
        self.item = item
        self.onToggle = onToggle
        self.displayTitle = displayTitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: item.isComplete ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(item.isComplete ? .green : .gray)
                        .font(.title2)

                    Text(displayTitle?(item.title) ?? item.title)
                        .strikethrough(item.isComplete)
                        .foregroundColor(item.isComplete ? .secondary : .primary)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    if let itemNotes = item.notes, !itemNotes.isEmpty {
                        Button(action: { showingNotes = true }) {
                            Image(systemName: "note.text")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.noHaptic)
                    }
                }

                // Display notes underneath the main item
                if let itemNotes = item.notes, !itemNotes.isEmpty {
                    Text(itemNotes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 32) // Align with the text above
                }
            }
            .offset(x: dragOffset)
            .contentShape(Rectangle()) // Make the entire area tappable
            .onTapGesture {
                // Only allow checking (not unchecking) with tap
                if !item.isComplete {
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
                        if horizontalMovement < 0 && item.isComplete {
                                // Smooth drag animation that follows finger
                                withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8)) {
                                    dragOffset = max(horizontalMovement, -120) // Limit drag distance
                                }
                            }
                        }
                    }
                    .onEnded { value in
                        let horizontalMovement = value.translation.width
                        let verticalMovement = abs(value.translation.height)
                        
                        print("DEBUG: Swipe ended - horizontal: \(horizontalMovement), vertical: \(verticalMovement)")
                        print("DEBUG: isComplete: \(item.isComplete), ratio: \(abs(horizontalMovement) / max(verticalMovement, 1))")
                        
                        // Check if this was a valid left swipe for unchecking
                        let isValidSwipe = horizontalMovement < -60 && verticalMovement < 40 && 
                                         abs(horizontalMovement) > verticalMovement * 2.0 && item.isComplete
                        
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
            
            if item.isComplete, let completedAt = item.completedAt {
                Text("Completed: \(completedAt, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $showingNotes) {
            NotesView(item: item)
        }
    }
}

struct NotesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let item: StudentChecklistItem
    @State private var notes: String

    init(item: StudentChecklistItem) {
        self.item = item
        self._notes = State(initialValue: item.notes ?? "")
    }

    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $notes)
                    .padding()
            }
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        item.notes = notes.isEmpty ? nil : notes
                        do {
                            try modelContext.save()
                        } catch {
                            print("Failed to save notes: \(error)")
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}

