//
//  ItemProgress.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation
import SwiftData

// MARK: - ItemProgress Model

@Model
class ItemProgress {
  var id: UUID = UUID()
  var templateItemId: UUID = UUID()  // References library item

  // MARK: - Instructor-Owned Fields (Read-Only for Student)
  // These fields are written by instructor app, read-only in student app
  var isComplete: Bool = false  // INSTRUCTOR → STUDENT (read-only for student)
  var notes: String?  // INSTRUCTOR → STUDENT (read-only for student - instructor comments)
  var completedAt: Date?
  var lastModified: Date = Date()

  // Relationship
  var assignment: ChecklistAssignment?

  init(templateItemId: UUID) {
    self.templateItemId = templateItemId
    self.lastModified = Date()
  }

  // CloudKit compatibility - generate display title
  var displayTitle: String {
    // This will be populated from the template item when syncing
    return "Item \(id.uuidString.prefix(8))"  // Fallback title
  }
}
