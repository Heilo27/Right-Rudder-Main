//
//  MigrationStatus.swift
//  Right Rudder
//
//  Created by AI on 12/19/25.
//

import Foundation

// MARK: - MigrationStatus

struct MigrationStatus {
  // MARK: - Properties

  let totalStudents: Int
  let studentsWithOldChecklists: Int
  let studentsWithNewProgress: Int
  let studentsWithBoth: Int
  let needsMigration: Bool

  // MARK: - Computed Properties

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

