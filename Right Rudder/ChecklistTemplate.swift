import Foundation
import SwiftData
import CloudKit

@Model
class ChecklistItem {
    var id: UUID = UUID()
    var title: String = ""
    var notes: String?
    var order: Int = 0
    
    // CloudKit sync attributes
    var cloudKitRecordID: String?
    var lastModified: Date = Date()
    
    // Inverse relationship
    var template: ChecklistTemplate?
    
    init(title: String, notes: String? = nil, order: Int = 0) {
        self.title = title
        self.notes = notes
        self.order = order
        self.lastModified = Date()
    }
}

@Model
class ChecklistTemplate {
    var id: UUID = UUID()
    var name: String = ""
    var category: String = "" // PPL, Instrument, Commercial
    var phase: String? // Phase 1, Phase 2, Phase 3, Pre-Solo
    var relevantData: String? // Optional field for lesson study materials or reference data
    @Relationship(deleteRule: .cascade, inverse: \ChecklistItem.template) var items: [ChecklistItem]?
    var createdAt: Date = Date()
    
    // Template tracking
    var isUserCreated: Bool = false  // True if created by user (not default)
    var isUserModified: Bool = false  // True if user edited a default template
    var originalAuthor: String?  // Name of instructor who created it
    var templateIdentifier: String?  // Unique identifier for default templates (e.g., "default_p1_l1")
    
    // CloudKit sync attributes
    var cloudKitRecordID: String?
    var lastModified: Date = Date()
    
    init(name: String, category: String, phase: String? = nil, relevantData: String? = nil, templateIdentifier: String? = nil, items: [ChecklistItem]? = nil) {
        self.name = name
        self.category = category
        self.phase = phase
        self.relevantData = relevantData
        self.templateIdentifier = templateIdentifier
        self.items = items
        self.lastModified = Date()
    }
}



