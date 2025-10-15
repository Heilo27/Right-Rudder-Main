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
    @State private var student: Student
    @State private var checklist: StudentChecklist
    @State private var template: ChecklistTemplate?

    init(student: Student, checklist: StudentChecklist) {
        self._student = State(initialValue: student)
        self._checklist = State(initialValue: checklist)
    }

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
                .background(Color(.systemBlue).opacity(0.1))
                .cornerRadius(8)
            }
            
            // Checklist items
            ForEach(Array((checklist.items ?? []).sorted { $0.order < $1.order }.enumerated()), id: \.element.id) { index, item in
                ChecklistItemRow(item: item, onToggle: { isComplete in
                    // Use a more controlled state update
                    DispatchQueue.main.async {
                        item.isComplete = isComplete
                        if isComplete {
                            item.completedAt = Date()
                        } else {
                            item.completedAt = nil
                        }
                        
                        // Save the context to persist changes
                        do {
                            try modelContext.save()
                        } catch {
                            print("Failed to save checklist item: \(error)")
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
                    .background(Color.appMutedBox)
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
                                get: { checklist.dualGivenHours },
                                set: { checklist.dualGivenHours = $0 }
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
                        get: { checklist.instructorComments ?? "" },
                        set: { checklist.instructorComments = $0.isEmpty ? nil : $0 }
                    ))
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(Color.appMutedBox)
                    .cornerRadius(8)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(checklist.templateName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
        .id(checklist.id) // Prevent view recreation when checklist data changes
        .onAppear {
            loadTemplate()
        }
    }
    
    private var sortedItems: [StudentChecklistItem] {
        (checklist.items ?? []).sorted { $0.order < $1.order }
    }
    
    private func extractNumberFromTitle(_ title: String) -> Int {
        let pattern = "^\\d+\\."
        if let range = title.range(of: pattern, options: .regularExpression) {
            let numberString = String(title[range]).replacingOccurrences(of: ".", with: "")
            return Int(numberString) ?? 999
        }
        return 999
    }
    
    private func displayTitle(_ title: String) -> String {
        let pattern = "^\\d+\\.\\s*"
        return title.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
    }
    
    private func moveItems(from source: IndexSet, to destination: Int) {
        var sortedItems = self.sortedItems
        sortedItems.move(fromOffsets: source, toOffset: destination)
        
        // Update order values
        for (index, item) in sortedItems.enumerated() {
            item.order = index
        }
        
        // Save the changes to the database
        do {
            try modelContext.save()
        } catch {
            print("Failed to save checklist item order: \(error)")
        }
    }
    
    private func loadTemplate() {
        let templateId = checklist.templateId
        let descriptor = FetchDescriptor<ChecklistTemplate>(
            predicate: #Predicate { $0.id == templateId }
        )
        do {
            let templates = try modelContext.fetch(descriptor)
            template = templates.first
        } catch {
            print("Failed to load template: \(error)")
        }
    }
}

#Preview {
    let student = Student(firstName: "John", lastName: "Doe", email: "john@example.com", telephone: "555-1234", homeAddress: "123 Main St", ftnNumber: "123456789")
    let checklist = StudentChecklist(templateId: UUID(), templateName: "Pre-Solo Training (61.87)", items: [
        StudentChecklistItem(templateItemId: UUID(), title: "(1) Proper flight preparation procedures including, Preflight planning, Powerplant operations, and aircraft systems"),
        StudentChecklistItem(templateItemId: UUID(), title: "(2) Taxiing or surface operations, including runups")
    ])
    PreSoloTrainingView(student: student, checklist: checklist)
        .modelContainer(for: [Student.self, StudentChecklist.self, StudentChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}