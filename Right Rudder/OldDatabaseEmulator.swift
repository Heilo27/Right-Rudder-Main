//
//  OldDatabaseEmulator.swift
//  Right Rudder
//
//  Database adapter that reads old database format and converts to new schema
//  Uses the proven save method from AddStudentView to ensure compatibility
//

import Combine
import CoreData
import Foundation
import SwiftData

@MainActor
class OldDatabaseEmulator: ObservableObject {
  static let shared = OldDatabaseEmulator()

  @Published var isMigrating = false
  @Published var migrationProgress: String = ""
  @Published var studentsMigrated: Int = 0

  private var modelContext: ModelContext?

  private init() {}

  func setModelContext(_ context: ModelContext) {
    self.modelContext = context
  }

  /// Reads old database and converts students using the proven save method
  func migrateOldDatabaseToNewSchema() async {
    guard let modelContext = modelContext else {
      print("❌ No model context available")
      return
    }

    isMigrating = true
    migrationProgress = "Accessing database..."

    do {
      // Try to read from Core Data store directly
      guard let storeURL = getDatabaseURL() else {
        migrationProgress = "Could not locate database - trying CloudKit..."
        await migrateFromCloudKit()
        return
      }

      print("📂 Attempting to read from: \(storeURL.path)")

      // Create Core Data container to read old data
      let container = try await createReadOnlyContainer(storeURL: storeURL)
      let context = container.viewContext

      migrationProgress = "Reading old student records..."

      // Fetch all managed objects that might be students
      let request = NSFetchRequest<NSManagedObject>(entityName: "Student")
      request.returnsObjectsAsFaults = false

      let oldStudents = try context.fetch(request)

      print("📊 Found \(oldStudents.count) records in old database")

      if oldStudents.isEmpty {
        migrationProgress = "No old data found - checking CloudKit..."
        await migrateFromCloudKit()
        return
      }

      migrationProgress = "Converting \(oldStudents.count) students..."

      // Get existing students
      let existingDescriptor = FetchDescriptor<Student>()
      let existingStudents = try modelContext.fetch(existingDescriptor)
      let existingUUIDs = Set(existingStudents.map { $0.id })
      let existingEmails = Set(
        existingStudents.compactMap { $0.email.isEmpty ? nil : $0.email.lowercased() })

      var migrated = 0

      for oldStudent in oldStudents {
        // Extract UUID
        var uuid: UUID?

        if let idValue = oldStudent.value(forKey: "id") {
          if let uuidValue = idValue as? UUID {
            uuid = uuidValue
          } else if let uuidString = idValue as? String {
            uuid = UUID(uuidString: uuidString)
          }
        }

        // Generate UUID if not found
        uuid = uuid ?? UUID()

        // Skip if already exists
        if existingUUIDs.contains(uuid!) {
          continue
        }

        // Extract student data
        let firstName = oldStudent.value(forKey: "firstName") as? String ?? ""
        let lastName = oldStudent.value(forKey: "lastName") as? String ?? ""
        let email = (oldStudent.value(forKey: "email") as? String ?? "").lowercased()

        // Skip if duplicate email
        if !email.isEmpty && existingEmails.contains(email) {
          continue
        }

        // Skip if completely empty OR if it's a temporary name
        if firstName.isEmpty && lastName.isEmpty {
          continue
        }

        // Skip temporary-named students (created during recovery with no real data)
        if firstName == "Student" && lastName.count == 8 && lastName.allSatisfy({ $0.isHexDigit }) {
          print("⚠️ Skipping temporary-named student during migration: \(firstName) \(lastName)")
          continue
        }

        migrationProgress = "Migrating: \(firstName) \(lastName)..."

        // Use the proven save method from AddStudentView
        let newStudent = Student(
          firstName: firstName,
          lastName: lastName,
          email: email,
          telephone: oldStudent.value(forKey: "telephone") as? String ?? "",
          homeAddress: oldStudent.value(forKey: "homeAddress") as? String ?? "",
          ftnNumber: oldStudent.value(forKey: "ftnNumber") as? String ?? ""
        )
        newStudent.id = uuid!
        newStudent.biography = oldStudent.value(forKey: "biography") as? String
        newStudent.backgroundNotes = oldStudent.value(forKey: "backgroundNotes") as? String
        newStudent.createdAt = oldStudent.value(forKey: "createdAt") as? Date ?? Date()
        newStudent.lastModified = oldStudent.value(forKey: "lastModified") as? Date ?? Date()
        newStudent.assignedCategory =
          oldStudent.value(forKey: "assignedCategory") as? String ?? "PPL"
        newStudent.isInactive = oldStudent.value(forKey: "isInactive") as? Bool ?? false

        // Insert and save using proven method
        modelContext.insert(newStudent)

        do {
          try modelContext.save()
          migrated += 1
          print("✅ Migrated student: \(newStudent.displayName) (ID: \(uuid!))")
        } catch {
          print("❌ Failed to save migrated student: \(error)")
          // Remove from context if save failed
          modelContext.delete(newStudent)
        }
      }

      studentsMigrated = migrated
      migrationProgress = "Migration complete! Migrated \(migrated) students"
      print("✅ Migration complete: \(migrated) students migrated")

    } catch {
      migrationProgress = "Database read failed: \(error.localizedDescription). Trying CloudKit..."
      print("⚠️ Could not read old database: \(error)")
      await migrateFromCloudKit()
    }

    isMigrating = false
  }

  /// Migrates from CloudKit as fallback
  private func migrateFromCloudKit() async {
    migrationProgress = "Fetching from CloudKit..."
    EmergencyDataRecovery.shared.setModelContext(modelContext!)
    await EmergencyDataRecovery.shared.emergencyRecovery()
    migrationProgress = "CloudKit migration complete"
  }

  /// Gets the database URL
  private func getDatabaseURL() -> URL? {
    let fileManager = FileManager.default
    guard
      let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        .first
    else {
      return nil
    }

    let storeURL = appSupportURL.appendingPathComponent("default.store")

    if fileManager.fileExists(atPath: storeURL.path) {
      return storeURL
    }

    return nil
  }

  /// Creates a read-only Core Data container
  private func createReadOnlyContainer(storeURL: URL) async throws -> NSPersistentContainer {
    return try await withCheckedThrowingContinuation { continuation in
      // Create minimal model to read any Core Data entity
      let model = NSManagedObjectModel()

      // Create a generic entity that can read any attributes
      let entity = NSEntityDescription()
      entity.name = "Student"
      entity.managedObjectClassName = "NSManagedObject"
      model.entities = [entity]

      let container = NSPersistentContainer(name: "TempReader", managedObjectModel: model)

      let description = NSPersistentStoreDescription(url: storeURL)
      description.type = NSSQLiteStoreType
      description.setOption(true as NSNumber, forKey: NSReadOnlyPersistentStoreOption)

      container.persistentStoreDescriptions = [description]

      container.loadPersistentStores { description, error in
        if let error = error {
          continuation.resume(throwing: error)
        } else {
          continuation.resume(returning: container)
        }
      }
    }
  }
}
