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
    @State private var student: Student
    @State private var checklist: StudentChecklist
    @State private var template: ChecklistTemplate?
    @State private var showingTrainingHours = false
    
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

    init(student: Student, checklist: StudentChecklist) {
        self._student = State(initialValue: student)
        self._checklist = State(initialValue: checklist)
    }

    var body: some View {
        List {
            // Standard checklist items
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
            
            // Special section for Previous Flight Training
            if let trainingItem = (checklist.items ?? []).first(where: { $0.title == "Previous Flight training" }) {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Button(action: {
                                trainingItem.isComplete.toggle()
                                if trainingItem.isComplete {
                                    trainingItem.completedAt = Date()
                                } else {
                                    trainingItem.completedAt = nil
                                }
                            }) {
                                Image(systemName: trainingItem.isComplete ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(trainingItem.isComplete ? .green : .gray)
                                    .font(.title2)
                            }
                            .buttonStyle(.noHaptic)
                            
                            Text(trainingItem.title)
                                .strikethrough(trainingItem.isComplete)
                                .foregroundColor(trainingItem.isComplete ? .secondary : .primary)
                        }
                        
                        if trainingItem.isComplete {
                        Button("Enter Training Hours") {
                            showingTrainingHours = true
                        }
                        .buttonStyle(.rounded)
                        }
                    }
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
            loadTemplate()
        }
    }
    
    private var sortedItems: [StudentChecklistItem] {
        let items = checklist.items ?? []
        let sorted = items.sorted { $0.order < $1.order }
        
        // Debug output to see what's happening
        print("=== ITEM SORTING DEBUG ===")
        print("Total items: \(items.count)")
        for (index, item) in items.prefix(5).enumerated() {
            print("Original \(index): '\(item.title)' -> order: \(item.order)")
        }
        print("After sorting:")
        for (index, item) in sorted.prefix(5).enumerated() {
            print("Sorted \(index): '\(item.title)' -> order: \(item.order)")
        }
        print("=========================")
        
        return sorted
    }
    
    private func extractNumberFromTitle(_ title: String) -> Int {
        // Try pattern "1. " first (period format)
        let periodPattern = "^\\d+\\."
        if let range = title.range(of: periodPattern, options: .regularExpression) {
            let numberString = String(title[range]).replacingOccurrences(of: ".", with: "")
            return Int(numberString) ?? 999
        }
        
        // Try pattern "(1)" (parentheses format)
        let parenthesesPattern = "^\\(\\d+\\)"
        if let range = title.range(of: parenthesesPattern, options: .regularExpression) {
            let numberString = String(title[range]).replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
            return Int(numberString) ?? 999
        }
        
        // If no number found, use the order property from the item
        // This will be handled by the sorting logic using the order property
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
    let checklist = StudentChecklist(templateId: UUID(), templateName: "Student Onboard/Training Overview", items: [
        StudentChecklistItem(templateItemId: UUID(), title: "Contact information"),
        StudentChecklistItem(templateItemId: UUID(), title: "U.S. Citizenship proof & endorsement"),
        StudentChecklistItem(templateItemId: UUID(), title: "Logbook Review"),
        StudentChecklistItem(templateItemId: UUID(), title: "Previous Flight training")
    ])
    StudentOnboardView(student: student, checklist: checklist)
        .modelContainer(for: [Student.self, StudentChecklist.self, StudentChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}