import Foundation
import SwiftData
import CloudKit
import SwiftUI
import Combine

@MainActor
class CloudKitSyncService: ObservableObject {
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncStatus: String = "Ready to sync"
    
    private var modelContext: ModelContext?
    private let container: CKContainer
    private let offlineSyncManager = OfflineSyncManager()
    
    init() {
        self.container = CKContainer(identifier: "iCloud.com.heiloprojects.rightrudder")
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        offlineSyncManager.setModelContext(context)
    }
    
    /// Initializes CloudKit schema by creating initial records for each record type
    /// This ensures all record types are deployed in CloudKit (especially in Development)
    /// In Development, CloudKit will auto-create the schema when we save a record
    /// In Production, schema must be manually deployed via CloudKit Dashboard
    /// Should be called once on app startup
    func initializeCloudKitSchema() async {
        print("🔄 Initializing CloudKit schema...")
        
        do {
            // Check CloudKit availability
            let accountStatus = try await container.accountStatus()
            guard accountStatus == .available else {
                print("⚠️ CloudKit account not available - cannot initialize schema")
                return
            }
            
            let database = container.privateCloudDatabase
            
            // Initialize CustomChecklistDefinition record type
            // Create a temporary dummy record to trigger schema creation in Development
            // This causes CloudKit to auto-register the record type in Development environment
            // Use a valid UUID for the record name (CloudKit requires valid UUID strings)
            let dummyRecordID = CKRecord.ID(recordName: UUID().uuidString)
            
            // Try to create the schema by saving a dummy record
            // In Development, this will auto-create the record type if it doesn't exist
            // In Production, this will fail and require manual deployment
            print("📝 Creating CustomChecklistDefinition record type in CloudKit...")
            let schemaRecord = CKRecord(recordType: "CustomChecklistDefinition", recordID: dummyRecordID)
            schemaRecord["templateId"] = UUID().uuidString
            schemaRecord["customName"] = "__SCHEMA_INIT__"
            schemaRecord["customCategory"] = "__SCHEMA_INIT__"
            schemaRecord["studentId"] = UUID().uuidString
            schemaRecord["lastModified"] = Date()
            
            do {
                _ = try await database.save(schemaRecord)
                print("✅ Created CustomChecklistDefinition record type in CloudKit")
                
                // Delete the dummy record immediately
                _ = try? await database.deleteRecord(withID: dummyRecordID)
                print("🧹 Cleaned up schema initialization record")
            } catch let saveError as CKError {
                // Handle different error cases
                if saveError.code == .unknownItem {
                    // Record was already deleted or doesn't exist - schema exists
                    print("✅ CustomChecklistDefinition record type exists in CloudKit")
                } else if saveError.code == .internalError || saveError.localizedDescription.contains("Production") || saveError.localizedDescription.contains("deploy") {
                    // Production environment requires manual schema deployment
                    print("⚠️ CustomChecklistDefinition needs manual deployment in Production")
                    print("   Go to: https://icloud.developer.apple.com/dashboard/")
                    print("   Navigate to Schema > Record Types > Add CustomChecklistDefinition")
                    print("   Required fields:")
                    print("     - templateId (String, Indexed)")
                    print("     - customName (String)")
                    print("     - customCategory (String)")
                    print("     - studentId (String, Indexed)")
                    print("     - lastModified (Date/Time)")
                    print("     - customItems (String)")
                } else {
                    // Other error - might already exist
                    print("ℹ️ CustomChecklistDefinition schema check: \(saveError.localizedDescription)")
                    // Try to delete in case it was created
                    _ = try? await database.deleteRecord(withID: dummyRecordID)
                }
            } catch {
                print("⚠️ Unexpected error initializing CustomChecklistDefinition schema: \(error)")
            }
            
            print("✅ CloudKit schema initialization complete")
        } catch {
            print("❌ Failed to initialize CloudKit schema: \(error)")
        }
    }
    
    /// Force a complete re-sync of all assignments for a specific student to the shared zone
    /// This is useful when assignments aren't appearing in the student app
    func forceSyncStudentAssignments(_ student: Student) async {
        guard modelContext != nil else {
            print("❌ Cannot force sync: No model context")
            return
        }
        
        print("🔄 FORCE SYNC: Starting complete re-sync of assignments for: \(student.displayName)")
        
        // First ensure student is synced
        await syncStudentToCloudKit(student)
        
        // Then do a full shared zone sync
        await syncStudentChecklistsToSharedZone(student)
        
        print("✅ FORCE SYNC: Completed for: \(student.displayName)")
    }
    
    func syncToCloudKit() async {
        guard !isSyncing, let _ = modelContext else { return }
        
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
            
            // Check if we're offline
            if offlineSyncManager.isOfflineMode {
                syncStatus = "Offline mode - queuing operations for later sync"
                await processPendingOperations()
                isSyncing = false
                return
            }
            
            syncStatus = "Syncing students..."
            
            // Sync students
            await syncStudents()
            
            syncStatus = "Syncing checklist templates..."
            
            // Sync checklist templates
            await syncChecklistTemplates()
            
            syncStatus = "Syncing from shared zones..."
            
            // Sync changes from shared zones (student updates)
            await syncFromSharedZones()
            
            // Process any pending offline operations
            await processPendingOperations()
            
            lastSyncDate = Date()
            syncStatus = "Sync completed successfully"
            
        } catch {
            syncStatus = "Sync failed: \(error.localizedDescription)"
            print("CloudKit sync error: \(error)")
            
            // If sync fails due to network issues, queue operations for retry
            if isNetworkError(error) {
                syncStatus = "Network error - operations queued for retry"
            }
        }
        
