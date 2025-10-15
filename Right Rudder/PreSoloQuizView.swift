//
//  PreSoloQuizView.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25. Melissa Approved
//

import SwiftUI
import SwiftData

struct PreSoloQuizView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var student: Student
    @State private var checklist: StudentChecklist
    @State private var template: ChecklistTemplate?
    @State private var showingCamera = false
    @State private var showingPhotoLibrary = false
    @State private var selectedImage: UIImage?

    init(student: Student, checklist: StudentChecklist) {
        self._student = State(initialValue: student)
        self._checklist = State(initialValue: checklist)
    }

    var body: some View {
        List {
            // Checklist item
            ForEach(Array((checklist.items ?? []).sorted { $0.order < $1.order }.enumerated()), id: \.element.id) { index, item in
                ChecklistItemRow(item: item, onToggle: { isComplete in
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
                }, displayTitle: displayTitle)
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
            
            // Photo upload section
            Section("Quiz Documentation") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Take a photo of the completed quiz or upload from photo library")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        Button("Take Photo") {
                            showingCamera = true
                        }
                        .buttonStyle(.rounded)
                        
                        Button("Photo Library") {
                            showingPhotoLibrary = true
                        }
                        .buttonStyle(.rounded)
                    }
                    
                    if !(student.endorsements?.isEmpty ?? true) {
                        Text("Uploaded Quiz Photos:")
                            .font(.headline)
                            .padding(.top, 8)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach((student.endorsements ?? []).filter { $0.filename.contains("quiz") || $0.filename.contains("Quiz") }) { endorsement in
                                QuizPhotoView(endorsement: endorsement)
                            }
                        }
                    }
                }
                .padding()
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
        .sheet(isPresented: $showingCamera) {
            CameraView { image in
                addQuizPhoto(image)
            }
        }
        .sheet(isPresented: $showingPhotoLibrary) {
            PhotoLibraryView { image in
                addQuizPhoto(image)
            }
        }
        .onAppear {
            loadTemplate()
        }
    }
    
    private func addQuizPhoto(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        let endorsement = EndorsementImage(
            filename: "PreSoloQuiz_\(Date().timeIntervalSince1970).jpg",
            imageData: imageData
        )
        
        if student.endorsements == nil {
            student.endorsements = []
        }
        student.endorsements?.append(endorsement)
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
        
        // Save the changes to the database
        do {
            try modelContext.save()
        } catch {
            print("Failed to save checklist item order: \(error)")
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

struct QuizPhotoView: View {
    let endorsement: EndorsementImage
    
    var body: some View {
        VStack {
            if let imageData = endorsement.imageData,
               let uiImage = UIImage(data: imageData) {
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
            
            Text(endorsement.filename)
                .font(.caption)
                .lineLimit(1)
        }
    }
}

#Preview {
    let student = Student(firstName: "John", lastName: "Doe", email: "john@example.com", telephone: "555-1234", homeAddress: "123 Main St", ftnNumber: "123456789")
    let checklist = StudentChecklist(templateId: UUID(), templateName: "Pre-Solo Quiz", items: [
        StudentChecklistItem(templateItemId: UUID(), title: "Administer, Grade and correct pre-solo quiz")
    ])
    PreSoloQuizView(student: student, checklist: checklist)
        .modelContainer(for: [Student.self, StudentChecklist.self, StudentChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}
