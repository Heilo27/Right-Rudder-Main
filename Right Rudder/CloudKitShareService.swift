import Foundation
import CloudKit
import SwiftUI
import SwiftData
import Combine

/// Data structure for offline operations
struct OfflineOperationData: Codable {
    let operationType: String
    let timestamp: Date
}

@MainActor
class CloudKitShareService: ObservableObject {
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
    
    // Reference-based CloudKit service
    private let referenceBasedService = ReferenceBasedCloudKitService()
    
    init() {
        self.container = CKContainer(identifier: "iCloud.com.heiloprojects.rightrudder")
        self.database = container.privateCloudDatabase
    }
    
    func setModelContext(_ context: ModelContext) {
        offlineSyncManager.setModelContext(context)
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
            
            // Create student record ID in the custom zone
            let studentRecordID = CKRecord.ID(recordName: student.id.uuidString, zoneID: customZone.zoneID)
            
            // Try to fetch existing record or create new one
            let studentRecord: CKRecord
            if let existingRecord = try? await database.record(for: studentRecordID) {
                studentRecord = existingRecord
                
                // CRITICAL: Ensure studentId field is set in existing record (for backward compatibility)
                var needsSave = false
                if studentRecord["studentId"] == nil || (studentRecord["studentId"] as? String) != student.id.uuidString {
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
                let savedRecord = try await database.save(studentRecord)
                
                // Use the saved record for sharing
                studentRecord.setValuesForKeys(savedRecord.dictionaryWithValues(forKeys: Array(savedRecord.allKeys())))
            }
            
            // CRITICAL: Clear any previous shareTerminated flag when creating a new share
            // This ensures student app doesn't see stale termination flags from previous unlinks
            studentRecord["shareTerminated"] = false
            studentRecord["shareTerminatedAt"] = nil
            print("   🔄 Cleared previous shareTerminated flag (if any)")
            
            // Create a new share
            let share = CKShare(rootRecord: studentRecord)
            
            // Configure share permissions
            share[CKShare.SystemFieldKey.title] = "Student Profile: \(student.displayName)" as CKRecordValue
            share[CKShare.SystemFieldKey.shareType] = "com.heiloprojects.rightrudder.student" as CKRecordValue
            
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
                    throw error
                }
            }
            
            // Use the share we just created if we can't find it in results
            if savedShare == nil {
                savedShare = share
            }
            
