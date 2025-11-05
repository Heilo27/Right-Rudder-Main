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
    @State private var student: Student
    @State private var progress: ChecklistAssignment
    @State private var template: ChecklistTemplate?
    @StateObject private var cloudKitShareService = CloudKitShareService()
    @State private var hasUnsavedChanges = false
    @State private var itemStates: [UUID: Bool] = [:]
    @State private var showingInstructorNotes = false

    init(student: Student, progress: ChecklistAssignment) {
        self._student = State(initialValue: student)
        self._progress = State(initialValue: progress)
    }

    
    /// Applies buffered changes to SwiftData objects and syncs to CloudKit when user exits the checklist
    private func syncChangesOnExit() async {
        print("🔵 DEBUG: LessonView.syncChangesOnExit() called - Checklist save triggered")
        print("🔵 DEBUG: Checklist: \(progress.displayName), Has changes: \(hasUnsavedChanges)")
        print("🔵 DEBUG: Buffered item states: \(itemStates)")
        
        if hasUnsavedChanges {
            print("🔄 Applying buffered changes and syncing on checklist exit...")
            
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
            
            // Ensure all template items have ItemProgress records (create missing ones)
            for displayItem in displayItems {
                let templateItemId = displayItem.templateItemId
                if progress.itemProgress?.first(where: { $0.templateItemId == templateItemId }) == nil {
                    let newProgressItem = ItemProgress(templateItemId: templateItemId)
                    newProgressItem.assignment = progress
                    // Use buffered state if available, otherwise use display item state
                    newProgressItem.isComplete = itemStates[templateItemId] ?? displayItem.isComplete
                    if newProgressItem.isComplete {
                        newProgressItem.completedAt = Date()
                    }
                    progress.itemProgress?.append(newProgressItem)
                    modelContext.insert(newProgressItem)
                    print("✅ Created missing ItemProgress record for templateItemId: \(templateItemId)")
                }
            }
            
            // Instructor comments are now saved automatically in InstructorNotesView
            
            // Update progress metadata
            progress.lastModified = Date()
            student.lastModified = Date() // Trigger progress bar refresh
            
            // Save to SwiftData with multiple attempts to ensure persistence
            var saveSuccessful = false
            for attempt in 1...3 {
                do {
                    try modelContext.save()
                    print("✅ Checklist progress saved successfully (attempt \(attempt))")
                    saveSuccessful = true
                    
                    // Post notification that checklist items were updated
                    NotificationCenter.default.post(name: Notification.Name("checklistItemCompleted"), object: nil)
                    print("📢 Posted checklistItemCompleted notification from LessonView")
                    break
                } catch {
                    print("❌ Save attempt \(attempt) failed: \(error)")
                    if attempt < 3 {
                        do {
                            try await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
                        } catch {
                            print("⚠️ Sleep failed: \(error)")
                        }
                    }
                }
            }
            
            if saveSuccessful {
                // Verify the save was successful by checking the data
                let completedCount = progress.itemProgress?.filter { $0.isComplete }.count ?? 0
                let totalCount = progress.itemProgress?.count ?? 0
                print("🔍 Verification: Progress shows \(completedCount)/\(totalCount) items completed after save")
                
                // Add a small delay before CloudKit sync to ensure SwiftData save is complete
                do {
                    try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                } catch {
                    print("⚠️ Sleep failed: \(error)")
                }
                
                // Sync to CloudKit and refresh progress (but don't let CloudKit failures affect local data)
                await cloudKitShareService.syncStudentChecklistProgressToSharedZone(student, modelContext: modelContext)
                await refreshStudentProgress()
                print("✅ Checklist progress synced to CloudKit and progress refreshed")
                
                hasUnsavedChanges = false
                itemStates.removeAll()
            } else {
                print("❌ Failed to save checklist after 3 attempts")
            }
        } else {
            print("🔵 DEBUG: No changes to save, skipping sync")
        }
    }
    
    private func refreshStudentProgress() async {
        // Force refresh of progress calculations by updating lastModified
        await MainActor.run {
            student.lastModified = Date()
            // This will trigger SwiftUI to recalculate weightedCategoryProgress
            // and update the progress bars in StudentsView
        }
    }
    
    /// Refreshes local data from SwiftData without triggering CloudKit sync
    private func refreshLocalData() async {
        print("🔄 Refreshing local data in LessonView (no CloudKit sync)")
        
        // Refresh the progress object from SwiftData
        let progressId = progress.id
        let request = FetchDescriptor<ChecklistAssignment>(
            predicate: #Predicate<ChecklistAssignment> { assignment in
                assignment.id == progressId
            }
        )
        
        if let refreshedProgress = try? modelContext.fetch(request).first {
            // Update local state with refreshed data
            await MainActor.run {
                // Process any pending changes in the context
                modelContext.processPendingChanges()
                
                // Update the progress reference to the freshly fetched one
                progress = refreshedProgress
                
                // Reload template relationship
                loadTemplate()
                
                // Clear buffered states to use fresh data from SwiftData
                itemStates.removeAll()
                
                // Update hasUnsavedChanges flag
                hasUnsavedChanges = false
                
                print("✅ Local data refreshed - template: \(template?.name ?? "nil"), items: \(refreshedProgress.itemProgress?.count ?? 0)")
            }
        } else {
            print("⚠️ Could not refresh progress from SwiftData")
        }
    }
    
    /// Calculate current completed count including buffered changes
    private var currentCompletedCount: Int {
        let displayItems = ChecklistAssignmentService.getDisplayItems(for: progress)
        
        // Count items that are completed in either buffered state or saved state
        var completed = 0
        for displayItem in displayItems {
            // Check buffered state first (most recent), then fall back to saved state
            let isComplete = itemStates[displayItem.templateItemId] ?? displayItem.isComplete
            if isComplete {
                completed += 1
            }
        }
        
        return completed
    }
    
    /// Calculate current total count
    private var currentTotalCount: Int {
        let displayItems = ChecklistAssignmentService.getDisplayItems(for: progress)
        return displayItems.count
    }

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
                        hasUnsavedChanges = true
                    }, 
                    displayTitle: displayTitle
                )
                .adaptiveRowBackgroundModifier(for: index)
            }
            
            // Relevant Data section (only if data exists)
            if let template = template, 
               let relevantData = template.relevantData,
               !relevantData.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(relevantData)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .padding()
                .background(Color.appAdaptiveMutedBox)
                .cornerRadius(8)
                .listRowBackground(Color.clear)
            }
            
            // Dual Given Hours Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Dual Given Hours")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                HStack {
                    SelectableTextField(
                        placeholder: "0.0",
                        value: Binding(
                            get: { progress.dualGivenHours },
                            set: { newValue in
                                progress.dualGivenHours = newValue
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
            .padding(.vertical, 8)
            .listRowBackground(Color.clear)
            
            // Instructor Comments Section
            Button(action: {
                showingInstructorNotes = true
            }) {
                HStack {
                    Image(systemName: "note.text")
                        .foregroundColor(.blue)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Instructor Notes")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let comments = progress.instructorComments, !comments.isEmpty {
                            Text(comments)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        } else {
                            Text("Tap to add notes about this lesson")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if progress.instructorComments != nil && !progress.instructorComments!.isEmpty {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
            .listRowBackground(Color.clear)
                }
                .scrollDismissesKeyboard(.interactively)
                .scrollContentBackground(.hidden)
                .warmTextInput()
                .refreshable {
                    // Refresh local data only - reload from SwiftData, no CloudKit sync
                    await refreshLocalData()
                }
            }
        }
        .navigationTitle(progress.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("\(currentCompletedCount)/\(currentTotalCount)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .cornerRadius(16)
            }
        }
        .id(progress.id) // Prevent view recreation when progress data changes
        .sheet(isPresented: $showingInstructorNotes) {
            InstructorNotesView(progress: progress, student: student)
        }
        .onAppear {
            print("🎯 LessonView appeared for checklist: \(progress.displayName)")
            loadTemplate()
            cloudKitShareService.setModelContext(modelContext)
            
            // Ensure all template items have ItemProgress records
            ensureItemProgressRecordsExist()
            
            // Debug: Check current progress state
            let completedCount = progress.itemProgress?.filter { $0.isComplete }.count ?? 0
            let totalCount = progress.itemProgress?.count ?? 0
            print("🔍 LessonView onAppear: Progress shows \(completedCount)/\(totalCount) items completed")
        }
        .onDisappear {
            print("🔵 DEBUG: LessonView.onDisappear called - Checklist exit detected")
            print("🚪 LessonView disappeared for checklist: \(progress.displayName)")
            // Sync changes when user exits the checklist
            Task {
                await syncChangesOnExit()
            }
        }
    }
    
    private func displayTitle(_ title: String) -> String {
        let pattern = "^\\d+\\.\\s*"
        return title.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
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

struct BufferedChecklistItemRow: View {
    let displayItem: DisplayChecklistItem
    let bufferedState: Bool
    let onToggle: (Bool) -> Void
    let displayTitle: ((String) -> String)?
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    init(displayItem: DisplayChecklistItem, bufferedState: Bool, onToggle: @escaping (Bool) -> Void, displayTitle: ((String) -> String)? = nil) {
        self.displayItem = displayItem
        self.bufferedState = bufferedState
        self.onToggle = onToggle
        self.displayTitle = displayTitle
    }

    var body: some View {
        HStack {
            Image(systemName: bufferedState ? "checkmark.circle.fill" : "circle")
                .foregroundColor(bufferedState ? .green : .gray)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text(displayTitle?(displayItem.title) ?? displayItem.title)
                    .strikethrough(bufferedState)
                    .foregroundColor(bufferedState ? .secondary : .primary)
                    .multilineTextAlignment(.leading)

                // Display notes underneath the main item
                if let itemNotes = displayItem.studentNotes ?? displayItem.notes, !itemNotes.isEmpty {
                    Text(itemNotes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                if bufferedState, let completedAt = displayItem.completedAt {
                    Text("Completed: \(completedAt, style: .date)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
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
    }
}

#Preview {
    let student = Student(firstName: "John", lastName: "Doe", email: "john@example.com", telephone: "555-1234", homeAddress: "123 Main St", ftnNumber: "123456789")
    let progress = ChecklistAssignment(templateId: UUID(), templateIdentifier: "test")
    LessonView(student: student, progress: progress)
        .modelContainer(for: [Student.self, ChecklistAssignment.self, ItemProgress.self, CustomChecklistDefinition.self, CustomChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}

