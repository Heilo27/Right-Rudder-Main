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

    init(item: StudentChecklistItem, onToggle: @escaping (Bool) -> Void, displayTitle: ((String) -> String)? = nil) {
        self.item = item
        self.onToggle = onToggle
        self.displayTitle = displayTitle
        self._notes = State(initialValue: item.notes ?? "")
        self._isComplete = State(initialValue: item.isComplete)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Make the entire row tappable
            Button(action: {
                // Update local state first
                isComplete.toggle()
                // Then notify parent
                onToggle(isComplete)
            }) {
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
            }
            .buttonStyle(.noHaptic) // Use custom no-haptic button style
            
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

