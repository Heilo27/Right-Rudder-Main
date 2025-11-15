//
//  EmergencyDataRecovery.swift
//  Right Rudder
//
//  Emergency data recovery tool to access CloudKit directly and restore all data
//

import CloudKit
import Combine
import Foundation
import SwiftData

@MainActor
class EmergencyDataRecovery: ObservableObject {
  static let shared = EmergencyDataRecovery()

  @Published var isRecovering = false
  @Published var recoveryProgress: String = ""
  @Published var studentsFound: Int = 0
  @Published var studentsRestored: Int = 0

  private let container = CKContainer(identifier: "iCloud.com.heiloprojects.rightrudder")
  private var modelContext: ModelContext?

  private init() {}

  func setModelContext(_ context: ModelContext) {
    self.modelContext = context
  }

  /// Emergency recovery - searches ALL possible record types and restores everything
  func emergencyRecovery() async {
    guard let modelContext = modelContext else {
      print("❌ No model context available")
      return
    }

    isRecovering = true
    recoveryProgress = "Starting emergency data recovery..."

    do {
      let accountStatus = try await container.accountStatus()
      guard accountStatus == .available else {
        recoveryProgress = "iCloud not available"
        isRecovering = false
        return
      }

      recoveryProgress = "Searching CloudKit for all student data..."

      // Search ALL possible record types that might contain student data
      var allStudentRecords: [CKRecord] = []

      // 1. Try "Student" record type (old format)
      recoveryProgress = "Checking 'Student' records..."
      allStudentRecords.append(contentsOf: await fetchRecords(recordType: "Student"))
      print("📊 Found \(allStudentRecords.count) records in 'Student' type")

      // 2. Try "StudentBackup" record type (backup format)
      recoveryProgress = "Checking 'StudentBackup' records..."
      let backupRecords = await fetchRecords(recordType: "StudentBackup")
      print("📊 Found \(backupRecords.count) records in 'StudentBackup' type")

      // Extract students from backup records
      for backupRecord in backupRecords {
        if let originalID = backupRecord["originalID"] as? String {
          // Create a student record from backup
          let studentRecord = CKRecord(recordType: "Student")
          studentRecord["originalID"] = originalID

          // Copy all fields from backup
          for key in backupRecord.allKeys() {
            if key != "backupVersion" && key != "backupTimestamp" && key != "originalID" {
              studentRecord[key] = backupRecord[key]
            }
          }

          allStudentRecords.append(studentRecord)
        }
      }

      // Remove duplicates based on ID
      var uniqueStudents: [String: CKRecord] = [:]
      for record in allStudentRecords {
        let id: String
        if let originalID = record["originalID"] as? String {
          id = originalID
        } else {
          id = record.recordID.recordName
        }

        // Keep the most complete record
        if let existing = uniqueStudents[id] {
          if record.allKeys().count > existing.allKeys().count {
            uniqueStudents[id] = record
          }
        } else {
          uniqueStudents[id] = record
        }
      }

      studentsFound = uniqueStudents.count
      recoveryProgress = "Found \(studentsFound) unique students. Restoring..."

      // Get existing students to avoid duplicates
      let existingDescriptor = FetchDescriptor<Student>()
      let existingStudents = try modelContext.fetch(existingDescriptor)
      let existingUUIDs = Set(existingStudents.map { $0.id })

      // Restore each student
      for (_, record) in uniqueStudents {
        let idString: String
        if let originalID = record["originalID"] as? String {
          idString = originalID
        } else {
          idString = record.recordID.recordName
        }

        guard let uuid = UUID(uuidString: idString) else {
          // Try to generate UUID from record ID if it's not a valid UUID format
          let fallbackUUID = UUID()
          print("⚠️ Invalid UUID format: \(idString), using generated: \(fallbackUUID)")

          // Check if we already have a student with this record ID
          if existingStudents.contains(where: { $0.cloudKitRecordID == record.recordID.recordName })
          {
            print("⏭️ Student with CloudKit ID already exists: \(record.recordID.recordName)")
            continue
          }

          // Create student with generated UUID
          let student = Student(
            firstName: record["firstName"] as? String ?? "",
            lastName: record["lastName"] as? String ?? "",
            email: record["email"] as? String ?? "",
            telephone: record["telephone"] as? String ?? "",
            homeAddress: record["homeAddress"] as? String ?? "",
            ftnNumber: record["ftnNumber"] as? String ?? ""
          )
          student.id = fallbackUUID
          student.biography = record["biography"] as? String
          student.backgroundNotes = record["backgroundNotes"] as? String
          student.createdAt = record["createdAt"] as? Date ?? Date()
          student.lastModified = record["lastModified"] as? Date ?? Date()
          student.cloudKitRecordID = record.recordID.recordName

          modelContext.insert(student)
          studentsRestored += 1
          print("✅ Restored student: \(student.displayName) (Generated ID: \(fallbackUUID))")
          continue
        }

        if existingUUIDs.contains(uuid) {
          print("⏭️ Student already exists: \(uuid)")

          // Update existing student if name is empty but CloudKit has data
          if let existing = existingStudents.first(where: { $0.id == uuid }) {
            let ckFirstName = record["firstName"] as? String ?? ""
            let ckLastName = record["lastName"] as? String ?? ""

            if existing.firstName.isEmpty && existing.lastName.isEmpty
              && (!ckFirstName.isEmpty || !ckLastName.isEmpty)
            {
              existing.firstName = ckFirstName
              existing.lastName = ckLastName
              existing.email = record["email"] as? String ?? existing.email
              existing.telephone = record["telephone"] as? String ?? existing.telephone
              existing.homeAddress = record["homeAddress"] as? String ?? existing.homeAddress
              existing.ftnNumber = record["ftnNumber"] as? String ?? existing.ftnNumber
              existing.biography = record["biography"] as? String ?? existing.biography
              existing.backgroundNotes =
                record["backgroundNotes"] as? String ?? existing.backgroundNotes
              print("✅ Updated existing student with CloudKit data: \(existing.displayName)")
            }
          }
          continue
        }

        // Create student from record
        let firstName = record["firstName"] as? String ?? ""
        let lastName = record["lastName"] as? String ?? ""

        // Skip if completely empty OR if it's a temporary name (Student + UUID pattern)
        if firstName.isEmpty && lastName.isEmpty {
          print("⚠️ Skipping student with no name data")
          continue
        }

        // Skip temporary-named students (created during recovery with no real data)
        if firstName == "Student" && lastName.count == 8 && lastName.allSatisfy({ $0.isHexDigit }) {
          print("⚠️ Skipping temporary-named student: \(firstName) \(lastName)")
          continue
        }

        let student = Student(
          firstName: firstName,
          lastName: lastName,
          email: record["email"] as? String ?? "",
          telephone: record["telephone"] as? String ?? "",
          homeAddress: record["homeAddress"] as? String ?? "",
          ftnNumber: record["ftnNumber"] as? String ?? ""
        )
        student.id = uuid
        student.biography = record["biography"] as? String
        student.backgroundNotes = record["backgroundNotes"] as? String
        student.createdAt = record["createdAt"] as? Date ?? Date()
        student.lastModified = record["lastModified"] as? Date ?? Date()

        // Try to preserve CloudKit record ID if available
        if let ckID = record["cloudKitRecordID"] as? String {
          student.cloudKitRecordID = ckID
        } else {
          student.cloudKitRecordID = record.recordID.recordName
        }

        modelContext.insert(student)
        studentsRestored += 1
        print("✅ Restored student: \(student.displayName) (ID: \(uuid))")
      }

      try modelContext.save()

      recoveryProgress =
        "Recovery complete! Restored \(studentsRestored) students from \(studentsFound) found"
      print("✅ Emergency recovery complete: \(studentsRestored) students restored")

    } catch {
      recoveryProgress = "Recovery failed: \(error.localizedDescription)"
      print("❌ Emergency recovery failed: \(error)")
    }

    isRecovering = false
  }

