import CloudKit
import Foundation
import SwiftData

// MARK: - Student

@Model
class Student {
  // MARK: - Properties

  var id: UUID = UUID()

  // MARK: - Bidirectional Fields (Last Write Wins)
  // These fields can be edited by both instructor and student apps
  // Conflict resolution: merge non-empty fields, timestamp comparison
  var firstName: String = ""  // BIDIRECTIONAL
  var lastName: String = ""  // BIDIRECTIONAL
  var email: String = ""  // BIDIRECTIONAL
  var telephone: String = ""  // BIDIRECTIONAL
  var homeAddress: String = ""  // BIDIRECTIONAL
  var ftnNumber: String = ""  // BIDIRECTIONAL
  var biography: String?  // BIDIRECTIONAL
  var backgroundNotes: String?  // BIDIRECTIONAL (internal notes, not synced)
  var profilePhotoData: Data?
  var createdAt: Date = Date()
  var customOrder: Int = 0  // For manual sorting
  var assignedCategory: String? = nil  // Manual category assignment
  var isInactive: Bool = false  // Inactive student status

  // Instructor information (entered by student in companion app)
  var instructorName: String?
  var instructorCFINumber: String?

  // MARK: - Student-Owned Fields (Read-Only for Instructor)
  // These fields are written by student app, read-only in instructor app
  var goalPPL: Bool = false  // STUDENT → INSTRUCTOR (read-only for instructor)
  var goalInstrument: Bool = false  // STUDENT → INSTRUCTOR (read-only for instructor)
  var goalCommercial: Bool = false  // STUDENT → INSTRUCTOR (read-only for instructor)
  var goalCFI: Bool = false  // STUDENT → INSTRUCTOR (read-only for instructor)

  // Training milestones - PPL
  var pplGroundSchoolCompleted: Bool = false  // STUDENT → INSTRUCTOR (read-only for instructor)
  var pplWrittenTestCompleted: Bool = false  // STUDENT → INSTRUCTOR (read-only for instructor)

  // Training milestones - Instrument
  var instrumentGroundSchoolCompleted: Bool = false  // STUDENT → INSTRUCTOR (read-only for instructor)
  var instrumentWrittenTestCompleted: Bool = false  // STUDENT → INSTRUCTOR (read-only for instructor)

  // Training milestones - Commercial
  var commercialGroundSchoolCompleted: Bool = false  // STUDENT → INSTRUCTOR (read-only for instructor)
  var commercialWrittenTestCompleted: Bool = false  // STUDENT → INSTRUCTOR (read-only for instructor)

  // Training milestones - CFI
  var cfiGroundSchoolCompleted: Bool = false  // STUDENT → INSTRUCTOR (read-only for instructor)
  var cfiWrittenTestCompleted: Bool = false  // STUDENT → INSTRUCTOR (read-only for instructor)

  // MARK: - CloudKit Sync Attributes
  var cloudKitRecordID: String?
  var shareRecordID: String?  // CKShare record ID for companion app access
  var lastModified: Date = Date()
  var lastModifiedBy: String?  // Tracks who last modified bidirectional fields: "instructor" or "student"
  var instructorEmail: String?  // Email of instructor who created the share (for identity validation)

  // NEW: Library-based checklist assignments
  @Relationship(deleteRule: .cascade, inverse: \ChecklistAssignment.student)
  var checklistAssignments: [ChecklistAssignment]?
  @Relationship(deleteRule: .cascade, inverse: \EndorsementImage.student) var endorsements:
    [EndorsementImage]?
  @Relationship(deleteRule: .cascade, inverse: \StudentDocument.student) var documents:
    [StudentDocument]?

  var displayName: String { "\(firstName) \(lastName)" }

  // Optimized computed property for sorting
  var sortKey: String { "\(lastName), \(firstName)" }

  var totalDualGivenHours: Double {
    checklistAssignments?.reduce(0.0) { $0 + $1.dualGivenHours } ?? 0.0
  }

  // Determine primary training category - use manual assignment if set, otherwise default to PPL
  var primaryCategory: String {
    return assignedCategory ?? "PPL"
  }

  // MARK: - Progress Calculation (Delegated to Service)

  /// Calculate progress for a specific category
  /// Delegates to StudentProgressService for calculation logic
  func progressForCategory(_ category: String) -> Double {
    return StudentProgressService.progressForCategory(category, for: self)
  }

  /// Get primary progress (for the main category)
  var primaryProgress: Double {
    return StudentProgressService.primaryProgress(for: self)
  }

  /// Get the current active category - simplified to just use assigned category
  var currentActiveCategory: String? {
    return StudentProgressService.currentActiveCategory(for: self)
  }

  /// Get progress for the current active category
  var currentActiveProgress: Double {
    return StudentProgressService.currentActiveProgress(for: self)
  }

  /// Calculate weighted overall progress for assigned category
  /// Delegates to StudentProgressService for calculation logic
  var weightedCategoryProgress: Double {
    return StudentProgressService.weightedCategoryProgress(for: self)
  }

  /// Document upload progress (0-100)
  /// Delegates to StudentProgressService for calculation logic
  var documentProgress: Double {
    return StudentProgressService.documentProgress(for: self)
  }

  /// Personal information completeness (0-100)
  /// Delegates to StudentProgressService for calculation logic
  var personalInfoProgress: Double {
    return StudentProgressService.personalInfoProgress(for: self)
  }

  init(
    firstName: String, lastName: String, email: String, telephone: String, homeAddress: String,
    ftnNumber: String
  ) {
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
