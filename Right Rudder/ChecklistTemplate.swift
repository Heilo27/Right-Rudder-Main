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

// MARK: - ChecklistTemplate Model

@Model
class ChecklistTemplate {
  var id: UUID = UUID()
  var name: String = ""
  var category: String = ""  // PPL, Instrument, Commercial
  var phase: String?  // Phase 1, Phase 1.5 Pre-Solo/Solo, Phase 2, Phase 3, Phase 4
  var relevantData: String?  // Optional field for lesson study materials or reference data
  @Relationship(deleteRule: .cascade, inverse: \ChecklistItem.template) var items: [ChecklistItem]?
  var createdAt: Date = Date()

  // MARK: - Template Tracking

  // Template tracking
  var isUserCreated: Bool = false  // True if created by user (not default)
  var isUserModified: Bool = false  // True if user edited a default template
  var originalAuthor: String?  // Name of instructor who created it
  var templateIdentifier: String?  // Unique identifier for default templates (e.g., "default_p1_l1")
  var contentHash: String?  // NEW: Integrity verification hash

  // MARK: - Relationships

  // NEW: Track which students have this template assigned
  @Relationship(deleteRule: .nullify, inverse: \ChecklistAssignment.template)
  var studentAssignments: [ChecklistAssignment]?

  // MARK: - CloudKit Sync Attributes

  // CloudKit sync attributes
  var cloudKitRecordID: String?
  var shareRecordID: String?  // For sharing templates to student app
  var lastModified: Date = Date()

  // MARK: - Initialization

  init(
    name: String, category: String, phase: String? = nil, relevantData: String? = nil,
    templateIdentifier: String? = nil, items: [ChecklistItem]? = nil
  ) {
    self.name = name
    self.category = category
    self.phase = phase
    self.relevantData = relevantData
    self.templateIdentifier = templateIdentifier
    self.items = items
    self.lastModified = Date()

    // Ensure all items have their template relationship set
    if let items = items {
      for item in items {
        item.template = self
      }
    }

    // Compute initial content hash
    self.contentHash = computeContentHash()
  }

  // MARK: - Content Hash Management

  // NEW: Compute content hash for integrity verification
  func computeContentHash() -> String {
    let itemTitles = (items ?? []).map { $0.title }.joined(separator: "|")
    let content = "\(name)|\(itemTitles)|\(items?.count ?? 0)"
    return content.hash.description
  }

  // NEW: Update content hash when template changes
  func updateContentHash() {
    self.contentHash = computeContentHash()
    self.lastModified = Date()
  }
}
