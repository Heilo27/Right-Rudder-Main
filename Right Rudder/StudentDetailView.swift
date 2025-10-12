//
//  StudentDetailView.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import SwiftUI
import SwiftData

struct StudentDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @State private var student: Student
    @State private var showingEditStudent = false
    @State private var showingAddChecklist = false
    @State private var showingCamera = false
    @State private var showingPhotoLibrary = false
    @State private var selectedImage: UIImage?
    @State private var showingStudentRecord = false
    @State private var checklistToDelete: StudentChecklist?
    @State private var showingDeleteConfirmation = false
    @State private var sortedChecklists: [StudentChecklist] = []
    @State private var sortedEndorsements: [EndorsementImage] = []
    @State private var showingShareSheet = false
    @State private var showingDocuments = false
    @State private var showingUnlinkConfirmation = false
    @State private var selectedEndorsement: EndorsementImage?
    @State private var showingEndorsementDetail = false
    
    init(student: Student) {
        self._student = State(initialValue: student)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                studentInfoHeader
                
                // Only show sharing section if not linked
                if !isStudentLinked {
                    sharingSection
                }
                
                backgroundInformation
                checklistsSection
                endorsementsSection
                documentsSection
                exportButton
                
                // Show unlink section at bottom if linked
                if isStudentLinked {
                    unlinkSection
                }
            }
            .padding()
        }
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
        .sheet(isPresented: $showingEditStudent) {
            EditStudentView(student: student)
        }
        .sheet(isPresented: $showingAddChecklist) {
            AddChecklistToStudentView(student: student, templates: getTemplates())
        }
        .sheet(isPresented: $showingCamera) {
            CameraView { image in
                addEndorsementImage(image)
            }
        }
        .sheet(isPresented: $showingPhotoLibrary) {
            PhotoLibraryView { image in
                addEndorsementImage(image)
            }
        }
        .sheet(isPresented: $showingStudentRecord) {
            PDFExportService.showStudentRecord(student)
        }
        .sheet(isPresented: $showingShareSheet) {
            StudentShareView(student: student)
        }
        .sheet(isPresented: $showingDocuments) {
            NavigationView {
                StudentDocumentsView(student: student)
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
                Text("Are you sure you want to delete '\(checklist.templateName)'? This action cannot be undone.")
            }
        }
        .onAppear {
            updateSortedLists()
        }
        .onChange(of: student.checklists) { _, _ in
            updateSortedLists()
        }
        .alert("Unlink Student App", isPresented: $showingUnlinkConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Unlink", role: .destructive) {
                unlinkStudent()
            }
        } message: {
            Text("This will remove the student's access to their companion app. They will no longer be able to view their profile or upload documents. You can re-link them later if needed.")
        }
        .sheet(isPresented: $showingEndorsementDetail) {
            if let endorsement = selectedEndorsement {
                EndorsementDetailView(endorsement: endorsement) {
                    deleteEndorsement(endorsement)
                    showingEndorsementDetail = false
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private var isStudentLinked: Bool {
        return student.shareRecordID != nil
    }
    
    private func updateSortedLists() {
        sortedChecklists = sortChecklists(student.checklists ?? [])
        sortedEndorsements = (student.endorsements ?? []).sorted { 
            $0.createdAt > $1.createdAt 
        }
    }
    
    private func unlinkStudent() {
        Task {
            let shareService = CloudKitShareService()
            let success = await shareService.removeShareForStudent(student, modelContext: modelContext)
            
            await MainActor.run {
                if success {
                    print("Student unlinked successfully")
                } else {
                    print("Failed to unlink student")
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
    
    private func sortChecklists(_ checklists: [StudentChecklist]) -> [StudentChecklist] {
        // Split into incomplete and completed checklists
        let incompleteChecklists = checklists.filter { !isChecklistComplete($0) }
        let completedChecklists = checklists.filter { isChecklistComplete($0) }
        
        // Sort incomplete checklists by phase order
        let sortedIncomplete = incompleteChecklists.sorted { checklist1, checklist2 in
            let phase1 = getPhasePriority(for: checklist1.templateName)
            let phase2 = getPhasePriority(for: checklist2.templateName)
            
            if phase1 != phase2 {
                return phase1 < phase2
            }
            
            // Within same phase, sort by lesson number if available
            let lesson1 = extractLessonNumber(from: checklist1.templateName)
            let lesson2 = extractLessonNumber(from: checklist2.templateName)
            
            if let num1 = lesson1, let num2 = lesson2 {
                return num1 < num2
            }
            
            return checklist1.templateName.localizedCaseInsensitiveCompare(checklist2.templateName) == .orderedAscending
        }
        
        // Sort completed checklists by phase order (not by date)
        let sortedCompleted = completedChecklists.sorted { checklist1, checklist2 in
            let phase1 = getPhasePriority(for: checklist1.templateName)
            let phase2 = getPhasePriority(for: checklist2.templateName)
            
            if phase1 != phase2 {
                return phase1 < phase2
            }
            
            // Within same phase, sort by lesson number if available
            let lesson1 = extractLessonNumber(from: checklist1.templateName)
            let lesson2 = extractLessonNumber(from: checklist2.templateName)
            
            if let num1 = lesson1, let num2 = lesson2 {
                return num1 < num2
            }
            
            return checklist1.templateName.localizedCaseInsensitiveCompare(checklist2.templateName) == .orderedAscending
        }
        
        // Return incomplete first, then completed
        return sortedIncomplete + sortedCompleted
    }
    
    private func isChecklistComplete(_ checklist: StudentChecklist) -> Bool {
        guard let items = checklist.items, !items.isEmpty else { return false }
        return items.allSatisfy { $0.isComplete }
    }
    
    private func getPhasePriority(for templateName: String) -> Int {
        // Define phase order: Onboarding > Phase 1 > Pre-Solo/Solo > Phase 2 > Phase 3 > Phase 4
        if templateName.contains("Student Onboard") || templateName.contains("Training Overview") {
            return 0 // Onboarding - highest priority
        } else if templateName.contains("P1-L") || templateName.contains("Phase 1") {
            return 1 // Phase 1
        } else if templateName.contains("Pre-Solo") || templateName.contains("Solo") || templateName.contains("First Solo") {
            return 2 // Pre-Solo/Solo
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
            .background(Color.appMutedBox)
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
                
                // ID Photo
                if let photoData = student.profilePhotoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
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
            }
        }
        .padding()
        .background(Color.appMutedBox)
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
            .background(Color.appMutedBox)
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
            .background(Color.appMutedBox)
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
        .background(Color.appMutedBox)
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
        .background(Color.appMutedBox)
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
            
            List {
                let incompleteChecklists = sortedChecklists.filter { !isChecklistComplete($0) }
                let completedChecklists = sortedChecklists.filter { isChecklistComplete($0) }
                
                // Incomplete checklists
                ForEach(Array(incompleteChecklists.enumerated()), id: \.element.id) { index, checklist in
                    NavigationLink(destination: destinationView(for: checklist).id(checklist.id)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(checklist.templateName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("\(completedItemsCount(for: checklist))/\(checklist.items?.count ?? 0) completed")
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
                            checklistToDelete = checklist
                            showingDeleteConfirmation = true
                        }
                    }
                }
                
                // Completed section divider and checklists
                if !completedChecklists.isEmpty {
                    Section {
                        ForEach(Array(completedChecklists.enumerated()), id: \.element.id) { index, checklist in
                            NavigationLink(destination: destinationView(for: checklist).id(checklist.id)) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(checklist.templateName)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text("\(completedItemsCount(for: checklist))/\(checklist.items?.count ?? 0) completed")
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
                                    checklistToDelete = checklist
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
            .listStyle(PlainListStyle())
            .frame(height: CGFloat(sortedChecklists.count * 80))
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
                    ForEach(sortedEndorsements) { endorsement in
                        EndorsementView(endorsement: endorsement) {
                            selectedEndorsement = endorsement
                            showingEndorsementDetail = true
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
    
    private func completedItemsCount(for checklist: StudentChecklist) -> Int {
        (checklist.items ?? []).filter { $0.isComplete }.count
    }
    
    @ViewBuilder
    private func destinationView(for checklist: StudentChecklist) -> some View {
        if checklist.templateName == "Student Onboard/Training Overview" {
            StudentOnboardView(student: student, checklist: checklist)
        } else if checklist.templateName == "Pre-Solo Training (61.87)" {
            PreSoloTrainingView(student: student, checklist: checklist)
        } else if checklist.templateName == "Pre-Solo Quiz" {
            PreSoloQuizView(student: student, checklist: checklist)
        } else if checklist.templateName == "Endorsements" {
            EndorsementsView(student: student, checklist: checklist)
        } else {
            LessonView(student: student, checklist: checklist)
        }
    }
    
    private func getTemplates() -> [ChecklistTemplate] {
        let request = FetchDescriptor<ChecklistTemplate>(
            sortBy: [SortDescriptor(\.name)]
        )
        do {
            return try modelContext.fetch(request)
        } catch {
            print("Failed to fetch templates: \(error)")
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
    
    private func deleteChecklist(_ checklist: StudentChecklist) {
        // Remove the checklist from the student's checklists
        if let index = student.checklists?.firstIndex(where: { $0.id == checklist.id }) {
            student.checklists?.remove(at: index)
        }
        
        // Save the changes
        do {
            try modelContext.save()
            // Update sorted lists after deleting checklist
            updateSortedLists()
        } catch {
            print("Failed to save after deleting checklist: \(error)")
        }
    }
    
    private func deleteEndorsement(_ endorsement: EndorsementImage) {
        // Remove the endorsement from the student's endorsements
        if let index = student.endorsements?.firstIndex(where: { $0.id == endorsement.id }) {
            student.endorsements?.remove(at: index)
        }
        
        // Delete the endorsement from the model context
        modelContext.delete(endorsement)
        
        // Save the changes
        do {
            try modelContext.save()
            // Update sorted lists after deleting endorsement
            updateSortedLists()
        } catch {
            print("Failed to save after deleting endorsement: \(error)")
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
                        .frame(height: 100)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 100)
                        .cornerRadius(8)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(endorsement.filename)
                .font(.caption)
                .lineLimit(1)
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        guard let imageData = endorsement.imageData else { return }
        
        // Load image on background queue to avoid blocking UI
        DispatchQueue.global(qos: .userInitiated).async {
            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                self.uiImage = image
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
    @State private var showingCropView = false
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
                    Menu {
                        Button {
                            showingCropView = true
                        } label: {
                            Label("Crop", systemImage: "crop")
                        }
                        
                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .onAppear {
            loadImage()
        }
        .alert("Delete Endorsement", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete this endorsement? This action cannot be undone.")
        }
        .sheet(isPresented: $showingCropView) {
            if let uiImage = uiImage {
                ImageCropView(image: uiImage) { croppedImage in
                    // Handle cropped image - for now just dismiss
                    showingCropView = false
                }
            }
        }
    }
    
    private func loadImage() {
        guard let imageData = endorsement.imageData else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                self.uiImage = image
            }
        }
    }
}

struct ImageCropView: View {
    let image: UIImage
    let onCrop: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var cropRect = CGRect(x: 0, y: 0, width: 200, height: 200)
    @State private var imageSize = CGSize.zero
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .overlay(
                        Rectangle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: cropRect.width, height: cropRect.height)
                            .position(x: cropRect.midX, y: cropRect.midY)
                    )
            }
            .navigationTitle("Crop Image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // For now, just dismiss - full crop implementation would be more complex
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let student = Student(firstName: "John", lastName: "Doe", email: "john@example.com", telephone: "555-1234", homeAddress: "123 Main St", ftnNumber: "123456789")
    StudentDetailView(student: student)
        .modelContainer(for: [Student.self, StudentChecklist.self, StudentChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}
