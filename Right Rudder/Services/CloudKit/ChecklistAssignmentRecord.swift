//
//  ChecklistAssignmentRecord.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import CloudKit
import Foundation

// MARK: - ChecklistAssignmentRecord

/// ChecklistAssignment record structure for CloudKit
/// Contains lesson assignments with progress (checked items, dual hours, instructor notes)
/// Instructor read/write, Student read-only
struct ChecklistAssignmentRecord {
  // MARK: - Properties

  static let recordType = "ChecklistAssignment"

  let assignmentId: String  // UUID string
  let templateId: String  // Library UUID string
  let templateIdentifier: String?
  let isCustomChecklist: Bool
  let instructorComments: String?
  let dualGivenHours: Double
  let assignedAt: Date
  let lastModified: Date
  let itemProgress: [ItemProgressData]  // All progress items encoded as JSON

  // MARK: - Methods

  func toCKRecord(recordID: CKRecord.ID) -> CKRecord {
    let record = CKRecord(recordType: Self.recordType, recordID: recordID)
    record["assignmentId"] = assignmentId
    record["templateId"] = templateId
    record["templateIdentifier"] = templateIdentifier
    record["isCustomChecklist"] = isCustomChecklist
    record["instructorComments"] = instructorComments
    record["dualGivenHours"] = dualGivenHours
    record["assignedAt"] = assignedAt
    record["lastModified"] = lastModified

    // Encode itemProgress as JSON
    if let jsonData = try? JSONEncoder().encode(itemProgress),
      let jsonString = String(data: jsonData, encoding: .utf8)
    {
      record["itemProgress"] = jsonString
    }

    return record
  }

  static func fromCKRecord(_ record: CKRecord) -> ChecklistAssignmentRecord? {
    guard let assignmentId = record["assignmentId"] as? String,
      let templateId = record["templateId"] as? String,
      let assignedAt = record["assignedAt"] as? Date,
      let lastModified = record["lastModified"] as? Date
    else {
      return nil
    }

    var itemProgress: [ItemProgressData] = []
    if let jsonString = record["itemProgress"] as? String,
      let jsonData = jsonString.data(using: .utf8),
      let decoded = try? JSONDecoder().decode([ItemProgressData].self, from: jsonData)
    {
      itemProgress = decoded
    }

    return ChecklistAssignmentRecord(
      assignmentId: assignmentId,
      templateId: templateId,
      templateIdentifier: record["templateIdentifier"] as? String,
      isCustomChecklist: record["isCustomChecklist"] as? Bool ?? false,
      instructorComments: record["instructorComments"] as? String,
      dualGivenHours: record["dualGivenHours"] as? Double ?? 0.0,
      assignedAt: assignedAt,
      lastModified: lastModified,
      itemProgress: itemProgress
    )
  }
}

