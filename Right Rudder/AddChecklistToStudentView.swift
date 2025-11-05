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
    @StateObject private var cloudKitShareService = CloudKitShareService()
    
    let student: Student
    let templates: [ChecklistTemplate]

    var body: some View {
        NavigationView {
            Group {
                if templates.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No Templates Available")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("No checklist templates found in the database. Templates may need to be initialized.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Dismiss") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .navigationTitle("Add Checklist")
                    .navigationBarTitleDisplayMode(.inline)
                } else if selectedCategory == nil {
                    categorySelectionView
                        .navigationTitle("Select Category")
                        .navigationBarTitleDisplayMode(.inline)
                } else {
                    templatesList
                        .navigationTitle("Add Checklist")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if selectedCategory != nil {
                        Button(action: {
                            selectedCategory = nil
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 17, weight: .medium))
                            }
                            .foregroundColor(.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.appAdaptiveMutedBox)
                            .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .onAppear {
            cloudKitShareService.setModelContext(modelContext)
            print("📋 AddChecklistToStudentView appeared with \(templates.count) templates")
            if templates.isEmpty {
                print("⚠️ WARNING: No templates available!")
            }
        }
    }
    
    private var categorySelectionView: some View {
        List {
            if availableCategories.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No Categories Available")
                        .font(.headline)
                    Text("No checklist templates found in any category")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
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
        let phaseOrder = ["First Steps", "Phase 1", "Phase 1.5 Pre-Solo/Solo", "Phase 2", "Phase 3", "Phase 4"]
        
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
        return student.checklistAssignments?.contains { $0.templateId == template.id } ?? false
    }
    
    private func addChecklistToStudent(_ template: ChecklistTemplate) {
        // Check if already assigned
        guard !isChecklistAlreadyAssigned(template) else { return }
        
        // Use new reference-based assignment system
        ChecklistAssignmentService.assignTemplate(template, to: student, modelContext: modelContext)
        
        // Save changes immediately to ensure UI updates
        do {
            try modelContext.save()
            print("✅ Checklist assigned and saved: \(template.name)")
        } catch {
            print("❌ Failed to save after assigning checklist: \(error)")
        }
        
        // Trigger automatic sync to shared zone using new system
        Task {
            await self.cloudKitShareService.syncStudentChecklistProgressToSharedZone(self.student, modelContext: self.modelContext)
        }
        
        // Don't dismiss - let user manually close the sheet
    }
    
    private func addAllTemplatesInPhase(_ templates: [ChecklistTemplate]) {
        // Filter out templates that are already assigned
        let unassignedTemplates = templates.filter { !isChecklistAlreadyAssigned($0) }
        
        // Use new reference-based assignment system for each template
        for template in unassignedTemplates {
            ChecklistAssignmentService.assignTemplate(template, to: student, modelContext: modelContext)
        }
        
        // Save changes immediately to ensure UI updates
        do {
            try modelContext.save()
            print("✅ All templates assigned and saved: \(unassignedTemplates.count) templates")
        } catch {
            print("❌ Failed to save after assigning templates: \(error)")
        }
        
        // Trigger automatic sync to shared zone using new system
        Task {
            await self.cloudKitShareService.syncStudentChecklistProgressToSharedZone(self.student, modelContext: self.modelContext)
        }
        
        // Don't dismiss - let user manually close the sheet
    }
    
    // Use shared utility for lesson info extraction
    private func extractLessonInfo(from name: String) -> (phase: String, lesson: String) {
        return TemplateSortingUtilities.extractLessonInfo(from: name)
    }
    
    private func deleteAllTemplatesInPhase(_ templates: [ChecklistTemplate]) {
        #if DEBUG
        print("Delete All button pressed for \(templates.count) templates")
        #endif
        
        // Find and delete checklist assignments that match any template in this phase
        guard let assignments = student.checklistAssignments else { return }
        
        // Match by template ID (more reliable than name matching)
        let assignmentsToDelete = assignments.filter { assignment in
            return templates.contains { template in
                return assignment.templateId == template.id
            }
        }
        
        if assignmentsToDelete.isEmpty { return }
        
        // Delete from database using the new assignment service
        for assignment in assignmentsToDelete {
            if let template = assignment.template {
                ChecklistAssignmentService.removeTemplate(template, from: student, modelContext: modelContext)
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
        .modelContainer(for: [Student.self, ChecklistAssignment.self, ItemProgress.self, CustomChecklistDefinition.self, CustomChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}

