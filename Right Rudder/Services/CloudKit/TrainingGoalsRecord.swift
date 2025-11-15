//
//  TrainingGoalsRecord.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import CloudKit
import Foundation

// MARK: - TrainingGoalsRecord

/// TrainingGoals record structure for CloudKit
/// Contains training goal selections, ground school, written test completions
/// Student read/write, Instructor read-only
struct TrainingGoalsRecord {
  // MARK: - Properties

  static let recordType = "TrainingGoals"

  let studentId: String  // UUID string
  let goalPPL: Bool
  let goalInstrument: Bool
  let goalCommercial: Bool
  let goalCFI: Bool
  let pplGroundSchoolCompleted: Bool
  let pplWrittenTestCompleted: Bool
  let instrumentGroundSchoolCompleted: Bool
  let instrumentWrittenTestCompleted: Bool
  let commercialGroundSchoolCompleted: Bool
  let commercialWrittenTestCompleted: Bool
  let cfiGroundSchoolCompleted: Bool
  let cfiWrittenTestCompleted: Bool
  let lastModified: Date

  // MARK: - Methods

  func toCKRecord(recordID: CKRecord.ID) -> CKRecord {
    let record = CKRecord(recordType: Self.recordType, recordID: recordID)
    record["studentId"] = studentId
    record["goalPPL"] = goalPPL
    record["goalInstrument"] = goalInstrument
    record["goalCommercial"] = goalCommercial
    record["goalCFI"] = goalCFI
    record["pplGroundSchoolCompleted"] = pplGroundSchoolCompleted
    record["pplWrittenTestCompleted"] = pplWrittenTestCompleted
    record["instrumentGroundSchoolCompleted"] = instrumentGroundSchoolCompleted
    record["instrumentWrittenTestCompleted"] = instrumentWrittenTestCompleted
    record["commercialGroundSchoolCompleted"] = commercialGroundSchoolCompleted
    record["commercialWrittenTestCompleted"] = commercialWrittenTestCompleted
    record["cfiGroundSchoolCompleted"] = cfiGroundSchoolCompleted
    record["cfiWrittenTestCompleted"] = cfiWrittenTestCompleted
    record["lastModified"] = lastModified
    return record
  }

  static func fromCKRecord(_ record: CKRecord) -> TrainingGoalsRecord? {
    guard let studentId = record["studentId"] as? String,
      let lastModified = record["lastModified"] as? Date
    else {
      return nil
    }

    return TrainingGoalsRecord(
      studentId: studentId,
      goalPPL: record["goalPPL"] as? Bool ?? false,
      goalInstrument: record["goalInstrument"] as? Bool ?? false,
      goalCommercial: record["goalCommercial"] as? Bool ?? false,
      goalCFI: record["goalCFI"] as? Bool ?? false,
      pplGroundSchoolCompleted: record["pplGroundSchoolCompleted"] as? Bool ?? false,
      pplWrittenTestCompleted: record["pplWrittenTestCompleted"] as? Bool ?? false,
      instrumentGroundSchoolCompleted: record["instrumentGroundSchoolCompleted"] as? Bool ?? false,
      instrumentWrittenTestCompleted: record["instrumentWrittenTestCompleted"] as? Bool ?? false,
      commercialGroundSchoolCompleted: record["commercialGroundSchoolCompleted"] as? Bool ?? false,
      commercialWrittenTestCompleted: record["commercialWrittenTestCompleted"] as? Bool ?? false,
      cfiGroundSchoolCompleted: record["cfiGroundSchoolCompleted"] as? Bool ?? false,
      cfiWrittenTestCompleted: record["cfiWrittenTestCompleted"] as? Bool ?? false,
      lastModified: lastModified
    )
  }
}

