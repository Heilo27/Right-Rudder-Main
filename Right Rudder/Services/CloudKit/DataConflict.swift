//
//  DataConflict.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation

// MARK: - DataConflict

struct DataConflict: Identifiable {
  // MARK: - Properties

  let id = UUID()
  let fieldName: String
  let displayName: String
  let instructorValue: String
  let studentValue: String
  let studentModifiedDate: Date
  let fieldType: ConflictFieldType

  // MARK: - ConflictFieldType

  enum ConflictFieldType {
    case text
    case boolean
    case date
  }
}