  /// Fetches all records of a specific type from CloudKit
  private func fetchRecords(recordType: String) async -> [CKRecord] {
    var records: [CKRecord] = []
    let database = container.privateCloudDatabase

    // Use NSPredicate(value: true) to get all records - this is safe for all record types
    let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
    let operation = CKQueryOperation(query: query)
    operation.resultsLimit = CKQueryOperation.maximumResults
    operation.desiredKeys = nil  // Get all fields

    operation.recordMatchedBlock = { _, result in
      if case .success(let record) = result {
        records.append(record)
      }
    }

    await withCheckedContinuation { continuation in
      operation.queryResultBlock = { result in
        switch result {
        case .success(let cursor):
          if cursor != nil {
            print("⚠️ More records available for \(recordType) (cursor exists)")
          }
        case .failure(let error):
          // Some record types might not exist yet - that's OK
          let nsError = error as NSError
          // CKError.unknownItem = 11, but we check error codes differently
          if nsError.domain != CKError.errorDomain || nsError.code != CKError.unknownItem.rawValue {
            print("⚠️ Query result for \(recordType): \(error.localizedDescription)")
          }
        }
        continuation.resume()
      }
      database.add(operation)
    }

    return records
  }

  /// Fixes students with duplicate IDs or empty names by attempting to recover from CloudKit
  func fixCorruptedStudents() async {
    guard let modelContext = modelContext else { return }

    isRecovering = true
    recoveryProgress = "Checking for corrupted students..."

    do {
      let existingDescriptor = FetchDescriptor<Student>()
      let existingStudents = try modelContext.fetch(existingDescriptor)

      // Find students with duplicate IDs or empty names
      var duplicatesByID: [UUID: [Student]] = [:]
      var emptyNames: [Student] = []

      for student in existingStudents {
        if duplicatesByID[student.id] == nil {
          duplicatesByID[student.id] = []
        }
        duplicatesByID[student.id]?.append(student)

        if student.firstName.isEmpty && student.lastName.isEmpty {
          emptyNames.append(student)
        }
      }

      let duplicates = duplicatesByID.values.filter { $0.count > 1 }.flatMap { $0 }

      print("📊 Found \(duplicates.count) duplicate students")
      print("📊 Found \(emptyNames.count) students with empty names")

      if duplicates.isEmpty && emptyNames.isEmpty {
        recoveryProgress = "No corrupted students found"
        isRecovering = false
        return
      }

      recoveryProgress = "Searching CloudKit for student data..."

      // Try to fetch from CloudKit
      let studentRecords = await fetchRecords(recordType: "Student")

      var recordsByID: [UUID: CKRecord] = [:]
      var recordsByCloudKitID: [String: CKRecord] = [:]

      for record in studentRecords {
        // Try to match by UUID from recordName
        if let uuid = UUID(uuidString: record.recordID.recordName) {
          recordsByID[uuid] = record
        }
        recordsByCloudKitID[record.recordID.recordName] = record
      }

      recoveryProgress = "Fixing corrupted students..."

      var fixed = 0

      // Fix duplicates - keep first, remove rest
      for (id, students) in duplicatesByID where students.count > 1 {
        let toKeep = students[0]
        let toRemove = Array(students[1...])

        // Try to update the one we're keeping with CloudKit data
        if let record = recordsByID[id] ?? recordsByCloudKitID[toKeep.cloudKitRecordID ?? ""] {
          if toKeep.firstName.isEmpty && toKeep.lastName.isEmpty {
            toKeep.firstName = record["firstName"] as? String ?? ""
            toKeep.lastName = record["lastName"] as? String ?? ""
          }
        }

        // Generate new UUIDs for duplicates
        for duplicate in toRemove {
          duplicate.id = UUID()
          if let record = recordsByID[id] {
            duplicate.firstName = record["firstName"] as? String ?? duplicate.firstName
            duplicate.lastName = record["lastName"] as? String ?? duplicate.lastName
          }
          fixed += 1
          print("✅ Fixed duplicate student by assigning new ID")
        }
      }

      // Fix empty names - only if we have CloudKit data
      for student in emptyNames {
        if let ckID = student.cloudKitRecordID,
          let record = recordsByCloudKitID[ckID]
        {
          let ckFirstName = record["firstName"] as? String ?? ""
          let ckLastName = record["lastName"] as? String ?? ""

          // Only update if CloudKit has real data (not temporary names)
          if !ckFirstName.isEmpty && ckFirstName != "Student" {
            student.firstName = ckFirstName
            student.lastName = ckLastName
            fixed += 1
            print("✅ Fixed empty name for student ID: \(student.id)")
          } else {
            // Mark for deletion if no real data exists
            print("⚠️ Marking student for deletion - no real name data available")
            modelContext.delete(student)
          }
        } else {
          // No CloudKit data - mark for deletion instead of creating temporary name
          print("⚠️ Marking student for deletion - no CloudKit data available")
          modelContext.delete(student)
        }
      }

      try modelContext.save()

      recoveryProgress = "Fixed \(fixed) corrupted students"
      print("✅ Fixed \(fixed) corrupted students")

    } catch {
      recoveryProgress = "Fix failed: \(error.localizedDescription)"
      print("❌ Failed to fix corrupted students: \(error)")
    }

    isRecovering = false
  }

