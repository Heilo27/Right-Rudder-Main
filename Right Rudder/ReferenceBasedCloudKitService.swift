import Foundation
import CloudKit
import SwiftData

class ReferenceBasedCloudKitService {
    
    private let container: CKContainer
    private let database: CKDatabase
    private let customZoneName = "SharedStudentsZone"
    
    init() {
        self.container = CKContainer(identifier: "iCloud.com.heiloprojects.rightrudder")
        self.database = container.privateCloudDatabase
    }
    
    /// Sync student checklist assignment to CloudKit for student app compatibility
    func syncStudentChecklistProgress(_ assignment: ChecklistAssignment, student: Student, customZone: CKRecordZone) async {
        do {
            // Create record ID in custom zone
            let recordID = CKRecord.ID(recordName: assignment.id.uuidString, zoneID: customZone.zoneID)
            let existingRecord = try? await database.record(for: recordID)
            
            let record: CKRecord
            if let existing = existingRecord {
                record = existing
            } else {
                record = CKRecord(recordType: "ChecklistAssignment", recordID: recordID)
            }
            
            // Update record with checklist data (CloudKit compatibility)
            record["templateId"] = assignment.templateId.uuidString
            record["templateName"] = assignment.displayName
            record["templateIdentifier"] = assignment.templateIdentifier
            record["instructorComments"] = assignment.instructorComments
            record["studentId"] = student.id.uuidString
            record["lastModified"] = assignment.lastModified
            record["dualGivenHours"] = assignment.dualGivenHours
            record["isComplete"] = assignment.isComplete
            record["completionPercentage"] = assignment.progressPercentage
            record["completedItemsCount"] = assignment.completedItemsCount
            record["totalItemsCount"] = assignment.totalItemsCount
            
            // Set parent reference to student record for sharing
            let studentRecordID = CKRecord.ID(recordName: student.id.uuidString, zoneID: customZone.zoneID)
            record.parent = CKRecord.Reference(recordID: studentRecordID, action: .none)
            
            let savedRecord = try await database.save(record)
            assignment.cloudKitRecordID = savedRecord.recordID.recordName
            assignment.lastModified = Date()
            
            // Sync checklist items
            await syncChecklistItemProgress(assignment, customZone: customZone)
            
        } catch {
            print("Failed to sync checklist progress \(assignment.displayName) to shared zone: \(error)")
        }
    }
    
    /// Sync checklist item progress to CloudKit
    private func syncChecklistItemProgress(_ assignment: ChecklistAssignment, customZone: CKRecordZone) async {
        guard let itemProgress = assignment.itemProgress else { return }
        
        for item in itemProgress {
            do {
                let recordID = CKRecord.ID(recordName: item.id.uuidString, zoneID: customZone.zoneID)
                let existingRecord = try? await database.record(for: recordID)
                
                let record: CKRecord
                if let existing = existingRecord {
                    record = existing
                } else {
                    record = CKRecord(recordType: "ItemProgress", recordID: recordID)
                }
                
                // Update record with item data
                record["templateItemId"] = item.templateItemId.uuidString
                record["title"] = item.displayTitle
                record["isComplete"] = item.isComplete
                record["notes"] = item.notes
                record["completedAt"] = item.completedAt
                record["lastModified"] = item.lastModified
                
                // Set parent reference to assignment record
                let assignmentRecordID = CKRecord.ID(recordName: assignment.id.uuidString, zoneID: customZone.zoneID)
                record.parent = CKRecord.Reference(recordID: assignmentRecordID, action: .none)
                
                let savedRecord = try await database.save(record)
                item.cloudKitRecordID = savedRecord.recordID.recordName
                item.lastModified = Date()
                
            } catch {
                print("Failed to sync checklist item \(item.id) to shared zone: \(error)")
            }
        }
    }
    
    /// Sync template to shared zone for student app access
    func syncTemplateToSharedZone(_ template: ChecklistTemplate, customZone: CKRecordZone) async {
        do {
            let recordID = CKRecord.ID(recordName: template.id.uuidString, zoneID: customZone.zoneID)
            let existingRecord = try? await database.record(for: recordID)
            
            let record: CKRecord
            if let existing = existingRecord {
                record = existing
            } else {
                record = CKRecord(recordType: "ChecklistTemplate", recordID: recordID)
            }
            
            // Update record with template data
            record["name"] = template.name
            record["category"] = template.category
            record["phase"] = template.phase
            record["relevantData"] = template.relevantData
            record["templateIdentifier"] = template.templateIdentifier
            record["contentHash"] = template.contentHash
            record["lastModified"] = template.lastModified
            
            let savedRecord = try await database.save(record)
            template.shareRecordID = savedRecord.recordID.recordName
            template.lastModified = Date()
            
            // Sync template items
            await syncTemplateItems(template, customZone: customZone)
            
        } catch {
            print("Failed to sync template \(template.name) to shared zone: \(error)")
        }
    }
    
