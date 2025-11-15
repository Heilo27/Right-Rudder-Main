//
//  StudentDetailView.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import SwiftUI
import SwiftData
import PDFKit
import Combine

extension Notification.Name {
    static let checklistItemCompleted = Notification.Name("checklistItemCompleted")
}

struct StudentDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Bindable var student: Student
    @State private var showingEditStudent = false
    @State private var showingAddChecklist = false
    @State private var showingCamera = false
    @State private var showingPhotoLibrary = false
    @State private var selectedImage: UIImage?
    @State private var showingStudentRecord = false
    @State private var checklistToDelete: ChecklistAssignment?
    @State private var showingDeleteConfirmation = false
    @State private var sortedChecklists: [ChecklistAssignment] = []
    @State private var sortedEndorsements: [EndorsementImage] = []
    @State private var showingShareSheet = false
    @State private var showingDocuments = false
    @State private var showingUnlinkConfirmation = false
    @State private var selectedEndorsement: EndorsementImage?
    @State private var showingEndorsementDetail = false
    @State private var showingConflictResolution = false
    @State private var detectedConflicts: [DataConflict] = []
    @State private var hasUnresolvedConflicts = false
    @State private var lastSyncDate = Date()
    @State private var isCheckingForUpdates = false
    @State private var refreshTrigger = 0
    @State private var showStudentLeftNotification = false
    @State private var studentLeftName: String?
    // Use CloudKitShareService for all sync operations (shared database only)
    private let shareService = CloudKitShareService.shared
    

    var body: some View {
        let content = mainContentView
            .navigationTitle("Student Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingEditStudent = true
                    }) {
                        Image(systemName: "ellipsis")
                    }
                    .buttonStyle(.noHaptic)
                }
            }
        
        return content
            .onChange(of: showingAddChecklist) { _, newValue in
                // When sheet dismisses, refresh the lists
                if !newValue {
                    print("🔄 Add checklist sheet dismissed, refreshing lists")
                    updateSortedLists()
                }
            }
            .onAppear {
            print("👁️ StudentDetailView APPEARED for student: \(student.displayName)")
            
            // Set model context for share service
            shareService.setModelContext(modelContext)
            
            updateSortedLists()
            
            // CRITICAL: Check for student-initiated unlink first
            Task {
                let studentUnlinked = await shareService.checkForStudentInitiatedUnlink(for: student, modelContext: modelContext)
                if studentUnlinked {
                    await MainActor.run {
                        studentLeftName = student.displayName
                        showStudentLeftNotification = true
                        // Auto-dismiss after 5 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            showStudentLeftNotification = false
                        }
                    }
                }
            }
            
            // CRITICAL: Auto-sync to CloudKit if student has active share
            // This ensures all assignments are synced to shared zone when viewing student
            // Only sync if student has actually accepted the share (not just URL generated)
            Task {
                // Check for share acceptance and send notification if needed
                await shareService.checkAndNotifyShareAcceptance(for: student)
                
                let hasActive = await shareService.hasActiveShare(for: student)
                if hasActive {
                    print("🔄 Student has active share (accepted) - triggering automatic sync for: \(student.displayName)")
                    await shareService.syncInstructorDataToCloudKit(student, modelContext: modelContext)
                    
                    // Also pull student-owned data (training goals) from CloudKit
                    await shareService.pullStudentDataFromCloudKit(student, modelContext: modelContext)
                } else {
                    print("⚠️ Student \(student.displayName) has share URL but hasn't accepted yet - skipping sync")
                }
            }
            
            // Only check for updates if student is linked and we haven't checked recently
            if isStudentLinked && lastSyncDate.timeIntervalSinceNow < -300 { // 5 minutes
                Task {
                    await checkForStudentUpdates()
                }
            }
            
            // Pre-warm gesture recognizers to prevent stuttery first swipe
            preWarmGestureRecognizers()
        }
        .onChange(of: student.endorsements?.count) { _, _ in
            // Refresh endorsements when the count changes
            updateSortedLists()
            refreshTrigger += 1
        }
        .onChange(of: student.checklistAssignments?.count) { _, _ in
            // Refresh checklists when assignments change
            updateSortedLists()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("checklistItemCompleted"))) { _ in
            // Refresh when any checklist item is completed
            print("🔄 Received checklist completion notification, updating lists")
            updateSortedLists()
        }
        .onDisappear {
            print("👋 StudentDetailView DISAPPEARED for student: \(student.displayName)")
            // Save all changes when navigating away from student detail
            do {
                try modelContext.save()
            } catch {
                print("Failed to save student changes: \(error)")
            }
        }
        .alert("Delete Checklist", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                checklistToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let checklist = checklistToDelete {
                    deleteChecklist(checklist)
                }
                checklistToDelete = nil
            }
        } message: {
            if let checklist = checklistToDelete {
                Text("Are you sure you want to delete '\(checklist.displayName)'? This action cannot be undone.")
            }
        }
        .alert("Unlink Student App", isPresented: $showingUnlinkConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Unlink", role: .destructive) {
                unlinkStudent()
            }
        } message: {
            Text("This will remove the student's access to their companion app. All shared data will be deleted from CloudKit. They will no longer be able to view their profile or upload documents. You can re-link them later if needed.")
        }
        .alert("Student Left Link", isPresented: $showStudentLeftNotification) {
            Button("OK") {
                showStudentLeftNotification = false
            }
        } message: {
            if let name = studentLeftName {
                Text("\(name) has left the link. All assigned lessons have been removed from their app. You can send a new invite if needed.")
            } else {
                Text("The student has left the link. All assigned lessons have been removed from their app.")
            }
        }
    }
    
    // MARK: - Main Content View
    
    private var mainContentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // iPad-optimized content width
                studentInfoHeader
                
                // Only show sharing section if not linked
                if !isStudentLinked {
                    sharingSection
                }
                
                backgroundInformation
                checklistsSection
                endorsementsSection
                    .id(refreshTrigger)
                trainingGoalsSection
                documentsSection
                exportButton
                
                // Show sync status section if linked
                if isStudentLinked {
                    syncStatusSection
                }
                
                // Show unlink section at bottom if linked
                if isStudentLinked {
                    unlinkSection
                }
            }
            .padding()
            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 800 : .infinity)
        }
        .frame(maxWidth: .infinity) // Center content on iPad
        .modifier(StudentDetailSheets(
            showingEditStudent: $showingEditStudent,
            showingAddChecklist: $showingAddChecklist,
            showingCamera: $showingCamera,
            showingPhotoLibrary: $showingPhotoLibrary,
            showingStudentRecord: $showingStudentRecord,
            showingShareSheet: $showingShareSheet,
            showingDocuments: $showingDocuments,
            showingConflictResolution: $showingConflictResolution,
            showingEndorsementDetail: $showingEndorsementDetail,
            selectedEndorsement: $selectedEndorsement,
            detectedConflicts: detectedConflicts,
            student: student,
            getTemplates: getTemplates,
            addEndorsementImage: addEndorsementImage,
            deleteEndorsement: deleteEndorsement
        ))
    }
    
    // MARK: - Helper Methods
    
    private var isStudentLinked: Bool {
        return student.shareRecordID != nil
    }
    
    /// Pre-warms gesture recognizers to prevent stuttery first swipe interactions
    private func preWarmGestureRecognizers() {
        // Pre-warm by briefly showing a hidden swipe action
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Force SwiftUI to initialize gesture recognizers by creating a temporary view
            // This is done by accessing the current window's gesture recognizers
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                // This triggers the gesture recognizer system to initialize
                window.gestureRecognizers?.forEach { _ in }
            }
        }
    }
    
    private func updateSortedLists() {
        print("📊 Updating sorted lists - student has \(student.checklistAssignments?.count ?? 0) checklist assignment records")
        print("📊 Student checklistAssignments is nil: \(student.checklistAssignments == nil)")
        if let assignments = student.checklistAssignments {
            print("📊 Assignment records:")
            for (index, assignment) in assignments.enumerated() {
                let completedCount = assignment.itemProgress?.filter { $0.isComplete }.count ?? 0
                let totalCount = assignment.itemProgress?.count ?? 0
                print("📊   [\(index)] ID: \(assignment.id), Template: \(assignment.template?.name ?? "nil"), DisplayName: \(assignment.displayName), Progress: \(completedCount)/\(totalCount)")
            }
        }
        sortedChecklists = sortChecklistProgress(student.checklistAssignments ?? [])
        sortedEndorsements = (student.endorsements ?? []).sorted { 
            $0.createdAt > $1.createdAt 
        }
        print("📊 Sorted into \(sortedChecklists.count) checklists")
    }
    
    private func unlinkStudent() {
        Task {
            let shareService = CloudKitShareService.shared
            let success = await shareService.removeShareForStudent(student, modelContext: modelContext)
            
            await MainActor.run {
                if success {
                    print("✅ Student unlinked successfully - all shared data deleted")
                    // Refresh the view to update UI state
                    updateSortedLists()
                    refreshTrigger += 1
                } else {
                    print("❌ Failed to unlink student")
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
    
    private func sortChecklistProgress(_ progress: [ChecklistAssignment]) -> [ChecklistAssignment] {
        // Split into incomplete and completed checklists
        let incompleteProgress = progress.filter { !$0.isComplete }
        let completedProgress = progress.filter { $0.isComplete }
        
        // Sort incomplete checklists by phase order
        let sortedIncomplete = incompleteProgress.sorted { progress1, progress2 in
            let phase1 = getPhasePriority(for: progress1.template?.name ?? "")
            let phase2 = getPhasePriority(for: progress2.template?.name ?? "")
            
            if phase1 != phase2 {
                return phase1 < phase2
            }
            
            // Within same phase, sort by lesson number if available
            let lesson1 = extractLessonNumber(from: progress1.template?.name ?? "")
            let lesson2 = extractLessonNumber(from: progress2.template?.name ?? "")
            
            if let num1 = lesson1, let num2 = lesson2 {
                return num1 < num2
            }
            
            return (progress1.template?.name ?? "").localizedCaseInsensitiveCompare(progress2.template?.name ?? "") == .orderedAscending
        }
        
        // Sort completed checklists by phase order (not by date)
        let sortedCompleted = completedProgress.sorted { progress1, progress2 in
            let phase1 = getPhasePriority(for: progress1.template?.name ?? "")
            let phase2 = getPhasePriority(for: progress2.template?.name ?? "")
            
            if phase1 != phase2 {
                return phase1 < phase2
            }
            
            // Within same phase, sort by lesson number if available
            let lesson1 = extractLessonNumber(from: progress1.template?.name ?? "")
            let lesson2 = extractLessonNumber(from: progress2.template?.name ?? "")
            
            if let num1 = lesson1, let num2 = lesson2 {
                return num1 < num2
            }
            
            return (progress1.template?.name ?? "").localizedCaseInsensitiveCompare(progress2.template?.name ?? "") == .orderedAscending
        }
        
        // Return incomplete first, then completed
        return sortedIncomplete + sortedCompleted
    }
    
    private func isChecklistComplete(_ progress: ChecklistAssignment) -> Bool {
        return progress.isComplete
    }
    
    private func getPhasePriority(for templateName: String) -> Int {
        // Define phase order: Onboarding > Phase 1 > Phase 1.5 Pre-Solo/Solo > Phase 2 > Phase 3 > Phase 4
        if templateName.contains("Student Onboard") || templateName.contains("Training Overview") {
            return 0 // Onboarding - highest priority
        } else if templateName.contains("P1-L") || templateName.contains("Phase 1") {
            return 1 // Phase 1
        } else if templateName.contains("Pre-Solo") || templateName.contains("Solo") || templateName.contains("First Solo") {
            return 2 // Phase 1.5 Pre-Solo/Solo
        } else if templateName.contains("P2-L") || templateName.contains("Phase 2") {
            return 3 // Phase 2
        } else if templateName.contains("P3-L") || templateName.contains("Phase 3") {
            return 4 // Phase 3
        } else if templateName.contains("P4-L") || templateName.contains("Phase 4") {
            return 5 // Phase 4
        } else {
            return 6 // Other templates
        }
    }
    
    private var unlinkSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Student App Linked")
                        .font(.headline)
                    Text("Student has access to their companion app")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                    showingUnlinkConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "link.badge.minus")
                        Text("Unlink Student")
                    }
                }
                .buttonStyle(.rounded)
                .foregroundColor(.red)
            }
            .padding()
            .background(Color.appAdaptiveMutedBox)
            .cornerRadius(12)
        }
    }
    
    private var studentInfoHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(student.displayName)
                        .font(.system(size: 28, weight: .bold))
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Button(action: {
                            if let emailURL = URL(string: "mailto:\(student.email)") {
                                UIApplication.shared.open(emailURL)
                            }
                        }) {
                            Label(student.email, systemImage: "envelope")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                        
                        Label(student.telephone, systemImage: "phone")
                        if !student.homeAddress.isEmpty {
                            Label(student.homeAddress, systemImage: "location")
                        }
                        if !student.ftnNumber.isEmpty {
                            Label("FTN: \(student.ftnNumber)", systemImage: "person.badge.key")
                        }
                        Label("Total Dual Given: \(String(format: "%.1f", student.totalDualGivenHours)) hours", systemImage: "clock")
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                
                // ID Photo - Optimized to reduce memory usage
                if let photoData = student.profilePhotoData {
                    if let uiImage = UIImage(data: photoData),
                       let optimizedImage = ImageOptimizationService.shared.optimizeImage(uiImage, maxSize: CGSize(width: 144, height: 144)) {
                        Image(uiImage: optimizedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 72, height: 72)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.appPrimary, lineWidth: 2)
                            )
                    } else {
                        Image(systemName: "person.circle")
                            .font(.system(size: 72))
                            .foregroundColor(.gray)
                    }
                } else {
                    Image(systemName: "person.circle")
                        .font(.system(size: 72))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.appAdaptiveMutedBox)
        .cornerRadius(12)
    }
    
    private var sharingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Student App Access")
                        .font(.headline)
                    Text("Share this profile with the student's companion app")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                    showingShareSheet = true
                } label: {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("Send Invite")
                    }
                }
                .buttonStyle(.rounded)
            }
            .padding()
            .background(Color.appAdaptiveMutedBox)
            .cornerRadius(12)
        }
    }
    
    private var documentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Documents")
                        .font(.headline)
                    
                    let documentCount = student.documents?.count ?? 0
                    Text("\(documentCount) document\(documentCount == 1 ? "" : "s") uploaded")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("View Documents") {
                    showingDocuments = true
                }
                .buttonStyle(.rounded)
            }
            .padding()
            .background(Color.appAdaptiveMutedBox)
            .cornerRadius(12)
        }
    }
    
    private var backgroundInformation: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let biography = student.biography, !biography.isEmpty {
                biographySection(biography)
            }
            
            if let backgroundNotes = student.backgroundNotes, !backgroundNotes.isEmpty {
                backgroundNotesSection(backgroundNotes)
            }
        }
    }
    
    private func biographySection(_ biography: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Biography")
                .font(.headline)
            Text(biography)
                .font(.body)
        }
        .padding()
        .background(Color.appAdaptiveMutedBox)
        .cornerRadius(12)
    }
    
    private func backgroundNotesSection(_ backgroundNotes: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Background Notes")
                .font(.headline)
            Text(backgroundNotes)
                .font(.body)
        }
        .padding()
        .background(Color.appAdaptiveMutedBox)
        .cornerRadius(12)
    }
    
    private var checklistsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Checklists")
                    .font(.headline)
                Spacer()
                Button("Add Checklist") {
                    showingAddChecklist = true
                }
                .buttonStyle(.rounded)
            }
            
            let incompleteChecklists = sortedChecklists.filter { !isChecklistComplete($0) }
            let completedChecklists = sortedChecklists.filter { isChecklistComplete($0) }
            
            List {
                
                // Incomplete checklists
                ForEach(Array(incompleteChecklists.enumerated()), id: \.element.id) { index, progress in
                    NavigationLink(destination: destinationView(for: progress)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(progress.displayName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("\(progress.completedItemsCount)/\(progress.totalItemsCount) completed")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .adaptiveRowBackgroundModifier(for: index)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button("Delete", role: .destructive) {
                            checklistToDelete = progress
                            showingDeleteConfirmation = true
                        }
                    }
                }
                
                // Hidden pre-warming view for gesture recognizers
                Color.clear
                    .frame(height: 0)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button("Pre-warm", role: .destructive) { }
                    }
                    .opacity(0)
                
                // Completed section divider and checklists
                if !completedChecklists.isEmpty {
                    Section {
                        ForEach(Array(completedChecklists.enumerated()), id: \.element.id) { index, progress in
                            NavigationLink(destination: destinationView(for: progress)) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(progress.displayName)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text("\(progress.completedItemsCount)/\(progress.totalItemsCount) completed")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                            .adaptiveRowBackgroundModifier(for: index)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button("Delete", role: .destructive) {
                                    checklistToDelete = progress
                                    showingDeleteConfirmation = true
                                }
                            }
                        }
                    } header: {
                        Text("Completed")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .modifier(iPadListStyleModifier())
            // Calculate proper height: each checklist row needs ~80 pixels
            // Add section header height (40px) if there are completed checklists
            // Ensure minimum height for completed section to make it easily visible
            .frame(height: {
                let rowHeight: CGFloat = 80
                let sectionHeaderHeight: CGFloat = 40
                
                // Base height for all checklists
                let baseHeight = CGFloat(sortedChecklists.count) * rowHeight
                
                // Add section header if there are completed checklists
                let totalHeight = baseHeight + (completedChecklists.isEmpty ? 0 : sectionHeaderHeight)
                
                // Return the calculated height without excessive minimum
                return totalHeight
            }())
        }
    }
    
    private var endorsementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Endorsements")
                    .font(.headline)
                Spacer()
                HStack(spacing: 12) {
                    Button("Camera") {
                        showingCamera = true
                    }
                    .buttonStyle(.rounded)
                    
                    Button("Photo Library") {
                        showingPhotoLibrary = true
                    }
                    .buttonStyle(.rounded)
                }
            }
            
            if student.endorsements?.isEmpty ?? true {
                Text("No endorsements added yet")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(Array(sortedEndorsements.enumerated()), id: \.element.id) { index, endorsement in
                        VStack(spacing: 4) {
                            EndorsementView(endorsement: endorsement) {
                                print("🎯 Endorsement tapped: \(endorsement.filename)")
                                selectedEndorsement = endorsement
                                showingEndorsementDetail = true
                                print("🎯 showingEndorsementDetail set to: \(showingEndorsementDetail)")
                            }
                            
                            // Show endorsement metadata
                            VStack(alignment: .leading, spacing: 2) {
                                if let code = endorsement.endorsementCode {
                                    Text(getEndorsementDisplayName(for: code))
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                                
                                if let expiration = endorsement.expirationDate {
                                    Text("Expires: \(formatDate(expiration))")
                                        .font(.caption2)
                                        .foregroundColor(expiration < Date() ? .red : .orange)
                                }
                            }
                            
                            // Delete button
                            Button("Delete") {
                                deleteEndorsement(endorsement)
                            }
                            .font(.caption2)
                            .foregroundColor(.red)
                            .buttonStyle(.bordered)
                        }
                        .contextMenu {
                            Button("View Details") {
                                print("🎯 Context menu 'View Details' tapped: \(endorsement.filename)")
                                selectedEndorsement = endorsement
                                showingEndorsementDetail = true
                                print("🎯 showingEndorsementDetail set to: \(showingEndorsementDetail)")
                            }
                            
                            Button("Delete", role: .destructive) {
                                deleteEndorsement(endorsement)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var exportButton: some View {
        Button("View Student Record") {
            showingStudentRecord = true
        }
        .buttonStyle(.rounded)
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    private func completedItemsCount(for assignment: ChecklistAssignment) -> Int {
        (assignment.itemProgress ?? []).filter { $0.isComplete }.count
    }
    
    @ViewBuilder
    private func destinationView(for progress: ChecklistAssignment) -> some View {
        Group {
            if progress.displayName == "Student Onboard/Training Overview" {
                StudentOnboardView(student: student, progress: progress)
            } else if progress.displayName == "Pre-Solo Training (61.87)" {
                PreSoloTrainingView(student: student, progress: progress)
            } else if progress.displayName == "Pre-Solo Quiz" {
                PreSoloQuizView(student: student, progress: progress)
            } else if progress.displayName == "Endorsements" {
                EndorsementsView(student: student, progress: progress)
            } else {
                LessonView(student: student, progress: progress)
            }
        }
    }
    
    private func getTemplates() -> [ChecklistTemplate] {
        let request = FetchDescriptor<ChecklistTemplate>(
            sortBy: [SortDescriptor(\.name)]
        )
        do {
            let allTemplates = try modelContext.fetch(request)
            print("📋 Fetched \(allTemplates.count) total templates from database")
            
            // Filter to only include the expected categories: PPL, Instrument, Commercial, Reviews
            let validCategories = ["PPL", "Instrument", "Commercial", "Reviews"]
            let filteredTemplates = allTemplates.filter { validCategories.contains($0.category) }
            print("📋 Filtered to \(filteredTemplates.count) templates in valid categories")
            
            if filteredTemplates.isEmpty && !allTemplates.isEmpty {
                print("⚠️ WARNING: Templates exist but none match valid categories!")
                print("📋 Available categories: \(Set(allTemplates.map { $0.category }))")
            }
            
            return filteredTemplates
        } catch {
            print("❌ Failed to fetch templates: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("❌ Error domain: \(nsError.domain), code: \(nsError.code)")
            }
            return []
        }
    }
    
    private func addEndorsementImage(_ image: UIImage) {
        // Use background queue for image processing
        DispatchQueue.global(qos: .userInitiated).async {
            guard let imageData = image.jpegData(compressionQuality: 0.7) else { return }
            
            let endorsement = EndorsementImage(
                filename: generateEndorsementFilename(),
                imageData: imageData
            )
            
            DispatchQueue.main.async {
                // Insert the endorsement into the model context first
                self.modelContext.insert(endorsement)
                
                // Set up the relationship
                endorsement.student = self.student
                
                // Add the endorsement to the student's endorsements array
                if self.student.endorsements == nil {
                    self.student.endorsements = []
                }
                self.student.endorsements?.append(endorsement)
                
                // Save the changes to the model context
                do {
                    try self.modelContext.save()
                    // Update sorted lists after adding endorsement
                    self.updateSortedLists()
                } catch {
                    print("Failed to save after adding endorsement: \(error)")
                }
            }
        }
    }
    
    private func deleteEndorsement(_ endorsement: EndorsementImage) {
        // Remove from student's endorsements array
        student.endorsements?.removeAll { $0.id == endorsement.id }
        
        // Delete from model context
        modelContext.delete(endorsement)
        
        // Save changes
        do {
            try modelContext.save()
            print("✅ Deleted endorsement: \(endorsement.filename)")
            // Update sorted lists after deletion
            updateSortedLists()
        } catch {
            print("❌ Failed to delete endorsement: \(error)")
        }
    }
    
    private func deleteChecklist(_ progress: ChecklistAssignment) {
        // CRITICAL: Delete from CloudKit first (if student has active share)
        // This ensures the student app will detect the deletion on next sync
        if student.shareRecordID != nil {
            Task {
                let shareService = CloudKitShareService.shared
                await shareService.deleteAssignmentFromCloudKit(assignment: progress, student: student)
            }
        }
        
        // Remove the checklist assignment from the student's assignments
        if let index = student.checklistAssignments?.firstIndex(where: { $0.id == progress.id }) {
            student.checklistAssignments?.remove(at: index)
        }
        
        // Remove from template's student assignment tracking
        if let template = progress.template {
            template.studentAssignments?.removeAll { $0.id == progress.id }
        }
        
        // Delete the assignment record
        modelContext.delete(progress)
        
        // Save the changes
        do {
            try modelContext.save()
            // Update sorted lists after deleting checklist
            updateSortedLists()
        } catch {
            print("Failed to save after deleting checklist: \(error)")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
    
    private func getEndorsementDisplayName(for code: String) -> String {
        switch code {
        case "A.1":
            return "Authorization to Take Practical Test"
        case "A.2":
            return "Authorization for Solo Flight"
        case "A.3":
            return "Aeronautical Knowledge"
        case "A.4":
            return "Pre-Solo Training to Proficiency"
        case "A.5":
            return "Solo Flight Training"
        case "A.6":
            return "Solo Cross-Country Flight Training"
        case "A.7":
            return "Solo Flight in Complex Airplane"
        case "A.8":
            return "Instrument Proficiency Check"
        case "A.9":
            return "Instrument Training"
        case "A.10":
            return "Instrument Experience"
        case "A.11":
            return "Instrument Recency"
        case "A.12":
            return "Instrument Approach Procedures"
        case "A.13":
            return "Instrument Training for Private Pilot"
        case "A.14":
            return "Instrument Training for Commercial Pilot"
        case "A.15":
            return "Instrument Training for Airline Transport Pilot"
        case "A.16":
            return "Instrument Training for Flight Instructor"
        case "A.17":
            return "Instrument Training for Ground Instructor"
        case "A.18":
            return "Instrument Training for Instrument Instructor"
        case "A.19":
            return "Instrument Training for Multi-Engine Instructor"
        case "A.20":
            return "Instrument Training for Sport Pilot"
        case "A.21":
            return "Instrument Training for Recreational Pilot"
        case "A.22":
            return "Instrument Training for Glider Pilot"
        case "A.23":
            return "Instrument Training for Lighter-Than-Air Pilot"
        case "A.24":
            return "Instrument Training for Powered-Lift Pilot"
        case "A.25":
            return "Instrument Training for Rotorcraft Pilot"
        case "A.26":
            return "Instrument Training for Powered Parachute Pilot"
        case "A.27":
            return "Instrument Training for Weight-Shift-Control Pilot"
        case "A.28":
            return "Instrument Training for Balloon Pilot"
        case "A.29":
            return "Instrument Training for Airship Pilot"
        case "A.30":
            return "Instrument Training for Powered-Lift Pilot"
        default:
            return code // Fallback to code if not recognized
        }
    }
    
    private func generateEndorsementFilename() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMddyy"
        let dateString = formatter.string(from: Date())
        
        // Count existing endorsements for today to get the sequence number
        let todayEndorsements = (student.endorsements ?? []).filter { endorsement in
            endorsement.filename.hasPrefix("Endorsement_\(dateString)")
        }
        
        let sequenceNumber = String(format: "%02d", todayEndorsements.count + 1)
        return "Endorsement_\(dateString)\(sequenceNumber).jpg"
    }
    
    private var trainingGoalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Student Information")
                    .font(.headline)
                Spacer()
            }
            
            NavigationLink(destination: StudentTrainingGoalsView(student: student)) {
                HStack {
                    Image(systemName: "target")
                        .foregroundColor(.appPrimary)
                        .frame(width: 20)
                    
                    Text("Training Goals & Milestones")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    private var syncStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Sync Status")
                    .font(.headline)
                Spacer()
            }
            
            HStack {
                Image(systemName: "icloud.and.arrow.up.and.down")
                    .foregroundColor(.appPrimary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Last synced: \(lastSyncDate, style: .relative)")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Text("Connected to student app")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    Task {
                        await checkForStudentUpdates()
                    }
                }) {
                    HStack(spacing: 4) {
                        if isCheckingForUpdates {
                            ProgressView()
                                .scaleEffect(0.7)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.caption)
                        }
                        Text(isCheckingForUpdates ? "Syncing..." : "Sync")
                            .font(.caption)
                    }
                }
                .buttonStyle(.bordered)
                .disabled(isCheckingForUpdates)
                
                if hasUnresolvedConflicts {
                    Badge(count: detectedConflicts.count, color: .orange)
                }
            }
            
            if hasUnresolvedConflicts {
                Button(action: {
                    showingConflictResolution = true
                }) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                        Text("Resolve \(detectedConflicts.count) Conflicts")
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
        }
        .padding()
        .background(Color.appAdaptiveMutedBox)
        .cornerRadius(12)
    }
    
    @MainActor
    private func checkForStudentUpdates() async {
        guard isStudentLinked else { 
            print("Student not linked, skipping update check")
            return 
        }
        
        // Prevent multiple concurrent update checks
        guard !isCheckingForUpdates else {
            print("Update check already in progress, skipping...")
            return
        }
        
        isCheckingForUpdates = true
        defer { isCheckingForUpdates = false }
        
        let conflictDetector = CloudKitConflictDetector()
        
        // Check if there's newer data in CloudKit
        let hasNewerData = await conflictDetector.hasNewerDataInCloudKit(for: student)
        
        if hasNewerData {
            // Detect conflicts
            let conflicts = await conflictDetector.detectConflicts(for: student)
            
            if !conflicts.isEmpty {
                detectedConflicts = conflicts
                hasUnresolvedConflicts = true
                print("⚠️ Found \(conflicts.count) conflicts with student data")
            } else {
                hasUnresolvedConflicts = false
                print("✅ No conflicts detected")
            }
        } else {
            hasUnresolvedConflicts = false
            print("✅ No updates available")
        }
        
        lastSyncDate = Date()
    }
}

struct EndorsementView: View {
    let endorsement: EndorsementImage
    let onTap: () -> Void
    @State private var uiImage: UIImage?
    
    var body: some View {
        VStack {
            Button(action: onTap) {
                if let uiImage = uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 60)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 60)
                        .cornerRadius(8)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .onAppear {
            loadImage()
        }
        .onDisappear {
            // Release image when view disappears to free memory
            uiImage = nil
        }
    }
    
    private func loadImage() {
        guard let imageData = endorsement.imageData else { 
            return 
        }
        
        // Check if this is PDF data or image data
        if endorsement.filename.hasSuffix(".pdf") {
            // For PDF files, create a PDF thumbnail - optimize for memory
            DispatchQueue.global(qos: .userInitiated).async {
                autoreleasepool {
                    guard let pdfDocument = PDFDocument(data: imageData),
                          let page = pdfDocument.page(at: 0) else {
                        return
                    }
                    let thumbnailSize = CGSize(width: 200, height: 200)
                    let thumbnail = page.thumbnail(of: thumbnailSize, for: .mediaBox)
                    // Optimize thumbnail to reduce memory
                    let optimizedThumbnail = ImageOptimizationService.shared.optimizeImage(thumbnail, maxSize: thumbnailSize)
                    DispatchQueue.main.async {
                        self.uiImage = optimizedThumbnail ?? thumbnail
                    }
                }
            }
        } else {
            // For regular image files - optimize to reduce memory
            DispatchQueue.global(qos: .userInitiated).async {
                autoreleasepool {
                    guard let originalImage = UIImage(data: imageData) else { return }
                    // Optimize image to reduce memory footprint
                    let optimizedImage = ImageOptimizationService.shared.optimizeImage(originalImage, maxSize: CGSize(width: 800, height: 800))
                    DispatchQueue.main.async {
                        self.uiImage = optimizedImage
                    }
                }
            }
        }
    }
}

struct EndorsementDetailView: View {
    let endorsement: EndorsementImage
    let onDelete: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var uiImage: UIImage?
    @State private var showingDeleteConfirmation = false
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if let uiImage = uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            SimultaneousGesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        scale = lastScale * value
                                    }
                                    .onEnded { value in
                                        lastScale = scale
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            if scale < 1.0 {
                                                scale = 1.0
                                                offset = .zero
                                                lastOffset = .zero
                                            }
                                        }
                                    },
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { value in
                                        lastOffset = offset
                                    }
                            )
                        )
                } else {
                    VStack {
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                        Text("Loading...")
                            .foregroundColor(.white)
                        Text("Debug: \(endorsement.filename)")
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Endorsement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .onAppear {
            loadImage()
        }
        .onDisappear {
            // Release image when view disappears to free memory
            uiImage = nil
        }
        .alert("Delete Endorsement", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete this endorsement? This action cannot be undone.")
        }
    }
    
    private func loadImage() {
        guard let imageData = endorsement.imageData else { 
            return 
        }
        
        // Check if this is PDF data or image data
        if endorsement.filename.hasSuffix(".pdf") {
            // For PDF files - optimize rendering to reduce memory
            DispatchQueue.global(qos: .userInitiated).async {
                autoreleasepool {
                    guard let pdfDocument = PDFDocument(data: imageData) else {
                        return
                    }
                    
                    guard let page = pdfDocument.page(at: 0) else {
                        return
                    }
                    
                    let pageBounds = page.bounds(for: .mediaBox)
                    
                    // Use lower scale for memory efficiency (1.5 instead of 2.0)
                    let scale: CGFloat = 1.5
                    // Limit maximum size to prevent excessive memory usage
                    let maxDimension: CGFloat = 2000
                    let rawWidth = pageBounds.width * scale
                    let rawHeight = pageBounds.height * scale
                    
                    let finalWidth = min(rawWidth, maxDimension)
                    let finalHeight = min(rawHeight, maxDimension)
                    let size = CGSize(width: finalWidth, height: finalHeight)
                    
                    let renderer = UIGraphicsImageRenderer(size: size)
                    let image = renderer.image { context in
                        // Set white background
                        context.cgContext.setFillColor(UIColor.white.cgColor)
                        context.cgContext.fill(CGRect(origin: .zero, size: size))
                        
                        // Scale and draw the page
                        let actualScale = min(finalWidth / pageBounds.width, finalHeight / pageBounds.height)
                        context.cgContext.scaleBy(x: actualScale, y: actualScale)
                        page.draw(with: .mediaBox, to: context.cgContext)
                    }
                    
                    // Optimize the rendered image to reduce memory
                    let optimizedImage = ImageOptimizationService.shared.optimizeImage(image, maxSize: size)
                    
                    DispatchQueue.main.async {
                        self.uiImage = optimizedImage ?? image
                    }
                }
            }
        } else {
            // For regular image files - optimize to reduce memory
            DispatchQueue.global(qos: .userInitiated).async {
                autoreleasepool {
                    guard let originalImage = UIImage(data: imageData) else { return }
                    // Optimize image to reduce memory footprint (larger size for detail view)
                    let optimizedImage = ImageOptimizationService.shared.optimizeImage(originalImage, maxSize: CGSize(width: 1200, height: 1200))
                    DispatchQueue.main.async {
                        self.uiImage = optimizedImage
                    }
                }
            }
        }
    }
}


