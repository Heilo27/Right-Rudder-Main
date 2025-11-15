//
//  ChecklistAssignment.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation
import SwiftData

// MARK: - ChecklistAssignment Model

@Model
class ChecklistAssignment {
  var id: UUID = UUID()
  var templateId: UUID = UUID()  // References library checklist
  var templateIdentifier: String?  // Fallback for custom
  var isCustomChecklist: Bool = false  // True if user-created

  // MARK: - Instructor-Owned Fields (Read-Only for Student)
  // These fields are written by instructor app, read-only in student app
  var instructorComments: String?  // INSTRUCTOR → STUDENT (read-only for student)
  var dualGivenHours: Double = 0.0  // INSTRUCTOR → STUDENT (read-only for student)
  var assignedAt: Date = Date()
  var lastModified: Date = Date()

  // Progress tracking
  @Relationship(deleteRule: .cascade, inverse: \ItemProgress.assignment) var itemProgress:
    [ItemProgress]?

  // Relationships
  var student: Student?

  init(templateId: UUID, templateIdentifier: String? = nil, isCustomChecklist: Bool = false) {
    self.templateId = templateId
    self.templateIdentifier = templateIdentifier
    self.isCustomChecklist = isCustomChecklist
    self.lastModified = Date()
  }

  // Computed properties for easy access
  var progressPercentage: Double {
    let total = totalItemsCount
    guard total > 0 else { return 0.0 }
    let completed = completedItemsCount
    return Double(completed) / Double(total)
  }

  var completedItemsCount: Int {
    return itemProgress?.filter { $0.isComplete }.count ?? 0
  }

  var totalItemsCount: Int {
    // First try to get count from itemProgress records
    if let progressItems = itemProgress, !progressItems.isEmpty {
      return progressItems.count
    }

    // Fallback to template's item count if itemProgress is empty/nil
    // This handles cases where items haven't been synced yet or assignment is incomplete
    if let template = template, let templateItems = template.items {
      return templateItems.count
    }

    return 0
  }

  var isComplete: Bool {
    let total = totalItemsCount
    guard total > 0 else { return false }
    return progressPercentage >= 1.0
  }

  // CloudKit compatibility - generate display name
  var displayName: String {
    // Try to get name from template relationship
    if let template = template {
      return template.name
    }

    // Fallback to templateIdentifier if available
    if let identifier = templateIdentifier, !identifier.isEmpty {
      return identifier.replacingOccurrences(of: "_", with: " ").capitalized
    }

    return "Unknown Checklist"
  }

  // Relationship to template (for instructor app)
  var template: ChecklistTemplate?
}
