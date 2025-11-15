//
//  ConflictResolutionView.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftData
import SwiftUI

// MARK: - ConflictResolutionView

struct ConflictResolutionView: View {
  // MARK: - Properties

  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  @Bindable var student: Student
  let conflicts: [DataConflict]

  @State private var resolvedConflicts: [String: String] = [:]
  @State private var isResolving = false

  // MARK: - Body

  var body: some View {
    NavigationView {
      VStack(spacing: 0) {
        // Header
        headerSection

        // Conflicts List
        ScrollView {
          LazyVStack(spacing: 16) {
            ForEach(conflicts) { conflict in
              ConflictRow(
                conflict: conflict,
                selectedValue: Binding(
                  get: { resolvedConflicts[conflict.fieldName] ?? "" },
                  set: { resolvedConflicts[conflict.fieldName] = $0 }
                )
              )
            }
          }
          .padding()
        }

        // Action Buttons
        actionButtonsSection
      }
      .navigationTitle("Resolve Conflicts")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            dismiss()
          }
        }
      }
    }
    .onAppear {
      initializeResolutions()
    }
  }

  // MARK: - Subviews

  private var headerSection: some View {
    VStack(spacing: 12) {
      HStack {
        Image(systemName: "exclamationmark.triangle")
          .foregroundColor(.orange)
          .font(.title2)

        VStack(alignment: .leading, spacing: 4) {
          Text("Data Conflicts Detected")
            .font(.headline)
            .foregroundColor(.primary)

          Text(
            "The student has made changes that conflict with your data. Choose which values to keep."
          )
          .font(.caption)
          .foregroundColor(.secondary)
        }

        Spacer()
      }

      HStack {
        Button("Accept All Student Changes") {
          acceptAllStudentChanges()
        }
        .buttonStyle(.bordered)
        .foregroundColor(.green)

        Spacer()

        Button("Keep All My Changes") {
          keepAllInstructorChanges()
        }
        .buttonStyle(.bordered)
        .foregroundColor(.blue)
      }
    }
    .padding()
    .background(Color.appAdaptiveMutedBox)
    .cornerRadius(12)
    .padding()
  }

  private var actionButtonsSection: some View {
    VStack(spacing: 12) {
      Button(action: {
        Task {
          await resolveConflicts()
        }
      }) {
        HStack {
          if isResolving {
            ProgressView()
              .scaleEffect(0.8)
          } else {
            Image(systemName: "checkmark.circle")
          }
          Text(isResolving ? "Resolving..." : "Resolve Conflicts")
        }
        .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .disabled(isResolving)

      Text("\(conflicts.count) conflicts to resolve")
        .font(.caption)
        .foregroundColor(.secondary)
    }
    .padding()
    .background(Color.appAdaptiveBackground)
  }

  // MARK: - Methods

  private func initializeResolutions() {
    // Initialize with instructor values as default
    for conflict in conflicts {
      resolvedConflicts[conflict.fieldName] = conflict.instructorValue
    }
  }

  private func acceptAllStudentChanges() {
    for conflict in conflicts {
      resolvedConflicts[conflict.fieldName] = conflict.studentValue
    }
  }

  private func keepAllInstructorChanges() {
    for conflict in conflicts {
      resolvedConflicts[conflict.fieldName] = conflict.instructorValue
    }
  }

  @MainActor
  private func resolveConflicts() async {
    isResolving = true

    do {
      // Apply resolved values to student
      for conflict in conflicts {
        let resolvedValue = resolvedConflicts[conflict.fieldName] ?? conflict.instructorValue
        applyResolvedValue(
          to: student, fieldName: conflict.fieldName, value: resolvedValue,
          fieldType: conflict.fieldType)
      }

      // Save changes
      student.lastModified = Date()
      try modelContext.save()

      // TODO: Push resolved changes back to CloudKit
      // This would require updating the CloudKitSyncService

      print("✅ Conflicts resolved successfully")
      dismiss()

    } catch {
      print("❌ Failed to resolve conflicts: \(error)")
    }

    isResolving = false
  }

  private func applyResolvedValue(
    to student: Student, fieldName: String, value: String, fieldType: DataConflict.ConflictFieldType
  ) {
    switch fieldName {
    case "firstName":
      student.firstName = value
    case "lastName":
      student.lastName = value
    case "email":
      student.email = value
    case "telephone":
      student.telephone = value
    case "homeAddress":
      student.homeAddress = value
    case "ftnNumber":
      student.ftnNumber = value
    case "biography":
      student.biography = value.isEmpty ? nil : value
    case "backgroundNotes":
      student.backgroundNotes = value.isEmpty ? nil : value
    case "instructorName":
      student.instructorName = value.isEmpty ? nil : value
    case "instructorCFINumber":
      student.instructorCFINumber = value.isEmpty ? nil : value

    // Training Goals
    case "goalPPL":
      student.goalPPL = value == "Yes"
    case "goalInstrument":
      student.goalInstrument = value == "Yes"
    case "goalCommercial":
      student.goalCommercial = value == "Yes"
    case "goalCFI":
      student.goalCFI = value == "Yes"

    // Training Milestones - PPL
    case "pplGroundSchoolCompleted":
      student.pplGroundSchoolCompleted = value == "Yes"
    case "pplWrittenTestCompleted":
      student.pplWrittenTestCompleted = value == "Yes"

    // Training Milestones - Instrument
    case "instrumentGroundSchoolCompleted":
      student.instrumentGroundSchoolCompleted = value == "Yes"
    case "instrumentWrittenTestCompleted":
      student.instrumentWrittenTestCompleted = value == "Yes"

    // Training Milestones - Commercial
    case "commercialGroundSchoolCompleted":
      student.commercialGroundSchoolCompleted = value == "Yes"
    case "commercialWrittenTestCompleted":
      student.commercialWrittenTestCompleted = value == "Yes"

    // Training Milestones - CFI
    case "cfiGroundSchoolCompleted":
      student.cfiGroundSchoolCompleted = value == "Yes"
    case "cfiWrittenTestCompleted":
      student.cfiWrittenTestCompleted = value == "Yes"

    default:
      print("Unknown field: \(fieldName)")
    }
  }
}

