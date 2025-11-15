//
//  DocumentData.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation

// MARK: - DocumentData

/// Document data structure for CloudKit
struct DocumentData: Codable {
  let id: String  // UUID string
  let documentType: String  // DocumentType rawValue
  let filename: String
  let fileData: Data?
  let notes: String?
  let uploadedAt: Date
  let expirationDate: Date?
  let lastModified: Date
  let lastModifiedBy: String?  // "instructor" or "student"
}

