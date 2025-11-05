//
//  ShareTemplatesView.swift
//  Right Rudder
//
//  Created by AI on 10/6/25.
//

import SwiftUI
import SwiftData

struct ShareTemplatesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \ChecklistTemplate.name) private var allTemplates: [ChecklistTemplate]
    
    // Filter out blank or invalid templates
    private var validTemplates: [ChecklistTemplate] {
        return allTemplates.filter { template in
            // Filter out templates with empty names
            guard !template.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
            
            // Filter out templates with no items (optional - you might want to keep these)
            // guard let items = template.items, !items.isEmpty else { return false }
            
            return true
        }
    }
    
    @State private var selectedTemplates: Set<UUID> = []
    @State private var shareURL: URL?
    @State private var showingShareSheet = false
    @State private var isExporting = false
    @State private var errorMessage: String?
    @State private var shareCompleted = false
    
    @AppStorage("instructorName") private var instructorName: String = ""
    
    private var sortedTemplates: [ChecklistTemplate] {
        // Get the default template order from DefaultTemplates.allTemplates
        let defaultTemplateOrder = DefaultTemplates.allTemplates.map { $0.templateIdentifier }
        
        return validTemplates.sorted { template1, template2 in
            // Priority 1: User-created templates (always first)
            if template1.isUserCreated != template2.isUserCreated {
                return template1.isUserCreated
            }
            
            // Priority 2: User-modified templates (second)
            if template1.isUserModified != template2.isUserModified {
                return template1.isUserModified
            }
            
            // Priority 3: Default templates in the order defined in DefaultTemplates.allTemplates
            if !template1.isUserCreated && !template1.isUserModified && 
               !template2.isUserCreated && !template2.isUserModified {
                
                let index1 = defaultTemplateOrder.firstIndex(of: template1.templateIdentifier)
                let index2 = defaultTemplateOrder.firstIndex(of: template2.templateIdentifier)
                
                if let idx1 = index1, let idx2 = index2 {
                    return idx1 < idx2
                } else if index1 != nil {
                    return true
                } else if index2 != nil {
                    return false
                }
            }
            
            // Priority 4: Alphabetical order for any remaining templates
            return template1.name.localizedCaseInsensitiveCompare(template2.name) == .orderedAscending
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header info
                VStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up.on.square")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Share Lesson Lists")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Select the lesson checklists you want to share with other Right Rudder users")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                
                // Template list
                List {
                    if !userCreatedTemplates.isEmpty {
                        Section("Your Custom Lessons") {
                            ForEach(userCreatedTemplates) { template in
                                TemplateRow(
                                    template: template,
                                    isSelected: selectedTemplates.contains(template.id),
                                    onToggle: { toggleSelection(template) }
                                )
                            }
                        }
                    }
                    
                    if !userModifiedTemplates.isEmpty {
                        Section("Modified Lessons") {
                            ForEach(userModifiedTemplates) { template in
                                TemplateRow(
                                    template: template,
                                    isSelected: selectedTemplates.contains(template.id),
                                    onToggle: { toggleSelection(template) }
                                )
                            }
                        }
                    }
                    
                    if !defaultTemplates.isEmpty {
                        Section("Default Lessons") {
                            ForEach(defaultTemplates) { template in
                                TemplateRow(
                                    template: template,
                                    isSelected: selectedTemplates.contains(template.id),
                                    onToggle: { toggleSelection(template) }
                                )
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                
                // Bottom action bar
                VStack(spacing: 12) {
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    HStack(spacing: 16) {
                        Button(action: selectAll) {
                            VStack(spacing: 4) {
                                Image(systemName: "checkmark.square")
                                    .font(.title3)
                                Text("Select All")
                                    .font(.caption)
                            }
                        }
                        .disabled(selectedTemplates.count == validTemplates.count)
                        
                        Button(action: deselectAll) {
                            VStack(spacing: 4) {
                                Image(systemName: "square")
                                    .font(.title3)
                                Text("Clear All")
                                    .font(.caption)
                            }
                        }
                        .disabled(selectedTemplates.isEmpty)
                        
                        Spacer()
                        
                        Text("\(selectedTemplates.count) selected")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    Button(action: shareTemplates) {
                        HStack {
                            if isExporting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Selected Lessons")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedTemplates.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(selectedTemplates.isEmpty || isExporting)
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(Color(UIColor.systemBackground))
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let shareURL = shareURL {
                    TemplateShareSheet(items: [shareURL]) { completed in
                        if completed {
                            // Dismiss both the share sheet and this view
                            showingShareSheet = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var userCreatedTemplates: [ChecklistTemplate] {
        sortedTemplates.filter { $0.isUserCreated }
    }
    
    private var userModifiedTemplates: [ChecklistTemplate] {
        sortedTemplates.filter { !$0.isUserCreated && $0.isUserModified }
    }
    
    private var defaultTemplates: [ChecklistTemplate] {
        sortedTemplates.filter { !$0.isUserCreated && !$0.isUserModified }
    }
    
    private func toggleSelection(_ template: ChecklistTemplate) {
        if selectedTemplates.contains(template.id) {
            selectedTemplates.remove(template.id)
        } else {
            selectedTemplates.insert(template.id)
        }
    }
    
    private func selectAll() {
        selectedTemplates = Set(validTemplates.map { $0.id })
    }
    
    private func deselectAll() {
        selectedTemplates.removeAll()
    }
    
    private func shareTemplates() {
        isExporting = true
        errorMessage = nil
        
        let templatesToShare = validTemplates.filter { selectedTemplates.contains($0.id) }
        
        if let url = TemplateExportService.exportTemplates(templatesToShare, authorName: instructorName) {
            shareURL = url
            showingShareSheet = true
            isExporting = false
        } else {
            errorMessage = "Failed to create share file. Please try again."
            isExporting = false
        }
    }
}

struct TemplateRow: View {
    let template: ChecklistTemplate
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(template.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if template.isUserCreated {
                            Image(systemName: "person.badge.plus")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else if template.isUserModified {
                            Image(systemName: "pencil.circle")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    HStack {
                        Text(template.category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let phase = template.phase {
                            Text("•")
                                .foregroundColor(.secondary)
                            Text(phase)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        Text("\(template.items?.count ?? 0) items")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// Template Share Sheet
struct TemplateShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    let onComplete: (Bool) -> Void
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        // Prioritize email, messages, and AirDrop
        controller.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .openInIBooks,
            .markupAsPDF,
            .saveToCameraRoll
        ]
        
        // Set completion handler
        controller.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            if completed {
                print("Share completed successfully")
                onComplete(true)
            } else if let error = error {
                print("Share error: \(error.localizedDescription)")
            }
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ShareTemplatesView()
        .modelContainer(for: [ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}

