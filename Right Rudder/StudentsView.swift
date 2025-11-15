//
//  StudentsView.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import SwiftUI
import SwiftData
import CloudKit

struct StudentsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var allStudents: [Student] = []
    @State private var showingAddStudent = false
    @State private var selectedStudent: Student?
    @State private var selectedCategory: String? = nil
    @State private var showingInactiveStudents = false
    @State private var cachedFilteredStudents: [Student] = []
    private let cloudKitShareService = CloudKitShareService.shared
    
    // Settings for progress bars and photos
    @AppStorage("showProgressBars") private var showProgressBars = true
    @AppStorage("showStudentPhotos") private var showStudentPhotos = false
    
    private let categories = ["PPL", "IFR", "CPL", "CFI", "Review"]
    
    init() {
        print("🏗️ StudentsView INIT")
    }
    
    private var filteredStudents: [Student] {
        return cachedFilteredStudents
    }
    
    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    studentsList
                }
            } else {
                NavigationView {
                    studentsList
                }
            }
        }
        .onAppear {
            print("👁️ StudentsView APPEARED")
            cloudKitShareService.setModelContext(modelContext)
            
            loadStudents()
            updateFilteredStudents()
            
            // If no students found, run diagnostics
            if allStudents.isEmpty {
                print("⚠️ No students found - attempting to migrate from old database...")
                Task {
                    OldDatabaseEmulator.shared.setModelContext(modelContext)
                    await OldDatabaseEmulator.shared.migrateOldDatabaseToNewSchema()
                    
                    // Reload students after migration
                    await MainActor.run {
                        loadStudents()
                        updateFilteredStudents()
                    }
                    
                    // If still empty, try CloudKit diagnostics
                    if allStudents.isEmpty {
                        EmergencyDataRecovery.shared.setModelContext(modelContext)
                        let diagnostics = await EmergencyDataRecovery.shared.diagnoseCloudKitData()
                        print("📊 CloudKit Diagnostics:")
                        for (type, count) in diagnostics {
                            print("   \(type): \(count) records")
                        }
                        
                        // If data exists in CloudKit, suggest recovery
                        let totalRecords = diagnostics.values.reduce(0, +)
                        if totalRecords > 0 {
                            print("💡 Found \(totalRecords) records in CloudKit - use Emergency Data Recovery in Settings")
                        }
                    }
                }
            } else {
                // Check for corrupted students (duplicate IDs or empty names)
                let hasDuplicates = allStudents.count != Set(allStudents.map { $0.id }).count
                let hasEmptyNames = allStudents.contains { $0.firstName.isEmpty && $0.lastName.isEmpty }
                
                if hasDuplicates || hasEmptyNames {
                    print("⚠️ Detected corrupted students - duplicate IDs: \(hasDuplicates), empty names: \(hasEmptyNames)")
                    print("💡 Use 'Fix Corrupted Students' in Settings to repair")
                    
                    // Try to auto-fix if we have CloudKit data
                    Task {
                        EmergencyDataRecovery.shared.setModelContext(modelContext)
                        await EmergencyDataRecovery.shared.fixCorruptedStudents()
                        // Reload students after fix
                        await MainActor.run {
                            loadStudents()
                            updateFilteredStudents()
                        }
                    }
                }
            }
        }
        .onChange(of: selectedCategory) { _, _ in
            updateFilteredStudents()
        }
        .onChange(of: showingInactiveStudents) { _, _ in
            updateFilteredStudents()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("StudentUpdated"))) { _ in
            // Reload students when a student is updated (e.g., category changed)
            loadStudents()
            updateFilteredStudents()
        }
    }
    
    private func loadStudents() {
        print("🔍 Starting student load process...")
        print("🔍 ModelContext description: \(modelContext)")
        
        // Try a basic fetch without any predicates first
        var request = FetchDescriptor<Student>(
            sortBy: [SortDescriptor(\.lastName, order: .forward)]
        )
        
        // Remove any predicates that might be filtering students
        request.predicate = nil
        
        do {
            allStudents = try modelContext.fetch(request)
            print("📊 Loaded \(allStudents.count) students from database")
            
            if allStudents.isEmpty {
                print("⚠️ WARNING: No students found in database!")
                print("📊 Attempting alternative fetch methods...")
                
                // Try fetching without any sorting
                var simpleRequest = FetchDescriptor<Student>()
                simpleRequest.predicate = nil
                let simpleFetch = try modelContext.fetch(simpleRequest)
                print("📊 Simple fetch returned: \(simpleFetch.count) students")
                
                // Try fetching all entities to see if ANY data exists
                let allEntities = try modelContext.fetch(FetchDescriptor<Student>())
                print("📊 Fetch all entities: \(allEntities.count) students")
                
                // Check if this might be a schema migration issue
                print("⚠️ SCHEMA ISSUE DETECTED: Database may need to be reset due to schema change")
                print("⚠️ Check Right_RudderApp.swift for database reset instructions")
                
            } else {
                for (index, student) in allStudents.enumerated() {
                    print("📊   [\(index)] \(student.displayName) - Active: \(!student.isInactive), ID: \(student.id)")
                }
            }
        } catch {
            print("❌ CRITICAL: Failed to load students: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            
            if let nsError = error as NSError? {
                print("❌ Error domain: \(nsError.domain)")
                print("❌ Error code: \(nsError.code)")
                print("❌ This might indicate a schema mismatch with CloudKit")
            }
            
            allStudents = []
            
            // Try to see if it's a schema issue
            print("🔍 This is likely a schema migration issue!")
            print("🔍 The schema changed from StudentChecklistProgress to ChecklistAssignment")
            print("🔍 You may need to reset the database - check Right_RudderApp.swift")
        }
    }
    
    private func updateFilteredStudents() {
        let baseStudents = showingInactiveStudents ? 
            allStudents.filter { $0.isInactive } : 
            allStudents.filter { !$0.isInactive }
        
        print("📊 Filtering students - Total: \(allStudents.count), Active: \(allStudents.filter { !$0.isInactive }.count), Showing inactive: \(showingInactiveStudents)")
        
        if let category = selectedCategory {
            cachedFilteredStudents = baseStudents.filter { student in
                let assignedCat = student.assignedCategory
                #if DEBUG
                if assignedCat != nil || student.checklistAssignments?.isEmpty == false {
                    print("🔍 Filtering student '\(student.displayName)': assignedCategory='\(assignedCat ?? "nil")', filter='\(category)'")
                }
                #endif
                
                // Direct match
                if assignedCat == category {
                    return true
                }
                
                // Handle category aliases/mappings
                // "IFR" in filter should match "Instrument" in assignedCategory
                // "CPL" in filter should match "Commercial" in assignedCategory
                if category == "IFR" && assignedCat == "Instrument" {
                    return true
                }
                if category == "CPL" && assignedCat == "Commercial" {
                    return true
                }
                
                // Also check if auto-detected category would match
                if assignedCat == nil {
                    // Auto-detect category from checklists for filtering purposes
                    let autoDetected = autoDetectCategoryForStudent(student)
                    #if DEBUG
                    print("🔍 Auto-detected category for '\(student.displayName)': '\(autoDetected ?? "nil")'")
                    #endif
                    if category == "IFR" && autoDetected == "Instrument" {
                        return true
                    }
                    if category == "CPL" && autoDetected == "Commercial" {
                        return true
                    }
                    if autoDetected == category {
                        return true
                    }
                }
                
                return false
            }
            .sorted { $0.sortKey < $1.sortKey }
            print("📊 Filtered by category '\(category)': \(cachedFilteredStudents.count) students")
        } else {
            cachedFilteredStudents = baseStudents.sorted { $0.sortKey < $1.sortKey }
            print("📊 No category filter: \(cachedFilteredStudents.count) students")
        }
    }
    
    /// Auto-detect category for a student (helper function for filtering)
    private func autoDetectCategoryForStudent(_ student: Student) -> String? {
        guard let assignments = student.checklistAssignments, !assignments.isEmpty else {
            return nil
        }
        
        // Count checklists by category
        var categoryCounts: [String: Int] = [:]
        
        for assignment in assignments {
            // Try template relationship first
            if let templateCategory = assignment.template?.category {
                categoryCounts[templateCategory, default: 0] += 1
            } else if let identifier = assignment.templateIdentifier {
                // Infer from templateIdentifier
                let identifierLower = identifier.lowercased()
                if identifierLower.contains("p1_") || identifierLower.contains("p2_") || identifierLower.contains("p3_") || identifierLower.contains("p4_") || identifierLower.contains("pre_solo") || identifierLower.contains("solo") {
                    categoryCounts["PPL", default: 0] += 1
                } else if identifierLower.contains("i1_") || identifierLower.contains("i2_") || identifierLower.contains("i3_") || identifierLower.contains("i4_") || identifierLower.contains("i5_") {
                    categoryCounts["Instrument", default: 0] += 1
                } else if identifierLower.contains("c1_") || identifierLower.contains("c2_") || identifierLower.contains("c3_") {
                    categoryCounts["Commercial", default: 0] += 1
                }
            }
        }
        
        // Return the category with the most checklists
        if let mostCommonCategory = categoryCounts.max(by: { $0.value < $1.value }) {
            return mostCommonCategory.key
        }
        
        // Default to PPL if no category detected
        return "PPL"
    }
    
    private var studentsList: some View {
        VStack(spacing: 0) {
            if !showingInactiveStudents {
                categoryFilterBar
                    .padding(.vertical, 8)
            }
            
            List {
                if allStudents.isEmpty {
                    VStack {
                        Text("No students found in database")
                            .foregroundColor(.secondary)
                        Text("Total students: \(allStudents.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ForEach(Array(filteredStudents.enumerated()), id: \.element.id) { index, student in
                        studentRow(index: index, student: student)
                    }
                    .onDelete(perform: deleteStudents)
                }
            }
            
            // Inactive Students button at bottom
            if !showingInactiveStudents {
                Button(action: {
                    showingInactiveStudents = true
                    selectedCategory = nil
                }) {
                    HStack {
                        Image(systemName: "person.crop.circle.badge.minus")
                        Text("Inactive Students")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                }
                .buttonStyle(.plain)
            } else {
                Button(action: {
                    showingInactiveStudents = false
                    selectedCategory = nil
                }) {
                    HStack {
                        Image(systemName: "person.crop.circle")
                        Text("Active Students")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle(showingInactiveStudents ? "Inactive Students" : "Students")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(false)
        .navigationBarItems(trailing: addButton)
        .sheet(isPresented: $showingAddStudent) {
            AddStudentView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onChange(of: showingAddStudent) { oldValue, newValue in
            // When sheet closes (dismisses), reload students
            if oldValue == true && newValue == false {
                print("🔄 AddStudent sheet dismissed - reloading students...")
                loadStudents()
                updateFilteredStudents()
            }
        }
    }
    
    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        if selectedCategory == category {
                            selectedCategory = nil // Deselect to show all
                        } else {
                            selectedCategory = category
                        }
                    }) {
                        Text(category)
                            .font(.subheadline)
                            .fontWeight(selectedCategory == category ? .semibold : .regular)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedCategory == category ? .white : .primary)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    
    private var addButton: some View {
        Button(action: { showingAddStudent = true }) {
            Image(systemName: "plus")
        }
        .buttonStyle(.noHaptic)
    }
    
    @ViewBuilder
    private func studentRow(index: Int, student: Student) -> some View {
        NavigationLink(destination: StudentDetailView(student: student)) {
            HStack(alignment: .center, spacing: 12) {
                // Progress indicators on the left side
                if showProgressBars {
                    HStack(spacing: 8) {
                        // Show progress if student has any checklists assigned
                        if let assignments = student.checklistAssignments, !assignments.isEmpty {
                            let progress = student.weightedCategoryProgress
                            HStack(spacing: 6) {
                                // Vertical progress bar
                                VStack {
                                    Spacer()
                                    Rectangle()
                                        .fill(progressColor(for: progress))
                                        .frame(width: 4, height: max(4, CGFloat(progress) * 26))
                                        .cornerRadius(2)
                                }
                                .frame(width: 4, height: 30)
                                
                                // Percentage text
                                Text("\(Int(progress * 100))%")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(progressColor(for: progress))
                                    .frame(width: 36, alignment: .leading)
                            }
                        } else {
                            // Show placeholder for students with no checklists
                            HStack(spacing: 6) {
                                VStack {
                                    Spacer()
                                    Rectangle()
                                        .fill(.gray)
                                        .frame(width: 4, height: 4)
                                        .cornerRadius(2)
                                }
                                .frame(width: 4, height: 30)
                                
                                Text("0%")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gray)
                                    .frame(width: 36, alignment: .leading)
                            }
                        }
                    }
                }
                
                Text(student.displayName)
                    .font(.system(size: 22, weight: .medium))
                    .fontWeight(.medium)
                    .padding(.leading, 4)
                
                Spacer()
                
                // Show photo thumbnail only if photo exists and setting is enabled
                if let photoData = student.profilePhotoData, let uiImage = UIImage(data: photoData), showStudentPhotos {
                    OptimizedImage(uiImage, maxSize: CGSize(width: 40, height: 40))
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .clipped()
                        .offset(x: -3) // Shift photo left by 3 points
                        .id("photo-\(student.id)") // Add ID for better memory management
                }
            }
            .frame(height: 35) // Back to original height since progress bars are now compact
        }
        .adaptiveRowBackgroundModifier(for: index)
    }
    
    // Helper function to determine progress bar color
    private func progressColor(for progress: Double) -> Color {
        switch progress {
        case 0.0..<0.3:
            return .red
        case 0.3..<0.7:
            return .orange
        case 0.7..<1.0:
            return .green
        case 1.0:
            return .blue
        default:
            return .gray
        }
    }
    
    
    private func deleteStudents(offsets: IndexSet) {
        for index in offsets {
            let student = filteredStudents[index]
            
            // Delete CloudKit record if it exists
            if let cloudKitRecordID = student.cloudKitRecordID {
                Task {
                    let container = CKContainer(identifier: "iCloud.com.heiloprojects.rightrudder")
                    let database = container.privateCloudDatabase
                    let recordID = CKRecord.ID(recordName: cloudKitRecordID)
                    
                    do {
                        try await database.deleteRecord(withID: recordID)
                        print("✅ Deleted student from CloudKit: \(student.displayName)")
                    } catch {
                        print("⚠️ Failed to delete student from CloudKit: \(error)")
                        // Continue with local deletion even if CloudKit deletion fails
                    }
                }
            }
            
            // Delete from local database
            modelContext.delete(student)
            
            do {
                try modelContext.save()
                print("✅ Deleted student locally: \(student.displayName)")
            } catch {
                print("❌ Failed to save after deleting student: \(error)")
            }
        }
        
        // Reload students
        loadStudents()
        updateFilteredStudents()
    }
    
}

#Preview {
    StudentsView()
        .modelContainer(for: [Student.self, ChecklistAssignment.self, ItemProgress.self, CustomChecklistDefinition.self, CustomChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}



