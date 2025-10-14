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
    
    // Instructor information (entered by student in companion app)
    var instructorName: String?
    var instructorCFINumber: String?
    
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
    
    // Determine primary training category based on checklists
    var primaryCategory: String {
        guard let checklists = checklists, !checklists.isEmpty else { return "PPL" }
        
        // Count categories from all checklists based on template names
        var categoryCounts: [String: Int] = [:]
        
        for checklist in checklists {
            let templateName = checklist.templateName.lowercased()
            
            // More comprehensive pattern matching for better categorization
            if templateName.contains("instrument") || templateName.contains("ifr") || 
               templateName.contains("ils") || templateName.contains("vor") || 
               templateName.contains("gps") || templateName.contains("ndb") ||
               templateName.contains("approach") || templateName.contains("holding") ||
               templateName.contains("cross country") || templateName.contains("p4l") ||
               templateName.contains("p5l") || templateName.contains("p1l") ||
               templateName.contains("p2l") || templateName.contains("p3l") {
                categoryCounts["Instrument", default: 0] += 1
            } else if templateName.contains("commercial") || templateName.contains("cpl") {
                categoryCounts["Commercial", default: 0] += 1
            } else if templateName.contains("review") || templateName.contains("flight review") ||
                      templateName.contains("biannual") || templateName.contains("biennial") ||
                      templateName.contains("ipc") || templateName.contains("proficiency") {
                categoryCounts["Reviews", default: 0] += 1
            } else if templateName.contains("ppl") || templateName.contains("private pilot") ||
                      templateName.contains("solo") || templateName.contains("cross country") ||
                      templateName.contains("maneuver") || templateName.contains("landing") ||
                      templateName.contains("takeoff") || templateName.contains("stall") ||
                      templateName.contains("emergency") || templateName.contains("night") ||
                      templateName.contains("phase 1") || templateName.contains("phase 2") ||
                      templateName.contains("phase 3") || templateName.contains("phase 4") {
                categoryCounts["PPL", default: 0] += 1
            } else {
                // Default to PPL for unrecognized templates
                categoryCounts["PPL", default: 0] += 1
            }
        }
        
        // Return the category with the most checklists, default to PPL if tied
        let maxCategory = categoryCounts.max(by: { $0.value < $1.value })?.key ?? "PPL"
        return maxCategory
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