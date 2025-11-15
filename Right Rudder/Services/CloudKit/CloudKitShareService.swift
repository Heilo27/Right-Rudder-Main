import CloudKit
import Combine
import Dispatch
import Foundation
import SwiftData
import SwiftUI

// MARK: - CloudKitShareService

@MainActor
class CloudKitShareService: ObservableObject {
  static let shared = CloudKitShareService()

  @Published var isSharing = false
  @Published var shareURL: URL?
  @Published var errorMessage: String?

  private let container: CKContainer
  private let database: CKDatabase
  private let customZoneName = "SharedStudentsZone"

  // Cache for the custom zone to avoid repeated checks
  private var cachedZone: CKRecordZone?

  // Offline sync manager
  private let offlineSyncManager = OfflineSyncManager()

  // Library cache for resolving student app library IDs
  private var libraryCache: ChecklistLibrary?

  // Track schema initialization to prevent repeated calls
  private var customChecklistDefinitionSchemaInitialized = false
  private var itemProgressSchemaInitialized = false
  private let schemaInitializationLock = AsyncLock()

  // Track diagnostic messages to avoid excessive logging
  private var diagnosticMessagesPrinted: Set<UUID> = []
  private let diagnosticLock = AsyncLock()

  // Track CloudKit environment (Development vs Production)
  private var cloudKitEnvironment: CloudKitEnvironment = .unknown
  private let environmentLock = AsyncLock()

  enum CloudKitEnvironment {
    case unknown
    case development  // Auto-creates schemas
    case production  // Requires pre-deployed schemas
  }

  private init() {
    self.container = CKContainer(identifier: "iCloud.com.heiloprojects.rightrudder")
    self.database = container.privateCloudDatabase

    // Detect CloudKit environment immediately (don't wait for async task)
    // This ensures environment is known before schema initialization
    Task {
      await logCloudKitEnvironment()
    }
  }

  /// Gets the current CloudKit environment
  /// Returns .unknown if environment hasn't been detected yet
  private func getCloudKitEnvironment() -> CloudKitEnvironment {
    return environmentLock.withLock {
      return cloudKitEnvironment
    }
  }

  /// Detects and logs the CloudKit environment (Development vs Production)
  /// CloudKit environment is determined by build configuration:
  /// - Debug builds = Development
  /// - Release builds = Production
  /// - App Store/TestFlight = Production
  private func logCloudKitEnvironment() async {
    do {
      // Try to detect environment by attempting to save a test record
      // In Development, CloudKit auto-creates schemas
      // In Production, it requires manual deployment
      let testRecordID = CKRecord.ID(recordName: UUID().uuidString)
      let testRecord = CKRecord(recordType: "__EnvironmentTest__", recordID: testRecordID)
      testRecord["test"] = "environment_detection"

      do {
        _ = try await database.save(testRecord)
        // If this succeeds, we're likely in Development (auto-creates schemas)
        environmentLock.withLock {
          cloudKitEnvironment = .development
        }
        print("🌍 CloudKit Environment: DEVELOPMENT (auto-creates schemas)")
        print("   ⚠️ NOTE: For Production, ensure both apps are built with Release configuration")
        // Clean up test record
        _ = try? await database.deleteRecord(withID: testRecordID)
      } catch let error as CKError {
        if error.localizedDescription.contains("not deployed")
          || error.localizedDescription.contains("Production") || error.code == .invalidArguments
        {
          environmentLock.withLock {
            cloudKitEnvironment = .production
          }
          print("🌍 CloudKit Environment: PRODUCTION (requires one-time schema deployment)")
          print(
            "   ✅ Schemas must be deployed to Production before publishing (see docs/guides/CLOUDKIT_SCHEMA_DEPLOYMENT.md)"
          )
          print("   ✅ After deployment, unlimited records can be created automatically")
        } else {
          // Could be Development or Production - check error code
          print(
            "🌍 CloudKit Environment: Unable to determine (error: \(error.localizedDescription))")
          print("   💡 Check build configuration: Debug = Development, Release = Production")
        }
      }
    } catch {
      print("🌍 CloudKit Environment: Unable to detect - \(error.localizedDescription)")
    }
  }

  // MARK: - Library ID Resolution

  /// Loads the student app's library JSON to resolve library IDs
  private func loadStudentLibrary() -> ChecklistLibrary? {
    if let cached = libraryCache {
      return cached
    }

    // Try to load from the student app's library JSON file
    // The file should be in the ChecklistLibrary subdirectory
    guard
      let url = Bundle.main.url(
        forResource: "DefaultChecklistLibrary", withExtension: "json",
        subdirectory: "ChecklistLibrary")
        ?? Bundle.main.url(forResource: "DefaultChecklistLibrary", withExtension: "json")
    else {
      print("⚠️ Could not find DefaultChecklistLibrary.json - library ID resolution disabled")
      print(
        "   Searched in: ChecklistLibrary/DefaultChecklistLibrary.json and DefaultChecklistLibrary.json"
      )
      return nil
    }

    do {
      let data = try Data(contentsOf: url)
      let library = try JSONDecoder().decode(ChecklistLibrary.self, from: data)
      libraryCache = library
      print(
        "✅ Loaded student library with \(library.checklists.count) checklists from: \(url.lastPathComponent)"
      )
      return library
    } catch {
      print("❌ Failed to load student library: \(error)")
      return nil
    }
  }

  /// Resolves the library template ID for a given templateIdentifier
  private func resolveLibraryTemplateID(templateIdentifier: String?) -> UUID? {
    guard let templateIdentifier = templateIdentifier else {
      return nil
    }

    guard let library = loadStudentLibrary() else {
      return nil
    }

    if let checklist = library.checklists.first(where: {
      $0.templateIdentifier?.lowercased() == templateIdentifier.lowercased()
    }) {
      return checklist.id
    }

    return nil
  }

  /// Resolves the library item ID for a given template item by matching order
  private func resolveLibraryItemID(templateIdentifier: String?, itemOrder: Int) -> UUID? {
    guard let templateIdentifier = templateIdentifier else {
      return nil
    }

    guard let library = loadStudentLibrary() else {
      print("⚠️ resolveLibraryItemID: Could not load student library")
      return nil
    }

    guard
      let checklist = library.checklists.first(where: {
        $0.templateIdentifier?.lowercased() == templateIdentifier.lowercased()
      })
    else {
      print(
        "⚠️ resolveLibraryItemID: Could not find checklist with templateIdentifier: \(templateIdentifier)"
      )
      return nil
    }

    // Match by order (items should be in the same order in both apps)
    // CRITICAL: Order values may be 0-based or 1-based, so we need to handle both cases
    let sortedItems = checklist.items.sorted { $0.order < $1.order }
    guard !sortedItems.isEmpty else {
      // Don't log this repeatedly - some templates legitimately have no items in library
      // (e.g., C3-L3 Endorsements template has items but library doesn't)
      return nil
    }

    // Determine if orders are 0-based or 1-based by checking the minimum order value
    let minOrder = sortedItems.first?.order ?? 0
    let isOneBased = minOrder == 1

    // Convert to array index (0-based)
    let arrayIndex: Int
    if isOneBased {
      // Order is 1-based, convert to 0-based index
      arrayIndex = itemOrder - 1
    } else {
      // Order is 0-based, use directly
      arrayIndex = itemOrder
    }

    if arrayIndex >= 0 && arrayIndex < sortedItems.count {
      let resolvedID = sortedItems[arrayIndex].id
      return resolvedID
    } else {
      let maxOrder = sortedItems.last?.order ?? 0
      print(
        "⚠️ resolveLibraryItemID: Item order \(itemOrder) (array index \(arrayIndex)) is out of bounds for checklist '\(templateIdentifier)' (has \(sortedItems.count) items, order range: \(minOrder)-\(maxOrder), \(isOneBased ? "1-based" : "0-based"))"
      )
      return nil
    }
  }

  /// Resolves the library item ID for an ItemProgress record
  /// Finds the item's order in the instructor's template, then looks up the library item ID
  private func resolveLibraryItemID(for itemProgress: ItemProgress, assignment: ChecklistAssignment)
    -> UUID?
  {
    // For custom checklists, use the instructor's ID (no library to resolve)
    guard !assignment.isCustomChecklist, let templateIdentifier = assignment.templateIdentifier
    else {
      return itemProgress.templateItemId
    }

    // Get the template to find the item's order
    guard let template = assignment.template,
      let templateItems = template.items?.sorted(by: { $0.order < $1.order })
    else {
      print(
        "⚠️ resolveLibraryItemID: Could not get template items for assignment: \(assignment.templateIdentifier ?? "unknown")"
      )
      return itemProgress.templateItemId
    }

    // Find the template item that matches this ItemProgress
    guard let templateItem = templateItems.first(where: { $0.id == itemProgress.templateItemId })
    else {
      print(
        "⚠️ resolveLibraryItemID: Could not find template item for ItemProgress.templateItemId: \(itemProgress.templateItemId.uuidString.prefix(8))"
      )
      print(
        "   Available template item IDs: \(templateItems.prefix(5).map { $0.id.uuidString.prefix(8) }.joined(separator: ", "))"
      )
      return itemProgress.templateItemId
    }

    // Resolve the library item ID using the item's order
    if let libraryItemID = resolveLibraryItemID(
      templateIdentifier: templateIdentifier, itemOrder: templateItem.order)
    {
      return libraryItemID
    }

    // Log warning if library resolution fails (but only once per template to avoid spam)
    // Some templates may have items not in the library (e.g., C3-L3 Endorsements)
    // This is expected and we'll use the instructor's ID as fallback

    // Fallback to instructor's ID if library resolution fails
    return itemProgress.templateItemId
  }

  func setModelContext(_ context: ModelContext) {
    offlineSyncManager.setModelContext(context)
  }

  // MARK: - Helper Methods for New Record Types

  /// Converts a Student to StudentPersonalInfoRecord
  private func createStudentPersonalInfoRecord(from student: Student) -> StudentPersonalInfoRecord {
    // Convert documents
    let documents = (student.documents ?? []).map { doc in
      DocumentData(
        id: doc.id.uuidString,
        documentType: doc.documentTypeRaw,
        filename: doc.filename,
        fileData: doc.fileData,
        notes: doc.notes,
        uploadedAt: doc.uploadedAt,
        expirationDate: doc.expirationDate,
        lastModified: doc.lastModified,
        lastModifiedBy: doc.lastModifiedBy ?? "instructor"
      )
    }

    return StudentPersonalInfoRecord(
      studentId: student.id.uuidString,
      firstName: student.firstName,
      lastName: student.lastName,
      email: student.email,
      telephone: student.telephone,
      homeAddress: student.homeAddress,
      ftnNumber: student.ftnNumber,
      profilePhotoData: student.profilePhotoData,
      documents: documents,
      lastModified: student.lastModified,
      lastModifiedBy: student.lastModifiedBy ?? "instructor"
    )
  }

  /// Converts a Student to TrainingGoalsRecord
  private func createTrainingGoalsRecord(from student: Student) -> TrainingGoalsRecord {
    return TrainingGoalsRecord(
      studentId: student.id.uuidString,
      goalPPL: student.goalPPL,
      goalInstrument: student.goalInstrument,
      goalCommercial: student.goalCommercial,
      goalCFI: student.goalCFI,
      pplGroundSchoolCompleted: student.pplGroundSchoolCompleted,
      pplWrittenTestCompleted: student.pplWrittenTestCompleted,
      instrumentGroundSchoolCompleted: student.instrumentGroundSchoolCompleted,
      instrumentWrittenTestCompleted: student.instrumentWrittenTestCompleted,
      commercialGroundSchoolCompleted: student.commercialGroundSchoolCompleted,
      commercialWrittenTestCompleted: student.commercialWrittenTestCompleted,
      cfiGroundSchoolCompleted: student.cfiGroundSchoolCompleted,
      cfiWrittenTestCompleted: student.cfiWrittenTestCompleted,
      lastModified: student.lastModified
    )
  }

  /// Converts a ChecklistAssignment to ChecklistAssignmentRecord
  private func createChecklistAssignmentRecord(
    from assignment: ChecklistAssignment, student: Student
  ) -> ChecklistAssignmentRecord {
    // Get template items to look up order values
    let templateItems = assignment.template?.items?.sorted { $0.order < $1.order } ?? []
    let templateItemOrderMap = Dictionary(
      uniqueKeysWithValues: templateItems.map { ($0.id, $0.order) })

    // Convert ItemProgress to ItemProgressData
    // CRITICAL: Resolve library item ID (student app's ID) instead of instructor's internal ID
    let itemProgressData = (assignment.itemProgress ?? []).map { progress in
      // Get order from template item (for matching in student app when IDs differ)
      let order = templateItemOrderMap[progress.templateItemId]

      // CRITICAL: Resolve to library item ID so student app can match by ID
      let libraryItemID =
        resolveLibraryItemID(for: progress, assignment: assignment) ?? progress.templateItemId

      // Log ID resolution for debugging (log all to see what's happening)
      let progressIndex =
        (assignment.itemProgress ?? []).firstIndex(where: { $0.id == progress.id }) ?? 0
      if libraryItemID != progress.templateItemId {
        if progressIndex < 10 || progressIndex % 10 == 0 {
          print(
            "🔄 createChecklistAssignmentRecord[\(progressIndex)]: Resolved library item ID: \(progress.templateItemId.uuidString.prefix(8)) -> \(libraryItemID.uuidString.prefix(8))"
          )
        }
      } else {
        // Always log failures - these are important
        print(
          "⚠️ createChecklistAssignmentRecord[\(progressIndex)]: Could not resolve library item ID, using instructor ID: \(progress.templateItemId.uuidString.prefix(8))"
        )
      }

      return ItemProgressData(
        id: progress.id.uuidString,
        templateItemId: libraryItemID.uuidString,  // Use resolved library item ID
        order: order,
        isComplete: progress.isComplete,
        notes: progress.notes,
        completedAt: progress.completedAt,
        lastModified: progress.lastModified
      )
    }

    // Resolve library template ID
    let libraryTemplateID =
      resolveLibraryTemplateID(templateIdentifier: assignment.templateIdentifier)
      ?? assignment.templateId

    return ChecklistAssignmentRecord(
      assignmentId: assignment.id.uuidString,
      templateId: libraryTemplateID.uuidString,
      templateIdentifier: assignment.templateIdentifier,
      isCustomChecklist: assignment.isCustomChecklist,
      instructorComments: assignment.instructorComments,
      dualGivenHours: assignment.dualGivenHours,
      assignedAt: assignment.assignedAt,
      lastModified: assignment.lastModified,
      itemProgress: itemProgressData
    )
  }

  /// Initializes CloudKit schemas for CustomChecklistDefinition and ItemProgress
  /// This should be called proactively to ensure schemas exist before syncing
  /// Works for both Development (auto-creates) and Production (requires manual deployment)
  func initializeCloudKitSchemas() async {
    // Prevent repeated initialization
    let (needsCustomChecklist, needsItemProgress) = schemaInitializationLock.withLock {
      return (!customChecklistDefinitionSchemaInitialized, !itemProgressSchemaInitialized)
    }

    if needsCustomChecklist {
      await initializeCustomChecklistDefinitionSchema()
    }
    if needsItemProgress {
      await initializeItemProgressSchema()
    }
  }

