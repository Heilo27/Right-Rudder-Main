//
//  EndorsementsView.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import SwiftData
import SwiftUI

// MARK: - EndorsementsView

struct EndorsementsView: View {
  // MARK: - Properties

  @Environment(\.modelContext) private var modelContext
  @Bindable var student: Student
  @Bindable var progress: ChecklistAssignment
  @State private var template: ChecklistTemplate?
  @State private var showingCamera = false
  @State private var showingPhotoLibrary = false
  @State private var showingPhotoOptions = false

  // MARK: - Body

  var body: some View {
    List {

      // A.3 Aeronautical knowledge
      Section {
        VStack(alignment: .leading, spacing: 8) {
          Text(
            "A.3 Aeronautical knowledge 61.87(b) (Pre-solo written to 100%. I have to ensure that their written test deficiencies have been reviewed and corrected to 100% by explaining to them the areas they got wrong.)"
          )
          .font(.headline)
          .fontWeight(.bold)

          Text(
            "I certify that (first, middle, last) has satisfactorily completed the pre-solo knowledge test of 61.87(b) for the [make and model] aircraft."
          )
          .font(.body)
          .italic()
          .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.appAdaptiveMutedBox)
        .cornerRadius(8)
      }

      // A.4 Pre-Solo Training to Proficiency
      Section {
        VStack(alignment: .leading, spacing: 8) {
          Text(
            "A.4 Pre-Solo Training to Proficiency 61.87(c)(1)(2) and 61.87(d). (I must cover all 15 procedures and maneuvers and determine that student is both safe and proficient)"
          )
          .font(.headline)
          .fontWeight(.bold)

          Text(
            "I certify that (first, middle, last) has received and logged pre-solo flight training for, the maneuvers and procedures that are appropriate to make the [make and model] aircraft. I have determined that (he or she) has demonstrated satisfactory proficiency and safety on the maneuvers and procedures required by 61.87 in this or similar make and model of aircraft to be flown."
          )
          .font(.body)
          .italic()
          .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.appAdaptiveMutedBox)
        .cornerRadius(8)
      }

      // A.6 Solo flight
      Section {
        VStack(alignment: .leading, spacing: 8) {
          Text("A.6 Solo flight (first 90 calendar day period): 61.87(n)")
            .font(.headline)
            .fontWeight(.bold)

          Text(
            "I certify that (first, middle, last) has received the required training to qualify for solo flying. I have determined that he or she meets the applicable requirements of 61.87(n) and is proficient to make solo flights in the (make and model)."
          )
          .font(.body)
          .italic()
          .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.appAdaptiveMutedBox)
        .cornerRadius(8)
      }

      // Photo Upload Section
      Section("Add Endorsement Photos") {
        VStack(spacing: 12) {
          Button(action: {
            showingCamera = true
          }) {
            HStack {
              Image(systemName: "camera")
              Text("Take Photo")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
          }
          .buttonStyle(.plain)

          Button(action: {
            showingPhotoLibrary = true
          }) {
            HStack {
              Image(systemName: "photo.on.rectangle")
              Text("Upload Photo")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
          }
          .buttonStyle(.plain)
        }
      }

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
    .id(progress.id)  // Prevent view recreation when progress data changes
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Text("Endorsement Text")
          .font(.caption)
          .foregroundColor(.secondary)
      }
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
    .onAppear {
      loadTemplate()
    }
  }

  // MARK: - Methods

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
        } catch {
          print("Failed to save after adding endorsement: \(error)")
        }
      }
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

  private func loadTemplate() {
    // In the new system, template is already available through the progress relationship
    template = progress.template
  }
}

#Preview {
  let student = Student(
    firstName: "John", lastName: "Doe", email: "john@example.com", telephone: "555-1234",
    homeAddress: "123 Main St", ftnNumber: "123456789")
  let progress = ChecklistAssignment(templateId: UUID(), templateIdentifier: "endorsements")
  EndorsementsView(student: student, progress: progress)
    .modelContainer(
      for: [
        Student.self, ChecklistAssignment.self, ItemProgress.self, CustomChecklistDefinition.self,
        CustomChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self,
      ], inMemory: true)
}
