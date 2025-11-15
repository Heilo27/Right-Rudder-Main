//
//  EndorsementImage.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import CloudKit
import Foundation
import SwiftData

// MARK: - EndorsementImage

@Model
class EndorsementImage {
  // MARK: - Properties

  var id: UUID = UUID()
  var filename: String = ""
  var createdAt: Date = Date()
  var imageData: Data?

  // Endorsement metadata
  var endorsementCode: String?  // FAA endorsement code (e.g., "A.1", "A.6")
  var expirationDate: Date?  // Expiration date for endorsements with expiration

  // CloudKit sync attributes
  var cloudKitRecordID: String?
  var lastModified: Date = Date()

  // Inverse relationship
  var student: Student?

  // MARK: - Initialization

  init(
    filename: String, imageData: Data? = nil, endorsementCode: String? = nil,
    expirationDate: Date? = nil
  ) {
    self.filename = filename
    self.imageData = imageData
    self.endorsementCode = endorsementCode
    self.expirationDate = expirationDate
    self.lastModified = Date()
  }
}

