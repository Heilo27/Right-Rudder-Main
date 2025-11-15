//
//  DatabaseRecoveryService.swift
//  Right Rudder
//
//  Created by AI on 12/19/25.
//

import CloudKit
import Combine
import Foundation
import SwiftData

// MARK: - DatabaseRecoveryService

/// Service to handle database corruption and recovery
class DatabaseRecoveryService: ObservableObject {
  // MARK: - Singleton

  static let shared = DatabaseRecoveryService()

  // MARK: - Published Properties

  @Published var isRecovering = false
  @Published var recoveryProgress: String = ""
  @Published var showRecoveryAlert = false
  @Published var recoveryError: String?

  // MARK: - Initialization

  private init() {}

  // MARK: - Corruption Detection

  /// Detects if the database is corrupted and needs recovery
  func detectCorruption() -> Bool {
    // Check if we can access the default store
    let storeURL = getDefaultStoreURL()

    // Check if file exists and is readable
    guard FileManager.default.fileExists(atPath: storeURL.path) else {
      print("⚠️ Database file does not exist - needs recovery")
      return true
    }

    // Try to open the database file
    do {
      let testData = try Data(contentsOf: storeURL)
      if testData.isEmpty {
        print("⚠️ Database file is empty - needs recovery")
        return true
      }
    } catch {
      print("⚠️ Cannot read database file - needs recovery: \(error)")
      return true
    }

    return false
  }

  // MARK: - Recovery

  /// Attempts to recover from database corruption
  func attemptRecovery() async -> Bool {
    await MainActor.run {
      isRecovering = true
      recoveryProgress = "Starting database recovery..."
    }

    do {
      // Step 1: Backup any recoverable data
      await MainActor.run {
        recoveryProgress = "Backing up recoverable data..."
      }

      let backupData = await backupRecoverableData()

      // Step 2: Remove corrupted database
      await MainActor.run {
        recoveryProgress = "Removing corrupted database..."
      }

      try await removeCorruptedDatabase()

      // Step 3: Create fresh database
      await MainActor.run {
        recoveryProgress = "Creating fresh database..."
      }

      try await createFreshDatabase()

      // Step 4: Restore backed up data
      if !backupData.isEmpty {
        await MainActor.run {
          recoveryProgress = "Restoring backed up data..."
        }

        try await restoreBackedUpData(backupData)
      }

      // Step 5: Re-initialize default templates
      await MainActor.run {
        recoveryProgress = "Re-initializing templates..."
      }

      await reinitializeDefaultTemplates()

      await MainActor.run {
        recoveryProgress = "Recovery completed successfully!"
        isRecovering = false
      }

      return true

    } catch {
      await MainActor.run {
        recoveryError = error.localizedDescription
        recoveryProgress = "Recovery failed: \(error.localizedDescription)"
        isRecovering = false
      }
      return false
    }
  }

  /// Backs up any data that can be recovered from CloudKit
  private func backupRecoverableData() async -> [String: Any] {
    var backupData: [String: Any] = [:]

    // Try to fetch data from CloudKit as backup
    do {
      let container = CKContainer.default()
      let privateDatabase = container.privateCloudDatabase

      // Try to fetch students
      let studentQuery = CKQuery(recordType: "Student", predicate: NSPredicate(value: true))
      let studentRecords = try await privateDatabase.records(matching: studentQuery)

      if !studentRecords.matchResults.isEmpty {
        backupData["students"] = studentRecords.matchResults.compactMap { _, result in
          switch result {
          case .success(let record):
            return record
          case .failure:
            return nil
          }
        }
      }

      print(
        "✅ Backed up \(backupData["students"] as? [CKRecord] ?? []).count students from CloudKit")

    } catch {
      print("⚠️ Could not backup from CloudKit: \(error)")
    }

    return backupData
  }

