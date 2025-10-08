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
    
    init() {
        self.container = CKContainer(identifier: "iCloud.com.heiloprojects.rightrudder")
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
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
            
            syncStatus = "Syncing students..."
            
            // Sync students
            await syncStudents()
            
            syncStatus = "Syncing checklist templates..."
            
            // Sync checklist templates
            await syncChecklistTemplates()
            
            lastSyncDate = Date()
            syncStatus = "Sync completed successfully"
            
        } catch {
            syncStatus = "Sync failed: \(error.localizedDescription)"
            print("CloudKit sync error: \(error)")
        }
        
        isSyncing = false
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
                
                // Sync checklist items
                await syncChecklistItems(checklist)
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
}
