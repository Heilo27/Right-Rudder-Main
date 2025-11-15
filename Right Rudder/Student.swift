import CloudKit
import Foundation
import SwiftData

// MARK: - EndorsementImage

@Model
class EndorsementImage {
  // MARK: - Properties

  var id: UUID = UUID()
  var filename: String = ""
  var createdAt: Date = Date()
  var imageData: Data?

  // Endorsement metadata
  var endorsementCode: String?  // FAA endorsement code (e.g., "A.1", "A.6")
  var expirationDate: Date?  // Expiration date for endorsements with expiration

  // CloudKit sync attributes
  var cloudKitRecordID: String?
  var lastModified: Date = Date()

  // Inverse relationship
  var student: Student?

  // MARK: - Initialization

  init(
    filename: String, imageData: Data? = nil, endorsementCode: String? = nil,
    expirationDate: Date? = nil
  ) {
    self.filename = filename
    self.imageData = imageData
    self.endorsementCode = endorsementCode
    self.expirationDate = expirationDate
    self.lastModified = Date()
  }
}

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

  // Helper function to normalize category names for consistent comparison
  // Handles case-insensitive matching and variations like "Review"/"Reviews"
  private func normalizedCategory(_ category: String?) -> String? {
    guard let category = category else { return nil }
    let normalized = category.lowercased().trimmingCharacters(in: .whitespaces)

    // Map variations to canonical forms
    switch normalized {
    case "review", "reviews":
      return "Review"
    case "ppl", "private pilot":
      return "PPL"
    case "ifr", "instrument":
      return "IFR"
    case "cpl", "commercial", "commercial pilot":
      return "CPL"
    case "cfi", "instructor":
      return "CFI"
    default:
      // Return capitalized version for known categories, or original if unknown
      return category
    }
  }

  // Helper function to check if two categories match (case-insensitive, handles variations)
  private func categoriesMatch(_ cat1: String?, _ cat2: String?) -> Bool {
    guard let norm1 = normalizedCategory(cat1),
      let norm2 = normalizedCategory(cat2)
    else {
      return false
    }
    return norm1 == norm2
  }

  // Helper function to determine category from template name
  private func getCategoryFromTemplateName(_ templateName: String) -> String {
    let name = templateName.lowercased()

    if name.contains("ppl") || name.contains("private") || name.contains("phase 1")
      || name.contains("phase 2") || name.contains("phase 3") || name.contains("phase 4")
      || name.contains("pre-solo") || name.contains("solo")
    {
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

    return "PPL"  // Default fallback
  }

  // Calculate progress for a specific category
  func progressForCategory(_ category: String) -> Double {
    guard let assignments = checklistAssignments else { return 0.0 }

    // Normalize the target category
    let normalizedTarget = normalizedCategory(category) ?? category

    // Filter assignments by category, handling both template relationship and templateIdentifier
    let categoryAssignments = assignments.filter { assignment in
      // First try template relationship with normalized matching
      if let templateCategory = assignment.template?.category {
        if categoriesMatch(templateCategory, normalizedTarget) {
          return true
        }
      }
      // Fallback: try to infer from templateIdentifier if available
      if let identifier = assignment.templateIdentifier {
        let identifierLower = identifier.lowercased()
        let normalizedCategoryLower = normalizedTarget.lowercased()

        if normalizedCategoryLower == "ppl"
          && (identifierLower.contains("p1_") || identifierLower.contains("p2_")
            || identifierLower.contains("p3_") || identifierLower.contains("p4_")
            || identifierLower.contains("pre_solo") || identifierLower.contains("solo"))
        {
          return true
        }
        if (normalizedCategoryLower == "ifr" || normalizedCategoryLower == "instrument")
          && (identifierLower.contains("i1_") || identifierLower.contains("i2_")
            || identifierLower.contains("i3_") || identifierLower.contains("i4_")
            || identifierLower.contains("i5_"))
        {
          return true
        }
        if (normalizedCategoryLower == "cpl" || normalizedCategoryLower == "commercial")
          && (identifierLower.contains("c1_") || identifierLower.contains("c2_")
            || identifierLower.contains("c3_"))
        {
          return true
        }
        if normalizedCategoryLower == "review" && identifierLower.contains("review") {
          return true
        }
      }
      return false
    }

    guard !categoryAssignments.isEmpty else { return 0.0 }

    let totalItems = categoryAssignments.reduce(0) { $0 + $1.totalItemsCount }
    let completedItems = categoryAssignments.reduce(0) { $0 + $1.completedItemsCount }

    guard totalItems > 0 else { return 0.0 }
    return Double(completedItems) / Double(totalItems)
  }

  // Get primary progress (for the main category)
  var primaryProgress: Double {
    return progressForCategory(primaryCategory)
  }

  // Get the current active category - simplified to just use assigned category
  var currentActiveCategory: String? {
    return assignedCategory
  }

  // Get progress for the current active category
  var currentActiveProgress: Double {
    guard let category = currentActiveCategory else { return 0.0 }
    return progressForCategory(category)
  }

  // MARK: - Weighted Progress Calculation (matches student app)

  /// Calculate weighted overall progress for assigned category
  var weightedCategoryProgress: Double {
    // Auto-detect category if not assigned
    let category = assignedCategory ?? autoDetectCategory()

    guard let category = category else {
      // If no category can be determined, calculate progress from all checklists
      return calculateOverallProgress()
    }

    // Normalize category for consistent comparison
    let normalizedCat = normalizedCategory(category) ?? category
    let isReviewCategory = normalizedCat == "Review"

    var totalWeightedProgress = 0.0

    // Training goals progress
    let goalProgress = categoryGoalProgress(for: category)

    // Documents progress
    let docProgress = documentProgress

    // Personal information progress
    let personalInfo = personalInfoProgress

    // Adjust weighting based on category
    if isReviewCategory {
      // For Review category: 85% goals, 15% personal info (no documents)
      totalWeightedProgress += goalProgress * 0.85
      totalWeightedProgress += personalInfo * 0.15
    } else {
      // For other categories: 70% goals, 15% documents, 15% personal info
      totalWeightedProgress += goalProgress * 0.7
      totalWeightedProgress += docProgress * 0.15
      totalWeightedProgress += personalInfo * 0.15
    }

    // First, check if we should return 100% based on completion status
    // This check happens BEFORE the weighted calculation to ensure accurate results
    if let assignments = checklistAssignments, !assignments.isEmpty {
      // Check all assignments (both category-specific and all) for completion
      let allAssignmentsComplete = assignments.allSatisfy { assignment in
        let total = assignment.totalItemsCount
        guard total > 0 else {
          #if DEBUG
            print("⚠️ Assignment '\(assignment.displayName)' has totalItemsCount = 0")
          #endif
          return false
        }
        return assignment.isComplete
      }

      // Check if category is Review (documents not required)
      let normalizedCat = normalizedCategory(category) ?? category
      let isReviewCategory = normalizedCat == "Review"

      // Return 100% based on category requirements
      if isReviewCategory {
        // Review category: only need checklists complete and personal info
        if allAssignmentsComplete && personalInfo >= 100.0 {
          return 1.0
        }
      } else {
        // Other categories: need checklists, personal info, AND documents
        if allAssignmentsComplete && personalInfo >= 100.0 && docProgress >= 100.0 {
          return 1.0
        }
      }
    } else {
      // No checklists assigned
      let normalizedCat = normalizedCategory(category) ?? category
      let isReviewCategory = normalizedCat == "Review"

      if isReviewCategory {
        // Review category: only need personal info
        if personalInfo >= 100.0 {
          return 1.0
        }
      } else {
        // Other categories: need personal info and documents
        if personalInfo >= 100.0 && docProgress >= 100.0 {
          return 1.0
        }
      }
    }

    // Debug logging (reduced verbosity - only log summary)
    #if DEBUG
      if let assignments = checklistAssignments, !assignments.isEmpty {
        let normalizedTarget = normalizedCategory(category) ?? category
        let _ = assignments.filter { assignment in
          if let templateCategory = assignment.template?.category {
            return categoriesMatch(templateCategory, normalizedTarget)
          }
          return false
        }
        // Only log if there are issues or significant information
        // Reduced logging frequency - only log on significant changes
        // This prevents excessive logging during normal app usage

      }
    #endif

    let calculatedProgress = totalWeightedProgress / 100.0  // Return as 0.0-1.0 for progress bars
    return calculatedProgress
  }

  /// Auto-detect category from assigned checklists
  private func autoDetectCategory() -> String? {
    guard let assignments = checklistAssignments, !assignments.isEmpty else {
      return nil
    }

    // Count checklists by category (using normalized categories)
    var categoryCounts: [String: Int] = [:]

    for assignment in assignments {
      // Try template relationship first
      if let templateCategory = assignment.template?.category {
        // Normalize the category to canonical form
        let normalized = normalizedCategory(templateCategory) ?? templateCategory
        categoryCounts[normalized, default: 0] += 1
      } else if let identifier = assignment.templateIdentifier {
        // Infer from templateIdentifier
        let identifierLower = identifier.lowercased()
        if identifierLower.contains("p1_") || identifierLower.contains("p2_")
          || identifierLower.contains("p3_") || identifierLower.contains("p4_")
          || identifierLower.contains("pre_solo") || identifierLower.contains("solo")
        {
          categoryCounts["PPL", default: 0] += 1
        } else if identifierLower.contains("i1_") || identifierLower.contains("i2_")
          || identifierLower.contains("i3_") || identifierLower.contains("i4_")
          || identifierLower.contains("i5_")
        {
          categoryCounts["IFR", default: 0] += 1
        } else if identifierLower.contains("c1_") || identifierLower.contains("c2_")
          || identifierLower.contains("c3_")
        {
          categoryCounts["CPL", default: 0] += 1
        } else if identifierLower.contains("review") {
          categoryCounts["Review", default: 0] += 1
        }
      }
    }

    // Return the category with the most checklists
    if let mostCommonCategory = categoryCounts.max(by: { $0.value < $1.value }) {
      return mostCommonCategory.key
    }

    // Default to PPL if no category detected
    return "PPL"
  }

  /// Calculate overall progress when category is unknown
  private func calculateOverallProgress() -> Double {
    guard let assignments = checklistAssignments, !assignments.isEmpty else {
      return 0.0
    }

    let totalItems = assignments.reduce(0) { $0 + $1.totalItemsCount }
    let completedItems = assignments.reduce(0) { $0 + $1.completedItemsCount }

    guard totalItems > 0 else {
      #if DEBUG
        print(
          "⚠️ Progress calculation: Student \(displayName) has \(assignments.count) assignments but totalItemsCount is 0"
        )
      #endif
      return 0.0
    }

    // Use a simplified progress calculation (just checklist progress, no weighting)
    let checklistProgress = Double(completedItems) / Double(totalItems)

    // Check if student is in Review category (documents not required)
    let category = assignedCategory ?? autoDetectCategory()
    let normalizedCat = normalizedCategory(category) ?? category
    let isReviewCategory = normalizedCat == "Review"

    let personalInfo = personalInfoProgress

    // Adjust weighting based on category
    let calculatedProgress: Double
    if isReviewCategory {
      // Review category: 85% checklist, 15% personal info (no documents)
      calculatedProgress = (checklistProgress * 0.85) + (personalInfo / 100.0 * 0.15)
    } else {
      // Other categories: 70% checklist, 15% documents, 15% personal info
      let docProgress = documentProgress
      calculatedProgress =
        (checklistProgress * 0.7) + (docProgress / 100.0 * 0.15) + (personalInfo / 100.0 * 0.15)
    }

    #if DEBUG
      if calculatedProgress == 0.0 && completedItems > 0 {
        print(
          "⚠️ Progress calculation: Student \(displayName) has \(completedItems)/\(totalItems) items completed but progress is 0"
        )
        print("   - Assignments count: \(assignments.count)")
        for assignment in assignments {
          print(
            "   - Assignment: \(assignment.displayName), completed: \(assignment.completedItemsCount)/\(assignment.totalItemsCount), template: \(assignment.template?.name ?? "nil")"
          )
        }
      }
    #endif

    return calculatedProgress
  }

  /// Calculate goal progress for specific category (0-100)
  private func categoryGoalProgress(for category: String) -> Double {
    var progress = 0.0

    // Base checklist progress (up to 83%)
    let checklistProgress = checklistProgressForCategory(category)
    progress += checklistProgress

    // Add milestone bonuses
    // Normalize category for switch statement
    let normalizedCat = normalizedCategory(category) ?? category

    switch normalizedCat {
    case "PPL":
      if pplGroundSchoolCompleted { progress += 15.0 }
      if pplWrittenTestCompleted { progress += 2.0 }
    case "IFR", "Instrument":
      if instrumentGroundSchoolCompleted { progress += 15.0 }
      if instrumentWrittenTestCompleted { progress += 2.0 }
    case "CPL", "Commercial":
      if commercialGroundSchoolCompleted { progress += 15.0 }
      if commercialWrittenTestCompleted { progress += 2.0 }
    case "CFI":
      if cfiGroundSchoolCompleted { progress += 15.0 }
      if cfiWrittenTestCompleted { progress += 2.0 }
    case "Review":
      // Review category doesn't have ground school or written test milestones
      // Progress comes entirely from checklist completion (already calculated above)
      break
    default:
      break
    }

    return min(100.0, progress)
  }

  /// Calculate checklist progress for category (0-83)
  private func checklistProgressForCategory(_ category: String) -> Double {
    guard let assignments = checklistAssignments else { return 0.0 }

    // Normalize the target category
    let normalizedTarget = normalizedCategory(category) ?? category

    // Filter by category, handling both template relationship and fallback
    let categoryAssignments = assignments.filter { assignment in
      // First try template relationship with normalized matching
      if let templateCategory = assignment.template?.category {
        if categoriesMatch(templateCategory, normalizedTarget) {
          return true
        }
      }
      // Fallback: try to infer from templateIdentifier if available
      if let identifier = assignment.templateIdentifier {
        let identifierLower = identifier.lowercased()
        let normalizedCategoryLower = normalizedTarget.lowercased()

        if normalizedCategoryLower == "ppl"
          && (identifierLower.contains("p1_") || identifierLower.contains("p2_")
            || identifierLower.contains("p3_") || identifierLower.contains("p4_")
            || identifierLower.contains("pre_solo") || identifierLower.contains("solo"))
        {
          return true
        }
        if (normalizedCategoryLower == "ifr" || normalizedCategoryLower == "instrument")
          && (identifierLower.contains("i1_") || identifierLower.contains("i2_")
            || identifierLower.contains("i3_") || identifierLower.contains("i4_")
            || identifierLower.contains("i5_"))
        {
          return true
        }
        if (normalizedCategoryLower == "cpl" || normalizedCategoryLower == "commercial")
          && (identifierLower.contains("c1_") || identifierLower.contains("c2_")
            || identifierLower.contains("c3_"))
        {
          return true
        }
        if normalizedCategoryLower == "review" && identifierLower.contains("review") {
          return true
        }
      }
      return false
    }

    guard !categoryAssignments.isEmpty else {
      return 0.0
    }

    // Calculate average progress percentage across all checklists (not just count completed ones)
    // This gives a more accurate representation of overall progress
    let totalProgress = categoryAssignments.reduce(0.0) { sum, assignment in
      let total = assignment.totalItemsCount
      guard total > 0 else { return sum }
      // Use progressPercentage which calculates (completedItemsCount / totalItemsCount)
      return sum + assignment.progressPercentage
    }

    let averageProgress = totalProgress / Double(categoryAssignments.count)

    // Scale to 83% maximum to leave room for milestones (15% + 2%)
    // For Review category, we don't have milestones, so scale to 100% instead
    if normalizedTarget == "Review" {
      return averageProgress * 100.0
    }

    return averageProgress * 83.0
  }

  /// Document upload progress (0-100)
  var documentProgress: Double {
    // Check if student is in Review category - documents are not required for Review students
    let category = assignedCategory ?? autoDetectCategory()
    let normalizedCat = normalizedCategory(category) ?? category

    if normalizedCat == "Review" {
      // Review students don't need documents - return 100% to not penalize progress
      return 100.0
    }

    guard let docs = documents else {
      // If no documents system is set up, default to 100% so it doesn't penalize progress
      // This handles cases where documents might not be applicable to all students
      return 100.0
    }
    let requiredDocs = docs.filter { !$0.documentType.isOptional }
    let requiredCount = DocumentType.allCases.filter { !$0.isOptional }.count

    // If no documents are required, consider it 100% complete
    guard requiredCount > 0 else { return 100.0 }

    return Double(requiredDocs.count) / Double(requiredCount) * 100.0
  }

  /// Personal information completeness (0-100)
  var personalInfoProgress: Double {
    var progress = 0.0
    if !firstName.isEmpty { progress += 20.0 }
    if !lastName.isEmpty { progress += 20.0 }
    if !email.isEmpty { progress += 20.0 }
    if !telephone.isEmpty { progress += 20.0 }
    if !homeAddress.isEmpty { progress += 20.0 }
    return progress
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
