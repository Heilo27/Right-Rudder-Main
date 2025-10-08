//
//  ChecklistTemplateDetailView.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import SwiftUI
import SwiftData

struct ChecklistTemplateDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var template: ChecklistTemplate
    @State private var showingEditTemplate = false
    @State private var newItemTitle = ""
    @State private var newItemNotes = ""

    init(template: ChecklistTemplate) {
        self._template = State(initialValue: template)
    }

    var body: some View {
        Form {
            Section("Template Information") {
                VStack(alignment: .leading, spacing: 8) {
                    Text(template.name)
                        .font(.headline)
                    Text("Category: \(template.category)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Items") {
                    ForEach((template.items ?? []).sorted { $0.order < $1.order }) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.subheadline)
                        if let notes = item.notes, !notes.isEmpty {
                            Text(notes)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
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
        .navigationTitle("Template Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditTemplate = true
                }
            }
        }
        .sheet(isPresented: $showingEditTemplate) {
            EditChecklistTemplateView(template: template)
        }
    }
    
    private var sortedItems: [ChecklistItem] {
        (template.items ?? []).sorted { $0.order < $1.order }
    }
    
    private func addItem() {
        let item = ChecklistItem(
            title: newItemTitle,
            notes: newItemNotes.isEmpty ? nil : newItemNotes
        )
        template.items?.append(item)
        newItemTitle = ""
        newItemNotes = ""
    }
    
    private func deleteItems(offsets: IndexSet) {
        template.items?.remove(atOffsets: offsets)
    }
}

#Preview {
    let template = ChecklistTemplate(name: "Pre-Flight Inspection", category: "PPL", items: [
        ChecklistItem(title: "Check fuel quantity", notes: "Verify adequate fuel for flight"),
        ChecklistItem(title: "Inspect exterior", notes: "Look for damage or loose parts")
    ])
    ChecklistTemplateDetailView(template: template)
        .modelContainer(for: [Student.self, StudentChecklist.self, StudentChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}