  /// Initializes CustomChecklistDefinition schema in CloudKit
  /// In Development: Attempts to auto-create schema
  /// In Production: Assumes schema is already deployed (skips auto-creation)
  private func initializeCustomChecklistDefinitionSchema() async {
    // Check if already initialized
    let alreadyInitialized = schemaInitializationLock.withLock {
      if customChecklistDefinitionSchemaInitialized {
        return true
      }
      return false
    }
    if alreadyInitialized {
      return
    }

    // Check environment - skip auto-creation in Production
    let environment = getCloudKitEnvironment()

    // In Production, assume schemas are already deployed (one-time setup)
    // If environment is unknown, attempt auto-creation (will fail gracefully in Production)
    if environment == .production {
      print(
        "ℹ️ Production mode detected - assuming CustomChecklistDefinition schema is already deployed"
      )
      schemaInitializationLock.withLock {
        customChecklistDefinitionSchemaInitialized = true
      }
      return
    }

    print("🔄 Initializing CustomChecklistDefinition schema...")

    do {
      // Check CloudKit availability
      let accountStatus = try await container.accountStatus()
      guard accountStatus == .available else {
        print("⚠️ CloudKit account not available - cannot initialize schema")
        return
      }

      // Try to initialize in both private and shared databases
      // This ensures the schema is available in both contexts
      let privateDatabase = container.privateCloudDatabase
      let sharedDatabase = container.sharedCloudDatabase

      // Create a dummy record with all required fields
      // Use a valid UUID for the record name (CloudKit requires valid UUID strings)
      let dummyRecordID = CKRecord.ID(recordName: UUID().uuidString)
      let schemaRecord = CKRecord(recordType: "CustomChecklistDefinition", recordID: dummyRecordID)
      schemaRecord["templateId"] = UUID().uuidString
      schemaRecord["customName"] = "__SCHEMA_INIT__"
      schemaRecord["customCategory"] = "__SCHEMA_INIT__"
      schemaRecord["studentId"] = UUID().uuidString  // CRITICAL: Must be set and queryable for student app queries
      schemaRecord["lastModified"] = Date()
      schemaRecord["customItems"] = "[]"

      var schemaInitialized = false

      // Try private database first
      do {
        _ = try await privateDatabase.save(schemaRecord)
        print("✅ CustomChecklistDefinition schema initialized in private database")
        _ = try? await privateDatabase.deleteRecord(withID: dummyRecordID)
        schemaInitialized = true
      } catch let saveError as CKError {
        if saveError.code == .unknownItem {
          print("ℹ️ CustomChecklistDefinition schema may already exist in private database")
          schemaInitialized = true  // Assume it exists
        } else {
          print("⚠️ Failed to initialize in private database: \(saveError.localizedDescription)")
          print("   Error code: \(saveError.code.rawValue)")
        }
      } catch {
        print("⚠️ Unexpected error initializing in private database: \(error)")
      }

      // Also try to initialize in shared database context
      // CRITICAL: In CloudKit, schemas are global - once created in private database, they're available everywhere
      // However, we can try to initialize in shared database by using an actual shared zone if available
      // If no shared zones exist yet, the schema will be available once shares are created
      do {
        // Try to find an existing shared zone to use for schema initialization
        let allSharedZones = try await sharedDatabase.allRecordZones()

        if let firstSharedZone = allSharedZones.first {
          // Use the first available shared zone
          let sharedDummyRecordID = CKRecord.ID(
            recordName: UUID().uuidString, zoneID: firstSharedZone.zoneID)
          let sharedSchemaRecord = CKRecord(
            recordType: "CustomChecklistDefinition", recordID: sharedDummyRecordID)
          sharedSchemaRecord["templateId"] = UUID().uuidString
          sharedSchemaRecord["customName"] = "__SCHEMA_INIT__"
          sharedSchemaRecord["customCategory"] = "__SCHEMA_INIT__"
          sharedSchemaRecord["studentId"] = UUID().uuidString
          sharedSchemaRecord["lastModified"] = Date()
          sharedSchemaRecord["customItems"] = "[]"

          _ = try await sharedDatabase.save(sharedSchemaRecord)
          print(
            "✅ CustomChecklistDefinition schema initialized in shared database (zone: \(firstSharedZone.zoneID.zoneName))"
          )
          _ = try? await sharedDatabase.deleteRecord(withID: sharedDummyRecordID)
          schemaInitialized = true
        } else {
          // No shared zones exist yet - schema will be available once shares are created
          // In Development, the schema from private database should propagate automatically
          print(
            "ℹ️ No shared zones exist yet - CustomChecklistDefinition schema will be available once shares are created"
          )
          print(
            "   Schema initialized in private database should propagate to shared database automatically in Development"
          )
          schemaInitialized = true  // Consider it initialized since private DB initialization succeeded
        }
      } catch let saveError as CKError {
        if saveError.code == .unknownItem {
          print("ℹ️ CustomChecklistDefinition schema may already exist in shared database")
          schemaInitialized = true
        } else if saveError.code == .invalidArguments {
          // In Development, try saving without a zone (default zone) - this should auto-create schema
          do {
            let defaultZoneDummyRecordID = CKRecord.ID(recordName: UUID().uuidString)
            let defaultSchemaRecord = CKRecord(
              recordType: "CustomChecklistDefinition", recordID: defaultZoneDummyRecordID)
            defaultSchemaRecord["templateId"] = UUID().uuidString
            defaultSchemaRecord["customName"] = "__SCHEMA_INIT__"
            defaultSchemaRecord["customCategory"] = "__SCHEMA_INIT__"
            defaultSchemaRecord["studentId"] = UUID().uuidString
            defaultSchemaRecord["lastModified"] = Date()
            defaultSchemaRecord["customItems"] = "[]"

            _ = try await sharedDatabase.save(defaultSchemaRecord)
            print(
              "✅ CustomChecklistDefinition schema initialized in shared database (default zone)")
            _ = try? await sharedDatabase.deleteRecord(withID: defaultZoneDummyRecordID)
            schemaInitialized = true
          } catch {
            // If default zone also fails, schema will be available once shares are created
            print(
              "ℹ️ CustomChecklistDefinition schema will be available in shared database once shares are created"
            )
            print("   Schema from private database should propagate automatically in Development")
            schemaInitialized = true  // Consider it initialized since private DB initialization succeeded
          }
        } else if saveError.localizedDescription.contains("not deployed")
          || saveError.localizedDescription.contains("Production")
        {
          print("⚠️ CustomChecklistDefinition schema not deployed in shared database")
          print("   This is expected in Production - schema must be manually deployed")
          print("   In Development, the schema should auto-create when saving records")
          // In Development, schema should still work once shares are created
          schemaInitialized = true  // Consider it initialized since private DB initialization succeeded
        } else {
          print("⚠️ Failed to initialize in shared database: \(saveError.localizedDescription)")
          print("   Error code: \(saveError.code.rawValue)")
          // Schema should still be available from private database initialization
          schemaInitialized = true  // Consider it initialized since private DB initialization succeeded
        }
      } catch {
        print("⚠️ Unexpected error initializing in shared database: \(error)")
        // Schema should still be available from private database initialization
        schemaInitialized = true  // Consider it initialized since private DB initialization succeeded
      }

      if !schemaInitialized {
        print("⚠️ CustomChecklistDefinition schema initialization may have failed")
        print("   For Production, deploy schema manually:")
        print("   1. Go to: https://icloud.developer.apple.com/dashboard/")
        print("   2. Navigate to Schema > Record Types > Add CustomChecklistDefinition")
        print("   3. Add fields:")
        print("      - templateId (String, Indexed)")
        print("      - customName (String)")
        print("      - customCategory (String)")
        print("      - studentId (String, Indexed, Queryable) - CRITICAL")
        print("      - lastModified (Date/Time)")
        print("      - customItems (String)")
      } else {
        // Mark as initialized
        schemaInitializationLock.withLock {
          customChecklistDefinitionSchemaInitialized = true
        }
        // Add a small delay to ensure schema propagation
        try? await Task.sleep(for: .milliseconds(1000))
        print("ℹ️ Schema initialization complete - should be available in all CloudKit databases")
      }

    } catch {
      print("❌ Failed to initialize CustomChecklistDefinition schema: \(error)")
    }
  }

  /// Initializes ItemProgress schema in CloudKit
  /// CRITICAL: This ensures the assignmentId field is queryable for student app queries
  /// In Development: Attempts to auto-create schema
  /// In Production: Assumes schema is already deployed (skips auto-creation)
  private func initializeItemProgressSchema() async {
    // Check if already initialized
    let alreadyInitialized = schemaInitializationLock.withLock {
      if itemProgressSchemaInitialized {
        return true
      }
      return false
    }
    if alreadyInitialized {
      return
    }

    // Check environment - skip auto-creation in Production
    let environment = getCloudKitEnvironment()

    // In Production, assume schemas are already deployed (one-time setup)
    // If environment is unknown, attempt auto-creation (will fail gracefully in Production)
    if environment == .production {
      print("ℹ️ Production mode detected - assuming ItemProgress schema is already deployed")
      schemaInitializationLock.withLock {
        itemProgressSchemaInitialized = true
      }
      return
    }

    print("🔄 Initializing ItemProgress schema...")

    do {
      // Check CloudKit availability
      let accountStatus = try await container.accountStatus()
      guard accountStatus == .available else {
        print("⚠️ CloudKit account not available - cannot initialize schema")
        return
      }

      // Initialize in private database first (this makes it available globally)
      let privateDatabase = container.privateCloudDatabase
      // Use a valid UUID for the dummy record ID
      let dummyRecordID = CKRecord.ID(recordName: UUID().uuidString)

      // Create a dummy record with all required fields, especially assignmentId which must be queryable
      let schemaRecord = CKRecord(recordType: "ItemProgress", recordID: dummyRecordID)
      schemaRecord["templateItemId"] = UUID().uuidString
      schemaRecord["isComplete"] = NSNumber(value: false)
      schemaRecord["assignmentId"] = UUID().uuidString  // CRITICAL: Must be queryable for student app queries
      schemaRecord["notes"] = "__SCHEMA_INIT__"
      schemaRecord["completedAt"] = Date()
      schemaRecord["lastModified"] = Date()

      do {
        _ = try await privateDatabase.save(schemaRecord)
        print("✅ ItemProgress schema initialized in private database")

        // Delete the dummy record immediately
        _ = try? await privateDatabase.deleteRecord(withID: dummyRecordID)
        print("🧹 Cleaned up ItemProgress schema initialization record")

        // Add a small delay to ensure schema propagation
        try? await Task.sleep(for: .milliseconds(500))
        print(
          "ℹ️ ItemProgress schema is now available in all CloudKit databases (private, shared, public)"
        )

      } catch let saveError as CKError {
        if saveError.code == .unknownItem {
          // Schema might already exist, or record was deleted
          print("✅ ItemProgress schema appears to exist")
        } else if saveError.localizedDescription.contains("Production")
          || saveError.localizedDescription.contains("deploy")
        {
          print("⚠️ ItemProgress needs manual deployment in Production")
          print("   Go to: https://icloud.developer.apple.com/dashboard/")
          print("   Navigate to Schema > Record Types > Add ItemProgress")
          print("   Required fields:")
          print("     - templateItemId (String, Indexed)")
          print("     - isComplete (Int64/Number)")
          print(
            "     - assignmentId (String, Indexed, Queryable) - CRITICAL for student app queries")
          print("     - notes (String)")
          print("     - completedAt (Date/Time)")
          print("     - lastModified (Date/Time)")
        } else {
          print("ℹ️ ItemProgress schema check: \(saveError.localizedDescription)")
        }
      } catch {
        print("⚠️ Unexpected error initializing ItemProgress schema: \(error)")
      }

      // Mark as initialized
      schemaInitializationLock.withLock {
        itemProgressSchemaInitialized = true
      }

      print("✅ ItemProgress schema initialization complete")
    } catch {
      print("❌ Failed to initialize ItemProgress schema: \(error)")
    }
  }

  /// Validates that all required CloudKit record types are deployed in Production
  /// This helps developers identify missing schemas before users encounter errors
  /// Only runs in Production mode - Development auto-creates schemas
  func validateProductionSchemas() async {
    let environment = getCloudKitEnvironment()

    // Only validate in Production mode
    // If environment is unknown, wait a moment for detection to complete
    if environment == .unknown {
      // Wait briefly for environment detection to complete
      try? await Task.sleep(for: .milliseconds(500))
    }

    let finalEnvironment = getCloudKitEnvironment()
    guard finalEnvironment == .production else {
      if finalEnvironment == .development {
        print("ℹ️ Schema validation skipped - Development mode (schemas auto-create)")
      } else {
        print("ℹ️ Schema validation skipped - CloudKit environment not yet detected")
      }
      return
    }

    print("🔍 Validating Production CloudKit schemas...")

    let requiredRecordTypes = [
      "Student",
      "ChecklistAssignment",
      "ItemProgress",
      "StudentDocument",
      "StudentPersonalInfo",
      "TrainingGoals",
      "CustomChecklistDefinition",
    ]

    var missingSchemas: [String] = []

    for recordType in requiredRecordTypes {
      do {
        // Try to create a test record to see if the schema exists
        let testRecordID = CKRecord.ID(recordName: UUID().uuidString)
        let testRecord = CKRecord(recordType: recordType, recordID: testRecordID)

        // Set a minimal field to avoid validation errors
        if recordType == "Student" {
          testRecord["studentId"] = UUID().uuidString
        } else if recordType == "ItemProgress" {
          testRecord["assignmentId"] = UUID().uuidString
        } else if recordType == "CustomChecklistDefinition" {
          testRecord["studentId"] = UUID().uuidString
        }

        // Try to save - if schema doesn't exist, this will fail
        do {
          _ = try await database.save(testRecord)
          // Schema exists - clean up test record
          _ = try? await database.deleteRecord(withID: testRecordID)
          print("   ✅ \(recordType): Schema exists")
        } catch let error as CKError {
          let errorDescription = error.localizedDescription.lowercased()
          if errorDescription.contains("cannot create new type")
            || errorDescription.contains("production schema")
            || errorDescription.contains("not deployed")
          {
            missingSchemas.append(recordType)
            print("   ❌ \(recordType): Schema NOT deployed")
          } else {
            // Other error - assume schema exists but test record had issues
            _ = try? await database.deleteRecord(withID: testRecordID)
            print("   ✅ \(recordType): Schema exists (test record had validation issues)")
          }
        }
      } catch {
        // Unexpected error - assume schema might exist
        print("   ⚠️ \(recordType): Could not validate (error: \(error.localizedDescription))")
      }
    }

    if missingSchemas.isEmpty {
      print("✅ All required Production schemas are deployed")
    } else {
      print("⚠️ Missing Production schemas: \(missingSchemas.joined(separator: ", "))")
      print("   See docs/guides/CLOUDKIT_SCHEMA_DEPLOYMENT.md for deployment instructions")
      print("   This is a ONE-TIME setup required before publishing the app")
    }
  }

  /// Creates or fetches the custom zone needed for sharing
  private func ensureCustomZoneExists() async throws -> CKRecordZone {
    // Return cached zone if available
    if let cachedZone = cachedZone {
      return cachedZone
    }

    let zoneID = CKRecordZone.ID(zoneName: customZoneName, ownerName: CKCurrentUserDefaultName)

    do {
      // Try to fetch existing zone
      let zone = try await database.recordZone(for: zoneID)
      print("Custom zone already exists: \(customZoneName)")
      cachedZone = zone
      return zone
    } catch {
      // Zone doesn't exist, create it
      print("Creating custom zone: \(customZoneName)")
      let zone = CKRecordZone(zoneID: zoneID)
      let savedZone = try await database.save(zone)
      print("Custom zone created successfully")
      cachedZone = savedZone
      return savedZone
    }
  }

