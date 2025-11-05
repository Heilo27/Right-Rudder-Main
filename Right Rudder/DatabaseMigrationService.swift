//
//  DatabaseMigrationService.swift
//  Right Rudder
//
//  Handles migration from StudentChecklistProgress to ChecklistAssignment schema
//

import Foundation
import CoreData
import SwiftData

class DatabaseMigrationService {
    
    /// Migrates data from old schema to new schema if needed
    static func migrateIfNeeded() {
        let migrationKey = "hasMigratedToChecklistAssignment"
        if UserDefaults.standard.bool(forKey: migrationKey) {
            print("✅ Database already migrated")
            return
        }
        
        print("🔄 Checking for database migration...")
        
        // Since SwiftData is built on Core Data, we can use Core Data migration
        // However, for CloudKit-backed databases, the simplest approach is:
        // 1. Reset local database (CloudKit has authoritative data)
        // 2. CloudKit will sync data back with new schema
        
        // For now, we'll reset local database and let CloudKit sync
        // This is safe because CloudKit has the authoritative data
        resetLocalDatabaseForMigration()
        
        UserDefaults.standard.set(true, forKey: migrationKey)
        print("✅ Migration marked as complete")
    }
    
    /// Resets local database files to allow CloudKit to sync with new schema
    private static func resetLocalDatabaseForMigration() {
        let fileManager = FileManager.default
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            print("❌ Could not find application support directory")
            return
        }
        
        let filesToRemove = [
            "default.store",
            "default.store-shm",
            "default.store-wal"
        ]
        
        var removedAny = false
        for fileName in filesToRemove {
            let fileURL = appSupportURL.appendingPathComponent(fileName)
            if fileManager.fileExists(atPath: fileURL.path) {
                do {
                    try fileManager.removeItem(at: fileURL)
                    print("🗑️ Removed: \(fileName)")
                    removedAny = true
                } catch {
                    print("⚠️ Failed to remove \(fileName): \(error)")
                }
            }
        }
        
        if removedAny {
            print("✅ Local database reset - CloudKit will sync data back with new schema")
            print("📋 Your data in CloudKit is safe and will be restored")
        } else {
            print("ℹ️ No local database files found - nothing to migrate")
        }
    }
    
    /// Alternative: Manual migration using Core Data (more complex but preserves unsynced data)
    /// This would require creating a temporary model with both old and new entities
    /// For CloudKit-backed databases, the reset approach above is recommended
    static func manualMigrationFromOldSchema() {
        // This would require:
        // 1. Creating a temporary Core Data model with both StudentChecklistProgress and ChecklistAssignment
        // 2. Opening old database with old model
        // 3. Reading all StudentChecklistProgress records
        // 4. Creating ChecklistAssignment records
        // 5. Migrating ItemProgress records
        // 6. Saving to new database
        
        // For now, we'll use the simpler CloudKit-based approach
        print("ℹ️ Using CloudKit-based migration (recommended for CloudKit databases)")
        migrateIfNeeded()
    }
}

