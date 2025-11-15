import CloudKit
import Foundation
import SwiftData

// MARK: - StudentDocument Model

@Model
class StudentDocument {
  var id: UUID = UUID()
  var documentTypeRaw: String = DocumentType.studentPilotCertificate.rawValue
  var filename: String = ""

  // MARK: - Bidirectional Fields (Last Write Wins)
  // Document data can be uploaded by both instructor and student apps
  var fileData: Data?  // BIDIRECTIONAL (last write wins)
  var notes: String?  // BIDIRECTIONAL (last write wins)

  var uploadedAt: Date = Date()
  var expirationDate: Date?

  // MARK: - CloudKit Sync Attributes

  // CloudKit sync attributes
  var cloudKitRecordID: String?
  var lastModified: Date = Date()
  var lastModifiedBy: String?  // Tracks who last modified: "instructor" or "student"

  // MARK: - Relationships

  // Inverse relationship
  var student: Student?

  // MARK: - Computed Properties

  var documentType: DocumentType {
    get { DocumentType(rawValue: documentTypeRaw) ?? .studentPilotCertificate }
    set { documentTypeRaw = newValue.rawValue }
  }

  // MARK: - Initialization

  init(
    documentType: DocumentType, filename: String, fileData: Data? = nil,
    expirationDate: Date? = nil, notes: String? = nil
  ) {
    self.documentTypeRaw = documentType.rawValue
    self.filename = filename
    self.fileData = fileData
    self.expirationDate = expirationDate
    self.notes = notes
    self.lastModified = Date()
  }
}
