import Foundation

struct EndorsementImage: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var filename: String
    var createdAt: Date = Date()
}

struct StudentChecklistItem: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var templateItemId: UUID
    var title: String
    var isComplete: Bool = false
    var notes: String?
    var completedAt: Date?
}

struct StudentChecklist: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var templateId: UUID
    var templateName: String
    var items: [StudentChecklistItem]
}

struct Student: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var firstName: String
    var lastName: String
    var email: String
    var phone: String
    var address: String
    var biography: String?
    var backgroundNotes: String?

    var checklists: [StudentChecklist] = []
    var endorsements: [EndorsementImage] = []

    var displayName: String { "\(firstName) \(lastName)" }
}