// MARK: - ConflictRow

struct ConflictRow: View {
  // MARK: - Properties

  let conflict: DataConflict
  @Binding var selectedValue: String

  // MARK: - Body

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Field Name
      Text(conflict.displayName)
        .font(.headline)
        .foregroundColor(.primary)

      // Value Comparison
      HStack(spacing: 16) {
        // Instructor Value
        VStack(alignment: .leading, spacing: 8) {
          HStack {
            Image(systemName: "person.circle")
              .foregroundColor(.blue)
            Text("Your Value")
              .font(.subheadline)
              .fontWeight(.medium)
              .foregroundColor(.blue)
          }

          Text(conflict.instructorValue)
            .font(.body)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            .overlay(
              RoundedRectangle(cornerRadius: 8)
                .stroke(
                  selectedValue == conflict.instructorValue ? Color.blue : Color.clear, lineWidth: 2
                )
            )
            .onTapGesture {
              selectedValue = conflict.instructorValue
            }
        }

        // Student Value
        VStack(alignment: .leading, spacing: 8) {
          HStack {
            Image(systemName: "person.circle.fill")
              .foregroundColor(.green)
            Text("Student's Value")
              .font(.subheadline)
              .fontWeight(.medium)
              .foregroundColor(.green)
          }

          Text(conflict.studentValue)
            .font(.body)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
            .overlay(
              RoundedRectangle(cornerRadius: 8)
                .stroke(
                  selectedValue == conflict.studentValue ? Color.green : Color.clear, lineWidth: 2)
            )
            .onTapGesture {
              selectedValue = conflict.studentValue
            }
        }
      }

      // Timestamp
      HStack {
        Image(systemName: "clock")
          .foregroundColor(.secondary)
        Text("Student changed this on \(conflict.studentModifiedDate, style: .date)")
          .font(.caption)
          .foregroundColor(.secondary)
      }
    }
    .padding()
    .background(Color.appAdaptiveBackground)
    .cornerRadius(12)
    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
  }
}

#Preview {
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: Student.self, configurations: config)
  let student = Student(
    firstName: "John", lastName: "Doe", email: "john@example.com", telephone: "555-0123",
    homeAddress: "123 Main St", ftnNumber: "FTN123")

  let conflicts = [
    DataConflict(
      fieldName: "firstName",
      displayName: "First Name",
      instructorValue: "John",
      studentValue: "Jonathan",
      studentModifiedDate: Date(),
      fieldType: .text
    ),
    DataConflict(
      fieldName: "goalPPL",
      displayName: "PPL Goal",
      instructorValue: "No",
      studentValue: "Yes",
      studentModifiedDate: Date(),
      fieldType: .boolean
    ),
  ]

  container.mainContext.insert(student)

  return ConflictResolutionView(student: student, conflicts: conflicts)
    .modelContainer(container)
}
