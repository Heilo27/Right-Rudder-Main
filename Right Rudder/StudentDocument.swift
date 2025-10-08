import Foundation
import SwiftData
import CloudKit

enum DocumentType: String, Codable, CaseIterable {
    case studentPilotCertificate = "Student Pilot Certificate"
    case medicalCertificate = "Medical Certificate"
    case passportBirthCertificate = "Passport/Birth Certificate"
    case logBook = "LogBook"
    
    var icon: String {
        switch self {
        case .studentPilotCertificate: return "airplane.circle"
        case .medicalCertificate: return "heart.text.square"
        case .passportBirthCertificate: return "person.text.rectangle"
        case .logBook: return "book.closed"
        }
    }
    
    var isOptional: Bool {
        return self == .logBook
    }
}

@Model
class StudentDocument {
    var id: UUID = UUID()
    var documentTypeRaw: String = DocumentType.studentPilotCertificate.rawValue
    var filename: String = ""
    var fileData: Data?
    var uploadedAt: Date = Date()
    var expirationDate: Date?
    var notes: String?
    
    // CloudKit sync attributes
    var cloudKitRecordID: String?
    var lastModified: Date = Date()
    
    // Inverse relationship
    var student: Student?
    
    var documentType: DocumentType {
        get { DocumentType(rawValue: documentTypeRaw) ?? .studentPilotCertificate }
        set { documentTypeRaw = newValue.rawValue }
    }
    
    init(documentType: DocumentType, filename: String, fileData: Data? = nil, expirationDate: Date? = nil, notes: String? = nil) {
        self.documentTypeRaw = documentType.rawValue
        self.filename = filename
        self.fileData = fileData
        self.expirationDate = expirationDate
        self.notes = notes
        self.lastModified = Date()
    }
}

