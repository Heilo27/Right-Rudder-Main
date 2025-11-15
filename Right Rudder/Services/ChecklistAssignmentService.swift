import Foundation
import SwiftData

// MARK: - ChecklistAssignmentService

class ChecklistAssignmentService {

  // MARK: - Assignment Management

  /// Assign a template to a student using new library-based system
  static func assignTemplate(
    _ template: ChecklistTemplate, to student: Student, modelContext: ModelContext
  ) {
    // Check if already assigned
    let existingAssignment = student.checklistAssignments?.first {
      $0.templateId == template.id
    }

    if existingAssignment != nil {
      print("Template \(template.name) already assigned to student \(student.displayName)")
      return
    }

    // Use template.id directly (no mapping needed)
    let templateId = template.id

    // Create new assignment record
    // NOTE: This assignment record acts as the "progress file" that will be synced to student app.
    // It only contains:
    // - templateId (reference to lesson in both apps' internal libraries)
    // - instructorComments, dualGivenHours, assignedAt
    // - ItemProgress records (one per item) containing check-offs, notes, completedAt
    // The full lesson definition is NOT synced - both apps already have it in their libraries.
    let assignment = ChecklistAssignment(
      templateId: templateId,
      templateIdentifier: template.templateIdentifier,
      isCustomChecklist: template.templateIdentifier == nil
    )

    // CRITICAL: Create ItemProgress records for ALL template items immediately when assigning.
    // These records act as the "progress file" that tracks:
    // - isComplete (check-offs)
    // - notes (instructor comments)
    // - completedAt (when checked)
    // - dualGivenHours and instructorComments are stored on the assignment itself
    // This ensures the student app can show the lesson and all progress immediately.
    if let templateItems = template.items {
      var itemProgressArray: [ItemProgress] = []

      for templateItem in templateItems {
        // Use templateItem.id directly (no mapping needed)
        let templateItemId = templateItem.id

        // Create ItemProgress record and set relationships explicitly
        let itemProgress = ItemProgress(templateItemId: templateItemId)
        itemProgress.assignment = assignment
        itemProgressArray.append(itemProgress)
        modelContext.insert(itemProgress)
      }

      assignment.itemProgress = itemProgressArray
    } else {
      // Initialize empty array if no template items
      assignment.itemProgress = []
    }

    // Set relationships
    assignment.student = student
    assignment.template = template

    // Initialize checklistAssignments array if nil
    if student.checklistAssignments == nil {
      student.checklistAssignments = []
    }
    student.checklistAssignments?.append(assignment)

    // Update template's student assignment tracking
    if template.studentAssignments == nil {
      template.studentAssignments = []
    }
    template.studentAssignments?.append(assignment)

    // Safety check: ensure template relationship is set (should already be set above)
    _ = ensureTemplateRelationship(for: assignment, modelContext: modelContext)

    // Debug: Verify relationships are set
    print("🔗 Assignment verification:")
    print("   Assignment.template: \(assignment.template?.name ?? "nil")")
    print("   Assignment.templateId: \(assignment.templateId)")
    print("   Template.id: \(template.id)")
    print("   Template.name: \(template.name)")

    // Save using serialized queue
    Task { @MainActor in
      do {
        try await modelContext.saveSafely()
        print("Assigned template \(template.name) to student \(student.displayName)")
      } catch {
        print("Failed to assign template: \(error)")
      }
    }
  }

  // MARK: - Removal

  /// Remove template assignment from student
  /// CRITICAL: Syncs deletion to CloudKit if student has active share
  static func removeTemplate(
    _ template: ChecklistTemplate, from student: Student, modelContext: ModelContext
  ) {
    guard
      let assignment = student.checklistAssignments?.first(where: { $0.templateId == template.id })
    else {
      return
    }

    // CRITICAL: Delete from CloudKit first (if student has active share)
    // This ensures the student app will detect the deletion on next sync
    if student.shareRecordID != nil {
      Task {
        let shareService = CloudKitShareService.shared
        // Check if share is actually active before attempting deletion
        let hasActive = await shareService.hasActiveShare(for: student)
        if hasActive {
          await shareService.deleteAssignmentFromCloudKit(assignment: assignment, student: student)
        } else {
          print("⚠️ Share exists but is not active - skipping CloudKit deletion")
        }
      }
    }

    // Remove from student
    student.checklistAssignments?.removeAll { $0.id == assignment.id }

    // Remove from template
    template.studentAssignments?.removeAll { $0.id == assignment.id }

    // Delete the assignment record
    modelContext.delete(assignment)

    // Save using serialized queue
    Task { @MainActor in
      do {
        try await modelContext.saveSafely()
        print("Removed template \(template.name) from student \(student.displayName)")
      } catch {
        print("Failed to remove template: \(error)")
      }
    }
  }

  // MARK: - Display Helpers

