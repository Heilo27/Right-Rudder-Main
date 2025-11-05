//
//  StudentOnboardView.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import SwiftUI
import SwiftData

struct StudentOnboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var student: Student
    @Bindable var progress: ChecklistAssignment
    @State private var template: ChecklistTemplate?
    @State private var showingTrainingHours = false
    @State private var itemStates: [UUID: Bool] = [:]
    
    // Training hours fields
    @State private var totalHours = ""
    @State private var dualHours = ""
    @State private var soloHours = ""
    @State private var xcDualHours = ""
    @State private var xcSoloHours = ""
    @State private var nightDualHours = ""
    @State private var nightSoloHours = ""
    @State private var nightLandings = ""
    @State private var instrumentHours = ""
    @State private var previousInstructorName = ""


    var body: some View {
        Group {
            if template == nil {
                VStack {
                    Text("Loading checklist...")
                        .font(.headline)
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    // Standard checklist items
                    ForEach(Array(ChecklistAssignmentService.getDisplayItems(for: progress).sorted { $0.order < $1.order }.enumerated()), id: \.element.templateItemId) { index, displayItem in
                        BufferedChecklistItemRow(
                            displayItem: displayItem,
                            bufferedState: itemStates[displayItem.templateItemId] ?? displayItem.isComplete,
                            onToggle: { isComplete in
                                // Buffer the change instead of modifying SwiftData object directly
                                itemStates[displayItem.templateItemId] = isComplete
                            },
                            displayTitle: displayTitle
                        )
                        .adaptiveRowBackgroundModifier(for: index)
                    }
                    .onMove(perform: moveItems)
                    
                    // Special section for Previous Flight Training
                    if let trainingDisplayItem = ChecklistAssignmentService.getDisplayItems(for: progress).first(where: { $0.title == "Previous Flight training" }) {
                        Section {
                            TrainingItemView(
                                trainingDisplayItem: trainingDisplayItem,
                                bufferedState: itemStates[trainingDisplayItem.templateItemId] ?? trainingDisplayItem.isComplete,
                                onToggle: { newState in
                                    itemStates[trainingDisplayItem.templateItemId] = newState
                                },
                                showingTrainingHours: $showingTrainingHours
                            )
                        }
                    }
                    
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
        .sheet(isPresented: $showingTrainingHours) {
            TrainingHoursView(
                totalHours: $totalHours,
                dualHours: $dualHours,
                soloHours: $soloHours,
                xcDualHours: $xcDualHours,
                xcSoloHours: $xcSoloHours,
                nightDualHours: $nightDualHours,
                nightSoloHours: $nightSoloHours,
                nightLandings: $nightLandings,
                instrumentHours: $instrumentHours,
                previousInstructorName: $previousInstructorName
            )
        }
        .onAppear {
            print("🎯 StudentOnboardView appeared for checklist: \(progress.displayName)")
            loadTemplate()
            
            // Ensure all template items have ItemProgress records
            ensureItemProgressRecordsExist()
        }
        .onDisappear {
            // Save buffered changes when leaving the view
            Task {
                await saveBufferedChanges()
            }
        }
    }
    
    /// Saves buffered item state changes to SwiftData
    private func saveBufferedChanges() async {
        guard !itemStates.isEmpty else { return }
        
        print("💾 Saving buffered checklist changes for \(progress.displayName)")
        
        // Ensure itemProgress array is initialized
        if progress.itemProgress == nil {
            progress.itemProgress = []
        }
        
        // Get display items to understand which items should exist
        let displayItems = ChecklistAssignmentService.getDisplayItems(for: progress)
        
        // Apply all buffered changes to SwiftData objects
        for (itemId, isComplete) in itemStates {
            // Try to find existing ItemProgress record
            var progressItem = progress.itemProgress?.first(where: { $0.templateItemId == itemId })
            
            // If not found, create a new one
            if progressItem == nil {
                // Verify the itemId exists in display items (for validation)
                if displayItems.contains(where: { $0.templateItemId == itemId }) {
                    progressItem = ItemProgress(templateItemId: itemId)
                    progressItem?.assignment = progress
                    progress.itemProgress?.append(progressItem!)
                    modelContext.insert(progressItem!)
                    print("✅ Created new ItemProgress record for templateItemId: \(itemId)")
                } else {
                    print("⚠️ Could not find display item for templateItemId: \(itemId)")
                    continue
                }
            }
            
            // Update the progress item
            if let progressItem = progressItem {
                progressItem.isComplete = isComplete
                progressItem.lastModified = Date()
                if isComplete {
                    progressItem.completedAt = Date()
                } else {
                    progressItem.completedAt = nil
                }
            }
        }
        
        // Update progress metadata
        progress.lastModified = Date()
        student.lastModified = Date() // Trigger progress bar refresh
        
        // Save to SwiftData
        do {
            try modelContext.save()
            print("✅ Saved buffered checklist changes for \(progress.displayName)")
            
            // Post notification that checklist items were updated
            NotificationCenter.default.post(name: Notification.Name("checklistItemCompleted"), object: nil)
            print("📢 Posted checklistItemCompleted notification from StudentOnboardView")
            
            itemStates.removeAll() // Clear buffer after successful save
        } catch {
            print("❌ Failed to save buffered changes: \(error)")
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
        
        // If template is nil, try to repair the relationship
        if template == nil {
            print("⚠️ Template is nil for progress \(progress.templateId), attempting repair...")
            
            // Try to find template by ID
            let request = FetchDescriptor<ChecklistTemplate>()
            
            do {
                let templates = try modelContext.fetch(request)
                if let foundTemplate = templates.first(where: { $0.id == progress.templateId }) {
                    progress.template = foundTemplate
                    template = foundTemplate
                    print("✅ Repaired template relationship: \(foundTemplate.name)")
                    // Save the repaired relationship
                    try? modelContext.save()
                } else {
                    print("❌ Template not found for ID: \(progress.templateId)")
                    
                    // If template still not found, check if default templates need to be initialized
                    let defaultTemplatesExist = templates.contains { $0.templateIdentifier != nil }
                    if !defaultTemplatesExist {
                        print("⚠️ No default templates found. Initializing default templates...")
                        DefaultDataService.initializeDefaultData(modelContext: modelContext)
                        
                        // Try again after initialization
                        let retryRequest = FetchDescriptor<ChecklistTemplate>()
                        if let retryTemplates = try? modelContext.fetch(retryRequest),
                           let foundTemplate = retryTemplates.first(where: { $0.id == progress.templateId }) {
                            progress.template = foundTemplate
                            template = foundTemplate
                            print("✅ Found template after initialization: \(foundTemplate.name)")
                            try? modelContext.save()
                        }
                    }
                }
            } catch {
                print("❌ Failed to fetch template: \(error)")
            }
        }
        
        print("🎯 Loaded template: \(template?.name ?? "nil")")
    }
    
    /// Ensures all template items have corresponding ItemProgress records
    private func ensureItemProgressRecordsExist() {
        guard let template = template, let templateItems = template.items else {
            print("⚠️ Cannot ensure ItemProgress records: template or items are nil")
            return
        }
        
        // Initialize itemProgress array if needed
        if progress.itemProgress == nil {
            progress.itemProgress = []
        }
        
        var createdCount = 0
        for templateItem in templateItems {
            let templateItemId = templateItem.id
            
            // Check if ItemProgress record exists for this item
            if progress.itemProgress?.first(where: { $0.templateItemId == templateItemId }) == nil {
                let newProgressItem = ItemProgress(templateItemId: templateItemId)
                newProgressItem.assignment = progress
                progress.itemProgress?.append(newProgressItem)
                modelContext.insert(newProgressItem)
                createdCount += 1
            }
        }
        
        if createdCount > 0 {
            print("✅ Created \(createdCount) missing ItemProgress records for \(progress.displayName)")
            
            // Save the new records
            do {
                try modelContext.save()
                print("✅ Saved new ItemProgress records")
            } catch {
                print("❌ Failed to save new ItemProgress records: \(error)")
            }
        }
    }
}

struct TrainingItemView: View {
    let trainingDisplayItem: DisplayChecklistItem
    let bufferedState: Bool
    let onToggle: (Bool) -> Void
    @Binding var showingTrainingHours: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button(action: {
                    // Toggle the state
                    onToggle(!bufferedState)
                }) {
                    Image(systemName: bufferedState ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(bufferedState ? .green : .gray)
                        .font(.title2)
                }
                .buttonStyle(.noHaptic)
                
                Text(trainingDisplayItem.title)
                    .strikethrough(bufferedState)
                    .foregroundColor(bufferedState ? .secondary : .primary)
            }
            
            if bufferedState {
                Button("Enter Training Hours") {
                    showingTrainingHours = true
                }
                .buttonStyle(.rounded)
            }
        }
    }
}

struct TrainingHoursView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var totalHours: String
    @Binding var dualHours: String
    @Binding var soloHours: String
    @Binding var xcDualHours: String
    @Binding var xcSoloHours: String
    @Binding var nightDualHours: String
    @Binding var nightSoloHours: String
    @Binding var nightLandings: String
    @Binding var instrumentHours: String
    @Binding var previousInstructorName: String

    var body: some View {
        NavigationView {
            Form {
                Section("Flight Training Hours") {
                    HStack {
                        Text("Total Hours")
                        Spacer()
                        TextField("0.0", text: $totalHours)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Dual Hours")
                        Spacer()
                        TextField("0.0", text: $dualHours)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Solo Hours")
                        Spacer()
                        TextField("0.0", text: $soloHours)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("X/C Dual Hours")
                        Spacer()
                        TextField("0.0", text: $xcDualHours)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("X/C Solo Hours")
                        Spacer()
                        TextField("0.0", text: $xcSoloHours)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Night Dual Hours")
                        Spacer()
                        TextField("0.0", text: $nightDualHours)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Night Solo Hours")
                        Spacer()
                        TextField("0.0", text: $nightSoloHours)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Night Landings")
                        Spacer()
                        TextField("0", text: $nightLandings)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Instrument Hours")
                        Spacer()
                        TextField("0.0", text: $instrumentHours)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Previous Instructor") {
                    TextField("Previous Instructor Name", text: $previousInstructorName)
                }
            }
            .navigationTitle("Training Hours")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let student = Student(firstName: "John", lastName: "Doe", email: "john@example.com", telephone: "555-1234", homeAddress: "123 Main St", ftnNumber: "123456789")
    let progress = ChecklistAssignment(templateId: UUID(), templateIdentifier: "student-onboard")
    StudentOnboardView(student: student, progress: progress)
        .modelContainer(for: [Student.self, ChecklistAssignment.self, ItemProgress.self, CustomChecklistDefinition.self, CustomChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}