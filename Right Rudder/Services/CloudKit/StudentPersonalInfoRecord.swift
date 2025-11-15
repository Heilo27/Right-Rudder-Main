//
//  StudentPersonalInfoRecord.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import CloudKit
import Foundation

// MARK: - StudentPersonalInfoRecord

/// StudentPersonalInfo record structure for CloudKit
/// Contains name, address, email, phone, FTN, photo, required documents
/// Both read/write, last-write-wins conflict resolution
struct StudentPersonalInfoRecord {
  // MARK: - Properties

  static let recordType = "StudentPersonalInfo"

  let studentId: String  // UUID string
  let firstName: String
  let lastName: String
  let email: String
  let telephone: String
  let homeAddress: String
  let ftnNumber: String
  let profilePhotoData: Data?
  let documents: [DocumentData]
  let lastModified: Date
  let lastModifiedBy: String  // "instructor" or "student"

  // MARK: - Methods

  func toCKRecord(recordID: CKRecord.ID) -> CKRecord {
    let record = CKRecord(recordType: Self.recordType, recordID: recordID)
    record["studentId"] = studentId
    record["firstName"] = firstName
    record["lastName"] = lastName
    record["email"] = email
    record["telephone"] = telephone
    record["homeAddress"] = homeAddress
    record["ftnNumber"] = ftnNumber
    record["profilePhotoData"] = profilePhotoData
    record["lastModified"] = lastModified
    record["lastModifiedBy"] = lastModifiedBy

    // Encode documents as JSON
    if let jsonData = try? JSONEncoder().encode(documents),
      let jsonString = String(data: jsonData, encoding: .utf8)
    {
      record["documents"] = jsonString
    }

    return record
  }

  static func fromCKRecord(_ record: CKRecord) -> StudentPersonalInfoRecord? {
    guard let studentId = record["studentId"] as? String,
      let firstName = record["firstName"] as? String,
      let lastName = record["lastName"] as? String,
      let email = record["email"] as? String,
      let telephone = record["telephone"] as? String,
      let homeAddress = record["homeAddress"] as? String,
      let ftnNumber = record["ftnNumber"] as? String,
      let lastModified = record["lastModified"] as? Date,
      let lastModifiedBy = record["lastModifiedBy"] as? String
    else {
      return nil
    }

    var documents: [DocumentData] = []
    if let jsonString = record["documents"] as? String,
      let jsonData = jsonString.data(using: .utf8),
      let decoded = try? JSONDecoder().decode([DocumentData].self, from: jsonData)
    {
      documents = decoded
    }

    return StudentPersonalInfoRecord(
      studentId: studentId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      telephone: telephone,
      homeAddress: homeAddress,
      ftnNumber: ftnNumber,
      profilePhotoData: record["profilePhotoData"] as? Data,
      documents: documents,
      lastModified: lastModified,
      lastModifiedBy: lastModifiedBy
    )
  }
}