  /// Gets the shared zone for a specific student
  /// CRITICAL: We know the zone name from when we created the share ("SharedStudentsZone")
  /// We can directly construct the zone ID instead of searching for it
  /// Returns nil if the zone is not accessible in the shared database (not shared yet)
  func getSharedZone(for student: Student) async throws -> CKRecordZone? {
    guard let shareRecordName = student.shareRecordID else {
      print("⚠️ No share record ID for student \(student.displayName)")
      return nil
    }

    let sharedDatabase = container.sharedCloudDatabase
    let privateDatabase = database

    do {
      // Step 1: Verify the share exists and has been accepted
      let customZone = try await ensureCustomZoneExists()
      let shareRecordID = CKRecord.ID(recordName: shareRecordName, zoneID: customZone.zoneID)

      guard let shareRecord = try? await privateDatabase.record(for: shareRecordID) as? CKShare
      else {
        print("⚠️ Share record not found in private database for student \(student.displayName)")
        return nil
      }

      print(
        "🔍 Found share record in private database, zone: \(shareRecord.recordID.zoneID.zoneName)")
      print("   Share participants: \(shareRecord.participants.count)")

      // Step 2: Check if share has been accepted (has participants)
      guard !shareRecord.participants.isEmpty else {
        print("⚠️ Share has no participants - student hasn't accepted the share yet")
        print("   💡 Solution: Student must accept the share invitation in the student app first")
        return nil
      }

      // Only print detailed diagnostics once per student to avoid excessive logging
      diagnosticLock.lock()
      let shouldPrintDiagnostics = !diagnosticMessagesPrinted.contains(student.id)
      if shouldPrintDiagnostics {
        diagnosticMessagesPrinted.insert(student.id)
      }
      diagnosticLock.unlock()

      if shouldPrintDiagnostics {
        // DIAGNOSTIC: Log detailed share information (only once per student)
        print("📊 Share Diagnostic Information:")
        print("   Share record ID: \(shareRecord.recordID.recordName)")
        print("   Share record zone: \(shareRecord.recordID.zoneID.zoneName)")
        print("   Share record zone owner: \(shareRecord.recordID.zoneID.ownerName)")
        print("   Share participants count: \(shareRecord.participants.count)")
        for (index, participant) in shareRecord.participants.enumerated() {
          print("   Participant \(index + 1):")
          print("     - Acceptance status: \(participant.acceptanceStatus.rawValue)")
          print("     - Permission: \(participant.permission.rawValue)")
          print(
            "     - User identity lookup info: \(participant.userIdentity.lookupInfo?.emailAddress ?? "no email")"
          )
        }

        // Get root record ID (the student record is the root record of the share)
        // The root record is the student record we created the share with
        let studentRecordID = CKRecord.ID(
          recordName: student.id.uuidString, zoneID: customZone.zoneID)
        print("   Root record (student) ID: \(studentRecordID.recordName)")
        print("   Root record zone: \(studentRecordID.zoneID.zoneName)")
        print("   Root record zone owner: \(studentRecordID.zoneID.ownerName)")

        // DIAGNOSTIC: Try to access the share record from the shared database
        print("🔍 DIAGNOSTIC: Attempting to find share record in shared database...")
      }
      // CRITICAL: First try to get zone from share metadata (most reliable)
      // This works even when allRecordZones() returns 0 (zone not yet propagated)
      if let shareURL = shareRecord.url {
        do {
          let shareMetadata = try await container.shareMetadata(for: shareURL)

          // Get the root record ID from metadata - this tells us the actual zone in shared DB
          let rootRecordIDFromMetadata: CKRecord.ID
          if #available(iOS 16.0, *) {
            rootRecordIDFromMetadata =
              shareMetadata.hierarchicalRootRecordID
              ?? CKRecord.ID(recordName: student.id.uuidString, zoneID: customZone.zoneID)
          } else {
            rootRecordIDFromMetadata = shareMetadata.rootRecordID
          }

          // The zone ID from metadata is the actual shared zone
          let sharedZoneID = rootRecordIDFromMetadata.zoneID

          // Try to access the zone directly
          do {
            let sharedZone = try await sharedDatabase.recordZone(for: sharedZoneID)
            if shouldPrintDiagnostics {
              print(
                "✅ Found shared zone via share metadata: \(sharedZoneID.zoneName), owner: \(sharedZoneID.ownerName)"
              )
            }
            return sharedZone
          } catch {
            // Zone might not be accessible yet, continue to other methods
            if shouldPrintDiagnostics {
              print("   ⚠️ Zone from metadata not yet accessible: \(error.localizedDescription)")
            }
          }
        } catch {
          if shouldPrintDiagnostics {
            print("   ⚠️ Could not fetch share metadata: \(error.localizedDescription)")
          }
        }
      }

      // Fallback: Try allRecordZones() (may return 0 if zone not propagated yet)
      let allSharedZonesForDiagnostic = try await sharedDatabase.allRecordZones()
      if shouldPrintDiagnostics {
        print(
          "   Found \(allSharedZonesForDiagnostic.count) zones in shared database for diagnostic search"
        )
      }

      // If we have zones, search through them
      if !allSharedZonesForDiagnostic.isEmpty {
        for zone in allSharedZonesForDiagnostic {
          let shareRecordIDInShared = CKRecord.ID(recordName: shareRecordName, zoneID: zone.zoneID)
          if let shareInShared = try? await sharedDatabase.record(for: shareRecordIDInShared)
            as? CKShare
          {
            if shouldPrintDiagnostics {
              print(
                "✅ DIAGNOSTIC: Found share record in shared database zone: \(zone.zoneID.zoneName)")
              print("   Zone owner: \(zone.zoneID.ownerName)")
              print("   Share participants in shared DB: \(shareInShared.participants.count)")
            }

            // Try to get the root record (student record) from this share
            // The root record is the student record
            let rootRecordIDFromShare = CKRecord.ID(
              recordName: student.id.uuidString, zoneID: zone.zoneID)
            do {
              let rootRecordInShared = try await sharedDatabase.record(for: rootRecordIDFromShare)
              if shouldPrintDiagnostics {
                print("✅ DIAGNOSTIC: Found root record in shared database!")
                print("   Root record zone: \(rootRecordInShared.recordID.zoneID.zoneName)")
                print("   Root record zone owner: \(rootRecordInShared.recordID.zoneID.ownerName)")
                print("   This is the correct shared zone!")
              }
              return zone
            } catch {
              if shouldPrintDiagnostics {
                print(
                  "   ⚠️ DIAGNOSTIC: Could not fetch root record from shared DB: \(error.localizedDescription)"
                )
              }
            }
          }
          // Share not in this zone, continue to next zone
        }
      }
      // If we still don't have zones from allRecordZones(), try searching by student record directly
      // This handles the case where CloudKit hasn't propagated zones yet
      if allSharedZonesForDiagnostic.isEmpty {
        if shouldPrintDiagnostics {
          print(
            "   ⚠️ DIAGNOSTIC: No zones found in allRecordZones() - zone may not be propagated yet")
          print(
            "   💡 This is normal immediately after share acceptance - CloudKit may take a few seconds"
          )
        }
      } else {
        // Try to find student record in the zones we found
        if shouldPrintDiagnostics {
          print(
            "🔍 DIAGNOSTIC: Attempting to access root record (student record) directly in shared database..."
          )
        }
        for zone in allSharedZonesForDiagnostic {
          do {
            let rootRecordIDInShared = CKRecord.ID(
              recordName: student.id.uuidString, zoneID: zone.zoneID)
            let rootRecordInShared = try await sharedDatabase.record(for: rootRecordIDInShared)
            if shouldPrintDiagnostics {
              print(
                "✅ DIAGNOSTIC: Found root record directly in shared zone: \(zone.zoneID.zoneName)")
              print("   Zone owner: \(zone.zoneID.ownerName)")
              print("   Root record ID: \(rootRecordInShared.recordID.recordName)")
            }
            return zone
          } catch {
            // Root record not in this zone, continue to next zone
            continue
          }
        }
      }

      // Step 3: Get all shared zones and search for the student record
      // CRITICAL: Try to access the shared zone directly first
      // The zone name is known: "SharedStudentsZone"
      // CloudKit sharing zones might exist but not appear in allRecordZones() immediately
      if shouldPrintDiagnostics {
        print("🔍 Attempting direct access to shared zone: \(customZoneName)")
      }
      let studentRecordName = student.id.uuidString

      // Try to fetch the student record directly using the known zone name
      // Try multiple owner name variations since shared zones can have different owners
      let zoneNameVariations: [String] = [
        "__defaultOwner__",  // Most common for shared zones
        CKCurrentUserDefaultName,  // Current user default
        customZone.zoneID.ownerName,  // Original zone owner
      ]

      // Also try with the user's record ID as owner
      if let userRecordID = try? await container.userRecordID() {
        let userRecordIDString = userRecordID.recordName
        if !zoneNameVariations.contains(userRecordIDString) {
          // Add user record ID to variations if not already there
          // (We'll handle this separately since it's async)
        }
      }

      for ownerName in zoneNameVariations {
        do {
          let testZoneID = CKRecordZone.ID(zoneName: customZoneName, ownerName: ownerName)
          let studentRecordID = CKRecord.ID(recordName: studentRecordName, zoneID: testZoneID)
          let studentRecord = try await sharedDatabase.record(for: studentRecordID)

          // Found it! The zone exists and we can access it
          print("✅ Found student record in shared zone: \(customZoneName)")
          print("   Zone owner: \(ownerName)")
          print("   Student ID matches: \(studentRecord["studentId"] as? String ?? "unknown")")

          // Return the zone (fetch it to get the full zone object)
          let sharedZone = try await sharedDatabase.recordZone(for: testZoneID)
          return sharedZone
        } catch let error as CKError {
          if error.code == .unknownItem {
            // Not this owner, continue
            continue
          } else if error.localizedDescription.contains("Only shared zones") {
            // This owner name doesn't work for shared DB, continue
            continue
          } else {
            // Some other error, log but continue
            print("   Error with owner '\(ownerName)': \(error.localizedDescription)")
            continue
          }
        } catch {
          // Unexpected error, continue
          continue
        }
      }

      // Also try with user record ID as owner
      if let userRecordID = try? await container.userRecordID() {
        let userRecordIDString = userRecordID.recordName
        do {
          let testZoneID = CKRecordZone.ID(zoneName: customZoneName, ownerName: userRecordIDString)
          let studentRecordID = CKRecord.ID(recordName: studentRecordName, zoneID: testZoneID)
          _ = try await sharedDatabase.record(for: studentRecordID)

          print("✅ Found student record in shared zone using user record ID: \(customZoneName)")
          let sharedZone = try await sharedDatabase.recordZone(for: testZoneID)
          return sharedZone
        } catch {
          // Failed, continue to fallback
        }
      }

      // Fallback: Try allRecordZones() in case the zone appears there
      print("🔍 Fallback: Getting all shared zones to find student record...")
      let allSharedZones = try await sharedDatabase.allRecordZones()
      print("   Found \(allSharedZones.count) shared zones")

      // Step 4: Search each zone for the student record
      for zone in allSharedZones {
        do {
          // Try to fetch the student record directly from this zone
          let studentRecordID = CKRecord.ID(recordName: studentRecordName, zoneID: zone.zoneID)
          let studentRecord = try await sharedDatabase.record(for: studentRecordID)

          // Found the student record - this is the correct zone!
          print("✅ Found student record in shared zone: \(zone.zoneID.zoneName)")
          print("   Zone owner: \(zone.zoneID.ownerName)")
          print("   Student ID matches: \(studentRecord["studentId"] as? String ?? "unknown")")
          return zone
        } catch let error as CKError {
          if error.code == .unknownItem {
            // Student record not in this zone, continue searching
            continue
          } else {
            // Some other error, log it but continue
            print("   Error checking zone \(zone.zoneID.zoneName): \(error.localizedDescription)")
            continue
          }
        } catch {
          // Unexpected error, continue searching
          continue
        }
      }

      // Step 5: If not found by searching zones, try multiple zone ID constructions
      // The shared zone should have the same zone name but might have different owner structure
      print("⚠️ Student record not found in any shared zone - trying direct zone access...")

      // Try 1: Use the custom zone's owner name (most likely to work)
      let directZoneID1 = CKRecordZone.ID(
        zoneName: customZoneName, ownerName: customZone.zoneID.ownerName)
      do {
        let sharedZone = try await sharedDatabase.recordZone(for: directZoneID1)
        print("✅ Found shared zone using custom zone owner: \(sharedZone.zoneID.zoneName)")
        return sharedZone
      } catch {
        print("   Direct zone access with custom owner failed: \(error.localizedDescription)")
      }

      // Try 2: Use __defaultOwner__ (sometimes works in shared database)
      let directZoneID2 = CKRecordZone.ID(
        zoneName: customZoneName, ownerName: CKCurrentUserDefaultName)
      do {
        let sharedZone = try await sharedDatabase.recordZone(for: directZoneID2)
        print("✅ Found shared zone using default owner: \(sharedZone.zoneID.zoneName)")
        return sharedZone
      } catch {
        print("   Direct zone access with default owner failed: \(error.localizedDescription)")
      }

      // Try 3: Get the current user's record ID and use that as owner
      // In shared database, the zone owner is the instructor's user record ID
      do {
        let userRecordID = try await container.userRecordID()
        let directZoneID3 = CKRecordZone.ID(
          zoneName: customZoneName, ownerName: userRecordID.recordName)
        let sharedZone = try await sharedDatabase.recordZone(for: directZoneID3)
        print("✅ Found shared zone using user record ID: \(sharedZone.zoneID.zoneName)")
        return sharedZone
      } catch {
        print("   Direct zone access with user record ID failed: \(error.localizedDescription)")
      }

      // Step 6: If still not found, the zone might not be accessible yet
      print("⚠️ Shared zone not accessible - student record not found in any shared zone")
      print("   Searched \(allSharedZones.count) shared zones")
      print(
        "   Available zones: \(allSharedZones.map { "\($0.zoneID.zoneName) (owner: \($0.zoneID.ownerName))" })"
      )
      print("   This may indicate:")
      print("   - CloudKit is still propagating the shared zone (try again in a few seconds)")
      print("   - The share was just accepted and records haven't synced yet")
      print("   - The student record hasn't been created in the shared zone yet")
      return nil
    } catch let error as CKError {
      print("⚠️ CloudKit error while accessing shared zone: \(error.localizedDescription)")
      print("   Error code: \(error.code.rawValue)")
      return nil
    } catch {
      print("⚠️ Unexpected error accessing shared zone: \(error.localizedDescription)")
      throw error
    }
  }

  /// Creates a CKShare for a specific student and returns the share URL
  func createShareForStudent(_ student: Student, modelContext: ModelContext) async -> URL? {
    print("🚀 Creating share for: \(student.displayName)")
    isSharing = true
    errorMessage = nil

    do {
      // Check CloudKit availability first
      let accountStatus = try await container.accountStatus()
      guard accountStatus == .available else {
        print("❌ CloudKit account not available: \(accountStatus.rawValue)")
        errorMessage = "iCloud account not available. Please sign in to iCloud in Settings."
        isSharing = false
        return nil
      }

      // Ensure custom zone exists (required for sharing)
      let customZone = try await ensureCustomZoneExists()

      // Initialize CloudKit schemas proactively
      // This ensures all schemas exist before we try to sync records
      await initializeCloudKitSchemas()

      // Create student record ID in the custom zone
      let studentRecordID = CKRecord.ID(
        recordName: student.id.uuidString, zoneID: customZone.zoneID)

      // Try to fetch existing record or create new one
      let studentRecord: CKRecord
      if let existingRecord = try? await database.record(for: studentRecordID) {
        studentRecord = existingRecord

        // CRITICAL: Ensure studentId field is set in existing record (for backward compatibility)
        var needsSave = false
        if studentRecord["studentId"] == nil
          || (studentRecord["studentId"] as? String) != student.id.uuidString
        {
          studentRecord["studentId"] = student.id.uuidString
          needsSave = true
          print("   📝 Setting studentId on existing student record: \(student.id.uuidString)")
        }

        // Ensure instructorEmail is set
        if studentRecord["instructorEmail"] == nil {
          if let instructorEmail = try? await getCurrentUserEmail() {
            studentRecord["instructorEmail"] = instructorEmail
            student.instructorEmail = instructorEmail
            needsSave = true
            print("   📧 Setting instructor email: \(instructorEmail)")
          }
        }

        // Check if share already exists
        if let existingShare = studentRecord.share {
          let shareRecord = try await database.record(for: existingShare.recordID)
          if let share = shareRecord as? CKShare {
            // If we updated the studentId field, save it before returning
            if needsSave {
              do {
                _ = try await database.save(studentRecord)
                print("   ✅ Saved studentId update to CloudKit")
              } catch {
                print("   ⚠️ Failed to save studentId update: \(error)")
              }
            }
            shareURL = share.url
            isSharing = false
            print("✅ Returning existing share URL")
            return share.url
          }
        }
      } else {
        // Create new student record
        studentRecord = CKRecord(recordType: "Student", recordID: studentRecordID)
        studentRecord["firstName"] = student.firstName
        studentRecord["lastName"] = student.lastName
        studentRecord["email"] = student.email
        studentRecord["telephone"] = student.telephone
        studentRecord["homeAddress"] = student.homeAddress
        studentRecord["ftnNumber"] = student.ftnNumber
        studentRecord["biography"] = student.biography
        studentRecord["backgroundNotes"] = student.backgroundNotes
        studentRecord["instructorName"] = student.instructorName
        studentRecord["instructorCFINumber"] = student.instructorCFINumber
        studentRecord["lastModified"] = student.lastModified

        // Training goals
        studentRecord["goalPPL"] = student.goalPPL
        studentRecord["goalInstrument"] = student.goalInstrument
        studentRecord["goalCommercial"] = student.goalCommercial
        studentRecord["goalCFI"] = student.goalCFI

        // Training milestones - PPL
        studentRecord["pplGroundSchoolCompleted"] = student.pplGroundSchoolCompleted
        studentRecord["pplWrittenTestCompleted"] = student.pplWrittenTestCompleted

        // Training milestones - Instrument
        studentRecord["instrumentGroundSchoolCompleted"] = student.instrumentGroundSchoolCompleted
        studentRecord["instrumentWrittenTestCompleted"] = student.instrumentWrittenTestCompleted

        // Training milestones - Commercial
        studentRecord["commercialGroundSchoolCompleted"] = student.commercialGroundSchoolCompleted
        studentRecord["commercialWrittenTestCompleted"] = student.commercialWrittenTestCompleted

        // Training milestones - CFI
        studentRecord["cfiGroundSchoolCompleted"] = student.cfiGroundSchoolCompleted
        studentRecord["cfiWrittenTestCompleted"] = student.cfiWrittenTestCompleted

        // CRITICAL: Store studentId explicitly in the record so student app can read it
        // This ensures student app uses the same ID when querying for assignments
        studentRecord["studentId"] = student.id.uuidString

        // Store instructor email for identity validation
        if let instructorEmail = try? await getCurrentUserEmail() {
          studentRecord["instructorEmail"] = instructorEmail
          student.instructorEmail = instructorEmail
          print("   📧 Stored instructor email: \(instructorEmail)")
        }

        // Save the record first to the custom zone
        do {
          let savedRecord = try await database.save(studentRecord)
          // Use the saved record for sharing
          studentRecord.setValuesForKeys(
            savedRecord.dictionaryWithValues(forKeys: Array(savedRecord.allKeys())))
        } catch let saveError as CKError {
          // Check if this is a schema deployment error
          let errorDescription = saveError.localizedDescription.lowercased()
          if errorDescription.contains("cannot create new type")
            || errorDescription.contains("production schema")
            || errorDescription.contains("not deployed")
          {
            // Re-throw so it gets caught by the outer catch block with proper error message
            throw saveError
          }
          // Re-throw other errors
          throw saveError
        }
      }

      // CRITICAL: Clear any previous shareTerminated flag when creating a new share
      // This ensures student app doesn't see stale termination flags from previous unlinks
      studentRecord["shareTerminated"] = false
      studentRecord["shareTerminatedAt"] = nil
      print("   🔄 Cleared previous shareTerminated flag (if any)")

      // Create a new share
      let share = CKShare(rootRecord: studentRecord)

      // Configure share permissions
      share[CKShare.SystemFieldKey.title] =
        "Student Profile: \(student.displayName)" as CKRecordValue
      // Note: Not setting shareType to avoid iOS version check - let the app handle the share directly

      // CRITICAL: Set public permission to readWrite for bidirectional fields
      // Student can read instructor data (read-only) but can write student-owned and bidirectional fields
      share.publicPermission = .readWrite

      // Save both the share and the record using the modify API
      let modifyResult = try await database.modifyRecords(
        saving: [studentRecord, share],
        deleting: [],
        savePolicy: .changedKeys
      )

      // Get the saved records from the result
      var savedShare: CKShare?
      for (recordID, result) in modifyResult.saveResults {
        switch result {
        case .success(let record):
          if let share = record as? CKShare {
            savedShare = share
          }
        case .failure(let error):
          print("❌ Failed to save record \(recordID.recordName): \(error)")
          // Check if this is a schema deployment error
          if let ckError = error as? CKError {
            let errorDescription = ckError.localizedDescription.lowercased()
            if errorDescription.contains("cannot create new type")
              || errorDescription.contains("production schema")
              || errorDescription.contains("not deployed")
            {
              // Re-throw as CKError so it gets caught by the outer catch block
              throw ckError
            }
          }
          throw error
        }
      }

      // Use the share we just created if we can't find it in results
      if savedShare == nil {
        savedShare = share
      }

      guard let finalShare = savedShare, let shareURL = finalShare.url else {
        throw NSError(
          domain: "CloudKitShareService", code: -1,
          userInfo: [NSLocalizedDescriptionKey: "Share was saved but has no URL"])
      }

      print("✅ Share created successfully: \(shareURL.absoluteString)")
      print("   - Share public permission: \(finalShare.publicPermission.rawValue)")
      print("   - Share participants count: \(finalShare.participants.count)")
      print("   - Share can be accepted by: Anyone with the URL (public permission enabled)")
      print("   ℹ️ Note: This share works for any Apple ID, regardless of Family Sharing status")

      // Update student's CloudKit record ID
      student.cloudKitRecordID = studentRecord.recordID.recordName
      student.shareRecordID = finalShare.recordID.recordName
      student.lastModified = Date()

      try modelContext.save()

      // NEW ARCHITECTURE: Initialize the three new record types in the share zone
      // These will be accessible through the share once the student accepts it
      print("🔄 Initializing new record types in share zone...")

      // 1. Create StudentPersonalInfoRecord
      let personalInfoRecord = createStudentPersonalInfoRecord(from: student)
      let personalInfoRecordID = CKRecord.ID(
        recordName: "\(student.id.uuidString)-personal-info", zoneID: customZone.zoneID)
      let personalInfoCKRecord = personalInfoRecord.toCKRecord(recordID: personalInfoRecordID)
      personalInfoCKRecord.parent = CKRecord.Reference(recordID: studentRecordID, action: .none)

      // 2. Create TrainingGoalsRecord
      let trainingGoalsRecord = createTrainingGoalsRecord(from: student)
      let trainingGoalsRecordID = CKRecord.ID(
        recordName: "\(student.id.uuidString)-training-goals", zoneID: customZone.zoneID)
      let trainingGoalsCKRecord = trainingGoalsRecord.toCKRecord(recordID: trainingGoalsRecordID)
      trainingGoalsCKRecord.parent = CKRecord.Reference(recordID: studentRecordID, action: .none)

      // Save the new record types to the zone
      // Handle "record already exists" errors gracefully - these are expected if records were created previously
      do {
        _ = try await database.save(personalInfoCKRecord)
        print("   ✅ Created StudentPersonalInfoRecord")
      } catch let error as CKError {
        if error.code == .serverRecordChanged {
          // Record already exists - this is fine, just update it
          do {
            _ = try await saveRecordWithConflictResolution(personalInfoCKRecord, database: database)
            print("   ✅ Updated existing StudentPersonalInfoRecord")
          } catch {
            print("   ⚠️ Failed to update StudentPersonalInfoRecord: \(error)")
          }
        } else {
          print("   ⚠️ Failed to create StudentPersonalInfoRecord: \(error)")
        }
      } catch {
        print("   ⚠️ Failed to create StudentPersonalInfoRecord: \(error)")
      }

      do {
        _ = try await database.save(trainingGoalsCKRecord)
        print("   ✅ Created TrainingGoalsRecord")
      } catch let error as CKError {
        if error.code == .serverRecordChanged {
          // Record already exists - this is fine, just update it
          do {
            _ = try await saveRecordWithConflictResolution(
              trainingGoalsCKRecord, database: database)
            print("   ✅ Updated existing TrainingGoalsRecord")
          } catch {
            print("   ⚠️ Failed to update TrainingGoalsRecord: \(error)")
          }
        } else {
          print("   ⚠️ Failed to create TrainingGoalsRecord: \(error)")
        }
      } catch {
        print("   ⚠️ Failed to create TrainingGoalsRecord: \(error)")
      }

      // 3. Create ALL student records in the private zone immediately
      // CRITICAL: Create all records (assignments, progress, custom definitions) in the private zone
      // These will automatically be available in the shared database once the student accepts the share
      print(
        "🔄 Creating all student records in private zone (will be available in shared zone once accepted)..."
      )
      let assignments = student.checklistAssignments ?? []
      print("📋 Found \(assignments.count) assignments to create")

      // CRITICAL: Create all records synchronously so they're ready when share URL is returned
      // This ensures the shared space is fully populated when the student accepts
      var createdCount = 0
      for assignment in assignments {
        do {
          // Create ChecklistAssignmentRecord with embedded ItemProgress
          let assignmentRecord = createChecklistAssignmentRecord(from: assignment, student: student)
          let assignmentRecordID = CKRecord.ID(
            recordName: assignment.id.uuidString, zoneID: customZone.zoneID)
          let assignmentCKRecord = assignmentRecord.toCKRecord(recordID: assignmentRecordID)
          assignmentCKRecord.parent = CKRecord.Reference(recordID: studentRecordID, action: .none)

          // Save assignment record to private zone
          _ = try await database.save(assignmentCKRecord)
          createdCount += 1
          print(
            "   ✅ Created assignment \(createdCount)/\(assignments.count): \(assignment.templateIdentifier ?? "unknown") (with all ItemProgress)"
          )

          // If this is a custom checklist, also create the CustomChecklistDefinition
          if assignment.isCustomChecklist, let template = assignment.template {
            let definitionRecordID = CKRecord.ID(
              recordName: "custom-definition-\(assignment.templateId.uuidString)",
              zoneID: customZone.zoneID)
            let existingDefinitionRecord = try? await database.record(for: definitionRecordID)

            let definitionRecord: CKRecord
            if let existing = existingDefinitionRecord {
              definitionRecord = existing
            } else {
              definitionRecord = CKRecord(
                recordType: "CustomChecklistDefinition", recordID: definitionRecordID)
            }

            definitionRecord["templateId"] = assignment.templateId.uuidString
            definitionRecord["customName"] = template.name
            definitionRecord["customCategory"] = template.category
            definitionRecord["studentId"] = student.id.uuidString
            definitionRecord["lastModified"] = Date()

            // Serialize template items as custom items
            if let templateItems = template.items {
              let customItems = templateItems.map { item -> [String: Any] in
                [
                  "id": item.id.uuidString,
                  "title": item.title,
                  "notes": item.notes ?? "",
                  "order": item.order,
                ]
              }

              if let jsonData = try? JSONSerialization.data(withJSONObject: customItems),
                let jsonString = String(data: jsonData, encoding: .utf8)
              {
                definitionRecord["customItems"] = jsonString
              } else {
                definitionRecord["customItems"] = "[]"
              }
            } else {
              definitionRecord["customItems"] = "[]"
            }

            definitionRecord.parent = CKRecord.Reference(recordID: studentRecordID, action: .none)

            do {
              _ = try await database.save(definitionRecord)
              print("      ✅ Created CustomChecklistDefinition for custom checklist")
            } catch {
              print("      ⚠️ Failed to create CustomChecklistDefinition: \(error)")
            }
          }
        } catch {
          print(
            "   ⚠️ Failed to create assignment \(assignment.templateIdentifier ?? "unknown"): \(error)"
          )
        }
      }

      print("✅ Created \(createdCount)/\(assignments.count) assignments in private zone")
      print(
        "   All records are now ready and will be available in shared zone once student accepts the share"
      )

      self.shareURL = shareURL
      isSharing = false

      return shareURL

    } catch let error as CKError {
      print("❌ CLOUDKIT ERROR during share creation:")
      print("  - Error: \(error)")
      print("  - Error code: \(error.errorCode)")
      print("  - Description: \(error.localizedDescription)")
      print("  - Retry after: \(error.retryAfterSeconds ?? 0)")
      if let underlyingError = error.errorUserInfo[NSUnderlyingErrorKey] as? Error {
        print("  - Underlying error: \(underlyingError)")
      }
      if let partialErrors = error.partialErrorsByItemID {
        print("  - Partial errors: \(partialErrors)")
      }

      // Check for Production schema deployment errors
      let errorDescription = error.localizedDescription.lowercased()
      if errorDescription.contains("cannot create new type")
        || errorDescription.contains("production schema")
        || errorDescription.contains("not deployed") || error.code == .invalidArguments
      {
        // This is a ONE-TIME schema deployment issue in Production
        // After schemas are deployed, unlimited records can be created automatically
        errorMessage = """
          CloudKit Schema Not Deployed (One-Time Setup Required)

          This is a ONE-TIME developer setup issue that must be completed before publishing the app.
          After deployment, unlimited Student records can be created automatically - no manual steps needed.

          Required Action (Developer Only):
          1. Deploy all record types to Production CloudKit schema via CloudKit Dashboard
          2. See docs/guides/CLOUDKIT_SCHEMA_DEPLOYMENT.md for complete instructions
          3. Required record types: Student, ChecklistAssignment, ItemProgress, StudentDocument, StudentPersonalInfo, TrainingGoals, CustomChecklistDefinition
          4. Wait 2-5 minutes for deployment to propagate
          5. Test share creation again

          Note: This is a pre-release setup task. Once deployed, all users can create shares automatically.
          """
      } else {
        errorMessage = "CloudKit error: \(error.localizedDescription)"
      }
      isSharing = false
      return nil
    } catch {
      print("❌ GENERAL ERROR during share creation:")
      print("  - Error: \(error)")
      print("  - Type: \(type(of: error))")
      print("  - Description: \(error.localizedDescription)")
      errorMessage = "Failed to create share: \(error.localizedDescription)"
      isSharing = false
      return nil
    }
  }

  /// Deletes all shared zone data for a student when unlinking
  /// This includes all ChecklistAssignment, ItemProgress, StudentDocument, and related records
  private func deleteAllSharedZoneData(for student: Student) async throws {
    print("🗑️ Starting deletion of all shared zone data for student: \(student.displayName)")

    // Get the shared zone - this is where all the data lives
    guard let sharedZone = try? await getSharedZone(for: student) else {
      print("⚠️ Could not access shared zone - may not be shared yet or already deleted")
      return
    }

    let sharedDatabase = container.sharedCloudDatabase
    let studentIdString = student.id.uuidString
    var totalDeleted = 0

    // 1. Delete all ChecklistAssignment records
    print("   🗑️ Deleting ChecklistAssignment records...")
    do {
      let assignmentPredicate = NSPredicate(format: "studentId == %@", studentIdString)
      let assignmentQuery = CKQuery(
        recordType: "ChecklistAssignment", predicate: assignmentPredicate)
      let assignmentResults = try await sharedDatabase.records(
        matching: assignmentQuery, inZoneWith: sharedZone.zoneID)

      var assignmentRecordIDs: [CKRecord.ID] = []
      for (_, result) in assignmentResults.matchResults {
        switch result {
        case .success(let record):
          assignmentRecordIDs.append(record.recordID)
        case .failure:
          continue
        }
      }

      // Delete assignments in batches
      if !assignmentRecordIDs.isEmpty {
        let batchSize = 400  // CloudKit batch limit
        for i in stride(from: 0, to: assignmentRecordIDs.count, by: batchSize) {
          let batch = Array(assignmentRecordIDs[i..<min(i + batchSize, assignmentRecordIDs.count)])
          do {
            let deleteResults = try await sharedDatabase.modifyRecords(saving: [], deleting: batch)
            for (_, result) in deleteResults.deleteResults {
              if case .success = result {
                totalDeleted += 1
              }
            }
          } catch {
            print("   ⚠️ Error deleting assignment batch: \(error)")
          }
        }
        print("   ✅ Deleted \(assignmentRecordIDs.count) ChecklistAssignment records")
      }

      // 2. Delete all ItemProgress records
      // Query all ItemProgress records in the zone and filter by assignmentId
      print("   🗑️ Deleting ItemProgress records...")
      var progressRecordIDs: [CKRecord.ID] = []

      // Get all assignment IDs as strings for querying
      let assignmentIds = assignmentRecordIDs.map { $0.recordName }

      if !assignmentIds.isEmpty {
        // Query ItemProgress records by assignmentId
        let progressPredicate = NSPredicate(format: "assignmentId IN %@", assignmentIds)
        let progressQuery = CKQuery(recordType: "ItemProgress", predicate: progressPredicate)
        let progressResults = try await sharedDatabase.records(
          matching: progressQuery, inZoneWith: sharedZone.zoneID)

        for (_, result) in progressResults.matchResults {
          switch result {
          case .success(let record):
            progressRecordIDs.append(record.recordID)
          case .failure:
            continue
          }
        }
      }

      // Also query all ItemProgress records in the zone to catch any orphaned records
      // This ensures we get everything, even if assignmentId field is missing
      let allProgressPredicate = NSPredicate(value: true)
      let allProgressQuery = CKQuery(recordType: "ItemProgress", predicate: allProgressPredicate)
      let allProgressResults = try await sharedDatabase.records(
        matching: allProgressQuery, inZoneWith: sharedZone.zoneID)

      for (_, result) in allProgressResults.matchResults {
        switch result {
        case .success(let record):
          // Add if not already in our list
          if !progressRecordIDs.contains(record.recordID) {
            progressRecordIDs.append(record.recordID)
          }
        case .failure:
          continue
        }
      }

      // Delete progress records in batches
      if !progressRecordIDs.isEmpty {
        let batchSize = 400
        for i in stride(from: 0, to: progressRecordIDs.count, by: batchSize) {
          let batch = Array(progressRecordIDs[i..<min(i + batchSize, progressRecordIDs.count)])
          do {
            let deleteResults = try await sharedDatabase.modifyRecords(saving: [], deleting: batch)
            for (_, result) in deleteResults.deleteResults {
              if case .success = result {
                totalDeleted += 1
              }
            }
          } catch {
            print("   ⚠️ Error deleting progress batch: \(error)")
          }
        }
        print("   ✅ Deleted \(progressRecordIDs.count) ItemProgress records")
      }
    } catch {
      print("   ⚠️ Error deleting assignments/progress: \(error)")
    }

    // 3. Delete all StudentDocument records
    print("   🗑️ Deleting StudentDocument records...")
    do {
      let documentPredicate = NSPredicate(format: "studentId == %@", studentIdString)
      let documentQuery = CKQuery(recordType: "StudentDocument", predicate: documentPredicate)
      let documentResults = try await sharedDatabase.records(
        matching: documentQuery, inZoneWith: sharedZone.zoneID)

      var documentRecordIDs: [CKRecord.ID] = []
      for (_, result) in documentResults.matchResults {
        switch result {
        case .success(let record):
          documentRecordIDs.append(record.recordID)
        case .failure:
          continue
        }
      }

      if !documentRecordIDs.isEmpty {
        let deleteResults = try await sharedDatabase.modifyRecords(
          saving: [], deleting: documentRecordIDs)
        var deletedCount = 0
        for (_, result) in deleteResults.deleteResults {
          if case .success = result {
            deletedCount += 1
            totalDeleted += 1
          }
        }
        print("   ✅ Deleted \(deletedCount) StudentDocument records")
      }
    } catch {
      print("   ⚠️ Error deleting documents: \(error)")
    }

    // 4. Delete StudentPersonalInfo record
    print("   🗑️ Deleting StudentPersonalInfo record...")
    do {
      let personalInfoRecordID = CKRecord.ID(
        recordName: "\(studentIdString)-personal-info", zoneID: sharedZone.zoneID)
      try await sharedDatabase.deleteRecord(withID: personalInfoRecordID)
      totalDeleted += 1
      print("   ✅ Deleted StudentPersonalInfo record")
    } catch let error as CKError where error.code == .unknownItem {
      print("   ℹ️ StudentPersonalInfo record not found (may have already been deleted)")
    } catch {
      print("   ⚠️ Error deleting StudentPersonalInfo: \(error)")
    }

    // 5. Delete TrainingGoals record
    print("   🗑️ Deleting TrainingGoals record...")
    do {
      let trainingGoalsRecordID = CKRecord.ID(
        recordName: "\(studentIdString)-training-goals", zoneID: sharedZone.zoneID)
      try await sharedDatabase.deleteRecord(withID: trainingGoalsRecordID)
      totalDeleted += 1
      print("   ✅ Deleted TrainingGoals record")
    } catch let error as CKError where error.code == .unknownItem {
      print("   ℹ️ TrainingGoals record not found (may have already been deleted)")
    } catch {
      print("   ⚠️ Error deleting TrainingGoals: \(error)")
    }

    // 6. Delete CustomChecklistDefinition records
    print("   🗑️ Deleting CustomChecklistDefinition records...")
    do {
      let customPredicate = NSPredicate(format: "studentId == %@", studentIdString)
      let customQuery = CKQuery(recordType: "CustomChecklistDefinition", predicate: customPredicate)
      let customResults = try await sharedDatabase.records(
        matching: customQuery, inZoneWith: sharedZone.zoneID)

      var customRecordIDs: [CKRecord.ID] = []
      for (_, result) in customResults.matchResults {
        switch result {
        case .success(let record):
          customRecordIDs.append(record.recordID)
        case .failure:
          continue
        }
      }

      if !customRecordIDs.isEmpty {
        let deleteResults = try await sharedDatabase.modifyRecords(
          saving: [], deleting: customRecordIDs)
        var deletedCount = 0
        for (_, result) in deleteResults.deleteResults {
          if case .success = result {
            deletedCount += 1
            totalDeleted += 1
          }
        }
        print("   ✅ Deleted \(deletedCount) CustomChecklistDefinition records")
      }
    } catch {
      print("   ⚠️ Error deleting CustomChecklistDefinition: \(error)")
    }

    // 7. Delete EndorsementImage records
    print("   🗑️ Deleting EndorsementImage records...")
    do {
      let endorsementPredicate = NSPredicate(format: "studentId == %@", studentIdString)
      let endorsementQuery = CKQuery(
        recordType: "EndorsementImage", predicate: endorsementPredicate)
      let endorsementResults = try await sharedDatabase.records(
        matching: endorsementQuery, inZoneWith: sharedZone.zoneID)

      var endorsementRecordIDs: [CKRecord.ID] = []
      for (_, result) in endorsementResults.matchResults {
        switch result {
        case .success(let record):
          endorsementRecordIDs.append(record.recordID)
        case .failure:
          continue
        }
      }

      if !endorsementRecordIDs.isEmpty {
        let deleteResults = try await sharedDatabase.modifyRecords(
          saving: [], deleting: endorsementRecordIDs)
        var deletedCount = 0
        for (_, result) in deleteResults.deleteResults {
          if case .success = result {
            deletedCount += 1
            totalDeleted += 1
          }
        }
        print("   ✅ Deleted \(deletedCount) EndorsementImage records")
      }
    } catch {
      print("   ⚠️ Error deleting EndorsementImage: \(error)")
    }

    print("✅ Completed deletion of shared zone data - total records deleted: \(totalDeleted)")
  }

  /// Removes sharing for a student
  /// This will be detected by the student app on next sync or when they check share status
  /// CRITICAL: This deletes ALL data in the shared zone before removing the share
  func removeShareForStudent(_ student: Student, modelContext: ModelContext) async -> Bool {
    guard let shareRecordName = student.shareRecordID else {
      print("No share record ID found for student")
      return false
    }

    do {
      // FIRST: Delete all shared zone data before removing the share
      do {
        try await deleteAllSharedZoneData(for: student)
        print("✅ All shared zone data deleted successfully")
      } catch {
        print("⚠️ Error deleting shared zone data (continuing with share removal): \(error)")
        // Continue with share removal even if data deletion fails
      }

      let customZone = try await ensureCustomZoneExists()
      let shareRecordID = CKRecord.ID(recordName: shareRecordName, zoneID: customZone.zoneID)

      // Mark the student record as unshared (add a flag that student app can check)
      let studentRecordID = CKRecord.ID(
        recordName: student.id.uuidString, zoneID: customZone.zoneID)
      if let studentRecord = try? await database.record(for: studentRecordID) {
        // Set a flag that sharing is terminated
        studentRecord["shareTerminated"] = true
        studentRecord["shareTerminatedAt"] = Date()
        do {
          try await database.save(studentRecord)
          print("📢 Marked student record as share terminated")
        } catch {
          print("⚠️ Failed to mark share as terminated (non-critical): \(error)")
        }
      }

      // Delete the share record - this will notify the student app that sharing has ended
      try await database.deleteRecord(withID: shareRecordID)

      student.shareRecordID = nil
      student.lastModified = Date()
      try await modelContext.saveSafely()

      print(
        "✅ Share removed successfully - all shared data deleted, student app will detect this on next sync"
      )
      return true
    } catch {
      print("Failed to remove share: \(error)")
      errorMessage = "Failed to remove share: \(error.localizedDescription)"
      return false
    }
  }

  /// Validates a share URL and provides debugging information
  func validateShareURL(_ url: URL) async -> (isValid: Bool, error: String?) {
    // For now, we'll assume the URL is valid if it's a proper CloudKit share URL
    // The actual validation will happen when the student app tries to accept the share
    if url.absoluteString.contains("icloud.com/share") {
      print("Share URL appears to be valid CloudKit share URL")
      return (true, nil)
    } else {
      print("Share URL does not appear to be a valid CloudKit share URL")
      return (false, "Invalid share URL format")
    }
  }

  /// Accepts a CloudKit share from a URL string
  /// This method is designed for the student app to handle manual URL pasting
  /// - Parameter urlString: The share URL as a string (can be pasted from anywhere)
  /// - Returns: A tuple with success status and error message (if any)
  func acceptShareFromURL(_ urlString: String) async -> (success: Bool, error: String?) {
    print("🔗 Attempting to accept share from URL: \(urlString)")

    // Step 1: Convert string to URL
    guard let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
      let error = "Invalid URL format. Please check the URL and try again."
      print("❌ \(error)")
      errorMessage = error
      return (false, error)
    }

    // Step 2: Validate URL format
    guard url.absoluteString.contains("icloud.com/share") else {
      let error =
        "This doesn't appear to be a valid CloudKit share URL. Please check the URL and try again."
      print("❌ \(error)")
      errorMessage = error
      return (false, error)
    }

    // Step 3: Check CloudKit account status
    do {
      let accountStatus = try await container.accountStatus()
      guard accountStatus == .available else {
        let error = "iCloud account not available. Please sign in to iCloud in Settings."
        print("❌ \(error)")
        errorMessage = error
        return (false, error)
      }
    } catch {
      let error = "Failed to check iCloud account status: \(error.localizedDescription)"
      print("❌ \(error)")
      errorMessage = error
      return (false, error)
    }

    // Step 4: Fetch share metadata from URL (with retry logic)
    var metadata: CKShare.Metadata?
    var metadataFetchError: Error?

    // Try fetching metadata with retries (sometimes CloudKit needs a moment to propagate)
    for attempt in 1...3 {
      do {
        print("📥 Fetching share metadata from URL (attempt \(attempt)/3)...")
        metadata = try await container.shareMetadata(for: url)
        print("✅ Share metadata received successfully")
        // Note: rootRecordID is deprecated in iOS 16.0 but still functional
        // We'll get the root record ID from the accepted share instead
        print("   - Container identifier: \(metadata!.containerIdentifier)")
        // ownerIdentity is not optional, access directly
        let ownerIdentity = metadata!.ownerIdentity
        print("   - Owner identity: \(ownerIdentity.lookupInfo?.emailAddress ?? "Unknown")")
        metadataFetchError = nil
        break
      } catch let error as CKError {
        metadataFetchError = error
        print("❌ Failed to fetch share metadata (attempt \(attempt)/3):")
        print("   - Error code: \(error.errorCode)")
        print("   - Error: \(error.localizedDescription)")

        // If it's unknownItem, don't retry - the share doesn't exist
        if error.code == .unknownItem {
          print("   - Share not found - will not retry")
          break
        }

        // For other errors, wait and retry
        if attempt < 3 {
          let delay = Double(attempt) * 1.0  // 1s, 2s delays
          print("   - Retrying in \(delay) seconds...")
          try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
      } catch {
        metadataFetchError = error
        print(
          "❌ Failed to fetch share metadata (attempt \(attempt)/3): \(error.localizedDescription)")
        if attempt < 3 {
          let delay = Double(attempt) * 1.0
          try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
      }
    }

    // Check if metadata fetch failed
    guard let shareMetadata = metadata else {
      if let ckError = metadataFetchError as? CKError {
        var userFriendlyError: String
        switch ckError.code {
        case .unknownItem:
          userFriendlyError =
            "Share not found. The share link may be invalid, expired, or the instructor may have removed it. Please ask your instructor to send a new link."
        case .notAuthenticated:
          userFriendlyError =
            "You are not signed in to iCloud. Please sign in to iCloud in Settings and try again."
        case .networkUnavailable, .networkFailure:
          userFriendlyError = "No internet connection. Please check your network and try again."
        case .serviceUnavailable:
          userFriendlyError =
            "CloudKit service is temporarily unavailable. Please try again in a few moments."
        default:
          userFriendlyError =
            "Failed to fetch share information: \(ckError.localizedDescription). Please try again."
        }
        errorMessage = userFriendlyError
        return (false, userFriendlyError)
      } else {
        let error =
          "Failed to fetch share information: \(metadataFetchError?.localizedDescription ?? "Unknown error"). Please try again."
        errorMessage = error
        return (false, error)
      }
    }

    // Step 5: Accept the share (with retry logic)
    for attempt in 1...3 {
      do {
        print("📝 Accepting share (attempt \(attempt)/3)...")
        let shareRecord = try await container.accept(shareMetadata)
        print("✅ Share accepted successfully!")
        print("   - Share record ID: \(shareRecord.recordID.recordName)")
        // Get title from share record using SystemFieldKey
        let shareTitle = shareRecord[CKShare.SystemFieldKey.title] as? String ?? "No title"
        print("   - Share title: \(shareTitle)")

        errorMessage = nil
        return (true, nil)

      } catch let error as CKError {
        print("❌ CLOUDKIT ERROR during share acceptance (attempt \(attempt)/3):")
        print("   - Error code: \(error.errorCode)")
        print("   - Description: \(error.localizedDescription)")
        print("   - Error: \(error)")

        // Log additional diagnostic info
        if let underlyingError = error.errorUserInfo[NSUnderlyingErrorKey] as? Error {
          print("   - Underlying error: \(underlyingError)")
        }
        if let partialErrors = error.partialErrorsByItemID {
          print("   - Partial errors: \(partialErrors)")
        }

        var userFriendlyError: String

        switch error.code {
        case .unknownItem:
          userFriendlyError =
            "Share not found. The share may have been removed or expired. Please ask your instructor to send a new link."
        case .notAuthenticated:
          userFriendlyError =
            "You are not signed in to iCloud. Please sign in to iCloud in Settings and try again."
        case .quotaExceeded:
          userFriendlyError = "Your iCloud storage is full. Please free up space and try again."
        case .networkUnavailable, .networkFailure:
          userFriendlyError = "No internet connection. Please check your network and try again."
          // Retry network errors
          if attempt < 3 {
            let delay = Double(attempt) * 1.0
            print("   - Retrying in \(delay) seconds...")
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            continue
          }
        case .serviceUnavailable:
          userFriendlyError =
            "CloudKit service is temporarily unavailable. Please try again in a few moments."
          // Retry service unavailable errors
          if attempt < 3 {
            let delay = Double(attempt) * 1.0
            print("   - Retrying in \(delay) seconds...")
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            continue
          }
        case .participantMayNeedVerification:
          userFriendlyError =
            "Your iCloud account needs verification. Please check your iCloud settings and try again."
        case .invalidArguments:
          userFriendlyError = "Invalid share URL. Please check the URL and try again."
        case .permissionFailure:
          userFriendlyError =
            "You don't have permission to accept this share. Please contact your instructor."
        default:
          userFriendlyError =
            "Failed to accept share: \(error.localizedDescription). Please try again."
        }

        // Don't retry for certain errors
        if error.code == .unknownItem || error.code == .notAuthenticated
          || error.code == .quotaExceeded || error.code == .permissionFailure
          || error.code == .invalidArguments
        {
          errorMessage = userFriendlyError
          return (false, userFriendlyError)
        }

        // For other errors, retry if we have attempts left
        if attempt < 3 {
          let delay = Double(attempt) * 1.0
          print("   - Retrying in \(delay) seconds...")
          try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        } else {
          errorMessage = userFriendlyError
          return (false, userFriendlyError)
        }

      } catch {
        print("❌ GENERAL ERROR during share acceptance (attempt \(attempt)/3):")
        print("   - Error: \(error)")
        print("   - Type: \(type(of: error))")
        print("   - Description: \(error.localizedDescription)")

        if attempt < 3 {
          let delay = Double(attempt) * 1.0
          try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        } else {
          let error = "Failed to accept share: \(error.localizedDescription). Please try again."
          errorMessage = error
          return (false, error)
        }
      }
    }

    // Should never reach here, but just in case
    let error = "Failed to accept share after multiple attempts. Please try again."
    errorMessage = error
    return (false, error)
  }

  /// Gets the current CloudKit user's email address
  /// Note: Direct user identity lookup is deprecated in iOS 17+
  /// We'll set instructorEmail when creating the share from the share metadata
  private func getCurrentUserEmail() async throws -> String? {
    // Note: userIdentity(forUserRecordID:) is deprecated in iOS 17+
    // For now, return nil - the instructorEmail should be set from share metadata
    // when the share is accepted by the student app
    return nil
  }

  /// Checks for student-initiated unlink and returns true if detected
  /// If detected, clears the shareRecordID and returns true
  func checkForStudentInitiatedUnlink(for student: Student, modelContext: ModelContext) async
    -> Bool
  {
    guard student.shareRecordID != nil else {
      return false
    }

    do {
      // Try to get the shared zone
      guard let sharedZone = try? await getSharedZone(for: student) else {
        // If we can't get the shared zone, the share may have been removed
        // Check if student record exists in private database
        let customZone = try await ensureCustomZoneExists()
        let studentRecordID = CKRecord.ID(
          recordName: student.id.uuidString, zoneID: customZone.zoneID)

        if let studentRecord = try? await database.record(for: studentRecordID) {
          // Check for studentInitiatedUnlink flag
          let studentInitiatedUnlink: Bool = {
            let rawValue = studentRecord["studentInitiatedUnlink"]
            if let boolValue = rawValue as? Bool {
              return boolValue
            } else if let numberValue = rawValue as? NSNumber {
              return numberValue.boolValue
            }
            return false
          }()

          if studentInitiatedUnlink {
            print("📢 Student-initiated unlink detected for: \(student.displayName)")
            // Clear the flag and shareRecordID
            studentRecord["studentInitiatedUnlink"] = false
            student.shareRecordID = nil
            student.lastModified = Date()

            do {
              try await database.save(studentRecord)
              try await modelContext.saveSafely()
              print("✅ Cleared student-initiated unlink flag and shareRecordID")
              return true
            } catch {
              print("⚠️ Failed to clear unlink flag: \(error)")
            }
          }
        }
        return false
      }

      // Check in shared database
      let sharedDatabase = container.sharedCloudDatabase
      let studentRecordID = CKRecord.ID(
        recordName: student.id.uuidString, zoneID: sharedZone.zoneID)

      if let studentRecord = try? await sharedDatabase.record(for: studentRecordID) {
        let studentInitiatedUnlink: Bool = {
          let rawValue = studentRecord["studentInitiatedUnlink"]
          if let boolValue = rawValue as? Bool {
            return boolValue
          } else if let numberValue = rawValue as? NSNumber {
            return numberValue.boolValue
          }
          return false
        }()

        if studentInitiatedUnlink {
          print("📢 Student-initiated unlink detected for: \(student.displayName)")

          // Clear the flag in CloudKit
          studentRecord["studentInitiatedUnlink"] = false
          do {
            try await sharedDatabase.save(studentRecord)
          } catch {
            print("⚠️ Failed to clear unlink flag in CloudKit: \(error)")
          }

          // Update local student record
          student.shareRecordID = nil
          student.lastModified = Date()
          try await modelContext.saveSafely()

          print("✅ Cleared student-initiated unlink flag and shareRecordID")
          return true
        }
      }

      return false
    } catch {
      print("⚠️ Error checking for student-initiated unlink: \(error)")
      return false
    }
  }

  /// Checks if a student has an active share
  /// Returns true only if:
  /// 1. shareRecordID exists
  /// 2. Share record exists in CloudKit
  /// 3. Share has participants (meaning student has accepted the invitation)
  func hasActiveShare(for student: Student) async -> Bool {
    guard let shareRecordName = student.shareRecordID else {
      return false
    }

    do {
      let customZone = try await ensureCustomZoneExists()
      let shareRecordID = CKRecord.ID(recordName: shareRecordName, zoneID: customZone.zoneID)
      let shareRecord = try await database.record(for: shareRecordID)

      // Check if it's actually a CKShare
      guard let share = shareRecord as? CKShare else {
        print("⚠️ Record is not a CKShare for student: \(student.displayName)")
        return false
      }

      // CRITICAL: Only return true if share has participants (student has accepted)
      // A share without participants means the URL was generated but not accepted yet
      let hasParticipants = !share.participants.isEmpty
      if !hasParticipants {
        print(
          "⚠️ Share exists but has no participants (student hasn't accepted) for: \(student.displayName)"
        )
      }
      return hasParticipants
    } catch {
      print("⚠️ Failed to check share status for \(student.displayName): \(error)")
      return false
    }
  }

  /// Fetches all participants for a student's share
  func fetchParticipants(for student: Student) async -> [CKShare.Participant] {
    guard let shareRecordName = student.shareRecordID else {
      return []
    }

    do {
      let customZone = try await ensureCustomZoneExists()
      let shareRecordID = CKRecord.ID(recordName: shareRecordName, zoneID: customZone.zoneID)
      let shareRecord = try await database.record(for: shareRecordID)

      if let share = shareRecord as? CKShare {
        return share.participants
      }
    } catch {
      print("Failed to fetch participants: \(error)")
    }

    return []
  }

  /// Monitors share acceptance for a student and sends notification when accepted
  /// This should be called periodically or when checking share status
  func checkAndNotifyShareAcceptance(for student: Student) async {
    guard let shareRecordName = student.shareRecordID else {
      return
    }

    // Check if we've already notified for this student
    let notificationKey = "shareAccepted_\(student.id.uuidString)"
    let alreadyNotified = UserDefaults.standard.bool(forKey: notificationKey)

    do {
      let customZone = try await ensureCustomZoneExists()
      let shareRecordID = CKRecord.ID(recordName: shareRecordName, zoneID: customZone.zoneID)
      let shareRecord = try await database.record(for: shareRecordID)

      guard let share = shareRecord as? CKShare else {
        return
      }

      // Check if share has participants (student has accepted)
      let hasParticipants = !share.participants.isEmpty

      if hasParticipants && !alreadyNotified {
        // Student has accepted - send notification
        await PushNotificationService.shared.notifyInstructorOfShareAcceptance(
          studentName: student.displayName)

        // Mark as notified
        UserDefaults.standard.set(true, forKey: notificationKey)

        print("✅ Notified instructor that \(student.displayName) accepted the share")
      } else if !hasParticipants && alreadyNotified {
        // Share was revoked or student left - reset notification flag
        UserDefaults.standard.set(false, forKey: notificationKey)
      }
    } catch {
      print("⚠️ Failed to check share acceptance for \(student.displayName): \(error)")
    }
  }

  /// Monitors all students with share URLs to detect when they accept
  /// This should be called periodically (e.g., when app becomes active or on a timer)
  func monitorShareAcceptanceForAllStudents(modelContext: ModelContext) async {
    do {
      let descriptor = FetchDescriptor<Student>(
        predicate: #Predicate<Student> { $0.shareRecordID != nil }
      )
      let studentsWithShares = try modelContext.fetch(descriptor)

      print("🔍 Monitoring share acceptance for \(studentsWithShares.count) students...")

      for student in studentsWithShares {
        await checkAndNotifyShareAcceptance(for: student)
      }
    } catch {
      print("⚠️ Failed to monitor share acceptance: \(error)")
    }
  }

  /// Syncs student personal information to CloudKit using new StudentPersonalInfoRecord
  /// Also pulls student-owned data (training goals) from CloudKit
  func syncStudentPersonalInfo(_ student: Student, modelContext: ModelContext) async {
    // First, pull student-owned data from CloudKit (training goals, milestones)
    // This ensures instructor sees the latest student goals
    await pullTrainingGoalsFromCloudKit(student, modelContext: modelContext)

    do {
      guard student.shareRecordID != nil else {
        print("No active share for student \(student.displayName), skipping personal info sync")
        return
      }

      // Get the shared zone
      guard let sharedZone = try? await getSharedZone(for: student) else {
        print("⚠️ Cannot sync personal info: Zone not accessible in shared database")
        return
      }

      let sharedDatabase = container.sharedCloudDatabase

      // Create StudentPersonalInfoRecord
      let personalInfoRecord = createStudentPersonalInfoRecord(from: student)
      let recordID = CKRecord.ID(
        recordName: "\(student.id.uuidString)-personal-info", zoneID: sharedZone.zoneID)
      let existingRecord = try? await sharedDatabase.record(for: recordID)

      let record: CKRecord
      if let existing = existingRecord {
        record = existing
        // Update with new data
        let newRecord = personalInfoRecord.toCKRecord(recordID: recordID)
        for key in newRecord.allKeys() {
          record[key] = newRecord[key]
        }
      } else {
        record = personalInfoRecord.toCKRecord(recordID: recordID)
        // Set parent reference to student record
        let studentRecordID = CKRecord.ID(
          recordName: student.id.uuidString, zoneID: sharedZone.zoneID)
        record.parent = CKRecord.Reference(recordID: studentRecordID, action: .none)
      }

      // Save to shared database
      _ = try await saveRecordWithConflictResolution(record, database: sharedDatabase)
      print("✅ Student personal info synced to CloudKit using new record type")

    } catch {
      print("❌ Failed to sync student personal info: \(error)")
    }
  }

  /// Syncs training goals to CloudKit (student app writes, instructor reads)
  func syncTrainingGoalsToCloudKit(_ student: Student, modelContext: ModelContext) async {
    // This is called by student app - instructor app only reads
    // For now, this is a placeholder as training goals are synced via TrainingGoalsRecord
    print("ℹ️ Training goals sync handled via TrainingGoalsRecord")
  }

  /// Pulls training goals from CloudKit (instructor app reads student-owned data)
  func pullTrainingGoalsFromCloudKit(_ student: Student, modelContext: ModelContext) async {
    guard student.shareRecordID != nil else {
      return
    }

    do {
      guard let sharedZone = try? await getSharedZone(for: student) else {
        return
      }

      let sharedDatabase = container.sharedCloudDatabase
      let predicate = NSPredicate(format: "studentId == %@", student.id.uuidString)
      let query = CKQuery(recordType: TrainingGoalsRecord.recordType, predicate: predicate)

      let results = try await sharedDatabase.records(matching: query, inZoneWith: sharedZone.zoneID)

      for (_, result) in results.matchResults {
        switch result {
        case .success(let record):
          if let trainingGoals = TrainingGoalsRecord.fromCKRecord(record) {
            // Update student with training goals (read-only for instructor)
            student.goalPPL = trainingGoals.goalPPL
            student.goalInstrument = trainingGoals.goalInstrument
            student.goalCommercial = trainingGoals.goalCommercial
            student.goalCFI = trainingGoals.goalCFI
            student.pplGroundSchoolCompleted = trainingGoals.pplGroundSchoolCompleted
            student.pplWrittenTestCompleted = trainingGoals.pplWrittenTestCompleted
            student.instrumentGroundSchoolCompleted = trainingGoals.instrumentGroundSchoolCompleted
            student.instrumentWrittenTestCompleted = trainingGoals.instrumentWrittenTestCompleted
            student.commercialGroundSchoolCompleted = trainingGoals.commercialGroundSchoolCompleted
            student.commercialWrittenTestCompleted = trainingGoals.commercialWrittenTestCompleted
            student.cfiGroundSchoolCompleted = trainingGoals.cfiGroundSchoolCompleted
            student.cfiWrittenTestCompleted = trainingGoals.cfiWrittenTestCompleted
            try modelContext.save()
            print("✅ Pulled training goals from CloudKit")
          }
        case .failure(let error):
          print("⚠️ Failed to pull training goals: \(error)")
        }
      }
    } catch {
      print("❌ Failed to pull training goals: \(error)")
    }
  }

  /// Syncs student documents to CloudKit for sharing
  func syncStudentDocuments(_ student: Student, modelContext: ModelContext) async {
    do {
      guard let documents = student.documents else { return }

      // Get the custom zone
      let customZone = try await ensureCustomZoneExists()

      for document in documents {
        // Create record ID in custom zone
        let recordID = CKRecord.ID(recordName: document.id.uuidString, zoneID: customZone.zoneID)
        let existingRecord = try? await database.record(for: recordID)

        let record: CKRecord
        if let existing = existingRecord {
          record = existing
        } else {
          record = CKRecord(recordType: "StudentDocument", recordID: recordID)
        }

        record["documentType"] = document.documentTypeRaw
        record["filename"] = document.filename
        record["fileData"] = document.fileData
        record["uploadedAt"] = document.uploadedAt
        record["expirationDate"] = document.expirationDate
        record["notes"] = document.notes
        record["studentId"] = student.id.uuidString
        record["lastModified"] = document.lastModified

        // If there's a share, set the parent to the student record (root of the share)
        if student.shareRecordID != nil {
          let studentRecordID = CKRecord.ID(
            recordName: student.id.uuidString, zoneID: customZone.zoneID)
          record.parent = CKRecord.Reference(recordID: studentRecordID, action: .none)
        }

        let savedRecord = try await database.save(record)
        document.cloudKitRecordID = savedRecord.recordID.recordName
        document.lastModified = Date()
      }

      try modelContext.save()
    } catch {
      print("Failed to sync student documents: \(error)")
    }
  }

  /// Automatically syncs student checklist assignments to CloudKit shared zones
  func syncStudentChecklistAssignmentsToSharedZone(_ student: Student, modelContext: ModelContext)
    async
  {
    guard student.shareRecordID != nil else {
      print("No active share for student \(student.displayName), skipping shared zone sync")
      return
    }

    // Check if we're offline and queue the operation
    if !offlineSyncManager.isOfflineMode {
      await syncAssignmentsToSharedZone(student, modelContext: modelContext)
    } else {
      await queueOfflineOperation(
        operationType: "checklist_update",
        studentId: student.id,
        modelContext: modelContext
      )
    }
  }

  /// NEW: Syncs student checklist progress to CloudKit shared zones using assignment-based system
  func syncStudentChecklistProgressToSharedZone(_ student: Student, modelContext: ModelContext)
    async
  {
    guard student.shareRecordID != nil else {
      print("No active share for student \(student.displayName), skipping shared zone sync")
      return
    }

    // Check if we're offline and queue the operation
    if !offlineSyncManager.isOfflineMode {
      await syncAssignmentsToSharedZone(student, modelContext: modelContext)
    } else {
      await queueOfflineOperation(
        operationType: "assignment_update",
        studentId: student.id,
        modelContext: modelContext
      )
    }
  }

  /// Syncs checklist assignments to CloudKit using new architecture
  private func syncAssignmentsToSharedZone(_ student: Student, modelContext: ModelContext) async {
    do {
      let customZone = try await ensureCustomZoneExists()

      for assignment in student.checklistAssignments ?? [] {
        await syncAssignmentToSharedZone(
          assignment, student: student, customZone: customZone, modelContext: modelContext)
      }

      try modelContext.save()
    } catch {
      print("Failed to sync student assignments to shared zone: \(error)")

      // If sync fails due to network issues, queue for retry
      if isNetworkError(error) {
        await queueOfflineOperation(
          operationType: "assignment_update",
          studentId: student.id,
          modelContext: modelContext
        )
      }
    }
  }

  /// Ensures all template items have corresponding ItemProgress records
  /// This fixes cases where ItemProgress records are missing (e.g., template was updated after assignment creation)
  /// Also verifies that the template has all items from the library (for default templates)
  @MainActor
  private func ensureAllItemProgressRecordsExist(
    for assignment: ChecklistAssignment, modelContext: ModelContext
  ) {
    guard let template = assignment.template, let templateItems = template.items else {
      print(
        "⚠️ Cannot ensure ItemProgress records: template or items are nil for assignment '\(assignment.displayName)'"
      )
      return
    }

    // For default templates, verify the template has all items from the library
    if !assignment.isCustomChecklist, let templateIdentifier = assignment.templateIdentifier {
      if let library = loadStudentLibrary(),
        let libraryChecklist = library.checklists.first(where: {
          $0.templateIdentifier?.lowercased() == templateIdentifier.lowercased()
        })
      {
        let libraryItemCount = libraryChecklist.items.count
        let templateItemCount = templateItems.count

        if templateItemCount != libraryItemCount {
          // Only warn once per template to avoid excessive logging
          // Some templates (like C3-L3 Endorsements) may legitimately have items not in library
          if libraryItemCount == 0 && templateItemCount > 0 {
            // Template has items but library doesn't - this is expected for some templates
            // Don't log this as it's not an error
          } else {
            // Only log if library has items but counts don't match
            print("⚠️ Template item count mismatch for '\(assignment.displayName)':")
            print(
              "   Template has \(templateItemCount) items, library has \(libraryItemCount) items")
            print("   Template identifier: \(templateIdentifier)")
            print("   This may indicate the template needs to be updated from the library")
          }
        }
      }
    }

    // Initialize itemProgress array if needed
    if assignment.itemProgress == nil {
      assignment.itemProgress = []
    }

    // Get existing ItemProgress templateItemIds
    let existingTemplateItemIds = Set(assignment.itemProgress?.map { $0.templateItemId } ?? [])

    // Find missing ItemProgress records
    var createdCount = 0
    for templateItem in templateItems {
      if !existingTemplateItemIds.contains(templateItem.id) {
        let newProgressItem = ItemProgress(templateItemId: templateItem.id)
        newProgressItem.assignment = assignment
        assignment.itemProgress?.append(newProgressItem)
        modelContext.insert(newProgressItem)
        createdCount += 1
      }
    }

    if createdCount > 0 {
      print(
        "✅ Created \(createdCount) missing ItemProgress records for assignment '\(assignment.displayName)' (now has \(assignment.itemProgress?.count ?? 0)/\(templateItems.count) items)"
      )
      do {
        try modelContext.save()
      } catch {
        print("⚠️ Failed to save newly created ItemProgress records: \(error)")
      }
    } else {
      let currentCount = assignment.itemProgress?.count ?? 0
      let expectedCount = templateItems.count
      if currentCount != expectedCount {
        print(
          "⚠️ ItemProgress count mismatch for assignment '\(assignment.displayName)': has \(currentCount), expected \(expectedCount)"
        )
        print("   Template identifier: \(assignment.templateIdentifier ?? "none")")
        print("   Template ID: \(assignment.templateId)")
        print("   Template name: \(template.name)")
        print(
          "   This may indicate the template is missing items or ItemProgress records were deleted")
      } else {
        // Log success for diagnostic purposes (only for bi-annual flight review to reduce noise)
        if assignment.templateIdentifier == "default_bi_annual_flight_review" {
          print(
            "✅ ItemProgress count verified for '\(assignment.displayName)': \(currentCount) items")
        }
      }
    }
  }

  /// Syncs a specific checklist assignment to the shared zone using new ChecklistAssignmentRecord
  /// Syncs a checklist assignment to CloudKit shared zone.
  /// IMPORTANT: Only syncs the assignment/progress data, NOT the full lesson definition.
  /// - ChecklistAssignmentRecord: Contains templateId, instructorComments, dualGivenHours, and embedded ItemProgress
  /// Both apps already have all lesson definitions in their internal libraries.
  /// When student app receives this, it looks up the lesson by templateId and displays progress.
  /// CRITICAL: Always syncs complete assignment + all ItemProgress records together (one file per lesson).
  private func syncAssignmentToSharedZone(
    _ assignment: ChecklistAssignment, student: Student, customZone: CKRecordZone,
    modelContext: ModelContext, syncItemProgress: Bool = true
  ) async {
    // CRITICAL: Ensure all template items have ItemProgress records before syncing
    // This fixes cases where the template was updated after assignment creation
    await MainActor.run {
      ensureAllItemProgressRecordsExist(for: assignment, modelContext: modelContext)
    }

    // Ensure schemas are initialized before syncing
    // This is critical for ItemProgress (assignmentId must be queryable) and CustomChecklistDefinition
    await initializeCloudKitSchemas()

    // CRITICAL: Try to get the shared zone from the shared database
    // If not available yet, fall back to private zone (records will sync to shared once zone is created)
    var targetDatabase: CKDatabase
    var targetZone: CKRecordZone

    if let sharedZone = try? await getSharedZone(for: student) {
      // Shared zone is available - use it
      targetDatabase = container.sharedCloudDatabase
      targetZone = sharedZone
      print("✅ Using shared database zone for assignment sync")
    } else {
      // Shared zone not available yet - use private zone as fallback
      // Records in private zone will automatically appear in shared database once CloudKit creates the shared zone
      targetDatabase = database
      targetZone = customZone
      print(
        "⚠️ Shared zone not yet available - writing to private zone (will sync to shared once zone is created)"
      )
      print(
        "   This is normal immediately after share acceptance - CloudKit may take a few seconds to create the shared zone"
      )
    }

    do {
      // Create ChecklistAssignmentRecord with embedded ItemProgress
      let assignmentRecordData = createChecklistAssignmentRecord(from: assignment, student: student)

      // DIAGNOSTIC: Log the resolved IDs that will be saved to CloudKit
      let resolvedIDs = assignmentRecordData.itemProgress.prefix(5).map {
        $0.templateItemId.prefix(8)
      }.joined(separator: ", ")
      print(
        "📤 SYNC: Saving ChecklistAssignmentRecord with \(assignmentRecordData.itemProgress.count) ItemProgress records"
      )
      print("   First 5 resolved templateItemIds: \(resolvedIDs)")

      let assignmentRecordID = CKRecord.ID(
        recordName: assignment.id.uuidString, zoneID: targetZone.zoneID)
      let existingAssignmentRecord = try? await targetDatabase.record(for: assignmentRecordID)

      // Check for notification triggers
      let hadComments =
        (existingAssignmentRecord?["instructorComments"] as? String)?.isEmpty == false
      let nowHasComments = !(assignment.instructorComments?.isEmpty ?? true)
      let commentsChanged = !hadComments && nowHasComments

      let wasComplete =
        (existingAssignmentRecord?["itemProgress"] as? String).flatMap { jsonString in
          guard let jsonData = jsonString.data(using: .utf8),
            let items = try? JSONDecoder().decode([ItemProgressData].self, from: jsonData)
          else {
            return false
          }
          return items.allSatisfy { $0.isComplete }
        } ?? false
      let isNowComplete = assignment.isComplete
      let completionChanged = !wasComplete && isNowComplete

      // Create or update the record
      let assignmentRecord: CKRecord
      if let existing = existingAssignmentRecord {
        assignmentRecord = existing
        // Update with new data
        let newRecord = assignmentRecordData.toCKRecord(recordID: assignmentRecordID)
        for key in newRecord.allKeys() {
          assignmentRecord[key] = newRecord[key]
        }
      } else {
        assignmentRecord = assignmentRecordData.toCKRecord(recordID: assignmentRecordID)
      }

      // Set parent reference to student record for sharing
      let studentRecordID = CKRecord.ID(
        recordName: student.id.uuidString, zoneID: targetZone.zoneID)
      assignmentRecord.parent = CKRecord.Reference(recordID: studentRecordID, action: .none)

      // CRITICAL: Set studentId field for querying (CloudKit doesn't support querying by parent reference in shared databases)
      assignmentRecord["studentId"] = student.id.uuidString

      // DIAGNOSTIC: Verify the JSON contains resolved IDs before saving
      if let itemProgressJSON = assignmentRecord["itemProgress"] as? String,
        let jsonData = itemProgressJSON.data(using: .utf8),
        let decoded = try? JSONDecoder().decode([ItemProgressData].self, from: jsonData)
      {
        let savedIDs = decoded.prefix(5).map { $0.templateItemId.prefix(8) }.joined(separator: ", ")
        print("✅ SYNC: Verified JSON contains resolved IDs: \(savedIDs)")
      } else {
        print("⚠️ SYNC: Could not verify JSON content before saving")
      }

      _ = try await saveRecordWithConflictResolution(assignmentRecord, database: targetDatabase)
      assignment.lastModified = Date()

      // Send notifications for significant changes
      if commentsChanged {
        await PushNotificationService.shared.notifyStudentOfComment(
          studentId: student.id,
          checklistId: assignment.id,
          checklistName: assignment.displayName
        )
      }

      if completionChanged {
        await PushNotificationService.shared.notifyStudentOfCompletion(
          studentId: student.id,
          checklistId: assignment.id,
          checklistName: assignment.displayName
        )
      }

      print(
        "✅ Synced ChecklistAssignmentRecord with embedded ItemProgress: \(assignment.displayName)")

      // CRITICAL: Also sync separate ItemProgress records (student app queries these directly)
      // The ChecklistAssignmentRecord has embedded JSON, but the student app queries separate ItemProgress records
      if syncItemProgress {
        let assignmentRecordID = CKRecord.ID(
          recordName: assignment.id.uuidString, zoneID: targetZone.zoneID)
        await syncItemProgressToSharedZone(
          assignment, assignmentRecordID: assignmentRecordID, sharedZone: targetZone,
          sharedDatabase: targetDatabase)
      }

      // For custom checklists, also sync the CustomChecklistDefinition record to shared zone
      // so student app can query it separately
      if assignment.isCustomChecklist {
        // CRITICAL: Ensure schema is initialized before syncing CustomChecklistDefinition
        // This prevents "record type not deployed" errors
        await initializeCustomChecklistDefinitionSchema()

        // Small delay to ensure schema is available
        try? await Task.sleep(for: .milliseconds(500))

        await syncCustomChecklistDefinitionToSharedZone(
          assignment, student: student, sharedZone: targetZone, targetDatabase: targetDatabase)
      }

    } catch let error as CKError {
      // Handle "record already exists" errors gracefully - these are expected when records were created previously
      if error.code == .serverRecordChanged {
        // Record already exists - this is fine, the saveRecordWithConflictResolution should have handled it
        print(
          "✅ Assignment '\(assignment.displayName)' already exists in CloudKit (updated if needed)")
      } else {
        print(
          "⚠️ Failed to sync assignment '\(assignment.displayName)': \(error.localizedDescription)")

        // If sync fails due to network issues, queue for retry
        if isNetworkError(error) {
          print("Network error detected, operation will be queued for retry")
        }
      }
    } catch {
      print(
        "⚠️ Failed to sync assignment '\(assignment.displayName)': \(error.localizedDescription)")

      // If sync fails due to network issues, queue for retry
      if isNetworkError(error) {
        print("Network error detected, operation will be queued for retry")
      }
    }
  }

  /// Syncs CustomChecklistDefinition record to shared zone for student app
  /// This allows the student app to query custom checklist definitions separately
  private func syncCustomChecklistDefinitionToSharedZone(
    _ assignment: ChecklistAssignment, student: Student, sharedZone: CKRecordZone,
    targetDatabase: CKDatabase
  ) async {
    guard assignment.isCustomChecklist, let template = assignment.template else {
      return
    }

    do {

      // Create CustomChecklistDefinition record in shared zone
      let definitionRecordID = CKRecord.ID(
        recordName: "custom-definition-\(assignment.templateId.uuidString)",
        zoneID: sharedZone.zoneID)
      let existingDefinitionRecord = try? await targetDatabase.record(for: definitionRecordID)

      let definitionRecord: CKRecord
      if let existing = existingDefinitionRecord {
        definitionRecord = existing
      } else {
        definitionRecord = CKRecord(
          recordType: "CustomChecklistDefinition", recordID: definitionRecordID)
      }

      // Update definition record fields
      // CRITICAL: All fields must be set, especially studentId which needs to be queryable
      definitionRecord["templateId"] = assignment.templateId.uuidString
      definitionRecord["customName"] = template.name
      definitionRecord["customCategory"] = template.category
      definitionRecord["studentId"] = student.id.uuidString  // Must be set and queryable for student app queries
      definitionRecord["lastModified"] = Date()

      // Store custom items as JSON string
      if let items = template.items {
        let customItems = items.map { item in
          [
            "id": item.id.uuidString,
            "title": item.title,
            "notes": item.notes ?? "",
            "order": item.order,
          ]
        }

        if let jsonData = try? JSONSerialization.data(withJSONObject: customItems),
          let jsonString = String(data: jsonData, encoding: .utf8)
        {
          definitionRecord["customItems"] = jsonString
        }
      } else {
        // Ensure field exists even if empty
        definitionRecord["customItems"] = "[]"
      }

      // Set parent reference to student record
      let studentRecordID = CKRecord.ID(
        recordName: student.id.uuidString, zoneID: sharedZone.zoneID)
      definitionRecord.parent = CKRecord.Reference(recordID: studentRecordID, action: .none)

      // Save to private database zone (the shared zone)
      // This will auto-create the schema in Development environment
      var retryCount = 0
      let maxRetries = 3

      while retryCount < maxRetries {
        do {
          _ = try await targetDatabase.save(definitionRecord)
          print("✅ Synced CustomChecklistDefinition to shared zone: \(template.name)")
          return
        } catch let error as CKError {
          if error.code == .serverRecordChanged && retryCount < maxRetries - 1 {
            // Handle conflict by fetching latest and retrying
            retryCount += 1
            if let latestRecord = try? await targetDatabase.record(for: definitionRecordID) {
              // Update our record with server values, then apply our changes
              definitionRecord.setValuesForKeys(
                latestRecord.allKeys().reduce(into: [String: Any]()) { result, key in
                  result[key] = latestRecord[key]
                })
              // Re-apply our changes
              definitionRecord["templateId"] = assignment.templateId.uuidString
              definitionRecord["customName"] = template.name
              definitionRecord["customCategory"] = template.category
              definitionRecord["studentId"] = student.id.uuidString
              definitionRecord["lastModified"] = Date()
              try await Task.sleep(for: .milliseconds(100 * retryCount))
              continue
            }
          } else if error.code == .unknownItem || error.localizedDescription.contains("recordType")
            || error.localizedDescription.contains("not deployed")
            || error.code == .invalidArguments
          {
            // Schema not deployed - try to initialize it by saving a real record
            print("⚠️ CustomChecklistDefinition schema not deployed")
            print("   Attempting to initialize schema by saving record directly...")

            // In Development, saving a record should auto-create the schema
            // Try saving this actual record - it should create the schema
            // If that fails, try the initialization method
            do {
              // First try: Save the actual record (this should create schema in Development)
              _ = try await targetDatabase.save(definitionRecord)
              print("✅ Schema created by saving CustomChecklistDefinition record: \(template.name)")
              return
            } catch let saveError as CKError {
              if saveError.code == .invalidArguments
                || saveError.localizedDescription.contains("not deployed")
              {
                // Schema still not available - try explicit initialization
                print("   Schema still not available, trying explicit initialization...")
                await initializeCloudKitSchemas()

                // Wait longer for schema to propagate
                try? await Task.sleep(for: .milliseconds(2000))

                // Retry saving
                do {
                  _ = try await targetDatabase.save(definitionRecord)
                  print(
                    "✅ Synced CustomChecklistDefinition after explicit schema init: \(template.name)"
                  )
                  return
                } catch let finalError {
                  print("❌ Schema initialization failed - manual deployment required")
                  print("   Error: \(finalError)")
                  print("   For Production, deploy schema manually:")
                  print("   1. Go to https://icloud.developer.apple.com/dashboard/")
                  print("   2. Navigate to Schema > Record Types")
                  print("   3. Add 'CustomChecklistDefinition' with fields:")
                  print("      - templateId (String, Indexed)")
                  print("      - customName (String)")
                  print("      - customCategory (String)")
                  print("      - studentId (String, Indexed, Queryable) - CRITICAL")
                  print("      - lastModified (Date/Time)")
                  print("      - customItems (String)")
                  throw finalError
                }
              } else {
                throw saveError
              }
            }
          } else {
            throw error
          }
        } catch {
          throw error
        }
      }

      print("❌ Failed to sync CustomChecklistDefinition after \(maxRetries) attempts")
    } catch let error as CKError {
      print("❌ Failed to sync CustomChecklistDefinition to shared zone: \(error)")
      if error.code == .unknownItem || error.localizedDescription.contains("recordType") {
        print("   Schema deployment required - see instructions above")
      }
    } catch {
      print("❌ Failed to sync CustomChecklistDefinition to shared zone: \(error)")
    }
  }

  /// Syncs only assignment metadata (fast) - does NOT sync ItemProgress
  /// This is used during initial share creation to avoid blocking
  private func syncAssignmentMetadataOnly(
    _ assignment: ChecklistAssignment, student: Student, customZone: CKRecordZone
  ) async {
    // CRITICAL: Get the zone from shared database context for this student
    guard let sharedZone = try? await getSharedZone(for: student) else {
      print("⚠️ Cannot sync assignment metadata: Zone not accessible in shared database")
      return
    }

    // CRITICAL: Use shared database for records that are part of a share
    let sharedDatabase = container.sharedCloudDatabase

    do {
      let assignmentRecordID = CKRecord.ID(
        recordName: assignment.id.uuidString, zoneID: sharedZone.zoneID)
      let existingAssignmentRecord = try? await sharedDatabase.record(for: assignmentRecordID)

      let assignmentRecord: CKRecord =
        existingAssignmentRecord
        ?? CKRecord(recordType: "ChecklistAssignment", recordID: assignmentRecordID)

      // Only sync assignment metadata - NO ItemProgress here
      // CRITICAL: Use library template ID (student app's ID) instead of instructor's internal ID
      let libraryTemplateID =
        resolveLibraryTemplateID(templateIdentifier: assignment.templateIdentifier)
        ?? assignment.templateId
      assignmentRecord["templateId"] = libraryTemplateID.uuidString
      assignmentRecord["templateIdentifier"] = assignment.templateIdentifier
      assignmentRecord["isCustomChecklist"] = assignment.isCustomChecklist
      assignmentRecord["instructorComments"] = assignment.instructorComments
      assignmentRecord["dualGivenHours"] = assignment.dualGivenHours
      assignmentRecord["assignedAt"] = assignment.assignedAt
      assignmentRecord["lastModified"] = assignment.lastModified
      assignmentRecord["studentId"] = student.id.uuidString

      // For custom checklists only - include definition since it's not in student's library
      if assignment.isCustomChecklist, let template = assignment.template {
        assignmentRecord["customName"] = template.name
        assignmentRecord["customCategory"] = template.category
        if let items = template.items {
          let customItems = items.map { item in
            [
              "id": item.id.uuidString,
              "title": item.title,
              "notes": item.notes ?? "",
              "order": item.order,
            ]
          }
          if let itemsData = try? JSONSerialization.data(withJSONObject: customItems) {
            assignmentRecord["customItems"] = itemsData
          }
        }
      }

      let studentRecordID = CKRecord.ID(
        recordName: student.id.uuidString, zoneID: sharedZone.zoneID)
      assignmentRecord.parent = CKRecord.Reference(recordID: studentRecordID, action: .none)

      _ = try await saveRecordWithConflictResolution(assignmentRecord, database: sharedDatabase)

    } catch {
      print("⚠️ Failed to sync assignment metadata for \(assignment.displayName): \(error)")
    }
  }

  /// Syncs ItemProgress for a single assignment using new ChecklistAssignmentRecord
  /// ItemProgress is now embedded in ChecklistAssignmentRecord (one file per lesson)
  private func syncItemProgressForAssignment(
    _ assignment: ChecklistAssignment, student: Student, customZone: CKRecordZone,
    modelContext: ModelContext
  ) async {
    // Use the new architecture - sync entire ChecklistAssignmentRecord with embedded ItemProgress
    await syncAssignmentToSharedZone(
      assignment, student: student, customZone: customZone, modelContext: modelContext,
      syncItemProgress: true)
  }

  /// Syncs a single ItemProgress record to CloudKit using new ChecklistAssignmentRecord
  /// This updates the ChecklistAssignmentRecord with the new ItemProgress data (embedded in the record)
  /// This is optimized to sync only the changed assignment record, not all items separately
  func syncSingleItemProgressToSharedZone(
    itemProgress: ItemProgress, assignment: ChecklistAssignment, student: Student,
    modelContext: ModelContext
  ) async {
    guard student.shareRecordID != nil else {
      return
    }

    // Update the entire ChecklistAssignmentRecord with all ItemProgress embedded
    // This ensures "one file per lesson" - assignment and progress synced together
    let customZone = try? await ensureCustomZoneExists()
    guard let customZone = customZone else {
      return
    }

    await syncAssignmentToSharedZone(
      assignment, student: student, customZone: customZone, modelContext: modelContext,
      syncItemProgress: true)
    print("✅ Synced single ItemProgress via ChecklistAssignmentRecord update")
  }

  /// Syncs ItemProgress records to CloudKit shared zone.
  /// These records contain:
  /// - templateItemId (reference to item in library)
  /// - isComplete (check-off status)
  /// - notes (instructor comments)
  /// - completedAt (when checked)
  /// This is the "progress file" that shows what items have been checked off.
  private func syncItemProgressToSharedZone(
    _ assignment: ChecklistAssignment, assignmentRecordID: CKRecord.ID, sharedZone: CKRecordZone,
    sharedDatabase: CKDatabase
  ) async {
    let items = assignment.itemProgress ?? []
    guard !items.isEmpty else {
      print("⚠️ No ItemProgress records to sync for assignment \(assignment.displayName)")
      return
    }

    print("📋 Syncing \(items.count) ItemProgress records for assignment: \(assignment.displayName)")

    do {
      var syncedCount = 0
      var completedCount = 0

      for item in items {
        let itemRecordID = CKRecord.ID(recordName: item.id.uuidString, zoneID: sharedZone.zoneID)
        let existingItemRecord = try? await sharedDatabase.record(for: itemRecordID)

        let itemRecord: CKRecord
        if let existing = existingItemRecord {
          itemRecord = existing
        } else {
          itemRecord = CKRecord(recordType: "ItemProgress", recordID: itemRecordID)
        }

        // Only sync essential progress data, not the full item details
        // CloudKit requires Bool values to be wrapped in NSNumber
        // CRITICAL: Use library item ID (student app's ID) instead of instructor's internal ID
        let libraryItemID =
          resolveLibraryItemID(for: item, assignment: assignment) ?? item.templateItemId
        if libraryItemID != item.templateItemId && syncedCount < 3 {
          print(
            "🔄 Resolved library item ID: \(item.templateItemId.uuidString) -> \(libraryItemID.uuidString)"
          )
        }
        let templateItemIdString = libraryItemID.uuidString
        guard !templateItemIdString.isEmpty else {
          print(
            "❌ ERROR: ItemProgress has empty templateItemId - skipping sync for item ID: \(item.id.uuidString)"
          )
          continue
        }
        itemRecord["templateItemId"] = templateItemIdString
        let isCompleteValue = NSNumber(value: item.isComplete)  // CRITICAL: Sync checkmark status (wrapped in NSNumber)
        itemRecord["isComplete"] = isCompleteValue
        itemRecord["notes"] = item.notes  // Also sync notes field (student app expects "notes" not "instructorNotes")
        itemRecord["instructorNotes"] = item.notes  // Keep for backwards compatibility
        itemRecord["completedAt"] = item.completedAt
        itemRecord["lastModified"] = item.lastModified
        itemRecord["assignmentId"] = assignment.id.uuidString  // CRITICAL: Must match assignment.id (not recordName)

        // Set parent reference to assignment record
        itemRecord.parent = CKRecord.Reference(recordID: assignmentRecordID, action: .none)

        _ = try await saveRecordWithConflictResolution(itemRecord, database: sharedDatabase)
        item.lastModified = Date()
        syncedCount += 1

        if item.isComplete {
          completedCount += 1
          print(
            "   ✅ Synced completed item: templateItemId=\(item.templateItemId.uuidString) (full UUID), isComplete=true"
          )
        } else if syncedCount <= 3 {
          // Log first few incomplete items for debugging
          print(
            "   📋 Synced incomplete item: templateItemId=\(item.templateItemId.uuidString) (full UUID), isComplete=false"
          )
        }
      }

      print(
        "✅ Synced \(syncedCount)/\(items.count) ItemProgress records (\(completedCount) completed) for assignment: \(assignment.displayName)"
      )

      // CRITICAL: Validate ItemProgress records after sync
      await validateItemProgressRecords(for: assignment)
    } catch {
      print("❌ Failed to sync item progress for \(assignment.displayName): \(error)")
    }
  }

  /// Validates ItemProgress records before/after sync to ensure data integrity
  @MainActor
  private func validateItemProgressRecords(for assignment: ChecklistAssignment) async {
    guard let itemProgress = assignment.itemProgress, !itemProgress.isEmpty else {
      return
    }

    guard let template = assignment.template, let templateItems = template.items else {
      print("⚠️ Validation skipped: Template not found for assignment '\(assignment.displayName)'")
      return
    }

    var validationErrors: [String] = []
    var orphanedProgress: [ItemProgress] = []

    // Check each ItemProgress record
    for progress in itemProgress {
      let templateItemId = progress.templateItemId

      // Check if templateItemId matches a template item ID directly
      let foundInTemplate = templateItems.contains { $0.id == templateItemId }

      if !foundInTemplate {
        orphanedProgress.append(progress)
        validationErrors.append(
          "ItemProgress with templateItemId \(templateItemId.uuidString) doesn't match any template item"
        )
      }

      // Check if templateItemId is valid UUID
      if templateItemId.uuidString.isEmpty {
        validationErrors.append("ItemProgress has empty templateItemId")
      }
    }

    // Check for count mismatches
    let templateItemCount = templateItems.count
    let progressCount = itemProgress.count
    if progressCount != templateItemCount {
      validationErrors.append(
        "ItemProgress count (\(progressCount)) doesn't match template items count (\(templateItemCount))"
      )
    }

    // Report validation results
    if !validationErrors.isEmpty {
      print(
        "⚠️ ItemProgress validation found \(validationErrors.count) issue(s) for assignment '\(assignment.displayName)':"
      )
      for error in validationErrors.prefix(5) {  // Limit to first 5 errors
        print("   - \(error)")
      }
      if validationErrors.count > 5 {
        print("   ... and \(validationErrors.count - 5) more errors")
      }
    } else {
      print("✅ ItemProgress validation passed: \(progressCount) records, all valid")
    }
  }

  /// Checks if a template exists in the default library
  private func isTemplateInLibrary(templateId: UUID) -> Bool {
    // This would check against the embedded library in the student app
    // For now, we'll assume all templates with standard identifiers are in the library
    // Custom templates would have different identifiers
    return true  // TODO: Implement actual library check
  }

  // MARK: - Legacy Sync Functions (Removed - Use assignment-based sync methods above)

  /// Queues an operation for offline retry
  private func queueOfflineOperation(
    operationType: String,
    studentId: UUID,
    checklistId: UUID? = nil,
    checklistItemId: UUID? = nil,
    modelContext: ModelContext
  ) async {
    // Create operation data
    let operationData = OfflineOperationData(
      operationType: operationType,
      timestamp: Date()
    )

    guard let data = try? JSONEncoder().encode(operationData) else {
      print("Failed to encode operation data")
      return
    }

    await offlineSyncManager.queueSyncOperation(
      operationType: operationType,
      studentId: studentId,
      checklistId: checklistId,
      checklistItemId: checklistItemId,
      operationData: data
    )

    print("Queued offline operation: \(operationType) for student \(studentId)")
  }

  /// Checks if an error is network-related
  private func isNetworkError(_ error: Error) -> Bool {
    if let ckError = error as? CKError {
      switch ckError.code {
      case .networkUnavailable, .networkFailure, .serviceUnavailable:
        return true
      default:
        return false
      }
    }
    return false
  }

  // MARK: - Legacy methods removed
  // syncChecklistToSharedZone and syncChecklistItemsToSharedZone have been removed
  // Use syncAssignmentToSharedZone and syncItemProgressToSharedZone instead

  /// Checks if a checklist assignment is 100% complete
  private func isChecklistComplete(_ assignment: ChecklistAssignment) -> Bool {
    guard let items = assignment.itemProgress, !items.isEmpty else { return false }
    return items.allSatisfy { $0.isComplete }
  }

  /// Calculates completion percentage for a checklist assignment
  private func calculateCompletionPercentage(_ assignment: ChecklistAssignment) -> Double {
    guard let items = assignment.itemProgress, !items.isEmpty else { return 0.0 }
    let completedCount = items.filter { $0.isComplete }.count
    return Double(completedCount) / Double(items.count)
  }

  // MARK: - Public Sync Methods (replacing CloudKitSyncService)

  @Published var isSyncing = false
  @Published var lastSyncDate: Date?
  @Published var syncStatus: String = "Ready to sync"

  /// Syncs all students' data to CloudKit shared database
  /// This replaces CloudKitSyncService.syncToCloudKit()
  func syncToCloudKit(modelContext: ModelContext) async {
    guard !isSyncing else { return }

    isSyncing = true
    syncStatus = "Starting sync..."

    do {
      // Check CloudKit availability
      let accountStatus = try await container.accountStatus()
      guard accountStatus == .available else {
        syncStatus = "iCloud account not available"
        isSyncing = false
        return
      }

      syncStatus = "Syncing students to shared database..."

      // Fetch all students
      let descriptor = FetchDescriptor<Student>()
      let students = try modelContext.fetch(descriptor)

      var syncedCount = 0
      for student in students {
        if student.shareRecordID != nil {
          await syncInstructorDataToCloudKit(student, modelContext: modelContext)
          syncedCount += 1
        }
      }

      lastSyncDate = Date()
      syncStatus = "Sync completed: \(syncedCount) students synced to shared database"

    } catch {
      syncStatus = "Sync failed: \(error.localizedDescription)"
      print("CloudKit sync error: \(error)")
    }

    isSyncing = false
  }

  /// Restores data from CloudKit shared database
  /// This replaces CloudKitSyncService.restoreFromCloudKit()
  func restoreFromCloudKit(modelContext: ModelContext) async {
    guard !isSyncing else { return }

    isSyncing = true
    syncStatus = "Restoring from shared database..."

    do {
      // Check CloudKit availability
      let accountStatus = try await container.accountStatus()
      guard accountStatus == .available else {
        syncStatus = "iCloud account not available"
        isSyncing = false
        return
      }

      syncStatus = "Pulling student data from shared database..."

      // Fetch all students
      let descriptor = FetchDescriptor<Student>()
      let students = try modelContext.fetch(descriptor)

      var restoredCount = 0
      for student in students {
        if student.shareRecordID != nil {
          await pullStudentDataFromCloudKit(student, modelContext: modelContext)
          restoredCount += 1
        }
      }

      lastSyncDate = Date()
      syncStatus = "Restore completed: \(restoredCount) students restored from shared database"

    } catch {
      syncStatus = "Restore failed: \(error.localizedDescription)"
      print("CloudKit restore error: \(error)")
    }

    isSyncing = false
  }

  /// Syncs a checklist template to CloudKit (for template sharing between instructors)
  /// This replaces CloudKitSyncService.syncTemplateToCloudKit()
  func syncTemplateToCloudKit(_ template: ChecklistTemplate, modelContext: ModelContext) async {
    // Templates are stored locally and don't need to sync to shared database
    // They're only shared via export/import, not CloudKit
    print("ℹ️ Template sync not needed - templates are local only")
  }

  /// Saves a CloudKit record with automatic conflict resolution
  private func saveRecordWithConflictResolution(_ record: CKRecord, database: CKDatabase? = nil)
    async throws -> CKRecord
  {
    let targetDatabase = database ?? self.database
    var retryCount = 0
    let maxRetries = 3

    while retryCount < maxRetries {
      do {
        return try await targetDatabase.save(record)
      } catch let error as CKError {
        if error.code == .serverRecordChanged {
          retryCount += 1
          print(
            "⚠️ Server record changed conflict detected for \(record.recordType) (attempt \(retryCount)/\(maxRetries)). Attempting resolution..."
          )

          // Fetch the latest version from server
          let latestRecord = try await targetDatabase.record(for: record.recordID)

          // Use intelligent merge strategy based on record type
          let mergedRecord = intelligentMerge(ourRecord: record, serverRecord: latestRecord)

          // Update our record with the merged version
          record.setValuesForKeys(
            mergedRecord.allKeys().reduce(into: [String: Any]()) { result, key in
              result[key] = mergedRecord[key]
            })

          // Add a small delay to prevent rapid retry loops
          try await Task.sleep(for: .milliseconds(100 * retryCount))

        } else {
          throw error
        }
      }
    }

    // If we've exhausted retries, log detailed error and throw
    print("❌ Failed to resolve conflict after \(maxRetries) attempts for \(record.recordType)")
    print("   Record ID: \(record.recordID)")
    print("   Our record keys: \(record.allKeys())")
    if let latestRecord = try? await targetDatabase.record(for: record.recordID) {
      print("   Server record keys: \(latestRecord.allKeys())")
    }
    throw CKError(.serverRecordChanged)
  }

  /// Intelligent merge strategy based on record type and field
  /// CRITICAL: For instructor-owned data (ChecklistAssignment, ItemProgress), always overwrite with our local version
  /// For bidirectional data (Student, StudentDocument), use merge strategy
  private func intelligentMerge(ourRecord: CKRecord, serverRecord: CKRecord) -> CKRecord {
    // For instructor-owned data, always overwrite with our local version (instructor's version wins)
    // This ensures instructor changes always take precedence
    switch ourRecord.recordType {
    case "ChecklistAssignment", "ItemProgress":
      // CRITICAL: Always use our local version for instructor-owned data
      // Instructor app owns these records, so our version is always correct
      print(
        "📝 Using overwrite strategy for \(ourRecord.recordType) - instructor version always wins")
      let overwrittenRecord = serverRecord  // Start with server metadata (zone, recordID, etc.)
      // Copy all our local values to overwrite server values
      for key in ourRecord.allKeys() {
        overwrittenRecord[key] = ourRecord[key]
      }
      overwrittenRecord["lastModified"] = Date()
      return overwrittenRecord

    case "StudentChecklist":
      return mergeChecklistRecord(ourRecord: ourRecord, serverRecord: serverRecord)
    case "StudentChecklistItem":
      return mergeChecklistItemRecord(ourRecord: ourRecord, serverRecord: serverRecord)
    default:
      // Default merge strategy for bidirectional data
      let mergedRecord = mergeGenericRecord(ourRecord: ourRecord, serverRecord: serverRecord)
      mergedRecord["lastModified"] = Date()
      return mergedRecord
    }
  }

  /// DEPRECATED: Merge strategy for ChecklistAssignment records
  /// This method is no longer used - ChecklistAssignment now uses overwrite strategy
  /// Kept for backwards compatibility but should not be called
  private func mergeChecklistAssignmentRecord(ourRecord: CKRecord, serverRecord: CKRecord)
    -> CKRecord
  {
    // This method should not be called anymore - ChecklistAssignment uses overwrite strategy
    // in intelligentMerge above
    print("⚠️ WARNING: mergeChecklistAssignmentRecord called but should use overwrite strategy")
    let overwrittenRecord = serverRecord
    for key in ourRecord.allKeys() {
      overwrittenRecord[key] = ourRecord[key]
    }
    overwrittenRecord["lastModified"] = Date()
    return overwrittenRecord
  }

  /// Merge strategy for StudentChecklist records
  private func mergeChecklistRecord(ourRecord: CKRecord, serverRecord: CKRecord) -> CKRecord {
    // Check if either record is marked as complete
    let ourComplete = ourRecord["isComplete"] as? Bool ?? false
    let serverComplete = serverRecord["isComplete"] as? Bool ?? false

    // If either record is complete, use "last writer wins" strategy
    // since completed checklists are unlikely to be edited again
    if ourComplete || serverComplete {
      print("📝 Using 'last writer wins' for completed checklist conflict resolution")

      // Use the record with the more recent lastModified date
      let ourLastModified = ourRecord["lastModified"] as? Date ?? Date.distantPast
      let serverLastModified = serverRecord["lastModified"] as? Date ?? Date.distantPast

      if ourLastModified > serverLastModified {
        print("   → Using our version (more recent: \(ourLastModified))")
        return ourRecord
      } else {
        print("   → Using server version (more recent: \(serverLastModified))")
        return serverRecord
      }
    }

    // For incomplete checklists, use intelligent merge strategy
    print("📝 Using intelligent merge for incomplete checklist conflict resolution")
    let mergedRecord = serverRecord

    // For instructor comments, prefer the longer/more recent one
    if let ourComments = ourRecord["instructorComments"] as? String,
      let serverComments = serverRecord["instructorComments"] as? String
    {
      if ourComments.count > serverComments.count {
        mergedRecord["instructorComments"] = ourComments
      }
    } else if ourRecord["instructorComments"] != nil {
      mergedRecord["instructorComments"] = ourRecord["instructorComments"]
    }

    // For completion status, prefer the more complete one
    if let ourComplete = ourRecord["isComplete"] as? Bool,
      let serverComplete = serverRecord["isComplete"] as? Bool
    {
      mergedRecord["isComplete"] = ourComplete || serverComplete
    } else if ourRecord["isComplete"] != nil {
      mergedRecord["isComplete"] = ourRecord["isComplete"]
    }

    // For dual given hours, use the higher value
    if let ourHours = ourRecord["dualGivenHours"] as? Double,
      let serverHours = serverRecord["dualGivenHours"] as? Double
    {
      mergedRecord["dualGivenHours"] = max(ourHours, serverHours)
    } else if ourRecord["dualGivenHours"] != nil {
      mergedRecord["dualGivenHours"] = ourRecord["dualGivenHours"]
    }

    // For counts and percentages, use the higher values
    if let ourCompleted = ourRecord["completedItemsCount"] as? Int,
      let serverCompleted = serverRecord["completedItemsCount"] as? Int
    {
      mergedRecord["completedItemsCount"] = max(ourCompleted, serverCompleted)
    } else if ourRecord["completedItemsCount"] != nil {
      mergedRecord["completedItemsCount"] = ourRecord["completedItemsCount"]
    }

    if let ourPercentage = ourRecord["completionPercentage"] as? Double,
      let serverPercentage = serverRecord["completionPercentage"] as? Double
    {
      mergedRecord["completionPercentage"] = max(ourPercentage, serverPercentage)
    } else if ourRecord["completionPercentage"] != nil {
      mergedRecord["completionPercentage"] = ourRecord["completionPercentage"]
    }

    // Handle any other fields that might exist
    for key in ourRecord.allKeys() {
      if mergedRecord[key] == nil && ourRecord[key] != nil {
        mergedRecord[key] = ourRecord[key]
      }
    }

    return mergedRecord
  }

  /// Merge strategy for StudentChecklistItem records
  private func mergeChecklistItemRecord(ourRecord: CKRecord, serverRecord: CKRecord) -> CKRecord {
    let mergedRecord = serverRecord

    // For completion status, prefer completed (true wins)
    if let ourComplete = ourRecord["isComplete"] as? Bool,
      let serverComplete = serverRecord["isComplete"] as? Bool
    {
      mergedRecord["isComplete"] = ourComplete || serverComplete
    }

    // For notes, prefer the longer/more recent one
    if let ourNotes = ourRecord["notes"] as? String,
      let serverNotes = serverRecord["notes"] as? String
    {
      if ourNotes.count > serverNotes.count {
        mergedRecord["notes"] = ourNotes
      }
    } else if ourRecord["notes"] != nil {
      mergedRecord["notes"] = ourRecord["notes"]
    }

    // For completion date, use the earlier date (when it was first completed)
    if let ourDate = ourRecord["completedAt"] as? Date,
      let serverDate = serverRecord["completedAt"] as? Date
    {
      mergedRecord["completedAt"] = min(ourDate, serverDate)
    } else if ourRecord["completedAt"] != nil {
      mergedRecord["completedAt"] = ourRecord["completedAt"]
    }

    return mergedRecord
  }

  /// Generic merge strategy for other record types
  private func mergeGenericRecord(ourRecord: CKRecord, serverRecord: CKRecord) -> CKRecord {
    let mergedRecord = serverRecord

    // For most fields, prefer our local changes
    for key in ourRecord.allKeys() {
      if let ourValue = ourRecord[key] {
        mergedRecord[key] = ourValue
      }
    }

    return mergedRecord
  }

  // MARK: - New Architecture: Data Ownership-Based Sync Methods

  /// Syncs instructor-owned data to CloudKit (one-way push: instructor → student)
  /// Instructor-owned data includes: checklist assignments, item progress, instructor comments, dual hours
  func syncInstructorDataToCloudKit(_ student: Student, modelContext: ModelContext) async {
    guard student.shareRecordID != nil else {
      print("⚠️ No active share for student \(student.displayName), skipping instructor data sync")
      return
    }

    do {
      let customZone = try await ensureCustomZoneExists()

      // Sync checklist assignments (instructor-owned)
      if let assignments = student.checklistAssignments {
        for assignment in assignments {
          await syncAssignmentToSharedZone(
            assignment, student: student, customZone: customZone, modelContext: modelContext)
        }
      }

      print("✅ Synced instructor data to CloudKit for: \(student.displayName)")
    } catch {
      print("❌ Failed to sync instructor data: \(error)")
    }
  }

  /// Deletes an assignment and all its ItemProgress records from CloudKit
  /// This is called when the instructor deletes an assignment locally
  func deleteAssignmentFromCloudKit(assignment: ChecklistAssignment, student: Student) async {
    guard student.shareRecordID != nil else {
      print("⚠️ No active share for student \(student.displayName), skipping CloudKit deletion")
      return
    }

    // CRITICAL: Get the shared zone from the shared database
    // The instructor must write to the shared database zone, never the private zone
    guard let sharedZone = try? await getSharedZone(for: student) else {
      print("⚠️ Cannot delete assignment: Zone not accessible in shared database")
      print("   This usually means the share hasn't been accepted by the student yet")
      return
    }

    let targetDatabase = container.sharedCloudDatabase
    let targetZone = sharedZone

    // Delete the assignment record
    let assignmentRecordID = CKRecord.ID(
      recordName: assignment.id.uuidString, zoneID: targetZone.zoneID)

    // First, delete all ItemProgress records for this assignment
    if let itemProgress = assignment.itemProgress {
      for progress in itemProgress {
        let progressRecordID = CKRecord.ID(
          recordName: progress.id.uuidString, zoneID: targetZone.zoneID)
        do {
          try await targetDatabase.deleteRecord(withID: progressRecordID)
          print("🗑️ Deleted ItemProgress record from CloudKit: \(progress.id.uuidString.prefix(8))")
        } catch {
          // If record doesn't exist, that's okay - it may have already been deleted
          if let ckError = error as? CKError, ckError.code == .unknownItem {
            print("ℹ️ ItemProgress record not found in CloudKit (may have already been deleted)")
          } else {
            print(
              "⚠️ Failed to delete ItemProgress record \(progress.id.uuidString.prefix(8)): \(error)"
            )
          }
          // Continue deleting other records even if one fails
        }
      }
    }

    // Delete the assignment record itself
    do {
      try await targetDatabase.deleteRecord(withID: assignmentRecordID)
      print("🗑️ Deleted assignment '\(assignment.displayName)' from CloudKit")
    } catch {
      // If record doesn't exist, that's okay - it may have already been deleted
      if let ckError = error as? CKError, ckError.code == .unknownItem {
        print("ℹ️ Assignment record not found in CloudKit (may have already been deleted)")
      } else {
        print("⚠️ Failed to delete assignment from CloudKit: \(error)")
      }
    }
  }

  /// Syncs bidirectional fields from CloudKit with conflict resolution
  /// Handles: personal information and documents (last write wins with merge strategy)
  func syncBidirectionalFieldsFromCloudKit(_ student: Student, modelContext: ModelContext) async {
    guard student.shareRecordID != nil else {
      return
    }

    do {
      let customZone = try await ensureCustomZoneExists()
      let studentRecordID = CKRecord.ID(
        recordName: student.id.uuidString, zoneID: customZone.zoneID)

      // Fetch student record from CloudKit
      let cloudKitRecord = try await database.record(for: studentRecordID)
      let cloudKitTime = cloudKitRecord.modificationDate ?? Date.distantPast
      let localTime = student.lastModified

      // Merge bidirectional fields: personal info
      if cloudKitTime > localTime || student.lastModifiedBy != "instructor" {
        // CloudKit version is newer or wasn't last modified by us - merge it
        mergePersonalInfo(from: cloudKitRecord, to: student)
      }

      // Sync documents (last write wins)
      await syncDocumentsFromCloudKit(
        student: student, customZone: customZone, modelContext: modelContext)

      try modelContext.save()
      print("✅ Synced bidirectional fields from CloudKit for: \(student.displayName)")
    } catch {
      print("❌ Failed to sync bidirectional fields: \(error)")
    }
  }

  /// Merges personal information from CloudKit record to local student model
  /// Uses custom merge strategy: prefer non-empty values, use timestamp if both non-empty
  private func mergePersonalInfo(from cloudKitRecord: CKRecord, to student: Student) {
    let cloudKitTime = cloudKitRecord.modificationDate ?? Date.distantPast

    // For each bidirectional field, merge intelligently
    func mergeField<T: Equatable>(
      _ key: String, getter: (Student) -> T, setter: (Student, T) -> Void, cloudKitValue: T?
    ) {
      if let cloudKitValue = cloudKitValue {
        let localValue = getter(student)

        // If CloudKit has a value and local doesn't (or is empty for strings), use CloudKit
        if localValue is String {
          let localStr = localValue as! String
          let cloudKitStr = cloudKitValue as! String
          if localStr.isEmpty && !cloudKitStr.isEmpty {
            setter(student, cloudKitValue)
          } else if !cloudKitStr.isEmpty {
            // Both have values - use CloudKit if it's newer
            if cloudKitTime > student.lastModified {
              setter(student, cloudKitValue)
            }
          }
        } else {
          // For non-string types, prefer CloudKit if newer
          if cloudKitTime > student.lastModified {
            setter(student, cloudKitValue)
          }
        }
      }
    }

    // Merge each bidirectional field
    if let firstName = cloudKitRecord["firstName"] as? String, !firstName.isEmpty {
      if student.firstName.isEmpty || cloudKitTime > student.lastModified {
        student.firstName = firstName
      }
    }
    if let lastName = cloudKitRecord["lastName"] as? String, !lastName.isEmpty {
      if student.lastName.isEmpty || cloudKitTime > student.lastModified {
        student.lastName = lastName
      }
    }
    if let email = cloudKitRecord["email"] as? String, !email.isEmpty {
      if student.email.isEmpty || cloudKitTime > student.lastModified {
        student.email = email
      }
    }
    if let telephone = cloudKitRecord["telephone"] as? String, !telephone.isEmpty {
      if student.telephone.isEmpty || cloudKitTime > student.lastModified {
        student.telephone = telephone
      }
    }
    if let homeAddress = cloudKitRecord["homeAddress"] as? String, !homeAddress.isEmpty {
      if student.homeAddress.isEmpty || cloudKitTime > student.lastModified {
        student.homeAddress = homeAddress
      }
    }
    if let ftnNumber = cloudKitRecord["ftnNumber"] as? String, !ftnNumber.isEmpty {
      if student.ftnNumber.isEmpty || cloudKitTime > student.lastModified {
        student.ftnNumber = ftnNumber
      }
    }
    if let biography = cloudKitRecord["biography"] as? String {
      if student.biography == nil || cloudKitTime > student.lastModified {
        student.biography = biography
      }
    }

    // Update lastModified if we merged changes
    if cloudKitTime > student.lastModified {
      student.lastModified = cloudKitTime
      student.lastModifiedBy = cloudKitRecord["lastModifiedBy"] as? String ?? "student"
    }
  }

  /// Syncs documents from CloudKit with last-write-wins conflict resolution
  private func syncDocumentsFromCloudKit(
    student: Student, customZone: CKRecordZone, modelContext: ModelContext
  ) async {
    do {
      let predicate = NSPredicate(format: "studentId == %@", student.id.uuidString)
      let query = CKQuery(recordType: "StudentDocument", predicate: predicate)

      let results = try await database.records(matching: query, inZoneWith: customZone.zoneID)

      for (recordID, result) in results.matchResults {
        switch result {
        case .success(let record):
          let cloudKitTime = record.modificationDate ?? Date.distantPast
          let documentIdString = recordID.recordName

          guard let documentId = UUID(uuidString: documentIdString) else { continue }

          // Find or create local document
          let request = FetchDescriptor<StudentDocument>(
            predicate: #Predicate { $0.id == documentId }
          )
          let existingDocs = try? modelContext.fetch(request)
          let document =
            existingDocs?.first
            ?? StudentDocument(
              documentType: DocumentType(rawValue: record["documentType"] as? String ?? "")
                ?? .studentPilotCertificate,
              filename: record["filename"] as? String ?? ""
            )

          if existingDocs?.first == nil {
            document.id = documentId
            document.student = student
            modelContext.insert(document)
          }

          // Check if CloudKit version is newer
          if cloudKitTime > document.lastModified {
            // CloudKit version is newer - use it
            if let fileAsset = record["fileData"] as? CKAsset {
              document.fileData = try? Data(contentsOf: fileAsset.fileURL!)
            }
            document.notes = record["notes"] as? String
            document.expirationDate = record["expirationDate"] as? Date
            document.lastModified = cloudKitTime
            document.lastModifiedBy = record["lastModifiedBy"] as? String
            document.cloudKitRecordID = documentIdString
          }

        case .failure(let error):
          print("⚠️ Failed to fetch document record: \(error)")
        }
      }
    } catch {
      print("❌ Failed to sync documents from CloudKit: \(error)")
    }
  }

  /// Pulls all student-owned data from CloudKit (training goals, milestones)
  /// Student-owned data includes: training goals, ground school completion, written test completion
  func pullStudentDataFromCloudKit(_ student: Student, modelContext: ModelContext) async {
    // Use the TrainingGoalsRecord-based approach for proper data flow
    await pullTrainingGoalsFromCloudKit(student, modelContext: modelContext)
  }

  // MARK: - Debug Methods
}
