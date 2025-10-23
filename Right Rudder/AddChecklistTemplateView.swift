//
//  AddChecklistTemplateView.swift
//  Right Rudder
//
//  Created by AI on 10/3/25.
//

import SwiftUI
import SwiftData

struct AddChecklistTemplateView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var templateName = ""
    @State private var selectedPhase = "Phase 1"
    @State private var relevantData = ""
    let category: String
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Lesson Name")) {
                    TextField("Enter lesson name", text: $templateName)
                        .autocapitalization(.words)
                }
                
                Section(header: Text("Phase")) {
                    Picker("Phase", selection: $selectedPhase) {
                        Text("First Steps").tag("First Steps")
                        Text("Phase 1").tag("Phase 1")
                        Text("Pre-Solo/Solo").tag("Pre-Solo/Solo")
                        Text("Phase 2").tag("Phase 2")
                        Text("Phase 3").tag("Phase 3")
                        Text("Phase 4").tag("Phase 4")
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Relevant Data (Optional)")) {
                    TextEditor(text: $relevantData)
                        .frame(minHeight: 100)
                    Text("Add study materials, ACS references, or other lesson-specific information. Leave blank if not applicable.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("New Lesson")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveTemplate() }
                        .disabled(templateName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    @AppStorage("instructorName") private var instructorName: String = ""
    
    private func saveTemplate() {
        let trimmedName = templateName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        let trimmedRelevantData = relevantData.trimmingCharacters(in: .whitespacesAndNewlines)
        let newTemplate = ChecklistTemplate(
            name: trimmedName, 
            category: category, 
            phase: selectedPhase,
            relevantData: trimmedRelevantData.isEmpty ? nil : trimmedRelevantData
        )
        
        // Mark as user-created and set author
        newTemplate.isUserCreated = true
        newTemplate.originalAuthor = instructorName.isEmpty ? nil : instructorName
        
        modelContext.insert(newTemplate)
        dismiss()
    }
}

#Preview {
    if #available(iOS 17.0, *) {
        AddChecklistTemplateView(category: "PPL")
            .modelContainer(for: [Student.self, StudentChecklist.self, StudentChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
    }
}
