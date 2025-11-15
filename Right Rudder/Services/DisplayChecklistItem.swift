//
//  DisplayChecklistItem.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation

// MARK: - DisplayChecklistItem

/// Helper struct for display
struct DisplayChecklistItem {
  let templateItemId: UUID
  let title: String
  let notes: String?
  let order: Int
  let isComplete: Bool
  let studentNotes: String?
  let completedAt: Date?
}

