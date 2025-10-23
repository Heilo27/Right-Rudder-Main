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
    @State private var selectedCategory: String? = nil
    
    let student: Student
    let templates: [ChecklistTemplate]

    var body: some View {
        NavigationView {
            if selectedCategory == nil {
                categorySelectionView
            } else {
                templatesList
            }
        }
        .navigationTitle(selectedCategory == nil ? "Select Category" : "Add Checklist")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if selectedCategory != nil {
                    Button("Back") {
                        selectedCategory = nil
                    }
                    .buttonStyle(.noHaptic)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.noHaptic)
            }
        }
    }
    
    private var categorySelectionView: some View {
        List {
            ForEach(availableCategories, id: \.self) { category in
                Button(action: {
                    selectedCategory = category
                }) {
                    HStack {
                        categoryIcon(for: category)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(category)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("\(templatesInCategory(category).count) lessons")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
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
            HStack(spacing: 12) {
                Button("Delete All") {
                    deleteAllTemplatesInPhase(phaseGroup.templates)
                }
                .buttonStyle(.rounded)
                .foregroundColor(.red)
                
                Button("Add All") {
                    addAllTemplatesInPhase(phaseGroup.templates)
                }
                .buttonStyle(.rounded)
            }
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
    
    // Use shared utility for lesson number extraction
    private func extractLessonNumber(from templateName: String) -> Int? {
        return TemplateSortingUtilities.extractLessonNumber(from: templateName)
    }
    
    private var availableCategories: [String] {
        let categories = Set(templates.map { $0.category })
        return Array(categories).sorted()
    }
    
    private func templatesInCategory(_ category: String) -> [ChecklistTemplate] {
        return templates.filter { $0.category == category }
    }
    
    private func categoryIcon(for category: String) -> some View {
        let (icon, color) = categoryIconInfo(for: category)
        return Image(systemName: icon)
            .foregroundColor(color)
            .font(.title2)
            .frame(width: 30)
    }
    
    private func categoryIconInfo(for category: String) -> (String, Color) {
        switch category {
        case "PPL":
            return ("airplane", .blue)
        case "Instrument":
            return ("cloud.fog", .gray)
        case "Commercial":
            return ("briefcase", .green)
        case "Reviews":
            return ("checkmark.circle", .orange)
        default:
            return ("list.bullet", .secondary)
        }
    }
    
    private var phaseGroups: [PhaseGroup] {
        guard let selectedCategory = selectedCategory else { return [] }
        
        let filteredTemplates = templates.filter { $0.category == selectedCategory }
        let grouped = Dictionary(grouping: filteredTemplates) { template in
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
            return sortPhase1Templates(templates)
        }
    }
    
    private func sortFirstStepsTemplates(_ templates: [ChecklistTemplate]) -> [ChecklistTemplate] {
        return TemplateSortingUtilities.sortFirstStepsTemplates(templates)
    }
    
    private func sortPhase1Templates(_ templates: [ChecklistTemplate]) -> [ChecklistTemplate] {
        return TemplateSortingUtilities.sortTemplatesByLessonNumber(templates)
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
            
            // Set template version tracking for automatic updates
            studentChecklist.templateVersion = SmartTemplateUpdateService.getCurrentTemplateVersion()
            studentChecklist.templateIdentifier = template.templateIdentifier
            
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
                
                let studentChecklist = StudentChecklist(
                    templateId: template.id,
                    templateName: template.name,
                    items: studentChecklistItems
                )
                
                // Set template version tracking for automatic updates
                studentChecklist.templateVersion = SmartTemplateUpdateService.getCurrentTemplateVersion()
                studentChecklist.templateIdentifier = template.templateIdentifier
                
                return studentChecklist
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
    
    // Use shared utility for lesson info extraction
    private func extractLessonInfo(from name: String) -> (phase: String, lesson: String) {
        return TemplateSortingUtilities.extractLessonInfo(from: name)
    }
    
    private func deleteAllTemplatesInPhase(_ templates: [ChecklistTemplate]) {
        #if DEBUG
        print("Delete All button pressed for \(templates.count) templates")
        #endif
        
        // Find and delete checklists that match any template in this phase
        guard let checklists = student.checklists else { return }
        
        // Match by category and lesson number instead of exact name
        // This works with both old (P1L5) and new (I1-L5) formats
        let checklistsToDelete = checklists.filter { checklist in
            let checklistName = checklist.templateName
            
            // Check if this checklist matches any template in this phase
            return templates.contains { template in
                // Extract lesson info from both names for comparison
                let checklistLesson = extractLessonInfo(from: checklistName)
                let templateLesson = extractLessonInfo(from: template.name)
                
                return checklistLesson.phase == templateLesson.phase && 
                       checklistLesson.lesson == templateLesson.lesson
            }
        }
        
        if checklistsToDelete.isEmpty { return }
        
        // Delete from database
        for checklist in checklistsToDelete {
            modelContext.delete(checklist)
        }
        
        // Update the student's checklists array
        student.checklists = checklists.filter { checklist in
            let checklistName = checklist.templateName
            
            // Keep checklists that don't match any template in this phase
            return !templates.contains { template in
                let checklistLesson = extractLessonInfo(from: checklistName)
                let templateLesson = extractLessonInfo(from: template.name)
                
                return checklistLesson.phase == templateLesson.phase && 
                       checklistLesson.lesson == templateLesson.lesson
            }
        }
        
        // Save the context to persist changes and trigger UI updates
        do {
            try modelContext.save()
            // Force a refresh of the student object to trigger UI updates
            student.lastModified = Date()
        } catch {
            print("Failed to save after deleting student checklists: \(error)")
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

