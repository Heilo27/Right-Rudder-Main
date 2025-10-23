import Foundation
import CloudKit
import SwiftUI
import SwiftData
import Combine

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
    
    init() {
        self.container = CKContainer(identifier: "iCloud.com.heiloprojects.rightrudder")
        self.database = container.privateCloudDatabase
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
        print("🚀 STARTING SHARE CREATION for student: \(student.displayName)")
        print("  - Student ID: \(student.id)")
        print("  - CloudKit Record ID: \(student.cloudKitRecordID ?? "none")")
        print("  - Container: \(container.containerIdentifier ?? "unknown")")
        print("  - Database: \(database.databaseScope.rawValue)")
        isSharing = true
        errorMessage = nil
        
        do {
            // Check CloudKit availability first
            print("🔍 Checking CloudKit account status...")
            let accountStatus = try await container.accountStatus()
            print("✅ CloudKit account status: \(accountStatus.rawValue)")
            
            guard accountStatus == .available else {
                print("❌ CloudKit account not available: \(accountStatus.rawValue)")
                errorMessage = "iCloud account not available. Please sign in to iCloud in Settings."
                isSharing = false
                return nil
            }
            
            print("Creating share for student: \(student.displayName)")
            
            // Ensure custom zone exists (required for sharing)
            let customZone = try await ensureCustomZoneExists()
            print("Using custom zone: \(customZone.zoneID.zoneName)")
            
            // Create student record ID in the custom zone
            let studentRecordID = CKRecord.ID(recordName: student.id.uuidString, zoneID: customZone.zoneID)
            
            // Try to fetch existing record or create new one
            let studentRecord: CKRecord
            if let existingRecord = try? await database.record(for: studentRecordID) {
                print("Found existing student record in custom zone")
                studentRecord = existingRecord
                
                // Check if share already exists
                if let existingShare = studentRecord.share {
                    print("Share already exists, fetching it")
                    let shareRecord = try await database.record(for: existingShare.recordID)
                    if let share = shareRecord as? CKShare {
                        shareURL = share.url
                        isSharing = false
                        print("Returning existing share URL: \(share.url?.absoluteString ?? "nil")")
                        return share.url
                    }
                }
            } else {
                print("Creating new student record in custom zone")
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
                
                // Save the record first to the custom zone
                print("Saving student record to custom zone in CloudKit")
                let savedRecord = try await database.save(studentRecord)
                print("Student record saved successfully to custom zone")
                
                // Use the saved record for sharing
                studentRecord.setValuesForKeys(savedRecord.dictionaryWithValues(forKeys: Array(savedRecord.allKeys())))
            }
            
            // Create a new share
            print("Creating new share")
            let share = CKShare(rootRecord: studentRecord)
            
            // Configure share permissions
            share[CKShare.SystemFieldKey.title] = "Student Profile: \(student.displayName)" as CKRecordValue
            share[CKShare.SystemFieldKey.shareType] = "com.apple.cloudkit.share" as CKRecordValue
            
            // Add version information to help with compatibility
            share["appVersion"] = "1.5" as CKRecordValue
            share["appIdentifier"] = "com.heiloprojects.rightrudder.student" as CKRecordValue
            
            print("Using Apple CloudKit share type: com.apple.cloudkit.share")
            print("Added version info: 1.5")
            
            // CRITICAL: Set public permission to readOnly to allow share URL access
            share.publicPermission = .readOnly  // Change from .none to .readOnly
            
            print("Share configuration:")
            print("  - Public Permission: \(share.publicPermission.rawValue)")
            print("  - Root Record: \(studentRecord.recordID.recordName)")
            print("  - Zone: \(studentRecord.recordID.zoneID.zoneName)")
            
            print("Saving share and record together")
            // Save both the share and the record using the modify API
            let modifyResult = try await database.modifyRecords(
                saving: [studentRecord, share],
                deleting: [],
                savePolicy: .changedKeys
            )
            
            print("Save completed, processing results...")
            
            // Get the saved records from the result
            var savedShare: CKShare?
            for (recordID, result) in modifyResult.saveResults {
                switch result {
                case .success(let record):
                    print("Saved record: \(recordID.recordName), type: \(type(of: record))")
                    if let share = record as? CKShare {
                        savedShare = share
                        print("Found saved share!")
                    }
                case .failure(let error):
                    print("❌ Failed to save record \(recordID.recordName): \(error)")
                    if let ckError = error as? CKError {
                        print("CloudKit error details:")
                        print("  - Error Code: \(ckError.errorCode)")
                        print("  - Description: \(ckError.localizedDescription)")
                        print("  - Retry After: \(ckError.retryAfterSeconds ?? 0)")
                        if let underlyingError = ckError.errorUserInfo[NSUnderlyingErrorKey] as? Error {
                            print("  - Underlying error: \(underlyingError)")
                        }
                        if let partialErrors = ckError.partialErrorsByItemID {
                            print("  - Partial errors: \(partialErrors)")
                        }
                    }
                    throw error // Re-throw to stop share creation if save fails
                }
            }
            
            // Use the share we just created if we can't find it in results
            if savedShare == nil {
                print("Share not in results, using original share object")
                savedShare = share
            }
            
            guard let finalShare = savedShare, let shareURL = finalShare.url else {
                throw NSError(domain: "CloudKitShareService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Share was saved but has no URL"])
            }
            
            print("Share URL: \(shareURL.absoluteString)")
            print("Share Record ID: \(finalShare.recordID.recordName)")
            print("Share Zone: \(finalShare.recordID.zoneID.zoneName)")
            print("Share Public Permission: \(finalShare.publicPermission)")
            print("Share Participants: \(finalShare.participants.count)")
            
            // Additional debugging information
            print("=== SHARE DEBUG INFO ===")
            print("Student Record ID: \(studentRecord.recordID.recordName)")
            print("Student Record Zone: \(studentRecord.recordID.zoneID.zoneName)")
            print("Share Title: \(finalShare[CKShare.SystemFieldKey.title] as? String ?? "No title")")
            print("Share Type: \(finalShare[CKShare.SystemFieldKey.shareType] as? String ?? "No type")")
            print("=========================")
            
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
}

