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