  /// Removes all temporary-named students (Student + UUID pattern)
  func removeTemporaryNamedStudents() async {
    guard let modelContext = modelContext else { return }

    isRecovering = true
    recoveryProgress = "Cleaning up temporary-named students..."

    do {
      let descriptor = FetchDescriptor<Student>()
      let allStudents = try modelContext.fetch(descriptor)

      var deleted = 0

      for student in allStudents {
        // Check if this is a temporary-named student
        if student.firstName == "Student" && student.lastName.count == 8
          && student.lastName.allSatisfy({ $0.isHexDigit })
        {

          print("🗑️ Deleting temporary-named student: \(student.displayName)")

          // Delete from CloudKit if it exists
          if let cloudKitRecordID = student.cloudKitRecordID {
            let container = CKContainer(identifier: "iCloud.com.heiloprojects.rightrudder")
            let database = container.privateCloudDatabase
            let recordID = CKRecord.ID(recordName: cloudKitRecordID)

            do {
              try await database.deleteRecord(withID: recordID)
              print("✅ Deleted from CloudKit: \(student.displayName)")
            } catch {
              print("⚠️ Failed to delete from CloudKit: \(error)")
            }
          }

          modelContext.delete(student)
          deleted += 1
        }
      }

      if deleted > 0 {
        try modelContext.save()
        recoveryProgress = "Removed \(deleted) temporary-named students"
        print("✅ Removed \(deleted) temporary-named students")
      } else {
        recoveryProgress = "No temporary-named students found"
        print("ℹ️ No temporary-named students found")
      }

    } catch {
      recoveryProgress = "Cleanup failed: \(error.localizedDescription)"
      print("❌ Failed to clean up temporary students: \(error)")
    }

    isRecovering = false
  }

  /// Diagnostic function to check what data exists in CloudKit
  func diagnoseCloudKitData() async -> [String: Int] {
    var results: [String: Int] = [:]

    let recordTypes = ["Student", "StudentBackup", "ChecklistTemplate", "TemplateBackup"]

    for recordType in recordTypes {
      let records = await fetchRecords(recordType: recordType)
      results[recordType] = records.count
      print("📊 \(recordType): \(records.count) records")
    }

    return results
  }
}
