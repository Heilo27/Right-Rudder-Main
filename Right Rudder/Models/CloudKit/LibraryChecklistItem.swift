//
//  LibraryChecklistItem.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation

// MARK: - LibraryChecklistItem

struct LibraryChecklistItem: Codable, Identifiable {
  let id: UUID
  let title: String
  let notes: String?
  let order: Int

  enum CodingKeys: String, CodingKey {
    case id, title, notes, order
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let idString = try container.decode(String.self, forKey: .id)
    guard let id = UUID(uuidString: idString) else {
      throw DecodingError.dataCorruptedError(
        forKey: .id, in: container, debugDescription: "Invalid UUID string")
    }
    self.id = id
    self.title = try container.decode(String.self, forKey: .title)
    self.notes = try container.decodeIfPresent(String.self, forKey: .notes)
    self.order = try container.decode(Int.self, forKey: .order)
  }
}