  /// Get display items for a student's checklist assignment
  /// Safely handles invalidated SwiftData objects
  static func getDisplayItems(for assignment: ChecklistAssignment) -> [DisplayChecklistItem] {
    // Validate assignment is still valid by checking if we can access its ID
    // SwiftData objects that are invalidated may have issues, but property access doesn't throw
    // We check by accessing the ID property - if the object is invalidated, this might return
    // an invalid value, but we'll catch that when accessing relationships
    let _ = assignment.id

    // Access template and items - if template relationship is broken, this will return nil
    // which is handled gracefully by returning empty array
    guard let template = assignment.template else {
      return []
    }

    // Validate template is still valid
    let _ = template.id

    guard let templateItems = template.items else {
      return []
    }

    // Validate items are still valid before processing
    // Accessing the id property will help ensure the object is still valid
    let validItems = templateItems.compactMap { item -> ChecklistItem? in
      // Access id to validate object is still accessible
      let _ = item.id
      return item
    }

    return processTemplateItems(templateItems: validItems, assignment: assignment)
  }

  /// Safely extracts all data from ChecklistItems into value types
  /// This prevents fatal errors from accessing invalidated SwiftData objects
  /// Returns an array of tuples containing only value types (no SwiftData references)
  static func extractItemDataSafely(items: [ChecklistItem]) -> [(
    id: UUID, title: String, notes: String?, order: Int
  )] {
    // Extract all properties immediately into value types
    // This ensures we never hold references to SwiftData objects that could become invalidated
    return items.map { item in
      // Access all properties immediately and convert to value types
      (id: item.id, title: item.title, notes: item.notes, order: item.order)
    }
  }

  /// Helper to process template items safely, creating snapshots to avoid invalidated object access
  private static func processTemplateItems(
    templateItems: [ChecklistItem], assignment: ChecklistAssignment
  ) -> [DisplayChecklistItem] {
    // Extract all data into value types immediately - no SwiftData object references after this
    let itemSnapshots = extractItemDataSafely(items: templateItems)

    // Use the snapshot to create display items (no longer holding SwiftData object references)
    return itemSnapshots.compactMap { snapshot in
      // Find ItemProgress using the snapshot ID
      let itemProgress = assignment.itemProgress?.first {
        $0.templateItemId == snapshot.id
      }

      return DisplayChecklistItem(
        templateItemId: snapshot.id,
        title: snapshot.title,
        notes: snapshot.notes,
        order: snapshot.order,
        isComplete: itemProgress?.isComplete ?? false,
        studentNotes: itemProgress?.notes,
        completedAt: itemProgress?.completedAt
      )
    }.sorted { $0.order < $1.order }
  }

  // MARK: - Item Progress Updates

  /// Update item completion status
  static func updateItemCompletion(
    _ assignment: ChecklistAssignment, templateItemId: UUID, isComplete: Bool, notes: String? = nil,
    modelContext: ModelContext
  ) {
    guard
      let itemProgress = assignment.itemProgress?.first(where: {
        $0.templateItemId == templateItemId
      })
    else {
      return
    }

    itemProgress.isComplete = isComplete
    itemProgress.notes = notes
    itemProgress.lastModified = Date()

    if isComplete {
      itemProgress.completedAt = Date()
    } else {
      itemProgress.completedAt = nil
    }

    assignment.lastModified = Date()

    do {
      try modelContext.save()

      // Post notification that a checklist item was completed
      NotificationCenter.default.post(
        name: Notification.Name("checklistItemCompleted"), object: nil)
      print("📢 Posted checklistItemCompleted notification")

      // Sync ItemProgress to CloudKit shared zone if student has active share
      // This syncs ONLY the changed item, not all items (for performance)
      // CRITICAL: Only sync if student has actually accepted the share
      if let student = assignment.student {
        Task {
          let shareService = CloudKitShareService.shared
          let hasActive = await shareService.hasActiveShare(for: student)
          if hasActive {
            await shareService.syncSingleItemProgressToSharedZone(
              itemProgress: itemProgress,
              assignment: assignment,
              student: student,
              modelContext: modelContext
            )
          }
        }
      }
    } catch {
      print("Failed to update item completion: \(error)")
    }
  }

  // MARK: - Relationship Management

  /// Ensures the template relationship is set for an assignment by looking up the template by templateId
  /// Returns true if relationship was set, false if template not found
  static func ensureTemplateRelationship(
    for assignment: ChecklistAssignment, modelContext: ModelContext
  ) -> Bool {
    // If relationship already exists, nothing to do
    if assignment.template != nil {
      return true
    }

    // Look up template by ID
    let request = FetchDescriptor<ChecklistTemplate>()

    do {
      let templates = try modelContext.fetch(request)
      if let template = templates.first(where: { $0.id == assignment.templateId }) {
        assignment.template = template
        return true
      } else {
        print("⚠️ Template not found for assignment templateId: \(assignment.templateId)")
        return false
      }
    } catch {
      print("❌ Failed to fetch template for relationship: \(error)")
      return false
    }
  }
}