        isSyncing = false
    }
    
    /// Processes pending offline operations
    private func processPendingOperations() async {
        await offlineSyncManager.processPendingOperations()
    }
    
    /// Gets the correct template ID for CloudKit sync (uses template ID directly)
    private func getCorrectTemplateID(for assignment: ChecklistAssignment) -> String {
        return assignment.templateId.uuidString
    }
    
    /// Gets the correct template item ID for CloudKit sync (uses item ID directly)
    private func getCorrectTemplateItemID(for item: ItemProgress, assignment: ChecklistAssignment) -> String {
        return item.templateItemId.uuidString
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
    
    /// Checks if a student has an active share (share exists AND has participants)
    /// Returns true only if:
    /// 1. shareRecordID exists
    /// 2. Share record exists in CloudKit
    /// 3. Share has participants (meaning student has accepted the invitation)
    /// CRITICAL: This prevents syncing to students who haven't accepted their share URL yet
    private func hasActiveShare(_ student: Student) async -> Bool {
        guard let shareRecordName = student.shareRecordID else {
            return false
        }
        
        do {
            let database = container.privateCloudDatabase
            let customZoneName = "SharedStudentsZone"
            let zoneID = CKRecordZone.ID(zoneName: customZoneName, ownerName: CKCurrentUserDefaultName)
            
            // Ensure zone exists
            let _ = try await database.recordZone(for: zoneID)
            
            // Fetch the share record
            let shareRecordID = CKRecord.ID(recordName: shareRecordName, zoneID: zoneID)
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
    
    private func syncStudents() async {
        guard let modelContext = modelContext else { return }
        
        do {
            let request = FetchDescriptor<Student>()
            let students = try modelContext.fetch(request)
            
            for student in students {
                await syncStudentToCloudKit(student)
            }
        } catch {
            print("Failed to fetch students for sync: \(error)")
        }
    }
    
    private func syncStudentToCloudKit(_ student: Student) async {
        do {
            let database = container.privateCloudDatabase
            let recordID = CKRecord.ID(recordName: student.id.uuidString)
            
            // Try to fetch existing record
            let existingRecord = try? await database.record(for: recordID)
            
            let record: CKRecord
            var hasChanges = false
            
            if let existing = existingRecord {
                record = existing
                
                // Only update fields that have actually changed
                // Compare each field with existing value before setting
                func updateIfChanged<T: Equatable & CKRecordValue>(_ key: String, newValue: T?) {
                    let existingValue = record[key] as? T
                    if existingValue != newValue {
                        record[key] = newValue
                        hasChanges = true
                    }
                }
                
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
                    // CloudKit requires Bool values to be wrapped in NSNumber
                    let existingValue = (record[key] as? NSNumber)?.boolValue ?? false
                    if existingValue != newValue {
                        record[key] = NSNumber(value: newValue)
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
                updateIfChangedString("instructorName", newValue: student.instructorName)
                updateIfChangedString("instructorCFINumber", newValue: student.instructorCFINumber)
                updateIfChangedDate("lastModified", newValue: student.lastModified)
                
                // Training goals
                updateIfChangedBool("goalPPL", newValue: student.goalPPL)
                updateIfChangedBool("goalInstrument", newValue: student.goalInstrument)
                updateIfChangedBool("goalCommercial", newValue: student.goalCommercial)
                updateIfChangedBool("goalCFI", newValue: student.goalCFI)
                
                // Training milestones - PPL
                updateIfChangedBool("pplGroundSchoolCompleted", newValue: student.pplGroundSchoolCompleted)
                updateIfChangedBool("pplWrittenTestCompleted", newValue: student.pplWrittenTestCompleted)
                
                // Training milestones - Instrument
                updateIfChangedBool("instrumentGroundSchoolCompleted", newValue: student.instrumentGroundSchoolCompleted)
                updateIfChangedBool("instrumentWrittenTestCompleted", newValue: student.instrumentWrittenTestCompleted)
                
                // Training milestones - Commercial
                updateIfChangedBool("commercialGroundSchoolCompleted", newValue: student.commercialGroundSchoolCompleted)
                updateIfChangedBool("commercialWrittenTestCompleted", newValue: student.commercialWrittenTestCompleted)
                
                // Training milestones - CFI
                updateIfChangedBool("cfiGroundSchoolCompleted", newValue: student.cfiGroundSchoolCompleted)
                updateIfChangedBool("cfiWrittenTestCompleted", newValue: student.cfiWrittenTestCompleted)
                
                // Always ensure studentId is set (for backward compatibility)
                if (record["studentId"] as? String) != student.id.uuidString {
                    record["studentId"] = student.id.uuidString
                    hasChanges = true
                }
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
                record["instructorName"] = student.instructorName
                record["instructorCFINumber"] = student.instructorCFINumber
                record["lastModified"] = student.lastModified
                // CloudKit requires Bool values to be wrapped in NSNumber
                record["goalPPL"] = NSNumber(value: student.goalPPL)
                record["goalInstrument"] = NSNumber(value: student.goalInstrument)
                record["goalCommercial"] = NSNumber(value: student.goalCommercial)
                record["goalCFI"] = NSNumber(value: student.goalCFI)
                record["pplGroundSchoolCompleted"] = NSNumber(value: student.pplGroundSchoolCompleted)
                record["pplWrittenTestCompleted"] = NSNumber(value: student.pplWrittenTestCompleted)
                record["instrumentGroundSchoolCompleted"] = NSNumber(value: student.instrumentGroundSchoolCompleted)
                record["instrumentWrittenTestCompleted"] = NSNumber(value: student.instrumentWrittenTestCompleted)
                record["commercialGroundSchoolCompleted"] = NSNumber(value: student.commercialGroundSchoolCompleted)
                record["commercialWrittenTestCompleted"] = NSNumber(value: student.commercialWrittenTestCompleted)
                record["cfiGroundSchoolCompleted"] = NSNumber(value: student.cfiGroundSchoolCompleted)
                record["cfiWrittenTestCompleted"] = NSNumber(value: student.cfiWrittenTestCompleted)
                record["studentId"] = student.id.uuidString
                hasChanges = true
            }
            
            // Only save if there are actual changes
            if hasChanges {
                let savedRecord = try await database.save(record)
                student.cloudKitRecordID = savedRecord.recordID.recordName
                student.lastModified = Date()
                print("✅ Synced student profile changes to CloudKit: \(student.displayName)")
            } else {
                print("ℹ️ Student profile unchanged, skipping CloudKit sync: \(student.displayName)")
            }
            
            // Sync related data (assignments and endorsements may have changed)
            await syncStudentChecklistAssignments(student)
            await syncStudentEndorsements(student)
            
        } catch {
            print("Failed to sync student \(student.displayName): \(error)")
        }
    }
    
    private func syncStudentChecklistAssignments(_ student: Student) async {
        // CRITICAL: All sync must go to shared database ONLY
        // Delegate to CloudKitShareService which handles shared database sync
        guard let modelContext = modelContext else {
            print("❌ Cannot sync: No model context")
            return
        }
        
        // Check if student has active share - only sync if share exists and is accepted
        let hasActiveShare = await hasActiveShare(student)
        guard hasActiveShare else {
            print("⚠️ Student \(student.displayName) does NOT have an active share - cannot sync")
            print("   (Share URL may exist but student hasn't accepted it yet)")
            return
        }
        
        print("🔄 Starting sync for student: \(student.displayName) to SHARED DATABASE ONLY")
        
        // Use CloudKitShareService to sync to shared database
        let shareService = CloudKitShareService.shared
        await shareService.syncInstructorDataToCloudKit(student, modelContext: modelContext)
        
        print("✅ Sync to shared database complete for: \(student.displayName)")
    }
    
    // REMOVED: syncChecklistItems - all sync now goes to shared database via CloudKitShareService
    // ItemProgress sync is handled by CloudKitShareService.syncItemProgressToSharedZone
    
    /// Syncs custom checklist definitions for student app (one-time sync)
    private func syncCustomChecklistDefinitions(_ student: Student) async {
        do {
            let database = container.privateCloudDatabase
            
            for assignment in student.checklistAssignments ?? [] {
                // Only sync custom checklists (those without templateIdentifier)
                guard assignment.templateIdentifier == nil else { continue }
                
                let recordID = CKRecord.ID(recordName: "custom-definition-\(assignment.templateId.uuidString)")
                let existingRecord = try? await database.record(for: recordID)
                
                // Skip if already synced
                if existingRecord != nil { continue }
                
                let record = CKRecord(recordType: "CustomChecklistDefinition", recordID: recordID)
                
                record["templateId"] = assignment.templateId.uuidString
                record["customName"] = assignment.displayName
                record["customCategory"] = assignment.template?.category ?? "Custom"
                record["studentId"] = student.id.uuidString
                record["lastModified"] = Date()
                
                // Store custom items as JSON
                if let template = assignment.template, let items = template.items {
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
                        record["customItems"] = jsonString
                    }
                }
                
                let _ = try await database.save(record)
                print("✅ Synced custom checklist definition: \(assignment.displayName)")
            }
        } catch {
            print("Failed to sync custom checklist definitions: \(error)")
        }
    }
    
    private func syncStudentEndorsements(_ student: Student) async {
        do {
            let database = container.privateCloudDatabase
            
            for endorsement in student.endorsements ?? [] {
                let recordID = CKRecord.ID(recordName: endorsement.id.uuidString)
                let existingRecord = try? await database.record(for: recordID)
                
                let record: CKRecord
                if let existing = existingRecord {
                    record = existing
                } else {
                    record = CKRecord(recordType: "EndorsementImage", recordID: recordID)
                }
                
                record["filename"] = endorsement.filename
                record["imageData"] = endorsement.imageData
                record["studentId"] = student.id.uuidString
                record["lastModified"] = endorsement.lastModified
                
                let savedRecord = try await database.save(record)
                endorsement.cloudKitRecordID = savedRecord.recordID.recordName
                endorsement.lastModified = Date()
            }
        } catch {
            print("Failed to sync student endorsements: \(error)")
        }
    }
    
    private func syncChecklistTemplates() async {
        guard let modelContext = modelContext else { return }
        
        do {
            let request = FetchDescriptor<ChecklistTemplate>()
            let templates = try modelContext.fetch(request)
            
            for template in templates {
                await syncTemplateToCloudKit(template)
            }
        } catch {
            print("Failed to fetch templates for sync: \(error)")
        }
    }
    
    func syncTemplateToCloudKit(_ template: ChecklistTemplate) async {
        do {
            let database = container.privateCloudDatabase
            let recordID = CKRecord.ID(recordName: template.id.uuidString)
            
            let existingRecord = try? await database.record(for: recordID)
            
            let record: CKRecord
            if let existing = existingRecord {
                record = existing
            } else {
                record = CKRecord(recordType: "ChecklistTemplate", recordID: recordID)
            }
            
            record["name"] = template.name
            record["category"] = template.category
            record["phase"] = template.phase
            record["lastModified"] = template.lastModified
            
            let savedRecord = try await database.save(record)
            template.cloudKitRecordID = savedRecord.recordID.recordName
            template.lastModified = Date()
            
            // Sync template items
            await syncTemplateItems(template)
            
        } catch {
            print("Failed to sync template \(template.name): \(error)")
        }
    }
    
    private func syncTemplateItems(_ template: ChecklistTemplate) async {
        do {
            let database = container.privateCloudDatabase
            
            for item in template.items ?? [] {
                let recordID = CKRecord.ID(recordName: item.id.uuidString)
                let existingRecord = try? await database.record(for: recordID)
                
                let record: CKRecord
                if let existing = existingRecord {
                    record = existing
                } else {
                    record = CKRecord(recordType: "ChecklistItem", recordID: recordID)
                }
                
                record["title"] = item.title
                record["notes"] = item.notes
                record["templateId"] = template.id.uuidString
                record["lastModified"] = item.lastModified
                
                let savedRecord = try await database.save(record)
                item.cloudKitRecordID = savedRecord.recordID.recordName
                item.lastModified = Date()
            }
        } catch {
            print("Failed to sync template items: \(error)")
        }
    }
    
    func restoreFromCloudKit() async {
        guard !isSyncing, let _ = modelContext else { return }
        
        isSyncing = true
        syncStatus = "Restoring from iCloud..."
        
        do {
            // Check CloudKit availability
            let accountStatus = try await container.accountStatus()
            guard accountStatus == .available else {
                syncStatus = "iCloud account not available"
                isSyncing = false
                return
            }
            
            syncStatus = "Restoring students..."
            await restoreStudents()
            
            syncStatus = "Restoring templates..."
            await restoreTemplates()
            
            lastSyncDate = Date()
            syncStatus = "Restore completed successfully"
            
        } catch {
            syncStatus = "Restore failed: \(error.localizedDescription)"
            print("CloudKit restore error: \(error)")
        }
        
        isSyncing = false
    }
    
    private func restoreStudents() async {
        do {
            let database = container.privateCloudDatabase
            let query = CKQuery(recordType: "Student", predicate: NSPredicate(value: true))
            let results = try await database.records(matching: query)
            
            for (_, result) in results.matchResults {
                switch result {
                case .success(let record):
                    await restoreStudentFromRecord(record)
                case .failure(let error):
                    print("Failed to fetch student record: \(error)")
                }
            }
        } catch {
            print("Failed to restore students: \(error)")
        }
    }
    
    private func restoreStudentFromRecord(_ record: CKRecord) async {
        guard let modelContext = modelContext else { return }
        
        do {
            // Check if student already exists
            let studentId = UUID(uuidString: record.recordID.recordName)
            guard let id = studentId else { return }
            
            let request = FetchDescriptor<Student>(
                predicate: #Predicate { $0.id == id }
            )
            let existingStudents = try modelContext.fetch(request)
            
            if existingStudents.isEmpty {
                // Create new student
                let student = Student(
                    firstName: record["firstName"] as? String ?? "",
                    lastName: record["lastName"] as? String ?? "",
                    email: record["email"] as? String ?? "",
                    telephone: record["telephone"] as? String ?? "",
                    homeAddress: record["homeAddress"] as? String ?? "",
                    ftnNumber: record["ftnNumber"] as? String ?? ""
                )
                
                student.biography = record["biography"] as? String
                student.backgroundNotes = record["backgroundNotes"] as? String
                student.instructorName = record["instructorName"] as? String
                student.instructorCFINumber = record["instructorCFINumber"] as? String
                student.cloudKitRecordID = record.recordID.recordName
                student.lastModified = record["lastModified"] as? Date ?? Date()
                
                modelContext.insert(student)
                try modelContext.save()
                
                // Restore related data
                await restoreStudentChecklists(student)
                await restoreStudentEndorsements(student)
            }
        } catch {
            print("Failed to restore student: \(error)")
        }
    }
    
    private func restoreStudentChecklists(_ student: Student) async {
        do {
            let database = container.privateCloudDatabase
            let query = CKQuery(recordType: "StudentChecklist", predicate: NSPredicate(format: "studentId == %@", student.id.uuidString))
            let results = try await database.records(matching: query)
            
            for (_, result) in results.matchResults {
                switch result {
                case .success(let record):
                    await restoreChecklistFromRecord(record, student: student)
                case .failure(let error):
                    print("Failed to fetch checklist record: \(error)")
                }
            }
        } catch {
            print("Failed to restore student checklists: \(error)")
        }
    }
    
    private func restoreChecklistFromRecord(_ record: CKRecord, student: Student) async {
        guard let modelContext = modelContext else { return }
        
        do {
            let progressId = UUID(uuidString: record.recordID.recordName)
            guard let id = progressId else { return }
            
            let request = FetchDescriptor<ChecklistAssignment>(
                predicate: #Predicate { $0.id == id }
            )
            let existingAssignments = try modelContext.fetch(request)
            
            if existingAssignments.isEmpty {
                // Create new assignment record
                let assignment = ChecklistAssignment(
                    templateId: UUID(uuidString: record["templateId"] as? String ?? "") ?? UUID(),
                    templateIdentifier: record["templateIdentifier"] as? String,
                    isCustomChecklist: record["isCustomChecklist"] as? Bool ?? false
                )
                
                assignment.id = id
                assignment.instructorComments = record["instructorComments"] as? String
                assignment.lastModified = record["lastModified"] as? Date ?? Date()
                assignment.dualGivenHours = record["dualGivenHours"] as? Double ?? 0.0
                
                if student.checklistAssignments == nil {
                    student.checklistAssignments = []
                }
                student.checklistAssignments?.append(assignment)
                modelContext.insert(assignment)
                
                // CRITICAL: Ensure template relationship is set immediately after creation
                // This prevents the need for repair functions later
                _ = ChecklistAssignmentService.ensureTemplateRelationship(for: assignment, modelContext: modelContext)
                
                // Restore checklist items
                await restoreChecklistItems(assignment)
            }
        } catch {
            print("Failed to restore checklist progress: \(error)")
        }
    }
    
    private func restoreChecklistItems(_ assignment: ChecklistAssignment) async {
        do {
            let database = container.privateCloudDatabase
            let query = CKQuery(recordType: "ItemProgress", predicate: NSPredicate(format: "assignmentId == %@", assignment.id.uuidString))
            let results = try await database.records(matching: query)
            
            for (_, result) in results.matchResults {
                switch result {
                case .success(let record):
                    await restoreChecklistItemFromRecord(record, assignment: assignment)
                case .failure(let error):
                    print("Failed to fetch checklist item record: \(error)")
                }
            }
        } catch {
            print("Failed to restore checklist items: \(error)")
        }
    }
    
    private func restoreChecklistItemFromRecord(_ record: CKRecord, assignment: ChecklistAssignment) async {
        guard let modelContext = modelContext else { return }
        
        do {
            let itemId = UUID(uuidString: record.recordID.recordName)
            guard let id = itemId else { return }
            
            let request = FetchDescriptor<ItemProgress>(
                predicate: #Predicate { $0.id == id }
            )
            let existingItems = try modelContext.fetch(request)
            
            if existingItems.isEmpty {
                let item = ItemProgress(
                    templateItemId: UUID(uuidString: record["templateItemId"] as? String ?? "") ?? UUID()
                )
                
                item.id = id
                item.isComplete = record["isComplete"] as? Bool ?? false
                item.notes = record["notes"] as? String
                item.completedAt = record["completedAt"] as? Date
                item.lastModified = record["lastModified"] as? Date ?? Date()
                
                if assignment.itemProgress == nil {
                    assignment.itemProgress = []
                }
                assignment.itemProgress?.append(item)
                modelContext.insert(item)
            }
        } catch {
            print("Failed to restore checklist item: \(error)")
        }
    }
    
    private func restoreStudentEndorsements(_ student: Student) async {
        do {
            let database = container.privateCloudDatabase
            let query = CKQuery(recordType: "EndorsementImage", predicate: NSPredicate(format: "studentId == %@", student.id.uuidString))
            let results = try await database.records(matching: query)
            
            for (_, result) in results.matchResults {
                switch result {
                case .success(let record):
                    await restoreEndorsementFromRecord(record, student: student)
                case .failure(let error):
                    print("Failed to fetch endorsement record: \(error)")
                }
            }
        } catch {
            print("Failed to restore student endorsements: \(error)")
        }
    }
    
    private func restoreEndorsementFromRecord(_ record: CKRecord, student: Student) async {
        guard let modelContext = modelContext else { return }
        
        do {
            let endorsementId = UUID(uuidString: record.recordID.recordName)
            guard let id = endorsementId else { return }
            
            let request = FetchDescriptor<EndorsementImage>(
                predicate: #Predicate { $0.id == id }
            )
            let existingEndorsements = try modelContext.fetch(request)
            
            if existingEndorsements.isEmpty {
                let endorsement = EndorsementImage(
                    filename: record["filename"] as? String ?? "",
                    imageData: record["imageData"] as? Data
                )
                
                endorsement.id = id
                endorsement.cloudKitRecordID = record.recordID.recordName
                endorsement.lastModified = record["lastModified"] as? Date ?? Date()
                
                if student.endorsements == nil {
                    student.endorsements = []
                }
                student.endorsements?.append(endorsement)
                modelContext.insert(endorsement)
            }
        } catch {
            print("Failed to restore endorsement: \(error)")
        }
    }
    
    private func restoreTemplates() async {
        do {
            let database = container.privateCloudDatabase
            let query = CKQuery(recordType: "ChecklistTemplate", predicate: NSPredicate(value: true))
            let results = try await database.records(matching: query)
            
            for (_, result) in results.matchResults {
                switch result {
                case .success(let record):
                    await restoreTemplateFromRecord(record)
                case .failure(let error):
                    print("Failed to fetch template record: \(error)")
                }
            }
        } catch {
            print("Failed to restore templates: \(error)")
        }
    }
    
    private func restoreTemplateFromRecord(_ record: CKRecord) async {
        guard let modelContext = modelContext else { return }
        
        do {
            let templateId = UUID(uuidString: record.recordID.recordName)
            guard let id = templateId else { return }
            
            let request = FetchDescriptor<ChecklistTemplate>(
                predicate: #Predicate { $0.id == id }
            )
            let existingTemplates = try modelContext.fetch(request)
            
            if existingTemplates.isEmpty {
                let templateName = record["name"] as? String ?? ""
                // Skip templates with empty names
                guard !templateName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    print("Skipping template with empty name from CloudKit")
                    return
                }
                
                let template = ChecklistTemplate(
                    name: templateName,
                    category: record["category"] as? String ?? "PPL",
                    phase: record["phase"] as? String
                )
                
                template.id = id
                template.cloudKitRecordID = record.recordID.recordName
                template.lastModified = record["lastModified"] as? Date ?? Date()
                
                modelContext.insert(template)
                
                // Restore template items
                await restoreTemplateItems(template)
            }
        } catch {
            print("Failed to restore template: \(error)")
        }
    }
    
    private func restoreTemplateItems(_ template: ChecklistTemplate) async {
        do {
            let database = container.privateCloudDatabase
            let query = CKQuery(recordType: "ChecklistItem", predicate: NSPredicate(format: "templateId == %@", template.id.uuidString))
            let results = try await database.records(matching: query)
            
            for (_, result) in results.matchResults {
                switch result {
                case .success(let record):
                    await restoreTemplateItemFromRecord(record, template: template)
                case .failure(let error):
                    print("Failed to fetch template item record: \(error)")
                }
            }
        } catch {
            print("Failed to restore template items: \(error)")
        }
    }
    
    private func restoreTemplateItemFromRecord(_ record: CKRecord, template: ChecklistTemplate) async {
        guard let modelContext = modelContext else { return }
        
        do {
            let itemId = UUID(uuidString: record.recordID.recordName)
            guard let id = itemId else { return }
            
            let request = FetchDescriptor<ChecklistItem>(
                predicate: #Predicate { $0.id == id }
            )
            let existingItems = try modelContext.fetch(request)
            
            if existingItems.isEmpty {
                let item = ChecklistItem(
                    title: record["title"] as? String ?? "",
                    notes: record["notes"] as? String
                )
                
                item.id = id
                item.cloudKitRecordID = record.recordID.recordName
                item.lastModified = record["lastModified"] as? Date ?? Date()
                
                template.items?.append(item)
                modelContext.insert(item)
            }
        } catch {
            print("Failed to restore template item: \(error)")
        }
    }
    
    // MARK: - Shared Zone Synchronization
    
    /// Syncs student checklists to shared zone for student app access
    /// This ensures ALL assignments are synced to shared zone so student app can see them
    /// CRITICAL: Only syncs if student has accepted the share (has participants)
    private func syncStudentChecklistsToSharedZone(_ student: Student) async {
        // CRITICAL: Only sync if share exists AND has participants (student has accepted)
        let hasActive = await hasActiveShare(student)
        guard hasActive else {
            print("⚠️ No active share (student hasn't accepted) for \(student.displayName), skipping shared zone sync")
            return
        }
        
        do {
            let customZoneName = "SharedStudentsZone"
            let zoneID = CKRecordZone.ID(zoneName: customZoneName, ownerName: CKCurrentUserDefaultName)
            
            // Try to fetch the custom zone
            let customZone = try await container.privateCloudDatabase.recordZone(for: zoneID)
            
            // CRITICAL: Ensure student record in shared zone has studentId field set
            // This ensures student app can correctly match assignments
            let studentRecordID = CKRecord.ID(recordName: student.id.uuidString, zoneID: customZone.zoneID)
            if let studentRecord = try? await container.privateCloudDatabase.record(for: studentRecordID) {
                if studentRecord["studentId"] == nil || (studentRecord["studentId"] as? String) != student.id.uuidString {
                    studentRecord["studentId"] = student.id.uuidString
                    do {
                        _ = try await container.privateCloudDatabase.save(studentRecord)
                        print("   📝 Updated studentId field in student record: \(student.id.uuidString)")
                    } catch {
                        print("   ⚠️ Failed to update studentId in student record: \(error)")
                    }
                }
            }
            
            // DIAGNOSTIC: Fetch assignments directly from SwiftData to verify relationship
            guard let modelContext = modelContext else {
                print("❌ Cannot sync: No model context")
                return
            }
            
            // Fetch assignments directly using student ID to verify count
            // Use a filter approach since optional relationship predicates can be tricky
            let studentId = student.id
            let allAssignmentsFromDB = try modelContext.fetch(FetchDescriptor<ChecklistAssignment>()).filter { assignment in
                assignment.student?.id == studentId
            }
            
            let assignmentsFromRelationship = student.checklistAssignments ?? []
            
            print("🔄 Full sync pass: Syncing assignments to shared zone for student: \(student.displayName)")
            print("   📊 Assignments from relationship: \(assignmentsFromRelationship.count)")
            print("   📊 Assignments from direct DB query: \(allAssignmentsFromDB.count)")
            
            // Use direct DB query results if relationship count is wrong or if relationship is smaller
            let assignments: [ChecklistAssignment]
            if allAssignmentsFromDB.count > assignmentsFromRelationship.count {
                print("   ⚠️ WARNING: Relationship count (\(assignmentsFromRelationship.count)) is LESS than DB count (\(allAssignmentsFromDB.count))")
                print("   Using direct DB query results to ensure all assignments are synced")
                assignments = allAssignmentsFromDB
            } else {
                assignments = assignmentsFromRelationship
            }
            
            print("   📊 Total assignments to sync: \(assignments.count)")
            
            // First, verify what's actually in the shared zone
            do {
                let query = CKQuery(recordType: "ChecklistAssignment", predicate: NSPredicate(format: "studentId == %@", student.id.uuidString))
                let results = try await container.privateCloudDatabase.records(matching: query, inZoneWith: customZone.zoneID)
                var existingCount = 0
                for (_, _) in results.matchResults {
                    existingCount += 1
                }
                print("   🔍 Found \(existingCount) existing assignment records in shared zone before sync")
            } catch {
                print("   ⚠️ Could not query existing assignments: \(error)")
            }
            
            var syncedCount = 0
            var errorCount = 0
            
            for (index, assignment) in assignments.enumerated() {
                do {
                    try await syncChecklistToSharedZone(assignment, student: student, customZone: customZone)
                    syncedCount += 1
                    
                    if index == 0 || (index + 1) % 10 == 0 || index == assignments.count - 1 {
                        print("   ✅ Synced \(syncedCount)/\(assignments.count) assignments: \(assignment.displayName)")
                    }
                } catch {
                    errorCount += 1
                    print("   ❌ Failed to sync assignment \(assignment.displayName) (ID: \(assignment.id.uuidString)): \(error)")
                }
            }
            
            // Verify final count
            do {
                let query = CKQuery(recordType: "ChecklistAssignment", predicate: NSPredicate(format: "studentId == %@", student.id.uuidString))
                query.sortDescriptors = [NSSortDescriptor(key: "assignedAt", ascending: true)]
                
                let results = try await container.privateCloudDatabase.records(matching: query, inZoneWith: customZone.zoneID)
                var finalCount = 0
                for (_, result) in results.matchResults {
                    switch result {
                    case .success:
                        finalCount += 1
                    case .failure(let error):
                        print("   ⚠️ Error reading record: \(error)")
                    }
                }
                print("✅ Full sync pass completed:")
                print("   📊 Synced: \(syncedCount) successful, \(errorCount) failed out of \(assignments.count) total assignments")
                print("   🔍 Final count in shared zone: \(finalCount) assignment records")
                if finalCount < assignments.count {
                    print("   ⚠️ WARNING: Only \(finalCount) assignments found in shared zone, expected \(assignments.count)!")
                }
            } catch {
                print("   ⚠️ Could not verify final count: \(error)")
                print("✅ Full sync pass completed: \(syncedCount) successful, \(errorCount) failed out of \(assignments.count) total assignments")
            }
        } catch {
            print("❌ Failed to sync student checklists to shared zone: \(error)")
        }
    }
    
    /// Syncs a specific checklist assignment to the shared zone (LEGACY)
    /// CRITICAL: This ensures the assignment is available to the student app via CloudKit sharing
    private func syncChecklistToSharedZone(_ assignment: ChecklistAssignment, student: Student, customZone: CKRecordZone) async throws {
        do {
            // Create record ID in custom zone
            let recordID = CKRecord.ID(recordName: assignment.id.uuidString, zoneID: customZone.zoneID)
            let existingRecord = try? await container.privateCloudDatabase.record(for: recordID)
            
            let isNewRecord = existingRecord == nil
            let record: CKRecord
            var hasChanges = false
            
            if let existing = existingRecord {
                record = existing
                
                // Check if assignment has changed compared to CloudKit record
                let cloudKitLastModified = existing["lastModified"] as? Date
                let localLastModified = assignment.lastModified
                let needsSync = cloudKitLastModified == nil || localLastModified > cloudKitLastModified!
                
                if needsSync {
                    // Only update fields that have changed
                    let newTemplateId = getCorrectTemplateID(for: assignment)
                    if (record["templateId"] as? String) != newTemplateId {
                        record["templateId"] = newTemplateId
                        hasChanges = true
                    }
                    
                    if (record["templateName"] as? String) != assignment.displayName {
                        record["templateName"] = assignment.displayName
                        hasChanges = true
                    }
                    
                    if (record["templateIdentifier"] as? String) != assignment.templateIdentifier {
                        record["templateIdentifier"] = assignment.templateIdentifier
                        hasChanges = true
                    }
                    
                    if (record["instructorComments"] as? String) != assignment.instructorComments {
                        record["instructorComments"] = assignment.instructorComments
                        hasChanges = true
                    }
                    
                    let studentIdString = student.id.uuidString
                    if (record["studentId"] as? String) != studentIdString {
                        record["studentId"] = studentIdString
                        print("      📝 Setting studentId on assignment record: \(studentIdString)")
                        hasChanges = true
                    }
                    
                    let existingAssignedAt = record["assignedAt"] as? Date
                    if existingAssignedAt != assignment.assignedAt {
                        record["assignedAt"] = assignment.assignedAt
                        hasChanges = true
                    }
                    
                    if (record["dualGivenHours"] as? Double) != assignment.dualGivenHours {
                        record["dualGivenHours"] = assignment.dualGivenHours
                        hasChanges = true
                    }
                    
                    if (record["isComplete"] as? Bool) != assignment.isComplete {
                        record["isComplete"] = assignment.isComplete
                        hasChanges = true
                    }
                    
                    if (record["completionPercentage"] as? Double) != assignment.progressPercentage {
                        record["completionPercentage"] = assignment.progressPercentage
                        hasChanges = true
                    }
                    
                    if (record["completedItemsCount"] as? Int) != assignment.completedItemsCount {
                        record["completedItemsCount"] = assignment.completedItemsCount
                        hasChanges = true
                    }
                    
                    if (record["totalItemsCount"] as? Int) != assignment.totalItemsCount {
                        record["totalItemsCount"] = assignment.totalItemsCount
                        hasChanges = true
                    }
                    
                    let isCustom = assignment.templateIdentifier == nil
                    if (record["isCustomChecklist"] as? Bool) != isCustom {
                        record["isCustomChecklist"] = isCustom
                        hasChanges = true
                    }
                    
                    // Always update lastModified if we're syncing
                    record["lastModified"] = assignment.lastModified
                    hasChanges = true
                }
            } else {
                // New record - set all fields
                record = CKRecord(recordType: "ChecklistAssignment", recordID: recordID)
                record["templateId"] = getCorrectTemplateID(for: assignment)
                record["templateName"] = assignment.displayName
                record["templateIdentifier"] = assignment.templateIdentifier
                record["instructorComments"] = assignment.instructorComments
                let studentIdString = student.id.uuidString
                record["studentId"] = studentIdString
                print("      📝 Setting studentId on assignment record: \(studentIdString)")
                record["assignedAt"] = assignment.assignedAt
                record["lastModified"] = assignment.lastModified
                record["dualGivenHours"] = assignment.dualGivenHours
                record["isComplete"] = assignment.isComplete
                record["completionPercentage"] = assignment.progressPercentage
                record["completedItemsCount"] = assignment.completedItemsCount
                record["totalItemsCount"] = assignment.totalItemsCount
                record["isCustomChecklist"] = assignment.templateIdentifier == nil
                hasChanges = true
            }
            
            // Set parent reference to student record for sharing (required for CloudKit sharing)
            let studentRecordID = CKRecord.ID(recordName: student.id.uuidString, zoneID: customZone.zoneID)
            if record.parent?.recordID != studentRecordID {
                record.parent = CKRecord.Reference(recordID: studentRecordID, action: .none)
                hasChanges = true
            }
            
            // Only save if there are actual changes
            if hasChanges {
                _ = try await saveRecordWithConflictResolution(record, database: container.privateCloudDatabase)
                assignment.lastModified = Date()
                
                // Sync checklist items (ItemProgress records) to shared zone
                // This includes isComplete status so student can see instructor checkmarks
                await syncChecklistItemsToSharedZone(assignment, customZone: customZone)
                
                if isNewRecord {
                    print("      ✅ Created assignment in shared zone: \(assignment.displayName)")
                } else {
                    print("      ✅ Updated assignment in shared zone: \(assignment.displayName)")
                }
            } else {
                print("      ℹ️ Assignment unchanged in shared zone, skipping: \(assignment.displayName)")
            }
        } catch let error as CKError {
            print("      ❌ FAILED to sync checklist \(assignment.displayName) to shared zone:")
            print("         Error Code: \(error.errorCode)")
            print("         Error Description: \(error.localizedDescription)")
            throw error  // Re-throw so caller knows it failed
        } catch {
            print("      ❌ FAILED to sync checklist \(assignment.displayName) to shared zone: \(error)")
            throw error  // Re-throw so caller knows it failed
        }
    }
    
    /// Syncs checklist items to the shared zone (LEGACY)
    /// CRITICAL: This syncs ItemProgress records including isComplete status so student app can see instructor checkmarks
    private func syncChecklistItemsToSharedZone(_ assignment: ChecklistAssignment, customZone: CKRecordZone) async {
        do {
            let items = assignment.itemProgress ?? []
            var itemsSynced = 0
            var itemsWithProgress = 0
            
            for item in items {
                let recordID = CKRecord.ID(recordName: item.id.uuidString, zoneID: customZone.zoneID)
                let existingRecord = try? await container.privateCloudDatabase.record(for: recordID)
                
                let wasComplete = (existingRecord?["isComplete"] as? Bool) ?? false
                let isNowComplete = item.isComplete
                let record: CKRecord
                var hasItemChanges = false
                
                // Check if item has changed compared to CloudKit record
                let cloudKitLastModified = existingRecord?["lastModified"] as? Date
                let localLastModified = item.lastModified
                let needsSync = existingRecord == nil || cloudKitLastModified == nil || localLastModified > cloudKitLastModified!
                
                if let existing = existingRecord {
                    record = existing
                    
                    if needsSync {
                        // Only update fields that have changed
                        let newTemplateItemId = getCorrectTemplateItemID(for: item, assignment: assignment)
                        if (record["templateItemId"] as? String) != newTemplateItemId {
                            record["templateItemId"] = newTemplateItemId
                            hasItemChanges = true
                        }
                        
                        if (record["title"] as? String) != item.displayTitle {
                            record["title"] = item.displayTitle
                            hasItemChanges = true
                        }
                        
                        if (record["isComplete"] as? Bool) != item.isComplete {
                            record["isComplete"] = item.isComplete
                            hasItemChanges = true
                        }
                        
                        if (record["notes"] as? String) != item.notes {
                            record["notes"] = item.notes
                            hasItemChanges = true
                        }
                        
                        let existingCompletedAt = record["completedAt"] as? Date
                        if existingCompletedAt != item.completedAt {
                            record["completedAt"] = item.completedAt
                            hasItemChanges = true
                        }
                        
                        if (record["assignmentId"] as? String) != assignment.id.uuidString {
                            record["assignmentId"] = assignment.id.uuidString
                            hasItemChanges = true
                        }
                        
                        // Always update lastModified if we're syncing
                        record["lastModified"] = item.lastModified
                        hasItemChanges = true
                    }
                } else {
                    // New record - set all fields
                    record = CKRecord(recordType: "ItemProgress", recordID: recordID)
                    record["templateItemId"] = getCorrectTemplateItemID(for: item, assignment: assignment)
                    record["title"] = item.displayTitle
                    record["isComplete"] = item.isComplete
                    record["notes"] = item.notes
                    record["completedAt"] = item.completedAt
                    record["assignmentId"] = assignment.id.uuidString
                    record["lastModified"] = item.lastModified
                    hasItemChanges = true
                }
                
                // Set parent reference to assignment record (for CloudKit sharing hierarchy)
                let assignmentRecordID = CKRecord.ID(recordName: assignment.id.uuidString, zoneID: customZone.zoneID)
                if record.parent?.recordID != assignmentRecordID {
                    record.parent = CKRecord.Reference(recordID: assignmentRecordID, action: .none)
                    hasItemChanges = true
                }
                
                // Only save if there are actual changes
                if hasItemChanges {
                    _ = try await container.privateCloudDatabase.save(record)
                    item.lastModified = Date()
                    itemsSynced += 1
                    
                    // Log when completion status changes (instructor checked/unchecked item)
                    if wasComplete != isNowComplete {
                        itemsWithProgress += 1
                        if isNowComplete {
                            print("      ✅ Synced checked item: \(item.displayTitle) (isComplete=true)")
                        }
                    }
                }
            }
            
            if itemsWithProgress > 0 {
                print("      📊 Synced \(itemsWithProgress) items with progress changes, \(itemsSynced) total items")
            }
        } catch {
            print("      ❌ Failed to sync checklist items to shared zone: \(error)")
        }
    }
    
    // MARK: - Shared Zone Change Handling
    
    /// Syncs changes from shared zones back to private database
    func syncFromSharedZones() async {
        guard let modelContext = modelContext else { return }
        
        print("🔄 Syncing changes from shared zones...")
        
        do {
            // Get all available shared zones
            let sharedDatabase = container.sharedCloudDatabase
            let zones = try await sharedDatabase.allRecordZones()
            print("Found \(zones.count) shared zones: \(zones.map { $0.zoneID.zoneName })")
            
            for zone in zones {
                await syncStudentChangesFromSharedZone(zone, modelContext: modelContext)
                await syncStudentDocumentsFromSharedZone(zone, modelContext: modelContext)
            }
            
            print("✅ Shared zone sync completed")
            
        } catch {
            print("❌ Failed to sync from shared zones: \(error)")
        }
    }
    
    /// Syncs student changes from a specific shared zone
    private func syncStudentChangesFromSharedZone(_ zone: CKRecordZone, modelContext: ModelContext) async {
        do {
            let sharedDatabase = container.sharedCloudDatabase
            
            // Query for Student records in this shared zone
            let query = CKQuery(recordType: "Student", predicate: NSPredicate(value: true))
            let results = try await sharedDatabase.records(matching: query)
            
            for (_, result) in results.matchResults {
                switch result {
                case .success(let record):
                    await updateStudentFromSharedRecord(record, modelContext: modelContext)
                case .failure(let error):
                    print("Failed to fetch student record from shared zone: \(error)")
                }
            }
            
        } catch {
            print("Failed to sync student changes from shared zone \(zone.zoneID.zoneName): \(error)")
        }
    }
    
    /// Updates local student record with changes from shared zone
    private func updateStudentFromSharedRecord(_ record: CKRecord, modelContext: ModelContext) async {
        do {
            let studentId = UUID(uuidString: record.recordID.recordName)
            guard let id = studentId else { return }
            
            let request = FetchDescriptor<Student>(
                predicate: #Predicate { $0.id == id }
            )
            let existingStudents = try modelContext.fetch(request)
            
            guard let student = existingStudents.first else {
                print("Student not found locally: \(record.recordID.recordName)")
                return
            }
            
            // Check if the shared record is newer than local
            let sharedLastModified = record["lastModified"] as? Date ?? Date.distantPast
            if sharedLastModified <= student.lastModified {
                print("Local student record is up to date: \(student.displayName)")
                return
            }
            
            print("🔄 Updating student from shared zone: \(student.displayName)")
            
            // Update student data from shared record
            student.firstName = record["firstName"] as? String ?? student.firstName
            student.lastName = record["lastName"] as? String ?? student.lastName
            student.email = record["email"] as? String ?? student.email
            student.telephone = record["telephone"] as? String ?? student.telephone
            student.homeAddress = record["homeAddress"] as? String ?? student.homeAddress
            student.ftnNumber = record["ftnNumber"] as? String ?? student.ftnNumber
            student.biography = record["biography"] as? String
            student.backgroundNotes = record["backgroundNotes"] as? String
            student.instructorName = record["instructorName"] as? String
            student.instructorCFINumber = record["instructorCFINumber"] as? String
            
            // Training goals
            student.goalPPL = record["goalPPL"] as? Bool ?? student.goalPPL
            student.goalInstrument = record["goalInstrument"] as? Bool ?? student.goalInstrument
            student.goalCommercial = record["goalCommercial"] as? Bool ?? student.goalCommercial
            student.goalCFI = record["goalCFI"] as? Bool ?? student.goalCFI
            
            // Training milestones - PPL
            student.pplGroundSchoolCompleted = record["pplGroundSchoolCompleted"] as? Bool ?? student.pplGroundSchoolCompleted
            student.pplWrittenTestCompleted = record["pplWrittenTestCompleted"] as? Bool ?? student.pplWrittenTestCompleted
            
            // Training milestones - Instrument
            student.instrumentGroundSchoolCompleted = record["instrumentGroundSchoolCompleted"] as? Bool ?? student.instrumentGroundSchoolCompleted
            student.instrumentWrittenTestCompleted = record["instrumentWrittenTestCompleted"] as? Bool ?? student.instrumentWrittenTestCompleted
            
            // Training milestones - Commercial
            student.commercialGroundSchoolCompleted = record["commercialGroundSchoolCompleted"] as? Bool ?? student.commercialGroundSchoolCompleted
            student.commercialWrittenTestCompleted = record["commercialWrittenTestCompleted"] as? Bool ?? student.commercialWrittenTestCompleted
            
            // Training milestones - CFI
            student.cfiGroundSchoolCompleted = record["cfiGroundSchoolCompleted"] as? Bool ?? student.cfiGroundSchoolCompleted
            student.cfiWrittenTestCompleted = record["cfiWrittenTestCompleted"] as? Bool ?? student.cfiWrittenTestCompleted
            
            student.lastModified = sharedLastModified
            
            try modelContext.save()
            print("✅ Student updated from shared zone: \(student.displayName)")
            
        } catch {
            print("Failed to update student from shared record: \(error)")
        }
    }
    
    /// Syncs student documents from a specific shared zone
    private func syncStudentDocumentsFromSharedZone(_ zone: CKRecordZone, modelContext: ModelContext) async {
        do {
            let sharedDatabase = container.sharedCloudDatabase
            
            // Query for StudentDocument records in this shared zone
            let query = CKQuery(recordType: "StudentDocument", predicate: NSPredicate(value: true))
            let results = try await sharedDatabase.records(matching: query)
            
            for (_, result) in results.matchResults {
                switch result {
                case .success(let record):
                    await updateStudentDocumentFromSharedRecord(record, modelContext: modelContext)
                case .failure(let error):
                    print("Failed to fetch document record from shared zone: \(error)")
                }
            }
            
        } catch {
            print("Failed to sync student documents from shared zone \(zone.zoneID.zoneName): \(error)")
        }
    }
    
    /// Updates local student document record with changes from shared zone
    private func updateStudentDocumentFromSharedRecord(_ record: CKRecord, modelContext: ModelContext) async {
        do {
            let documentId = UUID(uuidString: record.recordID.recordName)
            guard let id = documentId else { return }
            
            let request = FetchDescriptor<StudentDocument>(
                predicate: #Predicate { $0.id == id }
            )
            let existingDocuments = try modelContext.fetch(request)
            
            // Check if the shared record is newer than local
            let sharedLastModified = record["lastModified"] as? Date ?? Date.distantPast
            
            if let existingDocument = existingDocuments.first {
                // Update existing document if shared version is newer
                if sharedLastModified > existingDocument.lastModified {
                    print("🔄 Updating document from shared zone: \(existingDocument.filename)")
                    
                    existingDocument.documentTypeRaw = record["documentType"] as? String ?? existingDocument.documentTypeRaw
                    existingDocument.filename = record["filename"] as? String ?? existingDocument.filename
                    existingDocument.fileData = record["fileData"] as? Data
                    existingDocument.uploadedAt = record["uploadedAt"] as? Date ?? existingDocument.uploadedAt
                    existingDocument.expirationDate = record["expirationDate"] as? Date
                    existingDocument.notes = record["notes"] as? String
                    existingDocument.lastModified = sharedLastModified
                    
                    try modelContext.save()
                    print("✅ Document updated from shared zone: \(existingDocument.filename)")
                }
            } else {
                // Create new document if it doesn't exist locally
                print("➕ Creating new document from shared zone: \(record["filename"] as? String ?? "Unknown")")
                
                let documentType = DocumentType(rawValue: record["documentType"] as? String ?? "") ?? .studentPilotCertificate
                let document = StudentDocument(
                    documentType: documentType,
                    filename: record["filename"] as? String ?? "",
                    fileData: record["fileData"] as? Data,
                    expirationDate: record["expirationDate"] as? Date,
                    notes: record["notes"] as? String
                )
                
                document.id = id
                document.uploadedAt = record["uploadedAt"] as? Date ?? Date()
                document.cloudKitRecordID = record.recordID.recordName
                document.lastModified = sharedLastModified
                
                // Find the student this document belongs to
                if let parentRef = record.parent {
                    let studentId = UUID(uuidString: parentRef.recordID.recordName)
                    if let studentUUID = studentId {
                        let studentRequest = FetchDescriptor<Student>(
                            predicate: #Predicate { $0.id == studentUUID }
                        )
                        let students = try modelContext.fetch(studentRequest)
                        if let student = students.first {
                            document.student = student
                            if student.documents == nil {
                                student.documents = []
                            }
                            student.documents?.append(document)
                        }
                    }
                }
                
                modelContext.insert(document)
                try modelContext.save()
                print("✅ Document created from shared zone: \(document.filename)")
            }
            
        } catch {
            print("Failed to update document from shared record: \(error)")
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
    private func saveRecordWithConflictResolution(_ record: CKRecord, database: CKDatabase) async throws -> CKRecord {
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
        default:
            // Default merge strategy
            mergedRecord = mergeGenericRecord(ourRecord: ourRecord, serverRecord: serverRecord)
        }
        
        // Always update lastModified to current time
        mergedRecord["lastModified"] = Date()
        
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
        // Check if either record is marked as complete
        let ourComplete = ourRecord["isComplete"] as? Bool ?? false
        let serverComplete = serverRecord["isComplete"] as? Bool ?? false
        
        // If either record is complete, use "last writer wins" strategy
        // since completed items are unlikely to be edited again
        if ourComplete || serverComplete {
            print("📝 Using 'last writer wins' for completed checklist item conflict resolution")
            
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
        
        // For incomplete items, use intelligent merge strategy
        print("📝 Using intelligent merge for incomplete checklist item conflict resolution")
        let mergedRecord = serverRecord
        
        // For completion status, prefer completed (true wins)
        if let ourComplete = ourRecord["isComplete"] as? Bool,
           let serverComplete = serverRecord["isComplete"] as? Bool {
            mergedRecord["isComplete"] = ourComplete || serverComplete
        } else if ourRecord["isComplete"] != nil {
            mergedRecord["isComplete"] = ourRecord["isComplete"]
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
        
        // Handle any other fields that might exist
        for key in ourRecord.allKeys() {
            if mergedRecord[key] == nil && ourRecord[key] != nil {
                mergedRecord[key] = ourRecord[key]
            }
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
}
