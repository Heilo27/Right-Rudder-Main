//
//  ItemProgressData.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation

// MARK: - ItemProgressData

/// Data structure for ItemProgress in CloudKit records
struct ItemProgressData: Codable {
  let id: String  // UUID string
  let templateItemId: String  // Library UUID string (instructor's template item ID)
  let order: Int?  // Order position in checklist (for matching when IDs differ)
  let isComplete: Bool
  let notes: String?
  let completedAt: Date?
  let lastModified: Date
}

