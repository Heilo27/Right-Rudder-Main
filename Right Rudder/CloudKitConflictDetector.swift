//
//  CloudKitConflictDetector.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import CloudKit
import Combine
import Foundation
import SwiftData

struct DataConflict: Identifiable {
  let id = UUID()
  let fieldName: String
  let displayName: String
  let instructorValue: String
  let studentValue: String
  let studentModifiedDate: Date
  let fieldType: ConflictFieldType

  enum ConflictFieldType {
    case text
    case boolean
    case date
  }
}

class CloudKitConflictDetector: ObservableObject {
  @Published var isDetectingConflicts = false
  @Published var lastDetectionDate = Date()

  private let container: CKContainer
  private let privateDatabase: CKDatabase
  private let customZoneName = "SharedStudentsZone"

  init() {
    self.container = CKContainer(identifier: "iCloud.com.heiloprojects.rightrudder")
    self.privateDatabase = container.privateCloudDatabase
  }

  /// Detects conflicts between local student data and CloudKit version
  @MainActor
  func detectConflicts(for student: Student) async -> [DataConflict] {
    guard let cloudKitRecordID = student.cloudKitRecordID else {
      print("Cannot detect conflicts: No CloudKit record ID")
      return []
    }

    isDetectingConflicts = true

    do {
      // Access the record in the instructor's private database custom zone
      let customZoneID = CKRecordZone.ID(
        zoneName: customZoneName, ownerName: CKCurrentUserDefaultName)
      let recordID = CKRecord.ID(recordName: cloudKitRecordID, zoneID: customZoneID)
      let cloudKitRecord = try await privateDatabase.record(for: recordID)

      let conflicts = compareStudentData(localStudent: student, cloudKitRecord: cloudKitRecord)
      isDetectingConflicts = false
      lastDetectionDate = Date()
      return conflicts

    } catch {
      print("Failed to detect conflicts: \(error)")
      isDetectingConflicts = false
      return []
    }
  }

  private func compareStudentData(localStudent: Student, cloudKitRecord: CKRecord) -> [DataConflict]
  {
    var conflicts: [DataConflict] = []

    // Personal Information Fields
    conflicts.append(
      contentsOf: compareTextField(
        localValue: localStudent.firstName,
        cloudKitValue: cloudKitRecord["firstName"] as? String,
        fieldName: "firstName",
        displayName: "First Name"
      ))

    conflicts.append(
      contentsOf: compareTextField(
        localValue: localStudent.lastName,
        cloudKitValue: cloudKitRecord["lastName"] as? String,
        fieldName: "lastName",
        displayName: "Last Name"
      ))

    conflicts.append(
      contentsOf: compareTextField(
        localValue: localStudent.email,
        cloudKitValue: cloudKitRecord["email"] as? String,
        fieldName: "email",
        displayName: "Email"
      ))

    conflicts.append(
      contentsOf: compareTextField(
        localValue: localStudent.telephone,
        cloudKitValue: cloudKitRecord["telephone"] as? String,
        fieldName: "telephone",
        displayName: "Phone"
      ))

    conflicts.append(
      contentsOf: compareTextField(
        localValue: localStudent.homeAddress,
        cloudKitValue: cloudKitRecord["homeAddress"] as? String,
        fieldName: "homeAddress",
        displayName: "Home Address"
      ))

    conflicts.append(
      contentsOf: compareTextField(
        localValue: localStudent.ftnNumber,
        cloudKitValue: cloudKitRecord["ftnNumber"] as? String,
        fieldName: "ftnNumber",
        displayName: "FTN Number"
      ))

    conflicts.append(
      contentsOf: compareTextField(
        localValue: localStudent.biography,
        cloudKitValue: cloudKitRecord["biography"] as? String,
        fieldName: "biography",
        displayName: "Biography"
      ))

    conflicts.append(
      contentsOf: compareTextField(
        localValue: localStudent.backgroundNotes,
        cloudKitValue: cloudKitRecord["backgroundNotes"] as? String,
        fieldName: "backgroundNotes",
        displayName: "Background Notes"
      ))

    conflicts.append(
      contentsOf: compareTextField(
        localValue: localStudent.instructorName,
        cloudKitValue: cloudKitRecord["instructorName"] as? String,
        fieldName: "instructorName",
        displayName: "Instructor Name"
      ))

    conflicts.append(
      contentsOf: compareTextField(
        localValue: localStudent.instructorCFINumber,
        cloudKitValue: cloudKitRecord["instructorCFINumber"] as? String,
        fieldName: "instructorCFINumber",
        displayName: "CFI Number"
      ))

    // Training Goals
    conflicts.append(
      contentsOf: compareBooleanField(
        localValue: localStudent.goalPPL,
        cloudKitValue: cloudKitRecord["goalPPL"] as? Bool,
        fieldName: "goalPPL",
        displayName: "PPL Goal"
      ))

    conflicts.append(
      contentsOf: compareBooleanField(
        localValue: localStudent.goalInstrument,
        cloudKitValue: cloudKitRecord["goalInstrument"] as? Bool,
        fieldName: "goalInstrument",
        displayName: "Instrument Goal"
      ))

    conflicts.append(
      contentsOf: compareBooleanField(
        localValue: localStudent.goalCommercial,
        cloudKitValue: cloudKitRecord["goalCommercial"] as? Bool,
        fieldName: "goalCommercial",
        displayName: "Commercial Goal"
      ))

    conflicts.append(
      contentsOf: compareBooleanField(
        localValue: localStudent.goalCFI,
        cloudKitValue: cloudKitRecord["goalCFI"] as? Bool,
        fieldName: "goalCFI",
        displayName: "CFI Goal"
      ))

    // Training Milestones - PPL
    // Note: Ground school and written test completion are read-only for instructor
    // Student changes should always take precedence, no conflicts detected

    // Training Milestones - Instrument
    // Note: Ground school and written test completion are read-only for instructor
    // Student changes should always take precedence, no conflicts detected

    // Training Milestones - Commercial
    // Note: Ground school and written test completion are read-only for instructor
    // Student changes should always take precedence, no conflicts detected

    // Training Milestones - CFI
    // Note: Ground school and written test completion are read-only for instructor
    // Student changes should always take precedence, no conflicts detected

    return conflicts
  }

