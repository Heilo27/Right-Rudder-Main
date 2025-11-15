//
//  CustomChecklistItem.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation
import SwiftData

// MARK: - CustomChecklistItem Model

@Model
class CustomChecklistItem {
  var id: UUID = UUID()
  var title: String = ""
  var notes: String?
  var order: Int = 0

  // Relationship
  var definition: CustomChecklistDefinition?

  init(id: UUID = UUID(), title: String, notes: String? = nil, order: Int) {
    self.id = id
    self.title = title
    self.notes = notes
    self.order = order
  }
}
