//
//  InstructorNotesView.swift
//  Right Rudder
//
//  Created by AI on 12/19/25.
//

import SwiftUI
import SwiftData

struct InstructorNotesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    private let cloudKitShareService = CloudKitShareService.shared
    
    let progress: ChecklistAssignment
    let student: Student
    
    @State private var localText: String = ""
    @State private var hasUnsavedChanges = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TextEditor(text: $localText)
                    .focused($isFocused)
                    .padding()
                    .warmTextInput()
                    .onChange(of: localText) { oldValue, newValue in
                        if oldValue != newValue {
                            hasUnsavedChanges = true
                        }
                    }
            }
            .navigationTitle("Instructor Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        print("🔵 DEBUG: InstructorNotesView 'Done' button tapped - Manual save triggered")
                        saveNotes()
                        dismiss()
                    }
                }
            }
            .onAppear {
                localText = progress.instructorComments ?? ""
                // Multiple attempts to focus for better reliability
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    isFocused = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isFocused = true
                }
            }
            .onDisappear {
                print("🔵 DEBUG: InstructorNotesView.onDisappear called - Notes exit detected")
                if hasUnsavedChanges {
                    print("🔵 DEBUG: Unsaved changes detected, triggering save")
                    saveNotes()
                } else {
                    print("🔵 DEBUG: No unsaved changes, skipping save")
                }
            }
        }
    }
    
    private func saveNotes() {
        print("🔵 DEBUG: InstructorNotesView.saveNotes() called - Notes save triggered")
        print("🔵 DEBUG: Notes length: \(localText.count) characters")
        
        // Only save if there are actual changes
        let currentComments = progress.instructorComments ?? ""
        guard localText != currentComments else {
            print("🔵 DEBUG: No changes detected in notes, skipping save")
            return
        }
        
        print("🔵 DEBUG: Notes changed, saving to progress.instructorComments")
        progress.instructorComments = localText.isEmpty ? nil : localText
        progress.lastModified = Date()
        
        do {
            try modelContext.save()
            hasUnsavedChanges = false
            
            // Sync to CloudKit in background
            Task {
                await cloudKitShareService.syncStudentChecklistProgressToSharedZone(student, modelContext: modelContext)
            }
        } catch {
            print("❌ Failed to save instructor notes: \(error)")
        }
    }
}

#Preview {
    let student = Student(firstName: "John", lastName: "Doe", email: "john@example.com", telephone: "555-1234", homeAddress: "123 Main St", ftnNumber: "123456789")
    let progress = ChecklistAssignment(templateId: UUID(), templateIdentifier: "test")
    InstructorNotesView(progress: progress, student: student)
        .modelContainer(for: [Student.self, ChecklistAssignment.self, ItemProgress.self, CustomChecklistDefinition.self, CustomChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}

