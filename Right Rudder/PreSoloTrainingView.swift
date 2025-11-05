//
//  PreSoloTrainingView.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import SwiftUI
import SwiftData

struct PreSoloTrainingView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var student: Student
    @Bindable var progress: ChecklistAssignment
    @State private var template: ChecklistTemplate?


    var body: some View {
        List {
            // Header section
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Verify the following items are logged")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Pre-Solo Checklist (all items must be checked)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.appAdaptiveMutedBox)
                .cornerRadius(8)
            }
            
            // Checklist items
            ForEach(Array(ChecklistAssignmentService.getDisplayItems(for: progress).sorted { $0.order < $1.order }.enumerated()), id: \.element.templateItemId) { index, displayItem in
                ChecklistItemRow(displayItem: displayItem, onToggle: { isComplete in
                    // Find the corresponding progress item and update it
                    if let progressItem = progress.itemProgress?.first(where: { $0.templateItemId == displayItem.templateItemId }) {
                        progressItem.isComplete = isComplete
                        if isComplete {
                            progressItem.completedAt = Date()
                        } else {
                            progressItem.completedAt = nil
                        }
                    }
                }, displayTitle: displayTitle)
                .adaptiveRowBackgroundModifier(for: index)
            }
            .onMove(perform: moveItems)
            
            // Relevant Data section (only if data exists)
            if let template = template,
               let relevantData = template.relevantData,
               !relevantData.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(relevantData)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(Color.appAdaptiveMutedBox)
                    .cornerRadius(8)
                }
            }
            
            // Dual Given Hours Section
            Section("Dual Given Hours") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        SelectableTextField(
                            placeholder: "0.0",
                            value: Binding(
                                get: { progress.dualGivenHours },
                                set: { progress.dualGivenHours = $0 }
                            ),
                            format: .number.precision(.fractionLength(1))
                        )
                        .frame(width: 100)
                        
                        Text("hours")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
                .padding(.vertical, 4)
            }
            
            // Instructor Comments Section
            Section("Instructor Comments") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Additional details about student performance:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: Binding(
                        get: { progress.instructorComments ?? "" },
                        set: { progress.instructorComments = $0.isEmpty ? nil : $0 }
                    ))
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(Color.appAdaptiveMutedBox)
                    .cornerRadius(8)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(progress.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
        .id(progress.id) // Prevent view recreation when progress data changes
        .onDisappear {
            // Changes are automatically saved by SwiftData when context changes
        }
        .onAppear {
            loadTemplate()
        }
    }
    
    private func displayTitle(_ title: String) -> String {
        let pattern = "^\\d+\\.\\s*"
        return title.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
    }
    
    private func moveItems(from source: IndexSet, to destination: Int) {
        // Note: In the new reference-based system, item ordering is managed by the template
        print("⚠️ Item reordering not supported in reference-based system. Items should be reordered in the template.")
    }
    
    private func loadTemplate() {
        // In the new system, template is already available through the progress relationship
        template = progress.template
    }
}

#Preview {
    let student = Student(firstName: "John", lastName: "Doe", email: "john@example.com", telephone: "555-1234", homeAddress: "123 Main St", ftnNumber: "123456789")
    let progress = ChecklistAssignment(templateId: UUID(), templateIdentifier: "presolo-training")
    PreSoloTrainingView(student: student, progress: progress)
        .modelContainer(for: [Student.self, ChecklistAssignment.self, ItemProgress.self, CustomChecklistDefinition.self, CustomChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}