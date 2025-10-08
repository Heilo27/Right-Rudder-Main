import Foundation
import SwiftData
import CloudKit
import SwiftUI
import Combine

@MainActor
class CloudKitBackupService: ObservableObject {
    @Published var isBackingUp = false
    @Published var isRestoring = false
    @Published var lastBackupDate: Date?
    @Published var backupStatus: String = "Ready"
    @Published var restoreStatus: String = "Ready"
    
    private var modelContext: ModelContext?
    private let container: CKContainer
    private var backupTimer: Timer?
    
    init() {
        // Use the specific container from entitlements
        self.container = CKContainer(identifier: "iCloud.com.heiloprojects.rightrudder")
        loadLastBackupDate()
        startAutomaticBackup()
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func performBackup() async {
        guard !isBackingUp, let modelContext = modelContext else { return }
        
        isBackingUp = true
        backupStatus = "Starting backup..."
        
        do {
            // Check CloudKit availability
            let accountStatus = try await container.accountStatus()
            guard accountStatus == .available else {
                backupStatus = "iCloud not available - check entitlements"
                isBackingUp = false
                return
            }
            
            backupStatus = "Backing up data..."
            
            // Backup all data
            await backupStudents(modelContext)
            await backupTemplates(modelContext)
            
            lastBackupDate = Date()
            saveLastBackupDate()
            backupStatus = "Backup completed"
            print("CloudKit backup completed successfully")
            
        } catch {
            backupStatus = "Backup failed: \(error.localizedDescription)"
            print("CloudKit backup failed: \(error)")
        }
        
        isBackingUp = false
    }
    
    func deleteBackup() async {
        guard let modelContext = modelContext else { return }
        
        do {
            let accountStatus = try await container.accountStatus()
            guard accountStatus == .available else {
                print("iCloud not available for backup deletion")
                return
            }
            
            let database = container.privateCloudDatabase
            
            // Delete all student records
            let studentDescriptor = FetchDescriptor<Student>()
            let students = try modelContext.fetch(studentDescriptor)
            for student in students {
                if let recordID = student.cloudKitRecordID {
                    let ckRecordID = CKRecord.ID(recordName: recordID)
                    try await database.deleteRecord(withID: ckRecordID)
                }
            }
            
            // Delete all template records
            let templateDescriptor = FetchDescriptor<ChecklistTemplate>()
            let templates = try modelContext.fetch(templateDescriptor)
            for template in templates {
                if let recordID = template.cloudKitRecordID {
                    let ckRecordID = CKRecord.ID(recordName: recordID)
                    try await database.deleteRecord(withID: ckRecordID)
                }
            }
            
            print("CloudKit backup deleted successfully")
            
        } catch {
            print("Failed to delete CloudKit backup: \(error)")
        }
    }
    
    private func backupStudents(_ modelContext: ModelContext) async {
        do {
            let descriptor = FetchDescriptor<Student>()
            let students = try modelContext.fetch(descriptor)
            let database = container.privateCloudDatabase
            
            // Batch save records for better performance
            let records = students.map { student in
                let record = CKRecord(recordType: "Student", recordID: CKRecord.ID(recordName: student.id.uuidString))
                
                record["firstName"] = student.firstName
                record["lastName"] = student.lastName
                record["email"] = student.email
                record["telephone"] = student.telephone
                record["homeAddress"] = student.homeAddress
                record["ftnNumber"] = student.ftnNumber
                record["biography"] = student.biography
                record["backgroundNotes"] = student.backgroundNotes
                record["createdAt"] = student.createdAt
                record["lastModified"] = student.lastModified
                
                return record
            }
            
            // Save all records in batches
            let batchSize = 100
            for i in stride(from: 0, to: records.count, by: batchSize) {
                let endIndex = min(i + batchSize, records.count)
                let batch = Array(records[i..<endIndex])
                
                let (savedRecords, _) = try await database.modifyRecords(saving: batch, deleting: [])
                
                // Update CloudKit record IDs
                for (index, recordID) in batch.enumerated() {
                    let studentIndex = i + index
                    if let result = savedRecords[recordID.recordID] {
                        switch result {
                        case .success(let savedRecord):
                            students[studentIndex].cloudKitRecordID = savedRecord.recordID.recordName
                        case .failure(let error):
                            print("Failed to save record for student \(students[studentIndex].displayName): \(error)")
                        }
                    }
                }
            }
            
            try modelContext.save()
            
        } catch {
            print("Failed to backup students: \(error)")
        }
    }
    
    private func backupTemplates(_ modelContext: ModelContext) async {
        do {
            let descriptor = FetchDescriptor<ChecklistTemplate>()
            let templates = try modelContext.fetch(descriptor)
            let database = container.privateCloudDatabase
            
            // Batch save records for better performance
            let records = templates.map { template in
                let record = CKRecord(recordType: "ChecklistTemplate", recordID: CKRecord.ID(recordName: template.id.uuidString))
                
                record["name"] = template.name
                record["category"] = template.category
                record["phase"] = template.phase
                record["relevantData"] = template.relevantData
                record["createdAt"] = template.createdAt
                record["lastModified"] = template.lastModified
                
                return record
            }
            
            // Save all records in batches
            let batchSize = 100
            for i in stride(from: 0, to: records.count, by: batchSize) {
                let endIndex = min(i + batchSize, records.count)
                let batch = Array(records[i..<endIndex])
                
                let (savedRecords, _) = try await database.modifyRecords(saving: batch, deleting: [])
                
                // Update CloudKit record IDs
                for (index, recordID) in batch.enumerated() {
                    let templateIndex = i + index
                    if let result = savedRecords[recordID.recordID] {
                        switch result {
                        case .success(let savedRecord):
                            templates[templateIndex].cloudKitRecordID = savedRecord.recordID.recordName
                        case .failure(let error):
                            print("Failed to save record for template \(templates[templateIndex].name): \(error)")
                        }
                    }
                }
            }
            
            try modelContext.save()
            
        } catch {
            print("Failed to backup templates: \(error)")
        }
    }
    
    // MARK: - Restore Functionality
    
    func restoreFromBackup() async {
        guard !isRestoring, let modelContext = modelContext else { return }
        
        isRestoring = true
        restoreStatus = "Searching for backup..."
        
        do {
            // Check CloudKit availability
            let accountStatus = try await container.accountStatus()
            guard accountStatus == .available else {
                restoreStatus = "iCloud not available"
                isRestoring = false
                return
            }
            
            let database = container.privateCloudDatabase
            
            // Get all existing students and templates to check for duplicates
            let existingStudentDescriptor = FetchDescriptor<Student>()
            let existingStudents = try modelContext.fetch(existingStudentDescriptor)
            let existingStudentIDs = Set(existingStudents.compactMap { $0.cloudKitRecordID })
            
            let existingTemplateDescriptor = FetchDescriptor<ChecklistTemplate>()
            let existingTemplates = try modelContext.fetch(existingTemplateDescriptor)
            let existingTemplateIDs = Set(existingTemplates.compactMap { $0.cloudKitRecordID })
            
            // Restore students using fetchAllRecords
            restoreStatus = "Restoring students..."
            var studentsRestored = 0
            
            let studentQuery = CKQuery(recordType: "Student", predicate: NSPredicate(value: true))
            
            let studentOperation = CKQueryOperation(query: studentQuery)
            studentOperation.resultsLimit = CKQueryOperation.maximumResults
            
            var studentRecords: [CKRecord] = []
            studentOperation.recordMatchedBlock = { recordID, result in
                switch result {
                case .success(let record):
                    studentRecords.append(record)
                case .failure(let error):
                    print("Failed to fetch student record: \(error)")
                }
            }
            
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                studentOperation.queryResultBlock = { result in
                    continuation.resume()
                }
                database.add(studentOperation)
            }
            
            // Process student records
            for record in studentRecords {
                let recordName = record.recordID.recordName
                if !existingStudentIDs.contains(recordName) {
                    let id = UUID(uuidString: recordName) ?? UUID()
                    
                    let student = Student(
                        firstName: record["firstName"] as? String ?? "",
                        lastName: record["lastName"] as? String ?? "",
                        email: record["email"] as? String ?? "",
                        telephone: record["telephone"] as? String ?? "",
                        homeAddress: record["homeAddress"] as? String ?? "",
                        ftnNumber: record["ftnNumber"] as? String ?? ""
                    )
                    student.id = id
                    student.biography = record["biography"] as? String
                    student.backgroundNotes = record["backgroundNotes"] as? String
                    student.createdAt = record["createdAt"] as? Date ?? Date()
                    student.lastModified = record["lastModified"] as? Date ?? Date()
                    student.cloudKitRecordID = recordName
                    
                    modelContext.insert(student)
                    studentsRestored += 1
                }
            }
            
            // Restore templates
            restoreStatus = "Restoring templates..."
            var templatesRestored = 0
            
            let templateQuery = CKQuery(recordType: "ChecklistTemplate", predicate: NSPredicate(value: true))
            
            let templateOperation = CKQueryOperation(query: templateQuery)
            templateOperation.resultsLimit = CKQueryOperation.maximumResults
            
            var templateRecords: [CKRecord] = []
            templateOperation.recordMatchedBlock = { recordID, result in
                switch result {
                case .success(let record):
                    templateRecords.append(record)
                case .failure(let error):
                    print("Failed to fetch template record: \(error)")
                }
            }
            
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                templateOperation.queryResultBlock = { result in
                    continuation.resume()
                }
                database.add(templateOperation)
            }
            
            // Process template records
            for record in templateRecords {
                let recordName = record.recordID.recordName
                if !existingTemplateIDs.contains(recordName) {
                    let id = UUID(uuidString: recordName) ?? UUID()
                    
                    let template = ChecklistTemplate(
                        name: record["name"] as? String ?? "",
                        category: record["category"] as? String ?? "",
                        phase: record["phase"] as? String,
                        relevantData: record["relevantData"] as? String
                    )
                    template.id = id
                    template.createdAt = record["createdAt"] as? Date ?? Date()
                    template.lastModified = record["lastModified"] as? Date ?? Date()
                    template.cloudKitRecordID = recordName
                    
                    modelContext.insert(template)
                    templatesRestored += 1
                }
            }
            
            try modelContext.save()
            
            if studentsRestored > 0 || templatesRestored > 0 {
                restoreStatus = "Restored \(studentsRestored) students, \(templatesRestored) templates"
            } else {
                restoreStatus = "No new data to restore"
            }
            
            print("CloudKit restore completed: \(studentsRestored) students, \(templatesRestored) templates")
            
        } catch {
            restoreStatus = "Restore failed: \(error.localizedDescription)"
            print("CloudKit restore failed: \(error)")
        }
        
        isRestoring = false
    }
    
    // MARK: - Automatic Backup
    
    private func startAutomaticBackup() {
        // Check if we need to backup (every 24 hours)
        checkAndPerformAutomaticBackup()
        
        // Set up timer to check every hour
        backupTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.checkAndPerformAutomaticBackup()
            }
        }
    }
    
    private func checkAndPerformAutomaticBackup() {
        guard let lastBackup = lastBackupDate else {
            // No backup yet, perform one
            Task {
                await performBackup()
                saveLastBackupDate()
            }
            return
        }
        
        let hoursSinceLastBackup = Date().timeIntervalSince(lastBackup) / 3600
        if hoursSinceLastBackup >= 24 {
            Task {
                await performBackup()
                saveLastBackupDate()
            }
        }
    }
    
    private func saveLastBackupDate() {
        UserDefaults.standard.set(lastBackupDate, forKey: "lastBackupDate")
    }
    
    private func loadLastBackupDate() {
        lastBackupDate = UserDefaults.standard.object(forKey: "lastBackupDate") as? Date
    }
    
    deinit {
        backupTimer?.invalidate()
    }
}
