//
//  AddChecklistToStudentView.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import SwiftUI
import SwiftData

struct AddChecklistToStudentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let student: Student
    let templates: [ChecklistTemplate]

    var body: some View {
        NavigationView {
            templatesList
                .navigationTitle("Add Checklist")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .buttonStyle(.noHaptic)
                    }
                }
        }
    }
    
    private var templatesList: some View {
        List {
            ForEach(phaseGroups) { phaseGroup in
                Section(header: sectionHeader(phaseGroup)) {
                    ForEach(phaseGroup.templates) { template in
                        templateRow(template)
                    }
                }
            }
        }
    }
    
    private func sectionHeader(_ phaseGroup: PhaseGroup) -> some View {
        HStack {
            Text(phaseGroup.phase)
                .font(.headline)
            Spacer()
            Button("Add All") {
                addAllTemplatesInPhase(phaseGroup.templates)
            }
            .buttonStyle(.noHaptic)
            .background(Color(.systemBlue))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .cornerRadius(6)
        }
    }
    
    private func templateRow(_ template: ChecklistTemplate) -> some View {
        Button(action: {
            addChecklistToStudent(template)
        }) {
            HStack {
                templateInfo(template)
                Spacer()
                assignmentStatus(template)
            }
        }
        .buttonStyle(.noHaptic)
        .disabled(isChecklistAlreadyAssigned(template))
    }
    
    private func templateInfo(_ template: ChecklistTemplate) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(template.name)
                .font(.headline)
                .foregroundColor(.primary)
            Text("Category: \(template.category)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("\(template.items?.count ?? 0) items")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func assignmentStatus(_ template: ChecklistTemplate) -> some View {
        Group {
            if isChecklistAlreadyAssigned(template) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Already Assigned")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
    }
    
    // Helper function to extract lesson number from P1 template names
    private static let lessonNumberRegex = try? NSRegularExpression(pattern: "P1-L(\\d+)")
    
    private func extractLessonNumber(from templateName: String) -> Int? {
        guard let regex = Self.lessonNumberRegex else { return nil }
        
        let range = NSRange(location: 0, length: templateName.utf16.count)
        guard let match = regex.firstMatch(in: templateName, range: range),
              let numberRange = Range(match.range(at: 1), in: templateName) else {
            return nil
        }
        
        return Int(templateName[numberRange])
    }
    
    private var phaseGroups: [PhaseGroup] {
        let grouped = Dictionary(grouping: templates) { template in
            template.phase ?? "Phase 1"
        }
        
        // Define the logical order for phases - First Steps must be at the top
        let phaseOrder = ["First Steps", "Phase 1", "Pre-Solo", "Phase 2", "Phase 3", "Phase 4"]
        
        // Create phase groups with sorted templates
        var phaseGroups: [PhaseGroup] = []
        for (phase, templates) in grouped {
            let sortedTemplates = sortTemplatesForPhase(templates, phase: phase)
            let phaseGroup = PhaseGroup(phase: phase, templates: sortedTemplates)
            phaseGroups.append(phaseGroup)
        }
        
        return sortPhaseGroups(phaseGroups, phaseOrder: phaseOrder)
    }
    
    private func sortTemplatesForPhase(_ templates: [ChecklistTemplate], phase: String) -> [ChecklistTemplate] {
        if phase == "First Steps" {
            return sortFirstStepsTemplates(templates)
        } else if phase == "Phase 1" {
            return sortPhase1Templates(templates)
        } else {
            return templates.sorted { $0.name < $1.name }
        }
    }
    
    private func sortFirstStepsTemplates(_ templates: [ChecklistTemplate]) -> [ChecklistTemplate] {
        return templates.sorted { template1, template2 in
            if template1.name == "Student Onboard/Training Overview" {
                return true
            }
            if template2.name == "Student Onboard/Training Overview" {
                return false
            }
            return template1.name < template2.name
        }
    }
    
    private func sortPhase1Templates(_ templates: [ChecklistTemplate]) -> [ChecklistTemplate] {
        return templates.sorted { template1, template2 in
            let lesson1 = extractLessonNumber(from: template1.name)
            let lesson2 = extractLessonNumber(from: template2.name)
            
            if let num1 = lesson1, let num2 = lesson2 {
                return num1 < num2
            }
            
            return template1.name < template2.name
        }
    }
    
    private func sortPhaseGroups(_ phaseGroups: [PhaseGroup], phaseOrder: [String]) -> [PhaseGroup] {
        return phaseGroups.sorted { phase1, phase2 in
            let index1 = getPhaseIndex(phase1.phase, in: phaseOrder)
            let index2 = getPhaseIndex(phase2.phase, in: phaseOrder)
            return index1 < index2
        }
    }
    
    private func getPhaseIndex(_ phase: String, in phaseOrder: [String]) -> Int {
        if phase == "First Steps" {
            return 0 // Always first
        }
        return phaseOrder.firstIndex(of: phase) ?? phaseOrder.count
    }
    
    private func isChecklistAlreadyAssigned(_ template: ChecklistTemplate) -> Bool {
        return student.checklists?.contains { $0.templateName == template.name } ?? false
    }
    
    private func addChecklistToStudent(_ template: ChecklistTemplate) {
        // Check if already assigned
        guard !isChecklistAlreadyAssigned(template) else { return }
        
        // Process on background queue for better performance
        DispatchQueue.global(qos: .userInitiated).async {
            let templateItems = template.items ?? []
            let studentChecklistItems = templateItems.map { templateItem in
                print("Creating StudentChecklistItem: '\(templateItem.title)' -> order: \(templateItem.order)")
                return StudentChecklistItem(
                    templateItemId: templateItem.id,
                    title: templateItem.title,
                    notes: templateItem.notes,
                    order: templateItem.order
                )
            }
            
            let studentChecklist = StudentChecklist(
                templateId: template.id,
                templateName: template.name,
                items: studentChecklistItems
            )
            
            DispatchQueue.main.async {
                if self.student.checklists == nil {
                    self.student.checklists = []
                }
                self.student.checklists?.append(studentChecklist)
                
                // Save the context to persist changes and trigger UI updates
                do {
                    try self.modelContext.save()
                    // Force a refresh of the student object to trigger UI updates
                    self.student.lastModified = Date()
                } catch {
                    print("Failed to save student checklist: \(error)")
                }
                
                self.dismiss()
            }
        }
    }
    
    private func addAllTemplatesInPhase(_ templates: [ChecklistTemplate]) {
        // Process on background queue for better performance
        DispatchQueue.global(qos: .userInitiated).async {
            // Filter out templates that are already assigned
            let unassignedTemplates = templates.filter { !self.isChecklistAlreadyAssigned($0) }
            
            let studentChecklists = unassignedTemplates.map { template in
                let templateItems = template.items ?? []
                let studentChecklistItems = templateItems.map { templateItem in
                    StudentChecklistItem(
                        templateItemId: templateItem.id,
                        title: templateItem.title,
                        notes: templateItem.notes,
                        order: templateItem.order
                    )
                }
                
                return StudentChecklist(
                    templateId: template.id,
                    templateName: template.name,
                    items: studentChecklistItems
                )
            }
            
            DispatchQueue.main.async {
                if self.student.checklists == nil {
                    self.student.checklists = []
                }
                self.student.checklists?.append(contentsOf: studentChecklists)
                
                // Save the context to persist changes and trigger UI updates
                do {
                    try self.modelContext.save()
                    // Force a refresh of the student object to trigger UI updates
                    self.student.lastModified = Date()
                } catch {
                    print("Failed to save student checklists: \(error)")
                }
                
                self.dismiss()
            }
        }
    }
}


#Preview {
    let student = Student(firstName: "John", lastName: "Doe", email: "john@example.com", telephone: "555-1234", homeAddress: "123 Main St", ftnNumber: "123456789")
    let templates = [
        ChecklistTemplate(name: "Pre-Flight Inspection", category: "PPL", items: []),
        ChecklistTemplate(name: "Post-Flight Inspection", category: "PPL", items: [])
    ]
    AddChecklistToStudentView(student: student, templates: templates)
        .modelContainer(for: [Student.self, StudentChecklist.self, StudentChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}

