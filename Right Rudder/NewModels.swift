//
//  NewModels.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation
import SwiftData
import CloudKit

// MARK: - New Library-Based Architecture Models (Same as Student App)

@Model
class ChecklistAssignment {
    var id: UUID = UUID()
    var templateId: UUID = UUID()  // References library checklist
    var templateIdentifier: String?  // Fallback for custom
    var isCustomChecklist: Bool = false  // True if user-created
    
    // MARK: - Instructor-Owned Fields (Read-Only for Student)
    // These fields are written by instructor app, read-only in student app
    var instructorComments: String?  // INSTRUCTOR → STUDENT (read-only for student)
    var dualGivenHours: Double = 0.0  // INSTRUCTOR → STUDENT (read-only for student)
    var assignedAt: Date = Date()
    var lastModified: Date = Date()
    
    // Progress tracking
    @Relationship(deleteRule: .cascade, inverse: \ItemProgress.assignment) var itemProgress: [ItemProgress]?
    
    // CloudKit sync
    var cloudKitRecordID: String?
    
    // Relationships
    var student: Student?
    
    init(templateId: UUID, templateIdentifier: String? = nil, isCustomChecklist: Bool = false) {
        self.templateId = templateId
        self.templateIdentifier = templateIdentifier
        self.isCustomChecklist = isCustomChecklist
        self.lastModified = Date()
    }
    
    // Computed properties for easy access
    var progressPercentage: Double {
        let total = totalItemsCount
        guard total > 0 else { return 0.0 }
        let completed = completedItemsCount
        return Double(completed) / Double(total)
    }
    
    var completedItemsCount: Int {
        return itemProgress?.filter { $0.isComplete }.count ?? 0
    }
    
    var totalItemsCount: Int {
        // First try to get count from itemProgress records
        if let progressItems = itemProgress, !progressItems.isEmpty {
            return progressItems.count
        }
        
        // Fallback to template's item count if itemProgress is empty/nil
        // This handles cases where items haven't been synced yet or assignment is incomplete
        if let template = template, let templateItems = template.items {
            return templateItems.count
        }
        
        return 0
    }
    
    var isComplete: Bool {
        let total = totalItemsCount
        guard total > 0 else { return false }
        return progressPercentage >= 1.0
    }
    
    // CloudKit compatibility - generate display name
    var displayName: String {
        // Try to get name from template relationship
        if let template = template {
            return template.name
        }
        
        // Fallback to templateIdentifier if available
        if let identifier = templateIdentifier, !identifier.isEmpty {
            return identifier.replacingOccurrences(of: "_", with: " ").capitalized
        }
        
        return "Unknown Checklist"
    }
    
    // Relationship to template (for instructor app)
    var template: ChecklistTemplate?
}

@Model
class ItemProgress {
    var id: UUID = UUID()
    var templateItemId: UUID = UUID()  // References library item
    
    // MARK: - Instructor-Owned Fields (Read-Only for Student)
    // These fields are written by instructor app, read-only in student app
    var isComplete: Bool = false  // INSTRUCTOR → STUDENT (read-only for student)
    var notes: String?  // INSTRUCTOR → STUDENT (read-only for student - instructor comments)
    var completedAt: Date?
    var lastModified: Date = Date()
    
    // CloudKit sync
    var cloudKitRecordID: String?
    
    // Relationship
    var assignment: ChecklistAssignment?
    
    init(templateItemId: UUID) {
        self.templateItemId = templateItemId
        self.lastModified = Date()
    }
    
    // CloudKit compatibility - generate display title
    var displayTitle: String {
        // This will be populated from the template item when syncing
        return "Item \(id.uuidString.prefix(8))" // Fallback title
    }
}

@Model
class CustomChecklistDefinition {
    var id: UUID = UUID()  // Same as templateId
    var customName: String = ""
    var customCategory: String?
    var customItems: [CustomChecklistItem]?
    var cloudKitRecordID: String?
    var lastModified: Date = Date()
    
    init(id: UUID, customName: String, customCategory: String?) {
        self.id = id
        self.customName = customName
        self.customCategory = customCategory
        self.lastModified = Date()
    }
}

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