            guard let finalShare = savedShare, let shareURL = finalShare.url else {
                throw NSError(domain: "CloudKitShareService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Share was saved but has no URL"])
            }
            
            print("✅ Share created successfully: \(shareURL.absoluteString)")
            
            // Update student's CloudKit record ID
            student.cloudKitRecordID = studentRecord.recordID.recordName
            student.shareRecordID = finalShare.recordID.recordName
            student.lastModified = Date()
            
            try modelContext.save()
            
            // CRITICAL: After creating share, sync assignments to shared zone IN BACKGROUND
            // Don't block share creation - sync will happen asynchronously
            // Only sync assignment records (not item progress) initially for speed
            // ItemProgress will sync when instructor checks items
            print("🔄 Queueing assignment sync to shared zone (will happen in background)...")
            let assignments = student.checklistAssignments ?? []
            print("📋 Found \(assignments.count) assignments to sync (will sync progressively)")
            
            // Start background sync task - don't await it
            // CRITICAL: Only sync assignment metadata initially (fast).
            // ItemProgress syncs happen separately when instructor checks items.
            // This avoids syncing 700+ ItemProgress records (35 lessons × 20 items) during share creation.
            Task {
                var syncedCount = 0
                for assignment in assignments {
                    // Sync only assignment metadata first (fast) - just the assignment record, no ItemProgress
                    // Note: We use syncAssignmentMetadataOnly here (not syncAssignmentToSharedZone) to avoid ItemProgress sync during share creation
                    await syncAssignmentMetadataOnly(assignment, student: student, customZone: customZone)
                    syncedCount += 1
                    print("   ✅ Synced assignment metadata \(syncedCount)/\(assignments.count): \(assignment.templateIdentifier ?? "unknown")")
                }
                print("✅ Background sync completed: \(syncedCount)/\(assignments.count) assignment records synced")
                print("   ℹ️ ItemProgress will sync incrementally as instructor checks items")
            }
            
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
            errorMessage = "CloudKit error: \(error.localizedDescription)"
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
    
    /// Removes sharing for a student
    /// This will be detected by the student app on next sync or when they check share status
    func removeShareForStudent(_ student: Student, modelContext: ModelContext) async -> Bool {
        guard let shareRecordName = student.shareRecordID else {
            print("No share record ID found for student")
            return false
        }
        
        do {
            let customZone = try await ensureCustomZoneExists()
            let shareRecordID = CKRecord.ID(recordName: shareRecordName, zoneID: customZone.zoneID)
            
            // Delete the share record - this will notify the student app that sharing has ended
            try await database.deleteRecord(withID: shareRecordID)
            
            // Also mark the student record as unshared (add a flag that student app can check)
            let studentRecordID = CKRecord.ID(recordName: student.id.uuidString, zoneID: customZone.zoneID)
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
            
            student.shareRecordID = nil
            student.lastModified = Date()
            try modelContext.save()
            
            print("✅ Share removed successfully - student app will detect this on next sync")
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
    
    /// Gets the current CloudKit user's email address
    /// Note: Direct user identity lookup is deprecated in iOS 17+
    /// We'll set instructorEmail when creating the share from the share metadata
    private func getCurrentUserEmail() async throws -> String? {
        // Note: userIdentity(forUserRecordID:) is deprecated in iOS 17+
        // For now, return nil - the instructorEmail should be set from share metadata
        // when the share is accepted by the student app
        return nil
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
                print("⚠️ Share exists but has no participants (student hasn't accepted) for: \(student.displayName)")
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
    
    /// Syncs student personal information to CloudKit for sharing
    func syncStudentPersonalInfo(_ student: Student, modelContext: ModelContext) async {
        do {
            guard student.shareRecordID != nil else {
                print("No active share for student \(student.displayName), skipping personal info sync")
                return
            }
            
            // Get the custom zone
            let customZone = try await ensureCustomZoneExists()
            
            // Create record ID in custom zone
            let recordID = CKRecord.ID(recordName: student.id.uuidString, zoneID: customZone.zoneID)
            let existingRecord = try? await database.record(for: recordID)
            
            let record: CKRecord
            var hasChanges = false
            
            if let existing = existingRecord {
                record = existing
                
                // Only update fields that have actually changed
                func updateIfChangedString(_ key: String, newValue: String?) {
                    let existingValue = record[key] as? String
                    if existingValue != newValue {
                        record[key] = newValue
                        hasChanges = true
                    }
                }
                
                func updateIfChangedDate(_ key: String, newValue: Date?) {
                    let existingValue = record[key] as? Date
                    if existingValue != newValue {
                        record[key] = newValue
                        hasChanges = true
                    }
                }
                
                func updateIfChangedBool(_ key: String, newValue: Bool) {
                    let existingValue = record[key] as? Bool ?? false
                    if existingValue != newValue {
                        record[key] = newValue
                        hasChanges = true
                    }
                }
                
                // Update only changed fields
                updateIfChangedString("firstName", newValue: student.firstName)
                updateIfChangedString("lastName", newValue: student.lastName)
                updateIfChangedString("email", newValue: student.email)
                updateIfChangedString("telephone", newValue: student.telephone)
                updateIfChangedString("homeAddress", newValue: student.homeAddress)
                updateIfChangedString("ftnNumber", newValue: student.ftnNumber)
                updateIfChangedString("biography", newValue: student.biography)
                updateIfChangedString("backgroundNotes", newValue: student.backgroundNotes)
                updateIfChangedString("assignedCategory", newValue: student.assignedCategory)
                updateIfChangedBool("isInactive", newValue: student.isInactive)
                updateIfChangedDate("lastModified", newValue: student.lastModified)
            } else {
                // New record - set all fields
                record = CKRecord(recordType: "Student", recordID: recordID)
                record["firstName"] = student.firstName
                record["lastName"] = student.lastName
                record["email"] = student.email
                record["telephone"] = student.telephone
                record["homeAddress"] = student.homeAddress
                record["ftnNumber"] = student.ftnNumber
                record["biography"] = student.biography
                record["backgroundNotes"] = student.backgroundNotes
                record["assignedCategory"] = student.assignedCategory
                record["isInactive"] = student.isInactive
                record["lastModified"] = student.lastModified
                hasChanges = true
            }
            
            // Only save if there are actual changes
            if hasChanges {
                let savedRecord = try await saveRecordWithConflictResolution(record)
                print("✅ Student personal info synced to CloudKit: \(savedRecord.recordID)")
            } else {
                print("ℹ️ Student personal info unchanged, skipping CloudKit sync: \(student.displayName)")
            }
            
        } catch {
            print("❌ Failed to sync student personal info: \(error)")
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
                    let studentRecordID = CKRecord.ID(recordName: student.id.uuidString, zoneID: customZone.zoneID)
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
    func syncStudentChecklistAssignmentsToSharedZone(_ student: Student, modelContext: ModelContext) async {
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
    func syncStudentChecklistProgressToSharedZone(_ student: Student, modelContext: ModelContext) async {
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
                await syncAssignmentToSharedZone(assignment, student: student, customZone: customZone)
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
    
    /// Syncs a specific checklist assignment to the shared zone
    /// Syncs a checklist assignment to CloudKit shared zone.
    /// IMPORTANT: Only syncs the assignment/progress data, NOT the full lesson definition.
    /// - ChecklistAssignment record: Contains templateId (reference), instructorComments, dualGivenHours
    /// - ItemProgress records: One per item, containing isComplete, notes, completedAt
    /// Both apps already have all lesson definitions in their internal libraries.
    /// When student app receives this, it looks up the lesson by templateId and displays progress.
    /// - Parameter syncItemProgress: If true, also syncs all ItemProgress records. Set to false during initial share creation for performance.
    private func syncAssignmentToSharedZone(_ assignment: ChecklistAssignment, student: Student, customZone: CKRecordZone, syncItemProgress: Bool = true) async {
        do {
            // Create assignment record ID in custom zone
            let assignmentRecordID = CKRecord.ID(recordName: assignment.id.uuidString, zoneID: customZone.zoneID)
            let existingAssignmentRecord = try? await database.record(for: assignmentRecordID)
            
            let assignmentRecord: CKRecord
            let hadComments = (existingAssignmentRecord?["instructorComments"] as? String)?.isEmpty == false
            let nowHasComments = !(assignment.instructorComments?.isEmpty ?? true)
            let commentsChanged = !hadComments && nowHasComments
            
            // Check if checklist just reached 100% completion
            let wasComplete = (existingAssignmentRecord?["isComplete"] as? Bool) ?? false
            let isNowComplete = assignment.isComplete
            let completionChanged = !wasComplete && isNowComplete
            
            if let existing = existingAssignmentRecord {
                assignmentRecord = existing
            } else {
                assignmentRecord = CKRecord(recordType: "ChecklistAssignment", recordID: assignmentRecordID)
            }
            
            // Determine if this is a custom checklist or library checklist
            let isCustomChecklist = assignment.isCustomChecklist
            
            // Update assignment record with essential data (NOT the full lesson definition)
            // Only sync: templateId reference, instructorComments, dualGivenHours, assignment metadata
            assignmentRecord["templateId"] = assignment.templateId.uuidString
            assignmentRecord["templateIdentifier"] = assignment.templateIdentifier
            assignmentRecord["isCustomChecklist"] = isCustomChecklist
            assignmentRecord["instructorComments"] = assignment.instructorComments
            assignmentRecord["dualGivenHours"] = assignment.dualGivenHours
            assignmentRecord["assignedAt"] = assignment.assignedAt
            assignmentRecord["lastModified"] = assignment.lastModified
            assignmentRecord["studentId"] = student.id.uuidString
            
            // For custom checklists (user-created), we DO need to send the full definition
            // since it doesn't exist in the student app's library
            if isCustomChecklist {
                if let template = assignment.template {
                    assignmentRecord["customName"] = template.name
                    assignmentRecord["customCategory"] = template.category
                    
                    // Encode custom items as JSON
                    if let items = template.items {
                        let customItems = items.map { item in
                            [
                                "id": item.id.uuidString,
                                "title": item.title,
                                "notes": item.notes ?? "",
                                "order": item.order
                            ]
                        }
                        
                        if let itemsData = try? JSONSerialization.data(withJSONObject: customItems) {
                            assignmentRecord["customItems"] = itemsData
                        }
                    }
                }
            }
            
            // Set parent reference to student record for sharing
            let studentRecordID = CKRecord.ID(recordName: student.id.uuidString, zoneID: customZone.zoneID)
            assignmentRecord.parent = CKRecord.Reference(recordID: studentRecordID, action: .none)
            
            let savedAssignmentRecord = try await saveRecordWithConflictResolution(assignmentRecord)
            assignment.cloudKitRecordID = savedAssignmentRecord.recordID.recordName
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
            
            // Sync ItemProgress if requested (skip during initial share creation for performance)
            if syncItemProgress {
                await syncItemProgressToSharedZone(assignment, assignmentRecordID: savedAssignmentRecord.recordID, customZone: customZone)
            }
            
            // For custom checklists, also sync the CustomChecklistDefinition record to shared zone
            // so student app can query it separately
            if isCustomChecklist {
                await syncCustomChecklistDefinitionToSharedZone(assignment, student: student, customZone: customZone)
            }
            
        } catch {
            print("Failed to sync assignment \(assignment.displayName) to shared zone: \(error)")
            
            // If sync fails due to network issues, queue for retry
            if isNetworkError(error) {
                print("Network error detected, operation will be queued for retry")
            }
        }
    }
    
    /// Syncs CustomChecklistDefinition record to shared zone for student app
    /// This allows the student app to query custom checklist definitions separately
    private func syncCustomChecklistDefinitionToSharedZone(_ assignment: ChecklistAssignment, student: Student, customZone: CKRecordZone) async {
        guard assignment.isCustomChecklist, let template = assignment.template else {
            return
        }
        
        do {
            let sharedDatabase = container.sharedCloudDatabase
            
            // Create CustomChecklistDefinition record in shared zone
            let definitionRecordID = CKRecord.ID(recordName: "custom-definition-\(assignment.templateId.uuidString)", zoneID: customZone.zoneID)
            let existingDefinitionRecord = try? await sharedDatabase.record(for: definitionRecordID)
            
            let definitionRecord: CKRecord
            if let existing = existingDefinitionRecord {
                definitionRecord = existing
            } else {
                definitionRecord = CKRecord(recordType: "CustomChecklistDefinition", recordID: definitionRecordID)
            }
            
            // Update definition record fields
            definitionRecord["templateId"] = assignment.templateId.uuidString
            definitionRecord["customName"] = template.name
            definitionRecord["customCategory"] = template.category
            definitionRecord["studentId"] = student.id.uuidString
            definitionRecord["lastModified"] = Date()
            
            // Store custom items as JSON string
            if let items = template.items {
                let customItems = items.map { item in
                    [
                        "id": item.id.uuidString,
                        "title": item.title,
                        "notes": item.notes ?? "",
                        "order": item.order
                    ]
                }
                
                if let jsonData = try? JSONSerialization.data(withJSONObject: customItems),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    definitionRecord["customItems"] = jsonString
                }
            }
            
            // Set parent reference to student record
            let studentRecordID = CKRecord.ID(recordName: student.id.uuidString, zoneID: customZone.zoneID)
            definitionRecord.parent = CKRecord.Reference(recordID: studentRecordID, action: .none)
            
            _ = try await saveRecordWithConflictResolution(definitionRecord)
            print("✅ Synced CustomChecklistDefinition to shared zone: \(template.name)")
        } catch let error as CKError {
            if error.code == .unknownItem || error.localizedDescription.contains("recordType") || error.localizedDescription.contains("not deployed") {
                print("⚠️ CustomChecklistDefinition record type not deployed yet")
                print("   Run initializeCloudKitSchema() or deploy schema manually in CloudKit Dashboard")
            } else {
                print("❌ Failed to sync CustomChecklistDefinition to shared zone: \(error)")
            }
        } catch {
            print("❌ Failed to sync CustomChecklistDefinition to shared zone: \(error)")
        }
    }
    
    /// Syncs only assignment metadata (fast) - does NOT sync ItemProgress
    /// This is used during initial share creation to avoid blocking
    private func syncAssignmentMetadataOnly(_ assignment: ChecklistAssignment, student: Student, customZone: CKRecordZone) async {
        do {
            let assignmentRecordID = CKRecord.ID(recordName: assignment.id.uuidString, zoneID: customZone.zoneID)
            let existingAssignmentRecord = try? await database.record(for: assignmentRecordID)
            
            let assignmentRecord: CKRecord = existingAssignmentRecord ?? CKRecord(recordType: "ChecklistAssignment", recordID: assignmentRecordID)
            
            // Only sync assignment metadata - NO ItemProgress here
            assignmentRecord["templateId"] = assignment.templateId.uuidString
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
                            "order": item.order
                        ]
                    }
                    if let itemsData = try? JSONSerialization.data(withJSONObject: customItems) {
                        assignmentRecord["customItems"] = itemsData
                    }
                }
            }
            
            let studentRecordID = CKRecord.ID(recordName: student.id.uuidString, zoneID: customZone.zoneID)
            assignmentRecord.parent = CKRecord.Reference(recordID: studentRecordID, action: .none)
            
            let savedAssignmentRecord = try await saveRecordWithConflictResolution(assignmentRecord)
            assignment.cloudKitRecordID = savedAssignmentRecord.recordID.recordName
            
        } catch {
            print("⚠️ Failed to sync assignment metadata for \(assignment.displayName): \(error)")
        }
    }
    
    /// Syncs ItemProgress for a single assignment (called separately for performance)
    private func syncItemProgressForAssignment(_ assignment: ChecklistAssignment, student: Student, customZone: CKRecordZone) async {
        guard let assignmentRecordIDString = assignment.cloudKitRecordID else {
            print("⚠️ Cannot sync ItemProgress - assignment has no CloudKit record ID")
            return
        }
        
        let assignmentRecordID = CKRecord.ID(recordName: assignmentRecordIDString, zoneID: customZone.zoneID)
        await syncItemProgressToSharedZone(assignment, assignmentRecordID: assignmentRecordID, customZone: customZone)
    }
    
    /// Syncs a single ItemProgress record to CloudKit (called when instructor checks/unchecks an item)
    /// This is optimized to sync only the changed item, not all items in the assignment
    func syncSingleItemProgressToSharedZone(itemProgress: ItemProgress, assignment: ChecklistAssignment, student: Student) async {
        guard student.shareRecordID != nil,
              let assignmentRecordIDString = assignment.cloudKitRecordID else {
            return
        }
        
        do {
            let customZone = try await ensureCustomZoneExists()
            let assignmentRecordID = CKRecord.ID(recordName: assignmentRecordIDString, zoneID: customZone.zoneID)
            
            let itemRecordID = CKRecord.ID(recordName: itemProgress.id.uuidString, zoneID: customZone.zoneID)
            let existingItemRecord = try? await database.record(for: itemRecordID)
            
            let itemRecord: CKRecord = existingItemRecord ?? CKRecord(recordType: "ItemProgress", recordID: itemRecordID)
            
            // Sync only the changed item's progress data
            // CloudKit requires Bool values to be wrapped in NSNumber
            itemRecord["templateItemId"] = itemProgress.templateItemId.uuidString
            let isCompleteValue = NSNumber(value: itemProgress.isComplete)
            itemRecord["isComplete"] = isCompleteValue
            itemRecord["notes"] = itemProgress.notes
            itemRecord["instructorNotes"] = itemProgress.notes  // Backwards compatibility
            itemRecord["completedAt"] = itemProgress.completedAt
            itemRecord["lastModified"] = itemProgress.lastModified
            itemRecord["assignmentId"] = assignment.id.uuidString
            
            // Set parent reference
            itemRecord.parent = CKRecord.Reference(recordID: assignmentRecordID, action: .none)
            
            let savedItemRecord = try await saveRecordWithConflictResolution(itemRecord)
            itemProgress.cloudKitRecordID = savedItemRecord.recordID.recordName
            itemProgress.lastModified = Date()
            
            // Enhanced diagnostic logging
            print("✅ Synced single ItemProgress to CloudKit:")
            print("   - templateItemId: \(itemProgress.templateItemId.uuidString)")
            print("   - isComplete (Bool): \(itemProgress.isComplete)")
            print("   - isComplete (NSNumber): \(isCompleteValue)")
            print("   - assignmentId: \(assignment.id.uuidString)")
            print("   - CloudKit Record ID: \(savedItemRecord.recordID.recordName)")
            if let notes = itemProgress.notes {
                print("   - notes: \(notes)")
            }
            if let completedAt = itemProgress.completedAt {
                print("   - completedAt: \(completedAt)")
            }
        } catch {
            print("⚠️ Failed to sync single ItemProgress: \(error)")
        }
    }
    
    /// Syncs ItemProgress records to CloudKit shared zone.
    /// These records contain:
    /// - templateItemId (reference to item in library)
    /// - isComplete (check-off status)
    /// - notes (instructor comments)
    /// - completedAt (when checked)
    /// This is the "progress file" that shows what items have been checked off.
    private func syncItemProgressToSharedZone(_ assignment: ChecklistAssignment, assignmentRecordID: CKRecord.ID, customZone: CKRecordZone) async {
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
                let itemRecordID = CKRecord.ID(recordName: item.id.uuidString, zoneID: customZone.zoneID)
                let existingItemRecord = try? await database.record(for: itemRecordID)
                
                let itemRecord: CKRecord
                if let existing = existingItemRecord {
                    itemRecord = existing
                } else {
                    itemRecord = CKRecord(recordType: "ItemProgress", recordID: itemRecordID)
                }
                
                // Only sync essential progress data, not the full item details
                // CloudKit requires Bool values to be wrapped in NSNumber
                itemRecord["templateItemId"] = item.templateItemId.uuidString
                let isCompleteValue = NSNumber(value: item.isComplete)  // CRITICAL: Sync checkmark status (wrapped in NSNumber)
                itemRecord["isComplete"] = isCompleteValue
                itemRecord["notes"] = item.notes  // Also sync notes field (student app expects "notes" not "instructorNotes")
                itemRecord["instructorNotes"] = item.notes  // Keep for backwards compatibility
                itemRecord["completedAt"] = item.completedAt
                itemRecord["lastModified"] = item.lastModified
                itemRecord["assignmentId"] = assignment.id.uuidString  // CRITICAL: Must match assignment.id (not recordName)
                
                // Set parent reference to assignment record
                itemRecord.parent = CKRecord.Reference(recordID: assignmentRecordID, action: .none)
                
                let savedItemRecord = try await saveRecordWithConflictResolution(itemRecord)
                item.cloudKitRecordID = savedItemRecord.recordID.recordName
                item.lastModified = Date()
                syncedCount += 1
                
                if item.isComplete {
                    completedCount += 1
                    print("   ✅ Synced completed item: templateItemId=\(item.templateItemId.uuidString), isComplete=true (NSNumber: \(isCompleteValue))")
                }
            }
            
            print("✅ Synced \(syncedCount)/\(items.count) ItemProgress records (\(completedCount) completed) for assignment: \(assignment.displayName)")
        } catch {
            print("❌ Failed to sync item progress for \(assignment.displayName): \(error)")
        }
    }
    
    /// Checks if a template exists in the default library
    private func isTemplateInLibrary(templateId: UUID) -> Bool {
        // This would check against the embedded library in the student app
        // For now, we'll assume all templates with standard identifiers are in the library
        // Custom templates would have different identifiers
        return true // TODO: Implement actual library check
    }
    
    // MARK: - Legacy Sync Functions (Deprecated - Use assignment-based sync above)
    
    /// Performs the actual sync operation (DEPRECATED - Use syncAssignmentsToSharedZone)
    private func performSyncStudentChecklistsToSharedZone(_ student: Student, modelContext: ModelContext) async {
        // This function is deprecated - use syncAssignmentsToSharedZone instead
        await syncAssignmentsToSharedZone(student, modelContext: modelContext)
    }
    
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
    
    /// Syncs a specific checklist assignment to the shared zone (LEGACY - use syncAssignmentToSharedZone instead)
    private func syncChecklistToSharedZone(_ assignment: ChecklistAssignment, student: Student, customZone: CKRecordZone) async {
        do {
            // Create record ID in custom zone
            let recordID = CKRecord.ID(recordName: assignment.id.uuidString, zoneID: customZone.zoneID)
            let existingRecord = try? await database.record(for: recordID)
            
            let record: CKRecord
            let hadComments = (existingRecord?["instructorComments"] as? String)?.isEmpty == false
            let nowHasComments = !(assignment.instructorComments?.isEmpty ?? true)
            let commentsChanged = !hadComments && nowHasComments
            
            // Check if checklist just reached 100% completion
            let wasComplete = (existingRecord?["isComplete"] as? Bool) ?? false
            let isNowComplete = assignment.isComplete
            let completionChanged = !wasComplete && isNowComplete
            
            if let existing = existingRecord {
                record = existing
            } else {
                record = CKRecord(recordType: "ChecklistAssignment", recordID: recordID)
            }
            
            // Update record with checklist data
            record["templateId"] = assignment.templateId.uuidString
            record["templateName"] = assignment.displayName
            record["templateIdentifier"] = assignment.templateIdentifier
            record["instructorComments"] = assignment.instructorComments
            record["studentId"] = student.id.uuidString
            record["lastModified"] = assignment.lastModified
            record["dualGivenHours"] = assignment.dualGivenHours
            record["isComplete"] = isNowComplete
            record["completionPercentage"] = assignment.progressPercentage
            record["completedItemsCount"] = assignment.completedItemsCount
            record["totalItemsCount"] = assignment.totalItemsCount
            
            // Set parent reference to student record for sharing
            let studentRecordID = CKRecord.ID(recordName: student.id.uuidString, zoneID: customZone.zoneID)
            record.parent = CKRecord.Reference(recordID: studentRecordID, action: .none)
            
            let savedRecord = try await saveRecordWithConflictResolution(record)
            assignment.cloudKitRecordID = savedRecord.recordID.recordName
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
            
            // Sync checklist items
            await syncChecklistItemsToSharedZone(assignment, customZone: customZone)
            
        } catch {
            print("Failed to sync checklist \(assignment.displayName) to shared zone: \(error)")
            
            // If sync fails due to network issues, queue for retry
            if isNetworkError(error) {
                // Note: We can't access modelContext here, so we'll rely on the calling method to handle queuing
                print("Network error detected, operation will be queued for retry")
            }
        }
    }
    
    /// Syncs checklist items to the shared zone (LEGACY - use syncItemProgressToSharedZone instead)
    private func syncChecklistItemsToSharedZone(_ assignment: ChecklistAssignment, customZone: CKRecordZone) async {
        do {
            for item in assignment.itemProgress ?? [] {
                let recordID = CKRecord.ID(recordName: item.id.uuidString, zoneID: customZone.zoneID)
                let existingRecord = try? await database.record(for: recordID)
                
                let record: CKRecord
                if let existing = existingRecord {
                    record = existing
                } else {
                    record = CKRecord(recordType: "ItemProgress", recordID: recordID)
                }
                
                record["templateItemId"] = item.templateItemId.uuidString
                record["title"] = item.displayTitle
                record["isComplete"] = item.isComplete
                record["notes"] = item.notes
                record["completedAt"] = item.completedAt
                record["assignmentId"] = assignment.id.uuidString
                record["lastModified"] = item.lastModified
                
                // Set parent reference to assignment record
                let assignmentRecordID = CKRecord.ID(recordName: assignment.id.uuidString, zoneID: customZone.zoneID)
                record.parent = CKRecord.Reference(recordID: assignmentRecordID, action: .none)
                
                let savedRecord = try await saveRecordWithConflictResolution(record)
                item.cloudKitRecordID = savedRecord.recordID.recordName
                item.lastModified = Date()
            }
        } catch {
            print("Failed to sync checklist items to shared zone: \(error)")
        }
    }
    
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
    
    /// Saves a CloudKit record with automatic conflict resolution
    private func saveRecordWithConflictResolution(_ record: CKRecord) async throws -> CKRecord {
        var retryCount = 0
        let maxRetries = 3
        
        while retryCount < maxRetries {
            do {
                return try await database.save(record)
            } catch let error as CKError {
                if error.code == .serverRecordChanged {
                    retryCount += 1
                    print("⚠️ Server record changed conflict detected for \(record.recordType) (attempt \(retryCount)/\(maxRetries)). Attempting resolution...")
                    
                    // Fetch the latest version from server
                    let latestRecord = try await database.record(for: record.recordID)
                    
                    // Use intelligent merge strategy based on record type
                    let mergedRecord = intelligentMerge(ourRecord: record, serverRecord: latestRecord)
                    
                    // Update our record with the merged version
                    record.setValuesForKeys(mergedRecord.allKeys().reduce(into: [String: Any]()) { result, key in
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
        if let latestRecord = try? await database.record(for: record.recordID) {
            print("   Server record keys: \(latestRecord.allKeys())")
        }
        throw CKError(.serverRecordChanged)
    }
    
    /// Intelligent merge strategy based on record type and field
    private func intelligentMerge(ourRecord: CKRecord, serverRecord: CKRecord) -> CKRecord {
        var mergedRecord = serverRecord // Start with server version (latest metadata)
        
        // Merge strategy depends on record type
        switch ourRecord.recordType {
        case "StudentChecklist":
            mergedRecord = mergeChecklistRecord(ourRecord: ourRecord, serverRecord: serverRecord)
        case "StudentChecklistItem":
            mergedRecord = mergeChecklistItemRecord(ourRecord: ourRecord, serverRecord: serverRecord)
        case "ChecklistAssignment":
            mergedRecord = mergeChecklistAssignmentRecord(ourRecord: ourRecord, serverRecord: serverRecord)
        default:
            // Default merge strategy
            mergedRecord = mergeGenericRecord(ourRecord: ourRecord, serverRecord: serverRecord)
        }
        
        // Always update lastModified to current time
        mergedRecord["lastModified"] = Date()
        
        return mergedRecord
    }
    
    /// Merge strategy for ChecklistAssignment records
    private func mergeChecklistAssignmentRecord(ourRecord: CKRecord, serverRecord: CKRecord) -> CKRecord {
        print("📝 Using intelligent merge for ChecklistAssignment conflict resolution")
        let mergedRecord = serverRecord // Start with server version
        
        // For instructor comments, prefer the longer/more recent one
        if let ourComments = ourRecord["instructorComments"] as? String,
           let serverComments = serverRecord["instructorComments"] as? String {
            if ourComments.count > serverComments.count {
                mergedRecord["instructorComments"] = ourComments
            }
        } else if ourRecord["instructorComments"] != nil {
            mergedRecord["instructorComments"] = ourRecord["instructorComments"]
        }
        
        // For dual given hours, use the higher value
        if let ourHours = ourRecord["dualGivenHours"] as? Double,
           let serverHours = serverRecord["dualGivenHours"] as? Double {
            mergedRecord["dualGivenHours"] = max(ourHours, serverHours)
        } else if ourRecord["dualGivenHours"] != nil {
            mergedRecord["dualGivenHours"] = ourRecord["dualGivenHours"]
        }
        
        // For isComplete, prefer completed (true wins)
        if let ourComplete = ourRecord["isComplete"] as? Bool,
           let serverComplete = serverRecord["isComplete"] as? Bool {
            mergedRecord["isComplete"] = ourComplete || serverComplete
        } else if ourRecord["isComplete"] != nil {
            mergedRecord["isComplete"] = ourRecord["isComplete"]
        }
        
        // For completion percentage and counts, use the higher values
        if let ourPercentage = ourRecord["completionPercentage"] as? Double,
           let serverPercentage = serverRecord["completionPercentage"] as? Double {
            mergedRecord["completionPercentage"] = max(ourPercentage, serverPercentage)
        } else if ourRecord["completionPercentage"] != nil {
            mergedRecord["completionPercentage"] = ourRecord["completionPercentage"]
        }
        
        if let ourCompleted = ourRecord["completedItemsCount"] as? Int,
           let serverCompleted = serverRecord["completedItemsCount"] as? Int {
            mergedRecord["completedItemsCount"] = max(ourCompleted, serverCompleted)
        } else if ourRecord["completedItemsCount"] != nil {
            mergedRecord["completedItemsCount"] = ourRecord["completedItemsCount"]
        }
        
        if let ourTotal = ourRecord["totalItemsCount"] as? Int,
           let serverTotal = serverRecord["totalItemsCount"] as? Int {
            mergedRecord["totalItemsCount"] = max(ourTotal, serverTotal)
        } else if ourRecord["totalItemsCount"] != nil {
            mergedRecord["totalItemsCount"] = ourRecord["totalItemsCount"]
        }
        
        // Preserve essential fields that might be missing
        if mergedRecord["templateId"] == nil && ourRecord["templateId"] != nil {
            mergedRecord["templateId"] = ourRecord["templateId"]
        }
        
        if mergedRecord["templateIdentifier"] == nil && ourRecord["templateIdentifier"] != nil {
            mergedRecord["templateIdentifier"] = ourRecord["templateIdentifier"]
        }
        
        if mergedRecord["studentId"] == nil && ourRecord["studentId"] != nil {
            mergedRecord["studentId"] = ourRecord["studentId"]
        }
        
        if mergedRecord["assignedAt"] == nil && ourRecord["assignedAt"] != nil {
            mergedRecord["assignedAt"] = ourRecord["assignedAt"]
        }
        
        // Handle any other fields that might exist
        for key in ourRecord.allKeys() {
            if mergedRecord[key] == nil && ourRecord[key] != nil {
                mergedRecord[key] = ourRecord[key]
            }
        }
        
        return mergedRecord
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
           let serverComments = serverRecord["instructorComments"] as? String {
            if ourComments.count > serverComments.count {
                mergedRecord["instructorComments"] = ourComments
            }
        } else if ourRecord["instructorComments"] != nil {
            mergedRecord["instructorComments"] = ourRecord["instructorComments"]
        }
        
        // For completion status, prefer the more complete one
        if let ourComplete = ourRecord["isComplete"] as? Bool,
           let serverComplete = serverRecord["isComplete"] as? Bool {
            mergedRecord["isComplete"] = ourComplete || serverComplete
        } else if ourRecord["isComplete"] != nil {
            mergedRecord["isComplete"] = ourRecord["isComplete"]
        }
        
        // For dual given hours, use the higher value
        if let ourHours = ourRecord["dualGivenHours"] as? Double,
           let serverHours = serverRecord["dualGivenHours"] as? Double {
            mergedRecord["dualGivenHours"] = max(ourHours, serverHours)
        } else if ourRecord["dualGivenHours"] != nil {
            mergedRecord["dualGivenHours"] = ourRecord["dualGivenHours"]
        }
        
        // For counts and percentages, use the higher values
        if let ourCompleted = ourRecord["completedItemsCount"] as? Int,
           let serverCompleted = serverRecord["completedItemsCount"] as? Int {
            mergedRecord["completedItemsCount"] = max(ourCompleted, serverCompleted)
        } else if ourRecord["completedItemsCount"] != nil {
            mergedRecord["completedItemsCount"] = ourRecord["completedItemsCount"]
        }
        
        if let ourPercentage = ourRecord["completionPercentage"] as? Double,
           let serverPercentage = serverRecord["completionPercentage"] as? Double {
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
           let serverComplete = serverRecord["isComplete"] as? Bool {
            mergedRecord["isComplete"] = ourComplete || serverComplete
        }
        
        // For notes, prefer the longer/more recent one
        if let ourNotes = ourRecord["notes"] as? String,
           let serverNotes = serverRecord["notes"] as? String {
            if ourNotes.count > serverNotes.count {
                mergedRecord["notes"] = ourNotes
            }
        } else if ourRecord["notes"] != nil {
            mergedRecord["notes"] = ourRecord["notes"]
        }
        
        // For completion date, use the earlier date (when it was first completed)
        if let ourDate = ourRecord["completedAt"] as? Date,
           let serverDate = serverRecord["completedAt"] as? Date {
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
                    await syncAssignmentToSharedZone(assignment, student: student, customZone: customZone)
                }
            }
            
            print("✅ Synced instructor data to CloudKit for: \(student.displayName)")
        } catch {
            print("❌ Failed to sync instructor data: \(error)")
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
            let studentRecordID = CKRecord.ID(recordName: student.id.uuidString, zoneID: customZone.zoneID)
            
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
            await syncDocumentsFromCloudKit(student: student, customZone: customZone, modelContext: modelContext)
            
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
        func mergeField<T: Equatable>(_ key: String, getter: (Student) -> T, setter: (Student, T) -> Void, cloudKitValue: T?) {
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
    private func syncDocumentsFromCloudKit(student: Student, customZone: CKRecordZone, modelContext: ModelContext) async {
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
                    let document = existingDocs?.first ?? StudentDocument(
                        documentType: DocumentType(rawValue: record["documentType"] as? String ?? "") ?? .studentPilotCertificate,
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
    
    /// Pulls student-owned data from CloudKit (read-only for instructor)
    /// Student-owned data includes: training goals, ground school completion, written test completion
    func pullStudentDataFromCloudKit(_ student: Student, modelContext: ModelContext) async {
        guard student.shareRecordID != nil else {
            return
        }
        
        do {
            let customZone = try await ensureCustomZoneExists()
            let studentRecordID = CKRecord.ID(recordName: student.id.uuidString, zoneID: customZone.zoneID)
            
            // Fetch student record from CloudKit
            let cloudKitRecord = try await database.record(for: studentRecordID)
            
            // Update student-owned fields (read-only for instructor - just read them)
            student.goalPPL = cloudKitRecord["goalPPL"] as? Bool ?? student.goalPPL
            student.goalInstrument = cloudKitRecord["goalInstrument"] as? Bool ?? student.goalInstrument
            student.goalCommercial = cloudKitRecord["goalCommercial"] as? Bool ?? student.goalCommercial
            student.goalCFI = cloudKitRecord["goalCFI"] as? Bool ?? student.goalCFI
            
            student.pplGroundSchoolCompleted = cloudKitRecord["pplGroundSchoolCompleted"] as? Bool ?? student.pplGroundSchoolCompleted
            student.pplWrittenTestCompleted = cloudKitRecord["pplWrittenTestCompleted"] as? Bool ?? student.pplWrittenTestCompleted
            
            student.instrumentGroundSchoolCompleted = cloudKitRecord["instrumentGroundSchoolCompleted"] as? Bool ?? student.instrumentGroundSchoolCompleted
            student.instrumentWrittenTestCompleted = cloudKitRecord["instrumentWrittenTestCompleted"] as? Bool ?? student.instrumentWrittenTestCompleted
            
            student.commercialGroundSchoolCompleted = cloudKitRecord["commercialGroundSchoolCompleted"] as? Bool ?? student.commercialGroundSchoolCompleted
            student.commercialWrittenTestCompleted = cloudKitRecord["commercialWrittenTestCompleted"] as? Bool ?? student.commercialWrittenTestCompleted
            
            student.cfiGroundSchoolCompleted = cloudKitRecord["cfiGroundSchoolCompleted"] as? Bool ?? student.cfiGroundSchoolCompleted
            student.cfiWrittenTestCompleted = cloudKitRecord["cfiWrittenTestCompleted"] as? Bool ?? student.cfiWrittenTestCompleted
            
            try modelContext.save()
            print("✅ Pulled student-owned data from CloudKit for: \(student.displayName)")
        } catch {
            print("❌ Failed to pull student data: \(error)")
        }
    }
}

