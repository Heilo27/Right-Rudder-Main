//
//  PreSoloQuizView.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25. Melissa Approved
//

import SwiftData
import SwiftUI

// MARK: - PreSoloQuizView

struct PreSoloQuizView: View {
  // MARK: - Properties

  @Environment(\.modelContext) private var modelContext
  @Bindable var student: Student
  @Bindable var progress: ChecklistAssignment
  @State private var template: ChecklistTemplate?
  @State private var showingCamera = false
  @State private var showingPhotoLibrary = false
  @State private var selectedImage: UIImage?
  private let cloudKitShareService = CloudKitShareService.shared

  // MARK: - Body

  var body: some View {
    List {
      // Checklist item
      ForEach(
        Array(
          ChecklistAssignmentService.getDisplayItems(for: progress).sorted { $0.order < $1.order }
            .enumerated()), id: \.element.templateItemId
      ) { index, displayItem in
        ChecklistItemRow(
          displayItem: displayItem,
          onToggle: { isComplete in
            // Find the corresponding progress item and update it
            if let progressItem = progress.itemProgress?.first(where: {
              $0.templateItemId == displayItem.templateItemId
            }) {
              progressItem.isComplete = isComplete
              if isComplete {
                progressItem.completedAt = Date()
              } else {
                progressItem.completedAt = nil
              }
            }
          }, displayTitle: displayTitle
        )
        .adaptiveRowBackgroundModifier(for: index)
      }
      .onMove(perform: moveItems)

      // Relevant Data section (only if data exists)
      if let template = template,
        let relevantData = template.relevantData,
        !relevantData.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      {
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
              ForEach(
                (student.endorsements ?? []).filter {
                  $0.filename.contains("quiz") || $0.filename.contains("Quiz")
                }
              ) { endorsement in
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

          TextEditor(
            text: Binding(
              get: { progress.instructorComments ?? "" },
              set: { progress.instructorComments = $0.isEmpty ? nil : $0 }
            )
          )
          .frame(minHeight: 100)
          .padding(8)
          .background(Color.appAdaptiveMutedBox)
          .cornerRadius(8)
        }
        .padding(.vertical, 4)
      }
    }
    .navigationTitle(progress.displayName)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        EditButton()
      }
    }
    .id(progress.id)  // Prevent view recreation when progress data changes
    .onAppear {
      template = progress.template
      cloudKitShareService.setModelContext(modelContext)
    }
    .onDisappear {
      print("🔵 DEBUG: PreSoloQuizView.onDisappear called - Quiz exit detected")
      // Save changes and sync to CloudKit when user exits
      Task {
        await saveChangesAndSync()
      }
    }
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

  // MARK: - Private Helpers

  private func displayTitle(_ title: String) -> String {
    let pattern = "^\\d+\\.\\s*"
    return title.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
  }

  private func moveItems(from source: IndexSet, to destination: Int) {
    // Note: In the new reference-based system, item ordering is managed by the template
    print(
      "⚠️ Item reordering not supported in reference-based system. Items should be reordered in the template."
    )
  }

  private func loadTemplate() {
    // In the new system, template is already available through the progress relationship
    template = progress.template
  }

  private func saveChangesAndSync() async {
    print("🔵 DEBUG: PreSoloQuizView.saveChangesAndSync() called - Quiz save triggered")
    print("🔵 DEBUG: Quiz: \(progress.displayName), Student: \(student.displayName)")

    // Update progress metadata
    progress.lastModified = Date()
    student.lastModified = Date()  // Trigger progress bar refresh

    do {
      try await modelContext.saveSafely()
      print("✅ PreSoloQuiz progress saved successfully")

      // Sync to CloudKit and refresh progress
      await cloudKitShareService.syncStudentChecklistProgressToSharedZone(
        student, modelContext: modelContext)
      await refreshStudentProgress()
      print("✅ PreSoloQuiz progress synced to CloudKit and progress refreshed")

    } catch {
      print("❌ Failed to save PreSoloQuiz progress: \(error)")
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
}

#Preview {
  let student = Student(
    firstName: "John", lastName: "Doe", email: "john@example.com", telephone: "555-1234",
    homeAddress: "123 Main St", ftnNumber: "123456789")
  let progress = ChecklistAssignment(templateId: UUID(), templateIdentifier: "presolo-quiz")
  PreSoloQuizView(student: student, progress: progress)
    .modelContainer(
      for: [
        Student.self, ChecklistAssignment.self, ItemProgress.self, CustomChecklistDefinition.self,
        CustomChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self,
      ], inMemory: true)
}
