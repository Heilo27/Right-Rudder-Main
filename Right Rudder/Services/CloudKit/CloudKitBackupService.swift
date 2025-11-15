import CloudKit
import Combine
import Foundation
import SwiftData
import SwiftUI

// MARK: - BackupSnapshot

// Backup snapshot model for restore selection
struct BackupSnapshot: Identifiable, Codable {
  let id: String  // Date string "yyyy-MM-dd"
  let date: Date
  let studentCount: Int
  let templateCount: Int
  let size: Int64?  // Optional size in bytes
}

// MARK: - CloudKitBackupService

@MainActor
class CloudKitBackupService: ObservableObject {
  // MARK: - Published Properties

  @Published var isBackingUp = false
  @Published var isRestoring = false
  @Published var lastBackupDate: Date?
  @Published var backupStatus: String = "Ready"
  @Published var restoreStatus: String = "Ready"
  @Published var availableBackups: [BackupSnapshot] = []

  // MARK: - Properties

  private var modelContext: ModelContext?
  private let container: CKContainer
  private var backupTimer: Timer?

  // Date-based backup configuration (2 weeks = 14 days)
  private let maxBackupDays = 14
  private let backupDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = TimeZone.current
    return formatter
  }()

  // MARK: - Initialization

  init() {
    // Use the specific container from entitlements
    self.container = CKContainer(identifier: "iCloud.com.heiloprojects.rightrudder")
    loadLastBackupDate()
    startAutomaticBackup()
  }

  // MARK: - Configuration

  func setModelContext(_ context: ModelContext) {
    self.modelContext = context
  }

  // MARK: - Backup Operations

  func performBackup() async {
    guard !isBackingUp, let modelContext = modelContext else { return }

    // Check if backup already exists for today (one snapshot per day max)
    let todaySnapshot = backupDateFormatter.string(from: Date())
    if await backupExists(for: todaySnapshot) {
      backupStatus = "Backup already exists for today (\(todaySnapshot))"
      isBackingUp = false
      return
    }

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

      // Rotate old backups (keep only last 14 days)
      await rotateOldBackups()

      backupStatus = "Creating snapshot for \(todaySnapshot)..."

      let timestamp = Date()

      backupStatus = "Backing up data..."

      // Backup all data with date-based snapshot
      let studentCount = await backupStudents(
        modelContext, snapshotDate: todaySnapshot, timestamp: timestamp)
      let templateCount = await backupTemplates(
        modelContext, snapshotDate: todaySnapshot, timestamp: timestamp)

      // Save backup metadata
      await saveBackupMetadata(
        snapshotDate: todaySnapshot, timestamp: timestamp, studentCount: studentCount,
        templateCount: templateCount)

      // Refresh available backups list
      await loadAvailableBackups()

      lastBackupDate = Date()
      saveLastBackupDate()
      backupStatus = "Backup completed for \(todaySnapshot)"
      print("CloudKit backup completed successfully - snapshot: \(todaySnapshot)")

    } catch {
      backupStatus = "Backup failed: \(error.localizedDescription)"
      print("CloudKit backup failed: \(error)")
    }

    isBackingUp = false
  }

  /// Checks if a backup already exists for the given snapshot date
  private func backupExists(for snapshotDate: String) async -> Bool {
    do {
      let database = container.privateCloudDatabase
      let predicate = NSPredicate(format: "snapshotDate == %@", snapshotDate)
      let query = CKQuery(recordType: "BackupMetadata", predicate: predicate)

      let results = try await database.records(matching: query)
      return !results.matchResults.isEmpty
    } catch {
      print("⚠️ Error checking backup existence: \(error)")
      return false
    }
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

  private func backupStudents(_ modelContext: ModelContext, snapshotDate: String, timestamp: Date)
    async -> Int
  {
    do {
      let descriptor = FetchDescriptor<Student>()
      let students = try modelContext.fetch(descriptor)
      let database = container.privateCloudDatabase

      // Batch save records for better performance
      let records = students.map { student in
        // Create date-based record ID: studentID_2024-01-15
        let recordID = CKRecord.ID(recordName: "\(student.id.uuidString)_\(snapshotDate)")
        let record = CKRecord(recordType: "StudentBackup", recordID: recordID)

        // Store original ID and snapshot date
        record["originalID"] = student.id.uuidString
        record["snapshotDate"] = snapshotDate
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
            case .failure(let error) = result
          {
            print("Failed to save backup record for student: \(error)")
          }
        }
      }

      print("✅ Backed up \(records.count) students as snapshot \(snapshotDate)")
      return records.count

    } catch {
      print("Failed to backup students: \(error)")
      return 0
    }
  }

  private func backupTemplates(_ modelContext: ModelContext, snapshotDate: String, timestamp: Date)
    async -> Int
  {
    do {
      let descriptor = FetchDescriptor<ChecklistTemplate>()
      let templates = try modelContext.fetch(descriptor)
      let database = container.privateCloudDatabase

      // Batch save records for better performance
      let records = templates.map { template in
        // Create date-based record ID: templateID_2024-01-15
        let recordID = CKRecord.ID(recordName: "\(template.id.uuidString)_\(snapshotDate)")
        let record = CKRecord(recordType: "TemplateBackup", recordID: recordID)

        // Store original ID and snapshot date
        record["originalID"] = template.id.uuidString
        record["snapshotDate"] = snapshotDate
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
            case .failure(let error) = result
          {
            print("Failed to save backup record for template: \(error)")
          }
        }
      }

      print("✅ Backed up \(records.count) templates as snapshot \(snapshotDate)")
      return records.count
    } catch {
      print("Failed to backup templates: \(error)")
      return 0
    }
  }

  // MARK: - Snapshot Management

  /// Saves backup metadata to CloudKit
  private func saveBackupMetadata(
    snapshotDate: String, timestamp: Date, studentCount: Int, templateCount: Int
  ) async {
    do {
      let database = container.privateCloudDatabase
      let recordID = CKRecord.ID(recordName: "backupMetadata_\(snapshotDate)")
      let record = CKRecord(recordType: "BackupMetadata", recordID: recordID)

      record["snapshotDate"] = snapshotDate
      record["backupTimestamp"] = timestamp
      record["studentCount"] = studentCount
      record["templateCount"] = templateCount

      _ = try await database.save(record)

      print("✅ Saved backup metadata - snapshot: \(snapshotDate)")
    } catch {
      print("⚠️ Failed to save backup metadata: \(error)")
    }
  }

  /// Rotates old backups, keeping only the last 14 days
  private func rotateOldBackups() async {
    let cutoffDate = Calendar.current.date(byAdding: .day, value: -maxBackupDays, to: Date())!
    let cutoffSnapshot = backupDateFormatter.string(from: cutoffDate)

    print("🗑️ Rotating backups older than \(cutoffSnapshot)...")

    let database = container.privateCloudDatabase

    // Query all backup metadata records
    let query = CKQuery(recordType: "BackupMetadata", predicate: NSPredicate(value: true))
    let operation = CKQueryOperation(query: query)

    var oldMetadataRecords: [CKRecord.ID] = []
    var oldStudentRecords: [CKRecord.ID] = []
    var oldTemplateRecords: [CKRecord.ID] = []

    operation.recordMatchedBlock = { _, result in
      if case .success(let record) = result {
        if let snapshotDate = record["snapshotDate"] as? String,
          snapshotDate < cutoffSnapshot
        {
          oldMetadataRecords.append(record.recordID)
        }
      }
    }

    await withCheckedContinuation { continuation in
      operation.queryResultBlock = { _ in
        continuation.resume()
      }
      database.add(operation)
    }

    // Delete old metadata records
    if !oldMetadataRecords.isEmpty {
      let batchSize = 100
      for i in stride(from: 0, to: oldMetadataRecords.count, by: batchSize) {
        let endIndex = min(i + batchSize, oldMetadataRecords.count)
        let batch = Array(oldMetadataRecords[i..<endIndex])
        do {
          _ = try await database.modifyRecords(saving: [], deleting: batch)
        } catch {
          print("⚠️ Failed to delete metadata batch: \(error)")
        }
      }
      print("🗑️ Deleted \(oldMetadataRecords.count) old metadata records")
    }

    // Delete old student backups
    for metadataRecord in oldMetadataRecords {
      if let snapshotDate = (try? await database.record(for: metadataRecord))?["snapshotDate"]
        as? String
      {
        let studentQuery = CKQuery(
          recordType: "StudentBackup",
          predicate: NSPredicate(format: "snapshotDate == %@", snapshotDate))
        let studentOperation = CKQueryOperation(query: studentQuery)

        studentOperation.recordMatchedBlock = { _, result in
          if case .success(let record) = result {
            oldStudentRecords.append(record.recordID)
          }
        }

        await withCheckedContinuation { continuation in
          studentOperation.queryResultBlock = { _ in
            continuation.resume()
          }
          database.add(studentOperation)
        }
      }
    }

    if !oldStudentRecords.isEmpty {
      let batchSize = 100
      for i in stride(from: 0, to: oldStudentRecords.count, by: batchSize) {
        let endIndex = min(i + batchSize, oldStudentRecords.count)
        let batch = Array(oldStudentRecords[i..<endIndex])
        do {
          _ = try await database.modifyRecords(saving: [], deleting: batch)
        } catch {
          print("⚠️ Failed to delete student backup batch: \(error)")
        }
      }
      print("🗑️ Deleted \(oldStudentRecords.count) old student backup records")
    }

    // Delete old template backups
    for metadataRecord in oldMetadataRecords {
      if let snapshotDate = (try? await database.record(for: metadataRecord))?["snapshotDate"]
        as? String
      {
        let templateQuery = CKQuery(
          recordType: "TemplateBackup",
          predicate: NSPredicate(format: "snapshotDate == %@", snapshotDate))
        let templateOperation = CKQueryOperation(query: templateQuery)

        templateOperation.recordMatchedBlock = { _, result in
          if case .success(let record) = result {
            oldTemplateRecords.append(record.recordID)
          }
        }

        await withCheckedContinuation { continuation in
          templateOperation.queryResultBlock = { _ in
            continuation.resume()
          }
          database.add(templateOperation)
        }
      }
    }

    if !oldTemplateRecords.isEmpty {
      let batchSize = 100
      for i in stride(from: 0, to: oldTemplateRecords.count, by: batchSize) {
        let endIndex = min(i + batchSize, oldTemplateRecords.count)
        let batch = Array(oldTemplateRecords[i..<endIndex])
        do {
          _ = try await database.modifyRecords(saving: [], deleting: batch)
        } catch {
          print("⚠️ Failed to delete template backup batch: \(error)")
        }
      }
      print("🗑️ Deleted \(oldTemplateRecords.count) old template backup records")
    }

    print("✅ Backup rotation complete - keeping last \(maxBackupDays) days")
  }

  /// Loads available backups for restore selection
  func loadAvailableBackups() async {
    var snapshots: [BackupSnapshot] = []
    let database = container.privateCloudDatabase

    let query = CKQuery(recordType: "BackupMetadata", predicate: NSPredicate(value: true))
    let operation = CKQueryOperation(query: query)
    operation.resultsLimit = CKQueryOperation.maximumResults

    var metadataRecords: [CKRecord] = []
    var queryError: Error?

    operation.recordMatchedBlock = { _, result in
      if case .success(let record) = result {
        metadataRecords.append(record)
      }
    }

    await withCheckedContinuation { continuation in
      operation.queryResultBlock = { result in
        if case .failure(let error) = result {
          queryError = error
        }
        continuation.resume()
      }
      database.add(operation)
    }

    if let error = queryError {
      print("⚠️ Failed to load available backups: \(error)")
      await MainActor.run {
        self.availableBackups = []
      }
      return
    }

    // Convert metadata records to BackupSnapshot
    for record in metadataRecords {
      if let snapshotDate = record["snapshotDate"] as? String,
        let timestamp = record["backupTimestamp"] as? Date,
        let studentCount = record["studentCount"] as? Int,
        let templateCount = record["templateCount"] as? Int
      {

        let snapshot = BackupSnapshot(
          id: snapshotDate,
          date: timestamp,
          studentCount: studentCount,
          templateCount: templateCount,
          size: nil
        )
        snapshots.append(snapshot)
      }
    }

    // Sort by date descending (newest first)
    snapshots.sort { $0.date > $1.date }

    // Only keep last 14 days
    let cutoffDate = Calendar.current.date(byAdding: .day, value: -maxBackupDays, to: Date())!
    snapshots = snapshots.filter { $0.date >= cutoffDate }

    await MainActor.run {
      self.availableBackups = snapshots
    }
  }

  // MARK: - Restore Functionality

  /// Restores from a specific backup snapshot
  func restoreFromBackup(snapshotDate: String) async {
    guard !isRestoring, let modelContext = modelContext else { return }

    isRestoring = true
    restoreStatus = "Restoring from snapshot \(snapshotDate)..."

    do {
      // Check CloudKit availability
      let accountStatus = try await container.accountStatus()
      guard accountStatus == .available else {
        restoreStatus = "iCloud not available"
        isRestoring = false
        return
      }

      restoreStatus = "Fetching backup data..."

      // Get existing data to avoid duplicates
      let existingStudentDescriptor = FetchDescriptor<Student>()
      let existingStudents = try modelContext.fetch(existingStudentDescriptor)
      let existingStudentUUIDs = Set(existingStudents.map { $0.id })

      let existingTemplateDescriptor = FetchDescriptor<ChecklistTemplate>()
      let existingTemplates = try modelContext.fetch(existingTemplateDescriptor)
      let existingTemplateUUIDs = Set(existingTemplates.map { $0.id })

      restoreStatus = "Loading student backups..."

      // Fetch student records from specific snapshot
      let studentRecords = await fetchStudentBackups(snapshotDate: snapshotDate)
      print("📦 Found \(studentRecords.count) student records in snapshot \(snapshotDate)")

      restoreStatus = "Restoring students..."

      // Restore students
      var studentsRestored = 0
      for record in studentRecords {
        guard let originalID = record["originalID"] as? String,
          let uuid = UUID(uuidString: originalID)
        else { continue }

        // Skip if already exists
        if existingStudentUUIDs.contains(uuid) {
          continue
        }

        // Create student from backup data
        let student = Student(
          firstName: record["firstName"] as? String ?? "",
          lastName: record["lastName"] as? String ?? "",
          email: record["email"] as? String ?? "",
          telephone: record["telephone"] as? String ?? "",
          homeAddress: record["homeAddress"] as? String ?? "",
          ftnNumber: record["ftnNumber"] as? String ?? ""
        )
        student.id = uuid
        student.biography = record["biography"] as? String
        student.backgroundNotes = record["backgroundNotes"] as? String
        student.createdAt = record["createdAt"] as? Date ?? Date()
        student.lastModified = record["lastModified"] as? Date ?? Date()

        modelContext.insert(student)
        studentsRestored += 1
        print("✅ Restored student: \(student.displayName)")
      }

      restoreStatus = "Loading template backups..."

      // Fetch template records from specific snapshot
      let templateRecords = await fetchTemplateBackups(snapshotDate: snapshotDate)
      print("📦 Found \(templateRecords.count) template records in snapshot \(snapshotDate)")

      restoreStatus = "Restoring templates..."

      // Restore templates
      var templatesRestored = 0
      for record in templateRecords {
        guard let originalID = record["originalID"] as? String,
          let uuid = UUID(uuidString: originalID)
        else { continue }

        // Skip if already exists
        if existingTemplateUUIDs.contains(uuid) {
          continue
        }

        // Create template from backup data
        let template = ChecklistTemplate(
          name: record["name"] as? String ?? "",
          category: record["category"] as? String ?? "",
          phase: record["phase"] as? String,
          relevantData: record["relevantData"] as? String
        )
        template.id = uuid
        template.createdAt = record["createdAt"] as? Date ?? Date()
        template.lastModified = record["lastModified"] as? Date ?? Date()

        modelContext.insert(template)
        templatesRestored += 1
        print("✅ Restored template: \(template.name)")
      }

      try modelContext.save()

      restoreStatus =
        "Restored \(studentsRestored) students, \(templatesRestored) templates from snapshot \(snapshotDate)"
      print(
        "✅ Restore complete: \(studentsRestored) students, \(templatesRestored) templates from snapshot \(snapshotDate)"
      )

    } catch {
      restoreStatus = "Restore failed: \(error.localizedDescription)"
      print("❌ CloudKit restore failed: \(error)")
    }

    isRestoring = false
  }

  /// Fetches student backup records for a specific snapshot date
  private func fetchStudentBackups(snapshotDate: String) async -> [CKRecord] {
    var records: [CKRecord] = []
    let database = container.privateCloudDatabase

    let query = CKQuery(
      recordType: "StudentBackup",
      predicate: NSPredicate(format: "snapshotDate == %@", snapshotDate))
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

  /// Fetches template backup records for a specific snapshot date
  private func fetchTemplateBackups(snapshotDate: String) async -> [CKRecord] {
    var records: [CKRecord] = []
    let database = container.privateCloudDatabase

    let query = CKQuery(
      recordType: "TemplateBackup",
      predicate: NSPredicate(format: "snapshotDate == %@", snapshotDate))
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

  // MARK: - Automatic Backup

  private func startAutomaticBackup() {
    // Check if we need to backup (every 24 hours)
    checkAndPerformAutomaticBackup()

    // Set up timer to check every 6 hours
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

    // Check if we need a backup (at least 24 hours since last backup)
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
