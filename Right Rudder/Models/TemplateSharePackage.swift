//
//  TemplateSharePackage.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation

// MARK: - TemplateSharePackage

/// Codable struct for template share package export/import
struct TemplateSharePackage: Codable {
  // MARK: - Properties

  let templates: [ExportableTemplate]
  let exportDate: Date
  let exportedBy: String?
  let appVersion: String
}

