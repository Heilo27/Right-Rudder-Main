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
    let category: String
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Template Name")) {
                    TextField("Enter template name", text: $templateName)
                        .autocapitalization(.words)
                }
            }
            .navigationTitle("New Template")
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
    
    private func saveTemplate() {
        let trimmedName = templateName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        let newTemplate = ChecklistTemplate(name: trimmedName, category: category)
        modelContext.insert(newTemplate)
        dismiss()
    }
}

#Preview {
    AddChecklistTemplateView(category: "PPL")
        .modelContainer(for: [Student.self, ChecklistTemplate.self], inMemory: true)
}
