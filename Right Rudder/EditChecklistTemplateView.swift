//
//  EditChecklistTemplateView.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import SwiftUI
import SwiftData

struct EditChecklistTemplateView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cloudKitSyncService = CloudKitSyncService()
    
    @State private var template: ChecklistTemplate
    @State private var templateName: String
    @State private var relevantData: String
    @State private var items: [ChecklistItem]
    @State private var newItemTitle = ""
    @State private var newItemNotes = ""

    init(template: ChecklistTemplate) {
        self._template = State(initialValue: template)
        self._templateName = State(initialValue: template.name)
        self._relevantData = State(initialValue: template.relevantData ?? "")
        self._items = State(initialValue: template.items ?? [])
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Lesson Information") {
                    TextField("Lesson Name", text: $templateName)
                    Text("Category: \(template.category)")
                        .foregroundColor(.secondary)
                }
                
                Section("Relevant Data (Optional)") {
                    TextEditor(text: $relevantData)
                        .frame(minHeight: 100)
                    Text("Add study materials, ACS references, or other lesson-specific information. Leave blank if not applicable.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Items") {
                    ForEach(items.sorted { $0.order < $1.order }) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            TextField("Item title", text: Binding(
                                get: { item.title },
                                set: { item.title = $0 }
                            ))
                            .font(.subheadline)
                            
                            TextField("Notes (optional)", text: Binding(
                                get: { item.notes ?? "" },
                                set: { item.notes = $0.isEmpty ? nil : $0 }
                            ), axis: .vertical)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2...4)
                        }
                    }
                    .onDelete(perform: deleteItems)
                    
                    HStack {
                        TextField("New item title", text: $newItemTitle)
                        Button("Add") {
                            addItem()
                        }
                        .disabled(newItemTitle.isEmpty)
                    }
                    
                    if !newItemTitle.isEmpty {
                        TextField("Notes (optional)", text: $newItemNotes, axis: .vertical)
                            .lineLimit(2...4)
                    }
                }
            }
            .navigationTitle("Edit Lesson")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTemplate()
                    }
                    .disabled(templateName.isEmpty)
                }
            }
        }
        .onAppear {
            cloudKitSyncService.setModelContext(modelContext)
        }
    }
    
    private var sortedItems: [ChecklistItem] {
        items.sorted { $0.order < $1.order }
    }
    
    private func addItem() {
        let item = ChecklistItem(
            title: newItemTitle,
            notes: newItemNotes.isEmpty ? nil : newItemNotes
        )
        items.append(item)
        newItemTitle = ""
        newItemNotes = ""
    }
    
    private func deleteItems(offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
    private func saveTemplate() {
        template.name = templateName
        let trimmedRelevantData = relevantData.trimmingCharacters(in: .whitespacesAndNewlines)
        template.relevantData = trimmedRelevantData.isEmpty ? nil : trimmedRelevantData
        template.items = items
        
        // Mark as user-modified if not already user-created
        if !template.isUserCreated {
            template.isUserModified = true
        }
        
        // Update lastModified timestamp
        template.lastModified = Date()
        
        do {
            try modelContext.save()
            print("✅ Checklist template saved successfully")
            
            // Sync template to CloudKit in background
            Task {
                await cloudKitSyncService.syncTemplateToCloudKit(template)
            }
        } catch {
            print("❌ Failed to save checklist template: \(error)")
        }
        
        dismiss()
    }
}

#Preview {
    let template = ChecklistTemplate(name: "Pre-Flight Inspection", category: "PPL", items: [])
    EditChecklistTemplateView(template: template)
        .modelContainer(for: [Student.self, ChecklistAssignment.self, ItemProgress.self, CustomChecklistDefinition.self, CustomChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}
