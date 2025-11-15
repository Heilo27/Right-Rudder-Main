//
//  CustomChecklistDefinition.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation
import SwiftData

// MARK: - CustomChecklistDefinition Model

@Model
class CustomChecklistDefinition {
  // MARK: - Properties

  var id: UUID = UUID()  // Same as templateId
  var customName: String = ""
  var customCategory: String?
  var customItems: [CustomChecklistItem]?
  var cloudKitRecordID: String?
  var lastModified: Date = Date()

  // MARK: - Initialization

  init(id: UUID, customName: String, customCategory: String?) {
    self.id = id
    self.customName = customName
    self.customCategory = customCategory
    self.lastModified = Date()
  }
}
