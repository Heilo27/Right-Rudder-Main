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
    @State private var notes: String
    @State private var isComplete: Bool
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    init(item: StudentChecklistItem, onToggle: @escaping (Bool) -> Void, displayTitle: ((String) -> String)? = nil) {
        self.item = item
        self.onToggle = onToggle
        self.displayTitle = displayTitle
        self._notes = State(initialValue: item.notes ?? "")
        self._isComplete = State(initialValue: item.isComplete)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isComplete ? .green : .gray)
                        .font(.title2)

                    Text(displayTitle?(item.title) ?? item.title)
                        .strikethrough(isComplete)
                        .foregroundColor(isComplete ? .secondary : .primary)
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
                print("DEBUG: Tap gesture detected, isComplete: \(isComplete)")
                // Only allow checking (not unchecking) with tap
                if !isComplete {
                    print("DEBUG: Checking item")
                    isComplete = true
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
                            if horizontalMovement < 0 && isComplete {
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
                        print("DEBUG: isComplete: \(isComplete), ratio: \(abs(horizontalMovement) / max(verticalMovement, 1))")
                        
                        // Check if this was a valid left swipe for unchecking
                        let isValidSwipe = horizontalMovement < -60 && verticalMovement < 40 && 
                                         abs(horizontalMovement) > verticalMovement * 2.0 && isComplete
                        
                        print("DEBUG: isValidSwipe: \(isValidSwipe)")
                        
                        if isValidSwipe {
                            print("DEBUG: Left swipe - unchecking item")
                            // Perform the uncheck action
                            isComplete = false
                            onToggle(false)
                        }
                        
                        // Always animate back to original position
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            dragOffset = 0
                            isDragging = false
                        }
                    }
            )
            
            if isComplete, let completedAt = item.completedAt {
                Text("Completed: \(completedAt, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $showingNotes) {
            NotesView(notes: $notes, item: item)
        }
        .onAppear {
            // Sync with item state when view appears
            isComplete = item.isComplete
            notes = item.notes ?? ""
        }
        .onChange(of: item.isComplete) { _, newValue in
            // Update local state when item changes
            isComplete = newValue
        }
        .onChange(of: item.notes) { _, newValue in
            // Update local notes state when item notes change
            notes = newValue ?? ""
        }
    }
}

struct NotesView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var notes: String
    let item: StudentChecklistItem

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
                        dismiss()
                    }
                }
            }
        }
    }
}