    /// Sync template items to shared zone
    private func syncTemplateItems(_ template: ChecklistTemplate, customZone: CKRecordZone) async {
        guard let items = template.items else { return }
        
        for item in items {
            do {
                let recordID = CKRecord.ID(recordName: item.id.uuidString, zoneID: customZone.zoneID)
                let existingRecord = try? await database.record(for: recordID)
                
                let record: CKRecord
                if let existing = existingRecord {
                    record = existing
                } else {
                    record = CKRecord(recordType: "ChecklistItem", recordID: recordID)
                }
                
                // Update record with item data
                record["title"] = item.title
                record["notes"] = item.notes
                record["order"] = item.order
                record["lastModified"] = item.lastModified
                
                // Set parent reference to template record
                let templateRecordID = CKRecord.ID(recordName: template.id.uuidString, zoneID: customZone.zoneID)
                record.parent = CKRecord.Reference(recordID: templateRecordID, action: .none)
                
                let savedRecord = try await database.save(record)
                item.cloudKitRecordID = savedRecord.recordID.recordName
                item.lastModified = Date()
                
            } catch {
                print("Failed to sync template item \(item.id) to shared zone: \(error)")
            }
        }
    }
    
    /// Sync all student data to shared zone for student app access
    func syncStudentToSharedZone(_ student: Student, modelContext: ModelContext) async {
        do {
            // Ensure custom zone exists
            let zoneID = CKRecordZone.ID(zoneName: customZoneName, ownerName: CKCurrentUserDefaultName)
            let customZone = try await database.recordZone(for: zoneID)
            
            // Sync student record
            await syncStudentRecord(student, customZone: customZone)
            
            // Sync all checklist assignments
            if let assignments = student.checklistAssignments {
                for assignment in assignments {
                    await syncStudentChecklistProgress(assignment, student: student, customZone: customZone)
                    
                    // Sync template if not already synced
                    if let template = assignment.template {
                        await syncTemplateToSharedZone(template, customZone: customZone)
                    }
                }
            }
            
            // Sync documents
            if let documents = student.documents {
                for document in documents {
                    await syncStudentDocument(document, student: student, customZone: customZone)
                }
            }
            
        } catch {
            print("Failed to sync student \(student.displayName) to shared zone: \(error)")
        }
    }
    
    /// Sync student record to shared zone
    private func syncStudentRecord(_ student: Student, customZone: CKRecordZone) async {
        do {
            let recordID = CKRecord.ID(recordName: student.id.uuidString, zoneID: customZone.zoneID)
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
            record["assignedCategory"] = student.assignedCategory
            record["isInactive"] = student.isInactive
            record["lastModified"] = student.lastModified
            
            let savedRecord = try await database.save(record)
            student.shareRecordID = savedRecord.recordID.recordName
            student.lastModified = Date()
            
        } catch {
            print("Failed to sync student record \(student.displayName) to shared zone: \(error)")
        }
    }
    
    /// Sync student document to shared zone
    private func syncStudentDocument(_ document: StudentDocument, student: Student, customZone: CKRecordZone) async {
        do {
            let recordID = CKRecord.ID(recordName: document.id.uuidString, zoneID: customZone.zoneID)
            let existingRecord = try? await database.record(for: recordID)
            
            let record: CKRecord
            if let existing = existingRecord {
                record = existing
            } else {
                record = CKRecord(recordType: "StudentDocument", recordID: recordID)
            }
            
            // Update record with document data
            record["documentType"] = document.documentTypeRaw
            record["filename"] = document.filename
            record["fileData"] = document.fileData
            record["uploadedAt"] = document.uploadedAt
            record["expirationDate"] = document.expirationDate
            record["notes"] = document.notes
            record["lastModified"] = document.lastModified
            
            // Set parent reference to student record
            let studentRecordID = CKRecord.ID(recordName: student.id.uuidString, zoneID: customZone.zoneID)
            record.parent = CKRecord.Reference(recordID: studentRecordID, action: .none)
            
            let savedRecord = try await database.save(record)
            document.cloudKitRecordID = savedRecord.recordID.recordName
            document.lastModified = Date()
            
        } catch {
            print("Failed to sync document \(document.filename) to shared zone: \(error)")
        }
    }
}
