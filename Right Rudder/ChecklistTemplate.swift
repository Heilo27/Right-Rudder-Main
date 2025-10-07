import Foundation

struct ChecklistItem: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String
    var notes: String?
}

struct ChecklistTemplate: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var items: [ChecklistItem]
}



