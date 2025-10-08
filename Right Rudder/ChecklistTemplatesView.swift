//
//  ChecklistTemplatesView.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import SwiftUI
import SwiftData

struct ChecklistTemplatesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChecklistTemplate.name, order: .forward) private var templates: [ChecklistTemplate]
    @State private var showingAddTemplate = false
    @State private var selectedCategory = "PPL"
    @State private var isEditing = false

    var body: some View {
        NavigationView {
            VStack {
                categoryPicker
                templatesList
            }
            .navigationTitle("Checklist Templates")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Add new Checklist") {
                            showingAddTemplate = true
                        }
                        
                        Button(isEditing ? "Done Editing" : "Edit List Order") {
                            isEditing.toggle()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .buttonStyle(.noHaptic)
                }
            }
            .sheet(isPresented: $showingAddTemplate) {
                AddChecklistTemplateView(category: selectedCategory)
            }
        }
    }
    
    private var categoryPicker: some View {
        Picker("Category", selection: $selectedCategory) {
            Text("PPL").tag("PPL")
            Text("Instrument").tag("Instrument")
            Text("Commercial").tag("Commercial")
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    private var templatesList: some View {
        List {
            ForEach(phaseGroups) { phaseGroup in
                Section(header: Text(phaseGroup.phase).font(.headline)) {
                    ForEach(Array(phaseGroup.templates.enumerated()), id: \.element.id) { index, template in
                        if isEditing {
                            templateRow(template)
                                .listRowBackground(index.isMultiple(of: 2) ? Color.appMutedBox : Color.clear)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button("Delete", role: .destructive) {
                                        deleteTemplate(template)
                                    }
                                }
                        } else {
                            NavigationLink(destination: ChecklistTemplateDetailView(template: template)) {
                                templateRow(template)
                            }
                            .listRowBackground(index.isMultiple(of: 2) ? Color.appMutedBox : Color.clear)
                        }
                    }
                    .onMove { from, to in
                        moveTemplates(from: from, to: to, in: phaseGroup.templates)
                    }
                    .onDelete { offsets in
                        deleteTemplates(offsets: offsets, templates: phaseGroup.templates)
                    }
                }
            }
        }
        .environment(\.editMode, isEditing ? .constant(.active) : .constant(.inactive))
    }
    
    private func templateRow(_ template: ChecklistTemplate) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(template.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("\(template.items?.count ?? 0) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if isEditing {
                Spacer()
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }
    
    private var filteredTemplates: [ChecklistTemplate] {
        templates.filter { $0.category == selectedCategory }
            .sorted { $0.name < $1.name }
    }
    
    // Helper function to extract lesson number from P1 template names
    // Optimized: Compiles regex once as a static property
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
        let filtered = filteredTemplates
        let grouped = Dictionary(grouping: filtered) { template in
            template.phase ?? "Phase 1"
        }
        
        // Define the logical order for phases - First Steps must be at the top
        let phaseOrder = ["First Steps", "Phase 1", "Pre-Solo/Solo", "Phase 2", "Phase 3", "Phase 4"]
        
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
    
    private func deleteTemplates(offsets: IndexSet, templates: [ChecklistTemplate]) {
        withAnimation {
            for index in offsets {
                modelContext.delete(templates[index])
            }
        }
    }
    
    private func deleteTemplate(_ template: ChecklistTemplate) {
        withAnimation {
            modelContext.delete(template)
        }
    }
    
    private func moveTemplates(from source: IndexSet, to destination: Int, in templates: [ChecklistTemplate]) {
        // For now, we'll just save the context after moving
        // In a more sophisticated implementation, you might want to add an 'order' field to ChecklistTemplate
        do {
            try modelContext.save()
        } catch {
            print("Failed to save after moving templates: \(error)")
        }
    }
}

struct PhaseGroup: Identifiable {
    let id: String  // Use phase as the identifier
    let phase: String
    let templates: [ChecklistTemplate]
    
    init(phase: String, templates: [ChecklistTemplate]) {
        self.id = phase
        self.phase = phase
        self.templates = templates
    }
}

#Preview {
    ChecklistTemplatesView()
        .modelContainer(for: [Student.self, StudentChecklist.self, StudentChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}


