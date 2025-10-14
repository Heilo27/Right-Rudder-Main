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
            Text("Reviews").tag("Reviews")
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    private var templatesList: some View {
        List {
            ForEach(Array(phaseGroups.enumerated()), id: \.element.id) { phaseIndex, phaseGroup in
                phaseSection(phaseIndex: phaseIndex, phaseGroup: phaseGroup)
                
                  // Add spacing between phases for Instrument and Commercial categories (except after the last one)
                  if (selectedCategory == "Instrument" || selectedCategory == "Commercial") && phaseIndex < phaseGroups.count - 1 {
                      spacingSection
                  }
            }
        }
        .environment(\.editMode, isEditing ? .constant(.active) : .constant(.inactive))
    }
    
    @ViewBuilder
    private func phaseSection(phaseIndex: Int, phaseGroup: PhaseGroup) -> some View {
        Section(header: sectionHeader(phaseIndex: phaseIndex, phaseGroup: phaseGroup)) {
            ForEach(Array(phaseGroup.templates.enumerated()), id: \.element.id) { index, template in
                templateRowWithActions(template: template, index: index, phaseGroup: phaseGroup)
            }
            .onMove { from, to in
                moveTemplates(from: from, to: to, in: phaseGroup.templates)
            }
            .onDelete { offsets in
                deleteTemplates(offsets: offsets, templates: phaseGroup.templates)
            }
        }
    }
    
    @ViewBuilder
    private func sectionHeader(phaseIndex: Int, phaseGroup: PhaseGroup) -> some View {
        if selectedCategory == "Instrument" {
            phaseHeader(for: phaseGroup.phase, isFirst: phaseIndex == 0)
        } else {
            Text(phaseGroup.phase)
                .font(.headline)
        }
    }
    
    @ViewBuilder
    private func templateRowWithActions(template: ChecklistTemplate, index: Int, phaseGroup: PhaseGroup) -> some View {
        if isEditing {
            templateRow(template)
                .adaptiveRowBackgroundModifier(for: index)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button("Delete", role: .destructive) {
                        deleteTemplate(template)
                    }
                }
        } else {
            NavigationLink(destination: ChecklistTemplateDetailView(template: template)) {
                templateRow(template)
            }
            .adaptiveRowBackgroundModifier(for: index)
        }
    }
    
    private var spacingSection: some View {
        Section {
            EmptyView()
        } header: {
            Spacer()
                .frame(height: 4)
        }
    }
    
    @ViewBuilder
    private func phaseHeader(for phase: String, isFirst: Bool) -> some View {
        VStack(spacing: 8) {
            if !isFirst {
                // Add spacing above phase name (except for first phase)
                Spacer()
                    .frame(height: 3)
            }
            
            if selectedCategory == "Instrument" || selectedCategory == "Commercial" {
                // Special formatting for Instrument and Commercial phases with number and description
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(phase)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
                .padding(.horizontal, 4)
            } else {
                // Standard formatting for other categories
                HStack {
                    Text(phase)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
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
        
        if selectedCategory == "Instrument" {
            return createInstrumentPhaseGroups(filtered)
        } else if selectedCategory == "Commercial" {
            return createCommercialPhaseGroups(filtered)
        } else {
            let grouped = Dictionary(grouping: filtered) { template in
                template.phase ?? "Phase 1"
            }
            
            // Define the logical order for phases - First Steps must be at the top
            let phaseOrder = ["First Steps", "Phase 1", "Pre-Solo/Solo", "Phase 2", "Phase 3", "Phase 4", "Flight Reviews", "Instrument Rating", "Commercial Rating"]
            
            // Create phase groups with sorted templates
            var phaseGroups: [PhaseGroup] = []
            for (phase, templates) in grouped {
                let sortedTemplates = sortTemplatesForPhase(templates, phase: phase)
                let phaseGroup = PhaseGroup(phase: phase, templates: sortedTemplates)
                phaseGroups.append(phaseGroup)
            }
            
            return sortPhaseGroups(phaseGroups, phaseOrder: phaseOrder)
        }
    }
    
    private func createInstrumentPhaseGroups(_ templates: [ChecklistTemplate]) -> [PhaseGroup] {
        let phase1Templates = templates.filter { template in
            template.name.contains("P1L") || template.name.contains("P1-L")
        }
        let phase2Templates = templates.filter { template in
            template.name.contains("P2L") || template.name.contains("P2-L")
        }
        let phase3Templates = templates.filter { template in
            template.name.contains("P3L") || template.name.contains("P3-L")
        }
        let phase4Templates = templates.filter { template in
            template.name.contains("P4L") || template.name.contains("P4-L")
        }
        let phase5Templates = templates.filter { template in
            template.name.contains("P5L") || template.name.contains("P5-L")
        }
        
        var phaseGroups: [PhaseGroup] = []
        
        if !phase1Templates.isEmpty {
            phaseGroups.append(PhaseGroup(phase: "Phase 1: Basic instrument control and skills", templates: phase1Templates.sorted { $0.name < $1.name }))
        }
        if !phase2Templates.isEmpty {
            phaseGroups.append(PhaseGroup(phase: "Phase 2: Navigation systems and procedures", templates: phase2Templates.sorted { $0.name < $1.name }))
        }
        if !phase3Templates.isEmpty {
            phaseGroups.append(PhaseGroup(phase: "Phase 3: Instrument approaches and advanced procedures", templates: phase3Templates.sorted { $0.name < $1.name }))
        }
        if !phase4Templates.isEmpty {
            phaseGroups.append(PhaseGroup(phase: "Phase 4: Instrument Cross Countries", templates: phase4Templates.sorted { $0.name < $1.name }))
        }
        if !phase5Templates.isEmpty {
            phaseGroups.append(PhaseGroup(phase: "Phase 5: Becoming Instrument Rated", templates: phase5Templates.sorted { $0.name < $1.name }))
        }
        
        return phaseGroups
    }
    
    private func createCommercialPhaseGroups(_ templates: [ChecklistTemplate]) -> [PhaseGroup] {
        let stage1Templates = templates.filter { template in
            template.name.contains("C1L") || template.name.contains("C1-L")
        }
        let stage2Templates = templates.filter { template in
            template.name.contains("C2L") || template.name.contains("C2-L")
        }
        let stage3Templates = templates.filter { template in
            template.name.contains("C3L") || template.name.contains("C3-L")
        }
        
        var phaseGroups: [PhaseGroup] = []
        
        if !stage1Templates.isEmpty {
            phaseGroups.append(PhaseGroup(phase: "Stage 1: Learning Professional Cross-Country and Night Procedures", templates: stage1Templates.sorted { $0.name < $1.name }))
        }
        if !stage2Templates.isEmpty {
            phaseGroups.append(PhaseGroup(phase: "Stage 2: Flying Complex Airplanes and Commercial Maneuvers", templates: stage2Templates.sorted { $0.name < $1.name }))
        }
        if !stage3Templates.isEmpty {
            phaseGroups.append(PhaseGroup(phase: "Stage 3: Preparing for Commercial Pilot Check Ride", templates: stage3Templates.sorted { $0.name < $1.name }))
        }
        
        return phaseGroups
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
        if phase == "Flight Reviews" {
            return phaseOrder.firstIndex(of: "Flight Reviews") ?? phaseOrder.count
        }
        if phase == "Instrument Rating" {
            return phaseOrder.firstIndex(of: "Instrument Rating") ?? phaseOrder.count
        }
        if phase == "Commercial Rating" {
            return phaseOrder.firstIndex(of: "Commercial Rating") ?? phaseOrder.count
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


