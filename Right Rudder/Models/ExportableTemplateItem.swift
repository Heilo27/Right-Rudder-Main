//
//  ExportableTemplateItem.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation

// MARK: - ExportableTemplateItem

/// Codable struct for template item export/import
struct ExportableTemplateItem: Codable {
  // MARK: - Properties

  let id: String
  let title: String
  let notes: String?
}

