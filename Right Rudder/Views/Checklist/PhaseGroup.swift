//
//  PhaseGroup.swift
//  Right Rudder
//
//  Created by AI on 10/2/25.
//

import SwiftData
import SwiftUI

// MARK: - PhaseGroup

struct PhaseGroup: Identifiable {
  // MARK: - Properties

  let id: String  // Use phase as the identifier
  let phase: String
  let templates: [ChecklistTemplate]

  // MARK: - Initialization

  init(phase: String, templates: [ChecklistTemplate]) {
    self.id = phase
    self.phase = phase
    self.templates = templates
  }
}