struct Badge: View {
    let count: Int
    let color: Color
    
    var body: some View {
        Text("\(count)")
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(12)
    }
}

// MARK: - Student Detail Sheets Modifier

struct StudentDetailSheets: ViewModifier {
    @Binding var showingEditStudent: Bool
    @Binding var showingAddChecklist: Bool
    @Binding var showingCamera: Bool
    @Binding var showingPhotoLibrary: Bool
    @Binding var showingStudentRecord: Bool
    @Binding var showingShareSheet: Bool
    @Binding var showingDocuments: Bool
    @Binding var showingConflictResolution: Bool
    @Binding var showingEndorsementDetail: Bool
    @Binding var selectedEndorsement: EndorsementImage?
    let detectedConflicts: [DataConflict]
    let student: Student
    let getTemplates: () -> [ChecklistTemplate]
    let addEndorsementImage: (UIImage) -> Void
    let deleteEndorsement: (EndorsementImage) -> Void
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showingEditStudent) {
                EditStudentView(student: student)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingAddChecklist) {
                AddChecklistToStudentView(student: student, templates: getTemplates())
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingCamera) {
                CameraView { image in
                    addEndorsementImage(image)
                }
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingPhotoLibrary) {
                PhotoLibraryView { image in
                    addEndorsementImage(image)
                }
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingStudentRecord) {
                PDFExportService.showStudentRecord(student)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingShareSheet) {
                StudentShareView(student: student)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingDocuments) {
                NavigationView {
                    StudentDocumentsView(student: student)
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingConflictResolution) {
                ConflictResolutionView(student: student, conflicts: detectedConflicts)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingEndorsementDetail) {
                if let endorsement = selectedEndorsement {
                    EndorsementDetailView(endorsement: endorsement) {
                        deleteEndorsement(endorsement)
                        showingEndorsementDetail = false
                    }
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .onAppear {
                        print("🎯 Sheet is being presented, selectedEndorsement: \(endorsement.filename)")
                    }
                } else {
                    Text("No endorsement selected")
                        .foregroundColor(.red)
                }
            }
    }
}

// Helper modifier for iPad list styling
struct iPadListStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return AnyView(content.listStyle(.insetGrouped))
        } else {
            return AnyView(content.listStyle(.plain))
        }
        #else
        return AnyView(content.listStyle(.plain))
        #endif
    }
}

#Preview {
    let student = Student(firstName: "John", lastName: "Doe", email: "john@example.com", telephone: "555-1234", homeAddress: "123 Main St", ftnNumber: "123456789")
    StudentDetailView(student: student)
        .modelContainer(for: [Student.self, ChecklistAssignment.self, ItemProgress.self, CustomChecklistDefinition.self, CustomChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}
