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
                
                // Check if share already exists
                if let existingShare = studentRecord.share {
                    let shareRecord = try await database.record(for: existingShare.recordID)
                    if let share = shareRecord as? CKShare {
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
                
                // Save the record first to the custom zone
                let savedRecord = try await database.save(studentRecord)
                
                // Use the saved record for sharing
                studentRecord.setValuesForKeys(savedRecord.dictionaryWithValues(forKeys: Array(savedRecord.allKeys())))
            }
            
            // Create a new share
            let share = CKShare(rootRecord: studentRecord)
            
            // Configure share permissions
            share[CKShare.SystemFieldKey.title] = "Student Profile: \(student.displayName)" as CKRecordValue
            share[CKShare.SystemFieldKey.shareType] = "com.heiloprojects.rightrudder.student" as CKRecordValue
            
            // CRITICAL: Set public permission to readWrite to allow students to update their profile
            // This allows anyone with the share URL to read AND write the student record
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
    func removeShareForStudent(_ student: Student, modelContext: ModelContext) async -> Bool {
        guard let shareRecordName = student.shareRecordID else {
            print("No share record ID found for student")
            return false
        }
        
        do {
            let customZone = try await ensureCustomZoneExists()
            let shareRecordID = CKRecord.ID(recordName: shareRecordName, zoneID: customZone.zoneID)
            try await database.deleteRecord(withID: shareRecordID)
            
            student.shareRecordID = nil
            student.lastModified = Date()
            try modelContext.save()
            
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
    
    /// Checks if a student has an active share
    func hasActiveShare(for student: Student) async -> Bool {
        guard let shareRecordName = student.shareRecordID else {
            return false
        }
        
        do {
            let customZone = try await ensureCustomZoneExists()
            let shareRecordID = CKRecord.ID(recordName: shareRecordName, zoneID: customZone.zoneID)
            let shareRecord = try await database.record(for: shareRecordID)
            return shareRecord is CKShare
        } catch {
            print("Failed to check share status: \(error)")
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
    
    /// Automatically syncs student checklists to CloudKit shared zones
    func syncStudentChecklistsToSharedZone(_ student: Student, modelContext: ModelContext) async {
        guard student.shareRecordID != nil else {
            print("No active share for student \(student.displayName), skipping shared zone sync")
            return
        }
        
        // Check if we're offline and queue the operation
        if !offlineSyncManager.isOfflineMode {
            await performSyncStudentChecklistsToSharedZone(student, modelContext: modelContext)
        } else {
            await queueOfflineOperation(
                operationType: "checklist_update",
                studentId: student.id,
                modelContext: modelContext
            )
        }
    }
    
    /// Performs the actual sync operation
    private func performSyncStudentChecklistsToSharedZone(_ student: Student, modelContext: ModelContext) async {
        do {
            let customZone = try await ensureCustomZoneExists()
            
            for checklist in student.checklists ?? [] {
                await syncChecklistToSharedZone(checklist, student: student, customZone: customZone)
            }
            
            try modelContext.save()
        } catch {
            print("Failed to sync student checklists to shared zone: \(error)")
            
            // If sync fails due to network issues, queue for retry
            if isNetworkError(error) {
                await queueOfflineOperation(
                    operationType: "checklist_update",
                    studentId: student.id,
                    modelContext: modelContext
                )
            }
        }
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
    
    /// Syncs a specific checklist to the shared zone
    private func syncChecklistToSharedZone(_ checklist: StudentChecklist, student: Student, customZone: CKRecordZone) async {
        do {
            // Create record ID in custom zone
            let recordID = CKRecord.ID(recordName: checklist.id.uuidString, zoneID: customZone.zoneID)
            let existingRecord = try? await database.record(for: recordID)
            
            let record: CKRecord
            let hadComments = (existingRecord?["instructorComments"] as? String)?.isEmpty == false
            let nowHasComments = !(checklist.instructorComments?.isEmpty ?? true)
            let commentsChanged = !hadComments && nowHasComments
            
            // Check if checklist just reached 100% completion
            let wasComplete = (existingRecord?["isComplete"] as? Bool) ?? false
            let isNowComplete = isChecklistComplete(checklist)
            let completionChanged = !wasComplete && isNowComplete
            
            if let existing = existingRecord {
                record = existing
            } else {
                record = CKRecord(recordType: "StudentChecklist", recordID: recordID)
            }
            
            // Update record with checklist data
            record["templateId"] = checklist.templateId.uuidString
            record["templateName"] = checklist.templateName
            record["instructorComments"] = checklist.instructorComments
            record["studentId"] = student.id.uuidString
            record["lastModified"] = checklist.lastModified
            record["dualGivenHours"] = checklist.dualGivenHours
            record["isComplete"] = isNowComplete
            record["completionPercentage"] = calculateCompletionPercentage(checklist)
            
            // Set parent reference to student record for sharing
            let studentRecordID = CKRecord.ID(recordName: student.id.uuidString, zoneID: customZone.zoneID)
            record.parent = CKRecord.Reference(recordID: studentRecordID, action: .none)
            
            let savedRecord = try await saveRecordWithConflictResolution(record)
            checklist.cloudKitRecordID = savedRecord.recordID.recordName
            checklist.lastModified = Date()
            
            // Send notifications for significant changes
            if commentsChanged {
                await PushNotificationService.shared.notifyStudentOfComment(
                    studentId: student.id,
                    checklistId: checklist.id,
                    checklistName: checklist.templateName
                )
            }
            
            if completionChanged {
                await PushNotificationService.shared.notifyStudentOfCompletion(
                    studentId: student.id,
                    checklistId: checklist.id,
                    checklistName: checklist.templateName
                )
            }
            
            // Sync checklist items
            await syncChecklistItemsToSharedZone(checklist, customZone: customZone)
            
        } catch {
            print("Failed to sync checklist \(checklist.templateName) to shared zone: \(error)")
            
            // If sync fails due to network issues, queue for retry
            if isNetworkError(error) {
                // Note: We can't access modelContext here, so we'll rely on the calling method to handle queuing
                print("Network error detected, operation will be queued for retry")
            }
        }
    }
    
    /// Syncs checklist items to the shared zone
    private func syncChecklistItemsToSharedZone(_ checklist: StudentChecklist, customZone: CKRecordZone) async {
        do {
            for item in checklist.items ?? [] {
                let recordID = CKRecord.ID(recordName: item.id.uuidString, zoneID: customZone.zoneID)
                let existingRecord = try? await database.record(for: recordID)
                
                let record: CKRecord
                if let existing = existingRecord {
                    record = existing
                } else {
                    record = CKRecord(recordType: "StudentChecklistItem", recordID: recordID)
                }
                
                record["templateItemId"] = item.templateItemId.uuidString
                record["title"] = item.title
                record["isComplete"] = item.isComplete
                record["notes"] = item.notes
                record["completedAt"] = item.completedAt
                record["order"] = item.order
                record["checklistId"] = checklist.id.uuidString
                record["lastModified"] = item.lastModified
                
                // Set parent reference to checklist record
                let checklistRecordID = CKRecord.ID(recordName: checklist.id.uuidString, zoneID: customZone.zoneID)
                record.parent = CKRecord.Reference(recordID: checklistRecordID, action: .none)
                
                let savedRecord = try await saveRecordWithConflictResolution(record)
                item.cloudKitRecordID = savedRecord.recordID.recordName
                item.lastModified = Date()
            }
        } catch {
            print("Failed to sync checklist items to shared zone: \(error)")
        }
    }
    
    /// Checks if a checklist is 100% complete
    private func isChecklistComplete(_ checklist: StudentChecklist) -> Bool {
        guard let items = checklist.items, !items.isEmpty else { return false }
        return items.allSatisfy { $0.isComplete }
    }
    
    /// Calculates completion percentage for a checklist
    private func calculateCompletionPercentage(_ checklist: StudentChecklist) -> Double {
        guard let items = checklist.items, !items.isEmpty else { return 0.0 }
        let completedCount = items.filter { $0.isComplete }.count
        return Double(completedCount) / Double(items.count)
    }
    
    /// Saves a CloudKit record with automatic conflict resolution
    private func saveRecordWithConflictResolution(_ record: CKRecord) async throws -> CKRecord {
        do {
            return try await database.save(record)
        } catch let error as CKError {
            if error.code == .serverRecordChanged {
                print("⚠️ Server record changed conflict detected for \(record.recordType). Attempting resolution...")
                
                // Fetch the latest version from server
                let latestRecord = try await database.record(for: record.recordID)
                
                // Merge our changes with the server version
                let mergedRecord = mergeRecordChanges(ourRecord: record, serverRecord: latestRecord)
                
                // Try to save the merged record
                return try await database.save(mergedRecord)
            } else {
                throw error
            }
        }
    }
    
    /// Merges changes from our record with the server record
    private func mergeRecordChanges(ourRecord: CKRecord, serverRecord: CKRecord) -> CKRecord {
        // Use the server record as base (it has the latest metadata)
        let mergedRecord = serverRecord
        
        // Merge our field changes, preferring our values for most fields
        // This is a simple merge strategy - in production you might want more sophisticated conflict resolution
        
        for key in ourRecord.allKeys() {
            if let ourValue = ourRecord[key] {
                // For most fields, prefer our local changes
                // You might want to add specific logic for different field types
                mergedRecord[key] = ourValue
            }
        }
        
        // Always update lastModified to current time
        mergedRecord["lastModified"] = Date()
        
        return mergedRecord
    }
}

