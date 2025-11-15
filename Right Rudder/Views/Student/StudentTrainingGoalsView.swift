//
//  StudentTrainingGoalsView.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftData
import SwiftUI

// MARK: - StudentTrainingGoalsView

struct StudentTrainingGoalsView: View {
  // MARK: - Properties

  @Bindable var student: Student

  // MARK: - Body

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        // Read-Only Header
        readOnlyHeader

        // Training Goals Section
        trainingGoalsSection

        // Milestones Section
        milestonesSection

        // Progress Summary
        progressSummarySection
      }
      .padding()
    }
    .navigationTitle("Training Goals")
    .navigationBarTitleDisplayMode(.inline)
  }

  private var readOnlyHeader: some View {
    HStack {
      Image(systemName: "eye")
        .foregroundColor(.blue)
        .font(.title2)

      VStack(alignment: .leading, spacing: 4) {
        Text("Read-Only View")
          .font(.headline)
          .foregroundColor(.primary)

        Text("This information is synced from the student's app")
          .font(.caption)
          .foregroundColor(.secondary)
      }

      Spacer()
    }
    .padding()
    .background(Color.appAdaptiveMutedBox)
    .cornerRadius(12)
  }

  private var trainingGoalsSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        Image(systemName: "target")
          .foregroundColor(.appPrimary)
          .font(.title2)

        Text("Training Goals")
          .font(.headline)
          .fontWeight(.semibold)

        Spacer()
      }

      VStack(spacing: 12) {
        TrainingGoalRow(
          title: "PPL (Private Pilot License)",
          icon: "airplane",
          isSelected: student.goalPPL,
          color: .blue
        )

        TrainingGoalRow(
          title: "Instrument Rating",
          icon: "cloud.fog",
          isSelected: student.goalInstrument,
          color: .purple
        )

        TrainingGoalRow(
          title: "Commercial Pilot",
          icon: "briefcase",
          isSelected: student.goalCommercial,
          color: .orange
        )

        TrainingGoalRow(
          title: "CFI (Certified Flight Instructor)",
          icon: "person.badge.plus",
          isSelected: student.goalCFI,
          color: .green
        )
      }
    }
    .padding()
    .background(Color.appAdaptiveBackground)
    .cornerRadius(16)
    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
  }

  private var milestonesSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        Image(systemName: "graduationcap")
          .foregroundColor(.appPrimary)
          .font(.title2)

        Text("Training Milestones")
          .font(.headline)
          .fontWeight(.semibold)

        Spacer()
      }

      VStack(spacing: 16) {
        // PPL Milestones
        if student.goalPPL {
          MilestoneCategorySection(
            title: "PPL Training",
            icon: "airplane",
            color: .blue,
            groundSchoolCompleted: student.pplGroundSchoolCompleted,
            writtenTestCompleted: student.pplWrittenTestCompleted
          )
        }

        // Instrument Milestones
        if student.goalInstrument {
          MilestoneCategorySection(
            title: "Instrument Training",
            icon: "cloud.fog",
            color: .purple,
            groundSchoolCompleted: student.instrumentGroundSchoolCompleted,
            writtenTestCompleted: student.instrumentWrittenTestCompleted
          )
        }

        // Commercial Milestones
        if student.goalCommercial {
          MilestoneCategorySection(
            title: "Commercial Training",
            icon: "briefcase",
            color: .orange,
            groundSchoolCompleted: student.commercialGroundSchoolCompleted,
            writtenTestCompleted: student.commercialWrittenTestCompleted
          )
        }

        // CFI Milestones
        if student.goalCFI {
          MilestoneCategorySection(
            title: "CFI Training",
            icon: "person.badge.plus",
            color: .green,
            groundSchoolCompleted: student.cfiGroundSchoolCompleted,
            writtenTestCompleted: student.cfiWrittenTestCompleted
          )
        }
      }
    }
    .padding()
    .background(Color.appAdaptiveBackground)
    .cornerRadius(16)
    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
  }

  private var progressSummarySection: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        Image(systemName: "chart.line.uptrend.xyaxis")
          .foregroundColor(.appPrimary)
          .font(.title2)

        Text("Progress Summary")
          .font(.headline)
          .fontWeight(.semibold)

        Spacer()
      }

      VStack(spacing: 12) {
        ProgressSummaryRow(
          title: "Selected Goals",
          value: selectedGoalsCount,
          total: 4,
          icon: "target",
          color: .blue
        )

        ProgressSummaryRow(
          title: "Ground School Completed",
          value: completedGroundSchoolCount,
          total: selectedGoalsCount,
          icon: "graduationcap",
          color: .green
        )

        ProgressSummaryRow(
          title: "Written Tests Completed",
          value: completedWrittenTestCount,
          total: selectedGoalsCount,
          icon: "pencil.and.outline",
          color: .orange
        )
      }
    }
    .padding()
    .background(Color.appAdaptiveBackground)
    .cornerRadius(16)
    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
  }

  // MARK: - Computed Properties

  private var selectedGoalsCount: Int {
    var count = 0
    if student.goalPPL { count += 1 }
    if student.goalInstrument { count += 1 }
    if student.goalCommercial { count += 1 }
    if student.goalCFI { count += 1 }
    return count
  }

  private var completedGroundSchoolCount: Int {
    var count = 0
    if student.goalPPL && student.pplGroundSchoolCompleted { count += 1 }
    if student.goalInstrument && student.instrumentGroundSchoolCompleted { count += 1 }
    if student.goalCommercial && student.commercialGroundSchoolCompleted { count += 1 }
    if student.goalCFI && student.cfiGroundSchoolCompleted { count += 1 }
    return count
  }

  private var completedWrittenTestCount: Int {
    var count = 0
    if student.goalPPL && student.pplWrittenTestCompleted { count += 1 }
    if student.goalInstrument && student.instrumentWrittenTestCompleted { count += 1 }
    if student.goalCommercial && student.commercialWrittenTestCompleted { count += 1 }
    if student.goalCFI && student.cfiWrittenTestCompleted { count += 1 }
    return count
  }
}

#Preview {
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: Student.self, configurations: config)
  let student = Student(
    firstName: "John", lastName: "Doe", email: "john@example.com", telephone: "555-0123",
    homeAddress: "123 Main St", ftnNumber: "FTN123")

  // Set some example data
  student.goalPPL = true
  student.goalInstrument = true
  student.pplGroundSchoolCompleted = true
  student.pplWrittenTestCompleted = false
  student.instrumentGroundSchoolCompleted = false
  student.instrumentWrittenTestCompleted = true

  container.mainContext.insert(student)

  return NavigationView {
    StudentTrainingGoalsView(student: student)
  }
  .modelContainer(container)
}
