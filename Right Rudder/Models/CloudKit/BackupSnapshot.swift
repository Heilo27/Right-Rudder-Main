//
//  BackupSnapshot.swift
//  Right Rudder
//
//  Created by AI on 12/19/25.
//

import Foundation

// MARK: - BackupSnapshot

// Backup snapshot model for restore selection
struct BackupSnapshot: Identifiable, Codable {
  // MARK: - Properties

  let id: String  // Date string "yyyy-MM-dd"
  let date: Date
  let studentCount: Int
  let templateCount: Int
  let size: Int64?  // Optional size in bytes
}

