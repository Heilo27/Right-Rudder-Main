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
            if let existing = existingRecord {
                record = existing
            } else {
                record = CKRecord(recordType: "Student", recordID: recordID)
            }
            
            // Update record with student data
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
            
            // Training goals
            record["goalPPL"] = student.goalPPL
            record["goalInstrument"] = student.goalInstrument
            record["goalCommercial"] = student.goalCommercial
            record["goalCFI"] = student.goalCFI
            
            // Training milestones - PPL
            record["pplGroundSchoolCompleted"] = student.pplGroundSchoolCompleted
            record["pplWrittenTestCompleted"] = student.pplWrittenTestCompleted
            
            // Training milestones - Instrument
            record["instrumentGroundSchoolCompleted"] = student.instrumentGroundSchoolCompleted
            record["instrumentWrittenTestCompleted"] = student.instrumentWrittenTestCompleted
            
            // Training milestones - Commercial
            record["commercialGroundSchoolCompleted"] = student.commercialGroundSchoolCompleted
            record["commercialWrittenTestCompleted"] = student.commercialWrittenTestCompleted
            
            // Training milestones - CFI
            record["cfiGroundSchoolCompleted"] = student.cfiGroundSchoolCompleted
            record["cfiWrittenTestCompleted"] = student.cfiWrittenTestCompleted
            
            // Save to CloudKit
            let savedRecord = try await database.save(record)
            student.cloudKitRecordID = savedRecord.recordID.recordName
            student.lastModified = Date()
            
            // Sync related data
            await syncStudentChecklists(student)
            await syncStudentEndorsements(student)
            
        } catch {
            print("Failed to sync student \(student.displayName): \(error)")
        }
    }
    
    private func syncStudentChecklists(_ student: Student) async {
        do {
            let database = container.privateCloudDatabase
            
            for checklist in student.checklists ?? [] {
                let recordID = CKRecord.ID(recordName: checklist.id.uuidString)
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
                
                record["templateId"] = checklist.templateId.uuidString
                record["templateName"] = checklist.templateName
                record["instructorComments"] = checklist.instructorComments
                record["studentId"] = student.id.uuidString
                record["lastModified"] = checklist.lastModified
                record["dualGivenHours"] = checklist.dualGivenHours
                record["isComplete"] = isNowComplete
                record["completionPercentage"] = calculateCompletionPercentage(checklist)
                
                let savedRecord = try await database.save(record)
                checklist.cloudKitRecordID = savedRecord.recordID.recordName
                checklist.lastModified = Date()
                
                // If instructor just added comments, send notification
                if commentsChanged {
                    await PushNotificationService.shared.notifyStudentOfComment(
                        studentId: student.id,
                        checklistId: checklist.id,
                        checklistName: checklist.templateName
                    )
                }
                
                // If checklist just reached 100% completion, send notification
                if completionChanged {
                    await PushNotificationService.shared.notifyStudentOfCompletion(
                        studentId: student.id,
                        checklistId: checklist.id,
                        checklistName: checklist.templateName
                    )
                }
                
                // Sync checklist items
                await syncChecklistItems(checklist)
            }
            
            // Also sync to shared zone if student has an active share
            if student.shareRecordID != nil {
                await syncStudentChecklistsToSharedZone(student)
            }
        } catch {
            print("Failed to sync student checklists: \(error)")
        }
    }
    
    private func syncChecklistItems(_ checklist: StudentChecklist) async {
        do {
            let database = container.privateCloudDatabase
            
            for item in checklist.items ?? [] {
                let recordID = CKRecord.ID(recordName: item.id.uuidString)
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
                
                let savedRecord = try await database.save(record)
                item.cloudKitRecordID = savedRecord.recordID.recordName
                item.lastModified = Date()
            }
        } catch {
            print("Failed to sync checklist items: \(error)")
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
    
    private func syncTemplateToCloudKit(_ template: ChecklistTemplate) async {
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
            let checklistId = UUID(uuidString: record.recordID.recordName)
            guard let id = checklistId else { return }
            
            let request = FetchDescriptor<StudentChecklist>(
                predicate: #Predicate { $0.id == id }
            )
            let existingChecklists = try modelContext.fetch(request)
            
            if existingChecklists.isEmpty {
                let checklist = StudentChecklist(
                    templateId: UUID(uuidString: record["templateId"] as? String ?? "") ?? UUID(),
                    templateName: record["templateName"] as? String ?? ""
                )
                
                checklist.id = id
                checklist.instructorComments = record["instructorComments"] as? String
                checklist.cloudKitRecordID = record.recordID.recordName
                checklist.lastModified = record["lastModified"] as? Date ?? Date()
                
                if student.checklists == nil {
                    student.checklists = []
                }
                student.checklists?.append(checklist)
                modelContext.insert(checklist)
                
                // Restore checklist items
                await restoreChecklistItems(checklist)
            }
        } catch {
            print("Failed to restore checklist: \(error)")
        }
    }
    
    private func restoreChecklistItems(_ checklist: StudentChecklist) async {
        do {
            let database = container.privateCloudDatabase
            let query = CKQuery(recordType: "StudentChecklistItem", predicate: NSPredicate(format: "checklistId == %@", checklist.id.uuidString))
            let results = try await database.records(matching: query)
            
            for (_, result) in results.matchResults {
                switch result {
                case .success(let record):
                    await restoreChecklistItemFromRecord(record, checklist: checklist)
                case .failure(let error):
                    print("Failed to fetch checklist item record: \(error)")
                }
            }
        } catch {
            print("Failed to restore checklist items: \(error)")
        }
    }
    
    private func restoreChecklistItemFromRecord(_ record: CKRecord, checklist: StudentChecklist) async {
        guard let modelContext = modelContext else { return }
        
        do {
            let itemId = UUID(uuidString: record.recordID.recordName)
            guard let id = itemId else { return }
            
            let request = FetchDescriptor<StudentChecklistItem>(
                predicate: #Predicate { $0.id == id }
            )
            let existingItems = try modelContext.fetch(request)
            
            if existingItems.isEmpty {
                let item = StudentChecklistItem(
                    templateItemId: UUID(uuidString: record["templateItemId"] as? String ?? "") ?? UUID(),
                    title: record["title"] as? String ?? "",
                    order: record["order"] as? Int ?? 0
                )
                
                item.id = id
                item.isComplete = record["isComplete"] as? Bool ?? false
                item.notes = record["notes"] as? String
                item.completedAt = record["completedAt"] as? Date
                item.cloudKitRecordID = record.recordID.recordName
                item.lastModified = record["lastModified"] as? Date ?? Date()
                
                checklist.items?.append(item)
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
                let template = ChecklistTemplate(
                    name: record["name"] as? String ?? "",
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
    private func syncStudentChecklistsToSharedZone(_ student: Student) async {
        guard student.shareRecordID != nil else {
            print("No active share for student \(student.displayName), skipping shared zone sync")
            return
        }
        
        do {
            let customZoneName = "SharedStudentsZone"
            let zoneID = CKRecordZone.ID(zoneName: customZoneName, ownerName: CKCurrentUserDefaultName)
            
            // Try to fetch the custom zone
            let customZone = try await container.privateCloudDatabase.recordZone(for: zoneID)
            
            for checklist in student.checklists ?? [] {
                await syncChecklistToSharedZone(checklist, student: student, customZone: customZone)
            }
        } catch {
            print("Failed to sync student checklists to shared zone: \(error)")
        }
    }
    
    /// Syncs a specific checklist to the shared zone
    private func syncChecklistToSharedZone(_ checklist: StudentChecklist, student: Student, customZone: CKRecordZone) async {
        do {
            // Create record ID in custom zone
            let recordID = CKRecord.ID(recordName: checklist.id.uuidString, zoneID: customZone.zoneID)
            let existingRecord = try? await container.privateCloudDatabase.record(for: recordID)
            
            let record: CKRecord
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
            record["isComplete"] = isChecklistComplete(checklist)
            record["completionPercentage"] = calculateCompletionPercentage(checklist)
            
            // Set parent reference to student record for sharing
            let studentRecordID = CKRecord.ID(recordName: student.id.uuidString, zoneID: customZone.zoneID)
            record.parent = CKRecord.Reference(recordID: studentRecordID, action: .none)
            
            let savedRecord = try await container.privateCloudDatabase.save(record)
            checklist.cloudKitRecordID = savedRecord.recordID.recordName
            checklist.lastModified = Date()
            
            // Sync checklist items
            await syncChecklistItemsToSharedZone(checklist, customZone: customZone)
            
        } catch {
            print("Failed to sync checklist \(checklist.templateName) to shared zone: \(error)")
        }
    }
    
    /// Syncs checklist items to the shared zone
    private func syncChecklistItemsToSharedZone(_ checklist: StudentChecklist, customZone: CKRecordZone) async {
        do {
            for item in checklist.items ?? [] {
                let recordID = CKRecord.ID(recordName: item.id.uuidString, zoneID: customZone.zoneID)
                let existingRecord = try? await container.privateCloudDatabase.record(for: recordID)
                
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
                
                let savedRecord = try await container.privateCloudDatabase.save(record)
                item.cloudKitRecordID = savedRecord.recordID.recordName
                item.lastModified = Date()
            }
        } catch {
            print("Failed to sync checklist items to shared zone: \(error)")
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
}
