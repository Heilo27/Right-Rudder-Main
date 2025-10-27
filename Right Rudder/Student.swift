import Foundation
import SwiftData
import CloudKit

@Model
class EndorsementImage {
    var id: UUID = UUID()
    var filename: String = ""
    var createdAt: Date = Date()
    var imageData: Data?
    
    // CloudKit sync attributes
    var cloudKitRecordID: String?
    var lastModified: Date = Date()
    
    // Inverse relationship
    var student: Student?
    
    init(filename: String, imageData: Data? = nil) {
        self.filename = filename
        self.imageData = imageData
        self.lastModified = Date()
    }
}

@Model
class StudentChecklistItem {
    var id: UUID = UUID()
    var templateItemId: UUID = UUID()
    var title: String = ""
    var isComplete: Bool = false
    var notes: String?
    var completedAt: Date?
    var order: Int = 0
    
    // CloudKit sync attributes
    var cloudKitRecordID: String?
    var lastModified: Date = Date()
    
    // Inverse relationship
    var checklist: StudentChecklist?
    
    init(templateItemId: UUID, title: String, notes: String? = nil, order: Int = 0) {
        self.templateItemId = templateItemId
        self.title = title
        self.notes = notes
        self.order = order
        self.lastModified = Date()
    }
}

@Model
class StudentChecklist {
    var id: UUID = UUID()
    var templateId: UUID = UUID()
    var templateName: String = ""
    @Relationship(deleteRule: .cascade, inverse: \StudentChecklistItem.checklist) var items: [StudentChecklistItem]?
    var instructorComments: String?
    var dualGivenHours: Double = 0.0
    
    // Template version tracking for automatic updates
    var templateVersion: String? // Track which template version this checklist is based on
    var templateIdentifier: String? // For reliable matching to default templates
    
    // CloudKit sync attributes
    var cloudKitRecordID: String?
    var lastModified: Date = Date()
    
    // Inverse relationship
    var student: Student?
    
    init(templateId: UUID, templateName: String, items: [StudentChecklistItem]? = nil) {
        self.templateId = templateId
        self.templateName = templateName
        self.items = items
        self.lastModified = Date()
    }
}

@Model
class Student {
    var id: UUID = UUID()
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var telephone: String = ""
    var homeAddress: String = ""
    var ftnNumber: String = ""
    var biography: String?
    var backgroundNotes: String?
    var profilePhotoData: Data?
    var createdAt: Date = Date()
    var customOrder: Int = 0  // For manual sorting
    var assignedCategory: String? = nil  // Manual category assignment
    var isInactive: Bool = false  // Inactive student status
    
    // Instructor information (entered by student in companion app)
    var instructorName: String?
    var instructorCFINumber: String?
    
    // Training goals (synced from student app - read-only in instructor app)
    var goalPPL: Bool = false
    var goalInstrument: Bool = false
    var goalCommercial: Bool = false
    var goalCFI: Bool = false
    
    // Training milestones - PPL
    var pplGroundSchoolCompleted: Bool = false
    var pplWrittenTestCompleted: Bool = false
    
    // Training milestones - Instrument
    var instrumentGroundSchoolCompleted: Bool = false
    var instrumentWrittenTestCompleted: Bool = false
    
    // Training milestones - Commercial
    var commercialGroundSchoolCompleted: Bool = false
    var commercialWrittenTestCompleted: Bool = false
    
    // Training milestones - CFI
    var cfiGroundSchoolCompleted: Bool = false
    var cfiWrittenTestCompleted: Bool = false
    
    // CloudKit sync attributes
    var cloudKitRecordID: String?
    var shareRecordID: String?  // CKShare record ID for companion app access
    var lastModified: Date = Date()
    
    @Relationship(deleteRule: .cascade, inverse: \StudentChecklist.student) var checklists: [StudentChecklist]?
    @Relationship(deleteRule: .cascade, inverse: \EndorsementImage.student) var endorsements: [EndorsementImage]?
    @Relationship(deleteRule: .cascade, inverse: \StudentDocument.student) var documents: [StudentDocument]?
    
    var displayName: String { "\(firstName) \(lastName)" }
    
