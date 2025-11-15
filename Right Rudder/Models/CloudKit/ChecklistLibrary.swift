//
//  ChecklistLibrary.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation

// MARK: - ChecklistLibrary

struct ChecklistLibrary: Codable {
  let version: String
  let checklists: [LibraryChecklist]
}