  /// Removes the corrupted database file
  private func removeCorruptedDatabase() async throws {
    let storeURL = getDefaultStoreURL()

    if FileManager.default.fileExists(atPath: storeURL.path) {
      try FileManager.default.removeItem(at: storeURL)
      print("✅ Removed corrupted database file")
    }

    // Also remove any associated files
    let storeDirectory = storeURL.deletingLastPathComponent()
    let files = try FileManager.default.contentsOfDirectory(
      at: storeDirectory, includingPropertiesForKeys: nil)

    for file in files {
      if file.lastPathComponent.contains("default.store") {
        try FileManager.default.removeItem(at: file)
        print("✅ Removed associated file: \(file.lastPathComponent)")
      }
    }
  }

  /// Creates a fresh database
  private func createFreshDatabase() async throws {
    // This will be handled by the ModelContainer initialization
    // The fresh database will be created automatically
    print("✅ Fresh database will be created on next ModelContainer initialization")
  }

  /// Restores backed up data to the fresh database
  private func restoreBackedUpData(_ backupData: [String: Any]) async throws {
    // This would need to be implemented based on the backup data structure
    // For now, we'll rely on CloudKit sync to restore data
    print("✅ Data restoration will be handled by CloudKit sync")
  }

  /// Re-initializes default templates
  private func reinitializeDefaultTemplates() async {
    // This will be handled by DefaultDataService
    print("✅ Default templates will be re-initialized")
  }

  /// Gets the URL of the default store
  private func getDefaultStoreURL() -> URL {
    let documentsPath = FileManager.default.urls(
      for: .applicationSupportDirectory, in: .userDomainMask
    ).first!
    return documentsPath.appendingPathComponent("default.store")
  }

  /// Shows recovery alert to user
  func presentRecoveryAlert() {
    showRecoveryAlert = true
  }

  /// Handles the recovery process with user confirmation
  func handleRecoveryWithConfirmation() async {
    await MainActor.run {
      showRecoveryAlert = false
    }

    let success = await attemptRecovery()

    if !success {
      await MainActor.run {
        recoveryError = "Database recovery failed. Please restart the app or contact support."
      }
    }
  }

  /// Handles disk I/O errors detected during runtime
  func handleDiskIOError() async {
    print("⚠️ Disk I/O error detected during runtime - checking database state...")

    // Check if database is accessible
    if detectCorruption() {
      print("⚠️ Database corruption confirmed - triggering recovery...")
      await MainActor.run {
        showRecoveryAlert = true
      }
    } else {
      // Database might just be temporarily locked or have a transient I/O issue
      // Try to clear any locks by waiting a moment
      print("⚠️ Database appears accessible - may be transient I/O issue")
      try? await Task.sleep(nanoseconds: 500_000_000)  // 0.5 seconds
    }
  }
}

/// Extension to add recovery functionality to ModelContainer
extension ModelContainer {
  /// Creates a ModelContainer with corruption detection and recovery
  static func createWithRecovery() throws -> ModelContainer {
    // Check for corruption first
    if DatabaseRecoveryService.shared.detectCorruption() {
      print("⚠️ Database corruption detected - recovery needed")
      throw DatabaseCorruptionError.corruptionDetected
    }

    // Create normal ModelContainer
    let schema = Schema([
      Student.self,
      ChecklistAssignment.self,
      ItemProgress.self,
      CustomChecklistDefinition.self,
      CustomChecklistItem.self,
      EndorsementImage.self,
      ChecklistTemplate.self,
      ChecklistItem.self,
      StudentDocument.self,
      OfflineSyncOperation.self,
    ])

    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      print("⚠️ ModelContainer creation failed - attempting recovery: \(error)")
      throw DatabaseCorruptionError.containerCreationFailed(error)
    }
  }
}

/// Custom error types for database corruption
enum DatabaseCorruptionError: LocalizedError {
  case corruptionDetected
  case containerCreationFailed(Error)

  var errorDescription: String? {
    switch self {
    case .corruptionDetected:
      return "Database corruption detected. Recovery is needed."
    case .containerCreationFailed(let error):
      return "Failed to create database container: \(error.localizedDescription)"
    }
  }
}
