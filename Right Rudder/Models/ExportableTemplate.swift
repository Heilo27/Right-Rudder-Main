//
//  ExportableTemplate.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation

// MARK: - ExportableTemplate

/// Codable struct for template export/import
struct ExportableTemplate: Codable {
  // MARK: - Properties

  let id: String
  let name: String
  let category: String
  let phase: String?
  let relevantData: String?
  let items: [ExportableTemplateItem]
  let isUserCreated: Bool
  let isUserModified: Bool
  let originalAuthor: String?
  let createdAt: Date
  let lastModified: Date
}