  private func compareTextField(
    localValue: String?,
    cloudKitValue: String?,
    fieldName: String,
    displayName: String
  ) -> [DataConflict] {
    let localString = localValue ?? ""
    let cloudKitString = cloudKitValue ?? ""

    if localString != cloudKitString {
      return [
        DataConflict(
          fieldName: fieldName,
          displayName: displayName,
          instructorValue: localString.isEmpty ? "Not set" : localString,
          studentValue: cloudKitString.isEmpty ? "Not set" : cloudKitString,
          studentModifiedDate: Date(),  // We'll get this from CloudKit record if needed
          fieldType: .text
        )
      ]
    }

    return []
  }

  private func compareBooleanField(
    localValue: Bool,
    cloudKitValue: Bool?,
    fieldName: String,
    displayName: String
  ) -> [DataConflict] {
    let cloudKitBool = cloudKitValue ?? false

    if localValue != cloudKitBool {
      return [
        DataConflict(
          fieldName: fieldName,
          displayName: displayName,
          instructorValue: localValue ? "Yes" : "No",
          studentValue: cloudKitBool ? "Yes" : "No",
          studentModifiedDate: Date(),  // We'll get this from CloudKit record if needed
          fieldType: .boolean
        )
      ]
    }

    return []
  }

  /// Checks if CloudKit has newer data than local
  @MainActor
  func hasNewerDataInCloudKit(for student: Student) async -> Bool {
    guard let cloudKitRecordID = student.cloudKitRecordID else {
      return false
    }

    do {
      // Access the record in the instructor's private database custom zone
      let customZoneID = CKRecordZone.ID(
        zoneName: customZoneName, ownerName: CKCurrentUserDefaultName)
      let recordID = CKRecord.ID(recordName: cloudKitRecordID, zoneID: customZoneID)
      let cloudKitRecord = try await privateDatabase.record(for: recordID)

      if let cloudKitLastModified = cloudKitRecord["lastModified"] as? Date {
        return cloudKitLastModified > student.lastModified
      }

    } catch {
      print("Failed to check for newer data: \(error)")
    }

    return false
  }
}
