//
//  LessonView.swift
//  Right Rudder
//
//  Created by AI on 10/5/25.
//

import SwiftUI
import SwiftData

struct LessonView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var student: Student
    @Bindable var checklist: StudentChecklist
    @State private var template: ChecklistTemplate?
    @StateObject private var cloudKitShareService = CloudKitShareService()
    @State private var hasUnsavedChanges = false
    @State private var itemStates: [UUID: Bool] = [:]

    init(student: Student, checklist: StudentChecklist) {
        self.student = student
        self.checklist = checklist
    }
    
    /// Applies buffered changes to SwiftData objects and syncs to CloudKit when user exits the checklist
    private func syncChangesOnExit() async {
        if hasUnsavedChanges {
            print("🔄 Applying buffered changes and syncing on checklist exit...")
            
            // Apply all buffered changes to SwiftData objects
            for (itemId, isComplete) in itemStates {
                if let item = checklist.items?.first(where: { $0.id == itemId }) {
                    item.isComplete = isComplete
                    if isComplete {
                        item.completedAt = Date()
                    } else {
                        item.completedAt = nil
                    }
                }
            }
            
            // Save to SwiftData
            do {
                try modelContext.save()
                await cloudKitShareService.syncStudentChecklistsToSharedZone(student, modelContext: modelContext)
                hasUnsavedChanges = false
                itemStates.removeAll()
            } catch {
                print("Failed to save checklist on exit: \(error)")
            }
        }
    }

    var body: some View {
        List {
            // Standard checklist items
            ForEach(Array((checklist.items ?? []).sorted { $0.order < $1.order }.enumerated()), id: \.element.id) { index, item in
                BufferedChecklistItemRow(
                    item: item, 
                    bufferedState: itemStates[item.id] ?? item.isComplete,
                    onToggle: { isComplete in
                        // Buffer the change instead of modifying SwiftData object directly
                        itemStates[item.id] = isComplete
                        hasUnsavedChanges = true
                    }, 
                    displayTitle: displayTitle
                )
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
                                set: { newValue in
                                    checklist.dualGivenHours = newValue
                                    hasUnsavedChanges = true
                                }
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
                        set: { newValue in
                            checklist.instructorComments = newValue.isEmpty ? nil : newValue
                            hasUnsavedChanges = true
                        }
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("\(completedCount)/\((checklist.items ?? []).count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .id(checklist.id) // Prevent view recreation when checklist data changes
        .onAppear {
            print("🎯 LessonView appeared for checklist: \(checklist.templateName)")
            loadTemplate()
            cloudKitShareService.setModelContext(modelContext)
        }
        .onDisappear {
            print("🚪 LessonView disappeared for checklist: \(checklist.templateName)")
            // Sync changes when user exits the checklist
            Task {
                await syncChangesOnExit()
            }
        }
    }
    
    private var completedCount: Int {
        (checklist.items ?? []).filter { $0.isComplete }.count
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
        
        // Mark as having unsaved changes
        hasUnsavedChanges = true
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

struct BufferedChecklistItemRow: View {
    let item: StudentChecklistItem
    let bufferedState: Bool
    let onToggle: (Bool) -> Void
    let displayTitle: ((String) -> String)?
    @State private var showingNotes = false
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    init(item: StudentChecklistItem, bufferedState: Bool, onToggle: @escaping (Bool) -> Void, displayTitle: ((String) -> String)? = nil) {
        self.item = item
        self.bufferedState = bufferedState
        self.onToggle = onToggle
        self.displayTitle = displayTitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: bufferedState ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(bufferedState ? .green : .gray)
                        .font(.title2)

                    Text(displayTitle?(item.title) ?? item.title)
                        .strikethrough(bufferedState)
                        .foregroundColor(bufferedState ? .secondary : .primary)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    if let itemNotes = item.notes, !itemNotes.isEmpty {
                        Button(action: { showingNotes = true }) {
                            Image(systemName: "note.text")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.noHaptic)
                    }
                }

                // Display notes underneath the main item
                if let itemNotes = item.notes, !itemNotes.isEmpty {
                    Text(itemNotes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 32) // Align with the text above
                }
            }
            .offset(x: dragOffset)
            .contentShape(Rectangle()) // Make the entire area tappable
            .onTapGesture {
                // Only allow checking (not unchecking) with tap
                if !bufferedState {
                    onToggle(true)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 30)
                    .onChanged { value in
                        let horizontalMovement = value.translation.width
                        let verticalMovement = abs(value.translation.height)
                        
                        // Only respond to VERY clearly horizontal swipes
                        // Require horizontal movement to be at least 4x greater than vertical
                        // AND minimum 50 points horizontal movement
                        if abs(horizontalMovement) > 50 && abs(horizontalMovement) > verticalMovement * 4.0 {
                            isDragging = true
                        // Only allow left swipes (negative values) and only if item is complete
                        if horizontalMovement < 0 && bufferedState {
                                // Smooth drag animation that follows finger
                                withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8)) {
                                    dragOffset = max(horizontalMovement, -120) // Limit drag distance
                                }
                            }
                        }
                    }
                    .onEnded { value in
                        let horizontalMovement = value.translation.width
                        let verticalMovement = abs(value.translation.height)
                        
                        print("DEBUG: Swipe ended - horizontal: \(horizontalMovement), vertical: \(verticalMovement)")
                        print("DEBUG: isComplete: \(bufferedState), ratio: \(abs(horizontalMovement) / max(verticalMovement, 1))")
                        
                        // Check if this was a valid left swipe for unchecking
                        let isValidSwipe = horizontalMovement < -60 && verticalMovement < 40 && 
                                         abs(horizontalMovement) > verticalMovement * 2.0 && bufferedState
                        
                        if isValidSwipe {
                            // Perform the uncheck action
                            onToggle(false)
                        }
                        
                        // Always animate back to original position
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            dragOffset = 0
                            isDragging = false
                        }
                    }
            )
            
            if bufferedState, let completedAt = item.completedAt {
                Text("Completed: \(completedAt, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $showingNotes) {
            NotesView(item: item)
        }
    }
}

#Preview {
    let student = Student(firstName: "John", lastName: "Doe", email: "john@example.com", telephone: "555-1234", homeAddress: "123 Main St", ftnNumber: "123456789")
    let checklist = StudentChecklist(templateId: UUID(), templateName: "P1-L8: Regular Landings", items: [
        StudentChecklistItem(templateItemId: UUID(), title: "Regular Landing"),
        StudentChecklistItem(templateItemId: UUID(), title: "Pattern Work")
    ])
    LessonView(student: student, checklist: checklist)
        .modelContainer(for: [Student.self, StudentChecklist.self, StudentChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}

