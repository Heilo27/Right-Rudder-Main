//
//  ChecklistItem.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import CloudKit
import Foundation
import SwiftData

// MARK: - ChecklistItem Model

@Model
class ChecklistItem {
  var id: UUID = UUID()
  var title: String = ""
  var notes: String?
  var order: Int = 0

  // CloudKit sync attributes
  var cloudKitRecordID: String?
  var lastModified: Date = Date()

  // MARK: - Relationships

  // Inverse relationship
  var template: ChecklistTemplate?

  // MARK: - Initialization

  init(title: String, notes: String? = nil, order: Int = 0) {
    self.title = title
    self.notes = notes
    self.order = order
    self.lastModified = Date()
  }
}

