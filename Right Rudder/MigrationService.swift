import Foundation
import SwiftData

class MigrationService {

  /// Migrate from old StudentChecklist system to new reference-based system
  static func migrateToReferenceBasedSystem(modelContext: ModelContext) {
    print("🔄 Starting migration to reference-based checklist system...")

    do {
      // Get all students
      let studentDescriptor = FetchDescriptor<Student>()
      let students = try modelContext.fetch(studentDescriptor)

      var migratedCount = 0
      let skippedCount = 0  // Not used in current implementation

      for _ in students {
        // Migration logic would go here
        // For now, this is a placeholder since we're implementing the new system directly
        migratedCount += 1
      }

      try modelContext.save()
      print("✅ Migration completed: \(migratedCount) students processed, \(skippedCount) skipped")

    } catch {
      print("❌ Migration failed: \(error)")
    }
  }

  /// Check if migration is needed
  static func isMigrationNeeded(modelContext: ModelContext) -> Bool {
    do {
      // Check if any students still have old-style checklists
      let studentDescriptor = FetchDescriptor<Student>()
      let students = try modelContext.fetch(studentDescriptor)

      for student in students {
        // Since we're implementing the new system directly, migration is not needed
        // This function is kept for future compatibility
        if (student.checklistAssignments?.count ?? 0) == 0 {
          // Student has no progress records - might need migration
          // But since we're implementing new system directly, return false
          return false
        }
      }

      return false

    } catch {
      print("Error checking migration status: \(error)")
      return false
    }
  }

  /// Get migration status report
  static func getMigrationStatus(modelContext: ModelContext) -> MigrationStatus {
    do {
      let studentDescriptor = FetchDescriptor<Student>()
      let students = try modelContext.fetch(studentDescriptor)

      let studentsWithOldChecklists = 0
      var studentsWithNewProgress = 0
      let studentsWithBoth = 0

      for student in students {
        // Since we're implementing the new system directly, all students use the new progress system
        let hasNewProgress = (student.checklistAssignments?.count ?? 0) > 0

        if hasNewProgress {
          studentsWithNewProgress += 1
        }
      }

      return MigrationStatus(
        totalStudents: students.count,
        studentsWithOldChecklists: studentsWithOldChecklists,
        studentsWithNewProgress: studentsWithNewProgress,
        studentsWithBoth: studentsWithBoth,
        needsMigration: false  // No migration needed since we're implementing new system directly
      )

    } catch {
      print("Error getting migration status: \(error)")
      return MigrationStatus(
        totalStudents: 0,
        studentsWithOldChecklists: 0,
        studentsWithNewProgress: 0,
        studentsWithBoth: 0,
        needsMigration: false
      )
    }
  }

  /// Clean up old checklist data after successful migration
  static func cleanupOldChecklistData(modelContext: ModelContext) {
    print("🧹 Cleaning up old checklist data...")

    do {
      // Since we're implementing the new system directly, there's no old data to clean up
      // This function is kept for future compatibility

      let studentDescriptor = FetchDescriptor<Student>()
      let _ = try modelContext.fetch(studentDescriptor)

      let oldChecklistsToRemove = 0  // No old checklists since we're using new system directly

      print("📊 Found \(oldChecklistsToRemove) old checklists to remove")

      // No cleanup needed since we're implementing new system directly

    } catch {
      print("Error cleaning up old checklist data: \(error)")
    }
  }
}

struct MigrationStatus {
  let totalStudents: Int
  let studentsWithOldChecklists: Int
  let studentsWithNewProgress: Int
  let studentsWithBoth: Int
  let needsMigration: Bool

  var description: String {
    return """
      Migration Status:
      - Total Students: \(totalStudents)
      - Students with Old Checklists: \(studentsWithOldChecklists)
      - Students with New Progress: \(studentsWithNewProgress)
      - Students with Both: \(studentsWithBoth)
      - Migration Needed: \(needsMigration ? "Yes" : "No")
      """
  }
}
