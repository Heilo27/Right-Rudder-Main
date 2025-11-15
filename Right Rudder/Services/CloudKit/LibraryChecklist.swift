//
//  LibraryChecklist.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation

// MARK: - LibraryChecklist

/// Library Models (for resolving student app library IDs)
struct LibraryChecklist: Codable, Identifiable {
  let id: UUID
  let name: String
  let category: String
  let items: [LibraryChecklistItem]
  let templateIdentifier: String?

  enum CodingKeys: String, CodingKey {
    case id, name, category, items, templateIdentifier
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let idString = try container.decode(String.self, forKey: .id)
    guard let id = UUID(uuidString: idString) else {
      throw DecodingError.dataCorruptedError(
        forKey: .id, in: container, debugDescription: "Invalid UUID string")
    }
    self.id = id
    self.name = try container.decode(String.self, forKey: .name)
    self.category = try container.decode(String.self, forKey: .category)
    self.items = try container.decode([LibraryChecklistItem].self, forKey: .items)
    self.templateIdentifier = try container.decodeIfPresent(
      String.self, forKey: .templateIdentifier)
  }
}

