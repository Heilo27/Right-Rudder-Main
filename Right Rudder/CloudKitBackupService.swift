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
    
    // Versioned backup configuration
    private let maxBackupVersions = 3
    private let backupVersionKey = "backupVersion"
    private let backupTimestampKey = "backupTimestamp"
    
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
            
            backupStatus = "Rotating old backups..."
            
            // Rotate old backups (keep only last maxBackupVersions)
            await rotateOldBackups()
            
            backupStatus = "Creating new backup version..."
            
            // Get current backup version
            let currentVersion = await getCurrentBackupVersion()
            let newVersion = currentVersion + 1
            
            backupStatus = "Backing up data..."
            
            // Backup all data with version number
            await backupStudents(modelContext, version: newVersion)
            await backupTemplates(modelContext, version: newVersion)
            
            // Save backup metadata
            await saveBackupMetadata(version: newVersion)
            
            lastBackupDate = Date()
            saveLastBackupDate()
            backupStatus = "Backup completed (version \(newVersion))"
            print("CloudKit backup completed successfully - version \(newVersion)")
            
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
    
    private func backupStudents(_ modelContext: ModelContext, version: Int) async {
        do {
            let descriptor = FetchDescriptor<Student>()
            let students = try modelContext.fetch(descriptor)
            let database = container.privateCloudDatabase
            
            let timestamp = Date()
            
            // Batch save records for better performance
            let records = students.map { student in
                // Create versioned record ID: studentID_version
                let recordID = CKRecord.ID(recordName: "\(student.id.uuidString)_v\(version)")
                let record = CKRecord(recordType: "StudentBackup", recordID: recordID)
                
                // Store original ID for merging
                record["originalID"] = student.id.uuidString
                record["backupVersion"] = version
                record["backupTimestamp"] = timestamp
                
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
                
                // Log any failures
                for record in batch {
                    if let result = savedRecords[record.recordID],
                       case .failure(let error) = result {
                        print("Failed to save backup record for student: \(error)")
                    }
                }
            }
            
            print("✅ Backed up \(records.count) students as version \(version)")
            
        } catch {
            print("Failed to backup students: \(error)")
        }
    }
    
    private func backupTemplates(_ modelContext: ModelContext, version: Int) async {
        do {
            let descriptor = FetchDescriptor<ChecklistTemplate>()
            let templates = try modelContext.fetch(descriptor)
            let database = container.privateCloudDatabase
            
            let timestamp = Date()
            
            // Batch save records for better performance
            let records = templates.map { template in
                // Create versioned record ID: templateID_version
                let recordID = CKRecord.ID(recordName: "\(template.id.uuidString)_v\(version)")
                let record = CKRecord(recordType: "TemplateBackup", recordID: recordID)
                
                // Store original ID for merging
                record["originalID"] = template.id.uuidString
                record["backupVersion"] = version
                record["backupTimestamp"] = timestamp
                
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
                
                // Log any failures
                for record in batch {
                    if let result = savedRecords[record.recordID],
                       case .failure(let error) = result {
                        print("Failed to save backup record for template: \(error)")
                    }
                }
            }
            
            print("✅ Backed up \(records.count) templates as version \(version)")
            
        } catch {
            print("Failed to backup templates: \(error)")
        }
    }
    
    // MARK: - Version Management
    
    /// Gets the current backup version number
    private func getCurrentBackupVersion() async -> Int {
        let key = "currentBackupVersion"
        let version = UserDefaults.standard.integer(forKey: key)
        return version > 0 ? version : 0
    }
    
    /// Saves backup metadata to CloudKit
    private func saveBackupMetadata(version: Int) async {
        do {
            let database = container.privateCloudDatabase
            let recordID = CKRecord.ID(recordName: "backupMetadata")
            let record = CKRecord(recordType: "BackupMetadata", recordID: recordID)
            
            record["currentVersion"] = version
            record["lastBackupDate"] = Date()
            
            _ = try await database.save(record)
            
            // Also save locally
            UserDefaults.standard.set(version, forKey: "currentBackupVersion")
            
            print("✅ Saved backup metadata - version \(version)")
        } catch {
            print("⚠️ Failed to save backup metadata: \(error)")
        }
    }
    
    /// Rotates old backups, keeping only the last maxBackupVersions
    private func rotateOldBackups() async {
        let currentVersion = await getCurrentBackupVersion()
        let oldestVersionToKeep = max(1, currentVersion - maxBackupVersions + 1)
        
        if currentVersion < maxBackupVersions {
            print("ℹ️ Only \(currentVersion) backups exist, no rotation needed")
            return
        }
        
        let database = container.privateCloudDatabase
        
        // Delete old student backups
        for version in 1..<oldestVersionToKeep {
            let query = CKQuery(recordType: "StudentBackup", predicate: NSPredicate(format: "backupVersion == %d", version))
            let operation = CKQueryOperation(query: query)
            
            var recordIDsToDelete: [CKRecord.ID] = []
            operation.recordMatchedBlock = { _, result in
                if case .success(let record) = result {
                    recordIDsToDelete.append(record.recordID)
                }
            }
            
            await withCheckedContinuation { continuation in
                operation.queryResultBlock = { _ in
                    continuation.resume()
                }
                database.add(operation)
            }
            
            // Delete records in batches
            if !recordIDsToDelete.isEmpty {
                let batchSize = 100
                for i in stride(from: 0, to: recordIDsToDelete.count, by: batchSize) {
                    let endIndex = min(i + batchSize, recordIDsToDelete.count)
                    let batch = Array(recordIDsToDelete[i..<endIndex])
                    do {
                        _ = try await database.modifyRecords(saving: [], deleting: batch)
                    } catch {
                        print("⚠️ Failed to delete student backup batch: \(error)")
                    }
                }
                print("🗑️ Deleted \(recordIDsToDelete.count) student backup records from version \(version)")
            }
        }
        
        // Delete old template backups
        for version in 1..<oldestVersionToKeep {
            let query = CKQuery(recordType: "TemplateBackup", predicate: NSPredicate(format: "backupVersion == %d", version))
            let operation = CKQueryOperation(query: query)
            
            var recordIDsToDelete: [CKRecord.ID] = []
            operation.recordMatchedBlock = { _, result in
                if case .success(let record) = result {
                    recordIDsToDelete.append(record.recordID)
                }
            }
            
            await withCheckedContinuation { continuation in
                operation.queryResultBlock = { _ in
                    continuation.resume()
                }
                database.add(operation)
            }
            
            // Delete records in batches
            if !recordIDsToDelete.isEmpty {
                let batchSize = 100
                for i in stride(from: 0, to: recordIDsToDelete.count, by: batchSize) {
                    let endIndex = min(i + batchSize, recordIDsToDelete.count)
                    let batch = Array(recordIDsToDelete[i..<endIndex])
                    do {
                        _ = try await database.modifyRecords(saving: [], deleting: batch)
                    } catch {
                        print("⚠️ Failed to delete template backup batch: \(error)")
                    }
                }
                print("🗑️ Deleted \(recordIDsToDelete.count) template backup records from version \(version)")
            }
        }
        
        print("✅ Backup rotation complete - keeping versions \(oldestVersionToKeep) to \(currentVersion)")
    }
    
    // MARK: - Restore Functionality
    
    func restoreFromBackup() async {
        guard !isRestoring, let modelContext = modelContext else { return }
        
        isRestoring = true
        restoreStatus = "Searching for backups..."
        
        do {
            // Check CloudKit availability
            let accountStatus = try await container.accountStatus()
            guard accountStatus == .available else {
                restoreStatus = "iCloud not available"
                isRestoring = false
                return
            }
            
            restoreStatus = "Fetching all backup versions..."
            
            // Fetch all backup versions
            let currentVersion = await getCurrentBackupVersion()
            let versionsToCheck = max(1, min(maxBackupVersions, currentVersion))
            let startVersion = max(1, currentVersion - maxBackupVersions + 1)
            
            print("🔍 Searching backup versions \(startVersion) to \(currentVersion)")
            
            // Get existing data to avoid duplicates
            let existingStudentDescriptor = FetchDescriptor<Student>()
            let existingStudents = try modelContext.fetch(existingStudentDescriptor)
            let existingStudentUUIDs = Set(existingStudents.map { $0.id })
            
            let existingTemplateDescriptor = FetchDescriptor<ChecklistTemplate>()
            let existingTemplates = try modelContext.fetch(existingTemplateDescriptor)
            let existingTemplateUUIDs = Set(existingTemplates.map { $0.id })
            
            restoreStatus = "Loading student backups from all versions..."
            
            // Fetch student records from all backup versions
            var allStudentRecords: [String: [CKRecord]] = [:] // Grouped by originalID
            
            for version in startVersion...currentVersion {
                let studentRecords = await fetchStudentBackups(version: version)
                for record in studentRecords {
                    if let originalID = record["originalID"] as? String {
                        if allStudentRecords[originalID] == nil {
                            allStudentRecords[originalID] = []
                        }
                        allStudentRecords[originalID]?.append(record)
                    }
                }
                print("📦 Found \(studentRecords.count) student records in backup version \(version)")
            }
            
            restoreStatus = "Merging student data from all backups..."
            
            // Merge and restore students
            var studentsRestored = 0
            for (originalID, records) in allStudentRecords {
                guard let uuid = UUID(uuidString: originalID) else { continue }
                
                // Skip if already exists
                if existingStudentUUIDs.contains(uuid) {
                    continue
                }
                
                // Merge data from all versions (take most recent non-null value)
                let mergedRecord = mergeStudentRecords(records)
                
                // Create student from merged data
                let student = Student(
                    firstName: mergedRecord["firstName"] as? String ?? "",
                    lastName: mergedRecord["lastName"] as? String ?? "",
                    email: mergedRecord["email"] as? String ?? "",
                    telephone: mergedRecord["telephone"] as? String ?? "",
                    homeAddress: mergedRecord["homeAddress"] as? String ?? "",
                    ftnNumber: mergedRecord["ftnNumber"] as? String ?? ""
                )
                student.id = uuid
                student.biography = mergedRecord["biography"] as? String
                student.backgroundNotes = mergedRecord["backgroundNotes"] as? String
                student.createdAt = mergedRecord["createdAt"] as? Date ?? Date()
                student.lastModified = mergedRecord["lastModified"] as? Date ?? Date()
                
                modelContext.insert(student)
                studentsRestored += 1
                print("✅ Restored merged student: \(student.displayName)")
            }
            
            restoreStatus = "Loading template backups from all versions..."
            
            // Fetch template records from all backup versions
            var allTemplateRecords: [String: [CKRecord]] = [:] // Grouped by originalID
            
            for version in startVersion...currentVersion {
                let templateRecords = await fetchTemplateBackups(version: version)
                for record in templateRecords {
                    if let originalID = record["originalID"] as? String {
                        if allTemplateRecords[originalID] == nil {
                            allTemplateRecords[originalID] = []
                        }
                        allTemplateRecords[originalID]?.append(record)
                    }
                }
                print("📦 Found \(templateRecords.count) template records in backup version \(version)")
            }
            
            restoreStatus = "Merging template data from all backups..."
            
            // Merge and restore templates
            var templatesRestored = 0
            for (originalID, records) in allTemplateRecords {
                guard let uuid = UUID(uuidString: originalID) else { continue }
                
                // Skip if already exists
                if existingTemplateUUIDs.contains(uuid) {
                    continue
                }
                
                // Merge data from all versions
                let mergedRecord = mergeTemplateRecords(records)
                
                // Create template from merged data
                let template = ChecklistTemplate(
                    name: mergedRecord["name"] as? String ?? "",
                    category: mergedRecord["category"] as? String ?? "",
                    phase: mergedRecord["phase"] as? String,
                    relevantData: mergedRecord["relevantData"] as? String
                )
                template.id = uuid
                template.createdAt = mergedRecord["createdAt"] as? Date ?? Date()
                template.lastModified = mergedRecord["lastModified"] as? Date ?? Date()
                
                modelContext.insert(template)
                templatesRestored += 1
                print("✅ Restored merged template: \(template.name)")
            }
            
            try modelContext.save()
            
            restoreStatus = "Restored \(studentsRestored) students, \(templatesRestored) templates (merged from \(versionsToCheck) backups)"
            print("✅ Restore complete: \(studentsRestored) students, \(templatesRestored) templates from \(versionsToCheck) backup versions")
            
        } catch {
            restoreStatus = "Restore failed: \(error.localizedDescription)"
            print("❌ CloudKit restore failed: \(error)")
        }
        
        isRestoring = false
    }
    
    /// Fetches student backup records for a specific version
    private func fetchStudentBackups(version: Int) async -> [CKRecord] {
        var records: [CKRecord] = []
        let database = container.privateCloudDatabase
        
        let query = CKQuery(recordType: "StudentBackup", predicate: NSPredicate(format: "backupVersion == %d", version))
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = CKQueryOperation.maximumResults
        
        operation.recordMatchedBlock = { _, result in
            if case .success(let record) = result {
                records.append(record)
            }
        }
        
        await withCheckedContinuation { continuation in
            operation.queryResultBlock = { _ in
                continuation.resume()
            }
            database.add(operation)
        }
        
        return records
    }
    
    /// Fetches template backup records for a specific version
    private func fetchTemplateBackups(version: Int) async -> [CKRecord] {
        var records: [CKRecord] = []
        let database = container.privateCloudDatabase
        
        let query = CKQuery(recordType: "TemplateBackup", predicate: NSPredicate(format: "backupVersion == %d", version))
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = CKQueryOperation.maximumResults
        
        operation.recordMatchedBlock = { _, result in
            if case .success(let record) = result {
                records.append(record)
            }
        }
        
        await withCheckedContinuation { continuation in
            operation.queryResultBlock = { _ in
                continuation.resume()
            }
            database.add(operation)
        }
        
        return records
    }
    
    /// Merges multiple student records, taking the most recent non-null value for each field
    private func mergeStudentRecords(_ records: [CKRecord]) -> [String: Any] {
        // Sort by version (newest first)
        let sortedRecords = records.sorted { record1, record2 in
            let version1 = record1["backupVersion"] as? Int ?? 0
            let version2 = record2["backupVersion"] as? Int ?? 0
            return version1 > version2
        }
        
        var merged: [String: Any] = [:]
        
        // Merge fields: take most recent non-null value
        for record in sortedRecords {
            let fields = ["firstName", "lastName", "email", "telephone", "homeAddress", "ftnNumber", 
                         "biography", "backgroundNotes", "createdAt", "lastModified"]
            
            for field in fields {
                if merged[field] == nil, let value = record[field] {
                    merged[field] = value
                }
            }
        }
        
        return merged
    }
    
    /// Merges multiple template records, taking the most recent non-null value for each field
    private func mergeTemplateRecords(_ records: [CKRecord]) -> [String: Any] {
        // Sort by version (newest first)
        let sortedRecords = records.sorted { record1, record2 in
            let version1 = record1["backupVersion"] as? Int ?? 0
            let version2 = record2["backupVersion"] as? Int ?? 0
            return version1 > version2
        }
        
        var merged: [String: Any] = [:]
        
        // Merge fields: take most recent non-null value
        for record in sortedRecords {
            let fields = ["name", "category", "phase", "relevantData", "createdAt", "lastModified"]
            
            for field in fields {
                if merged[field] == nil, let value = record[field] {
                    merged[field] = value
                }
            }
        }
        
        return merged
    }
    
    // MARK: - Automatic Backup
    
    private func startAutomaticBackup() {
        // Check if we need to backup (every 24 hours)
        checkAndPerformAutomaticBackup()
        
        // Set up timer to check every 6 hours instead of every hour
        backupTimer = Timer.scheduledTimer(withTimeInterval: 21600, repeats: true) { [weak self] _ in
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