    // Optimized computed property for sorting
    var sortKey: String { "\(lastName), \(firstName)" }
    
    var totalDualGivenHours: Double {
        checklists?.reduce(0.0) { $0 + $1.dualGivenHours } ?? 0.0
    }
    
    // Determine primary training category - use manual assignment if set, otherwise default to PPL
    var primaryCategory: String {
        return assignedCategory ?? "PPL"
    }
    
    // Helper function to determine category from template name
    private func getCategoryFromTemplateName(_ templateName: String) -> String {
        let name = templateName.lowercased()
        
        if name.contains("ppl") || name.contains("private") || name.contains("phase 1") || name.contains("phase 2") || name.contains("phase 3") || name.contains("phase 4") || name.contains("pre-solo") || name.contains("solo") {
            return "PPL"
        } else if name.contains("ifr") || name.contains("instrument") {
            return "IFR"
        } else if name.contains("cpl") || name.contains("commercial") {
            return "CPL"
        } else if name.contains("cfi") || name.contains("instructor") {
            return "CFI"
        } else if name.contains("review") {
            return "Review"
        }
        
        return "PPL" // Default fallback
    }
    
    // Calculate progress for a specific category
    func progressForCategory(_ category: String) -> Double {
        guard let checklists = checklists else { return 0.0 }
        
        let categoryChecklists = checklists.filter { checklist in
            getCategoryFromTemplateName(checklist.templateName) == category
        }
        
        guard !categoryChecklists.isEmpty else { return 0.0 }
        
        var totalItems = 0
        var completedItems = 0
        
        for checklist in categoryChecklists {
            guard let items = checklist.items else { continue }
            totalItems += items.count
            completedItems += items.filter { $0.isComplete }.count
        }
        
        guard totalItems > 0 else { return 0.0 }
        return Double(completedItems) / Double(totalItems)
    }
    
    // Get all categories this student has checklists for
    var enrolledCategories: [String] {
        guard let checklists = checklists else { return [] }
        
        var categories = Set<String>()
        
        for checklist in checklists {
            let category = getCategoryFromTemplateName(checklist.templateName)
            categories.insert(category)
        }
        
        // If no categories found from templates, use assigned category
        if categories.isEmpty, let assigned = assignedCategory {
            categories.insert(assigned)
        }
        
        return Array(categories).sorted()
    }
    
    // Get primary progress (for the main category)
    var primaryProgress: Double {
        return progressForCategory(primaryCategory)
    }
    
    // Get the current active category (lowest incomplete category)
    var currentActiveCategory: String? {
        guard let checklists = checklists else { return nil }
        
        // Define category hierarchy (lowest to highest)
        let categoryHierarchy = ["PPL", "IFR", "CPL", "CFI", "Review"]
        
        var enrolledCategories = Set<String>()
        
        for checklist in checklists {
            let category = getCategoryFromTemplateName(checklist.templateName)
            enrolledCategories.insert(category)
        }
        
        // If no categories found from templates, use assigned category
        if enrolledCategories.isEmpty, let assigned = assignedCategory {
            enrolledCategories.insert(assigned)
        }
        
        // Special case: if only Review category, show it regardless of completion
        if enrolledCategories.count == 1 && enrolledCategories.contains("Review") {
            return "Review"
        }
        
        // Find the lowest incomplete category
        for category in categoryHierarchy {
            if enrolledCategories.contains(category) {
                let progress = progressForCategory(category)
                if progress < 1.0 { // Not 100% complete
                    return category
                }
            }
        }
        
        // If all categories are 100% complete, return the highest one
        for category in categoryHierarchy.reversed() {
            if enrolledCategories.contains(category) {
                return category
            }
        }
        
        return nil
    }
    
    // Get progress for the current active category
    var currentActiveProgress: Double {
        guard let category = currentActiveCategory else { return 0.0 }
        return progressForCategory(category)
    }
    
    init(firstName: String, lastName: String, email: String, telephone: String, homeAddress: String, ftnNumber: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.telephone = telephone
        self.homeAddress = homeAddress
        self.ftnNumber = ftnNumber
        self.lastModified = Date()
        // Don't initialize relationships here - let SwiftData handle them
    }
}