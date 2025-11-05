import Foundation
import SwiftData

class ChecklistAssignmentService {
    
    /// Assign a template to a student using new library-based system
    static func assignTemplate(_ template: ChecklistTemplate, to student: Student, modelContext: ModelContext) {
        // Check if already assigned
        let existingAssignment = student.checklistAssignments?.first { 
            $0.templateId == template.id 
        }
        
        if existingAssignment != nil {
            print("Template \(template.name) already assigned to student \(student.displayName)")
            return
        }
        
        // Get the correct template ID for CloudKit sync
        let templateId: UUID
        if let templateIdentifier = template.templateIdentifier {
            // For default templates, must use TemplateIDMappingService
            if let mappedId = TemplateIDMappingService.getTemplateID(for: templateIdentifier) {
                templateId = mappedId
                print("✅ Using mapped template ID for default template: \(templateIdentifier) -> \(mappedId)")
            } else {
                print("❌ ERROR: Default template '\(template.name)' has templateIdentifier '\(templateIdentifier)' but no mapping found in TemplateIDMappingService")
                print("   This indicates a missing mapping - template will not sync correctly to student app")
                // Still use template.id as fallback, but log the error
                templateId = template.id
            }
        } else {
            // For custom templates (no templateIdentifier), use template.id
            templateId = template.id
            print("📝 Using template.id for custom template: \(template.name) -> \(template.id)")
        }
        
        // Create new assignment record
        // NOTE: This assignment record acts as the "progress file" that will be synced to student app.
        // It only contains:
        // - templateId (reference to lesson in both apps' internal libraries)
        // - instructorComments, dualGivenHours, assignedAt
        // - ItemProgress records (one per item) containing check-offs, notes, completedAt
        // The full lesson definition is NOT synced - both apps already have it in their libraries.
        let assignment = ChecklistAssignment(
            templateId: templateId,
            templateIdentifier: template.templateIdentifier,
            isCustomChecklist: template.templateIdentifier == nil
        )
        
        // CRITICAL: Create ItemProgress records for ALL template items immediately when assigning.
        // These records act as the "progress file" that tracks:
        // - isComplete (check-offs)
        // - notes (instructor comments)
        // - completedAt (when checked)
        // - dualGivenHours and instructorComments are stored on the assignment itself
        // This ensures the student app can show the lesson and all progress immediately.
        if let templateItems = template.items {
            var itemProgressArray: [ItemProgress] = []
            
            for (index, templateItem) in templateItems.enumerated() {
                // Get the correct template item ID for CloudKit sync
                let templateItemId: UUID
                if let templateIdentifier = template.templateIdentifier {
                    // For default templates, must use TemplateIDMappingService
                    if let mappedItemIDs = TemplateIDMappingService.getTemplateItemIDs(for: templateIdentifier),
                       index < mappedItemIDs.count {
                        templateItemId = mappedItemIDs[index]
                        print("✅ Using mapped item ID for default template item: \(templateItem.title) -> \(templateItemId)")
                    } else {
                        print("❌ ERROR: Default template '\(template.name)' item '\(templateItem.title)' (index \(index)) has no mapping in TemplateIDMappingService")
                        print("   This indicates a missing mapping - item will not sync correctly to student app")
                        // Still use templateItem.id as fallback, but log the error
                        templateItemId = templateItem.id
                    }
                } else {
                    // For custom templates (no templateIdentifier), use templateItem.id
                    templateItemId = templateItem.id
                    print("📝 Using templateItem.id for custom template item: \(templateItem.title) -> \(templateItemId)")
                }
                
                // Create ItemProgress record and set relationships explicitly
                let itemProgress = ItemProgress(templateItemId: templateItemId)
                itemProgress.assignment = assignment
                itemProgressArray.append(itemProgress)
                modelContext.insert(itemProgress)
                print("✅ Created ItemProgress record for templateItemId: \(templateItemId)")
            }
            
            assignment.itemProgress = itemProgressArray
        } else {
            // Initialize empty array if no template items
            assignment.itemProgress = []
        }
        
        // Set relationships
        assignment.student = student
        assignment.template = template
        
        // Initialize checklistAssignments array if nil
        if student.checklistAssignments == nil {
            student.checklistAssignments = []
        }
        student.checklistAssignments?.append(assignment)
        
        // Update template's student assignment tracking
        if template.studentAssignments == nil {
            template.studentAssignments = []
        }
        template.studentAssignments?.append(assignment)
        
        // Debug: Verify relationships are set
        print("🔗 Assignment verification:")
        print("   Assignment.template: \(assignment.template?.name ?? "nil")")
        print("   Assignment.templateId: \(assignment.templateId)")
        print("   Template.id: \(template.id)")
        print("   Template.name: \(template.name)")
        
        // Save
        do {
            try modelContext.save()
            print("Assigned template \(template.name) to student \(student.displayName)")
        } catch {
            print("Failed to assign template: \(error)")
        }
    }
    
    /// Remove template assignment from student
    static func removeTemplate(_ template: ChecklistTemplate, from student: Student, modelContext: ModelContext) {
        guard let assignment = student.checklistAssignments?.first(where: { $0.templateId == template.id }) else {
            return
        }
        
        // Remove from student
        student.checklistAssignments?.removeAll { $0.id == assignment.id }
        
        // Remove from template
        template.studentAssignments?.removeAll { $0.id == assignment.id }
        
        // Delete the assignment record
        modelContext.delete(assignment)
        
        do {
            try modelContext.save()
            print("Removed template \(template.name) from student \(student.displayName)")
        } catch {
            print("Failed to remove template: \(error)")
        }
    }
    
    /// Get display items for a student's checklist assignment
    static func getDisplayItems(for assignment: ChecklistAssignment) -> [DisplayChecklistItem] {
        guard let template = assignment.template,
              let templateItems = template.items else {
            return []
        }
        
        return templateItems.compactMap { templateItem in
            let itemProgress = assignment.itemProgress?.first { 
                $0.templateItemId == templateItem.id 
            }
            
            return DisplayChecklistItem(
                templateItemId: templateItem.id,
                title: templateItem.title,
                notes: templateItem.notes,
                order: templateItem.order,
                isComplete: itemProgress?.isComplete ?? false,
                studentNotes: itemProgress?.notes,
                completedAt: itemProgress?.completedAt
            )
        }.sorted { $0.order < $1.order }
    }
    
    /// Update item completion status
    static func updateItemCompletion(_ assignment: ChecklistAssignment, templateItemId: UUID, isComplete: Bool, notes: String? = nil, modelContext: ModelContext) {
        guard let itemProgress = assignment.itemProgress?.first(where: { $0.templateItemId == templateItemId }) else {
            return
        }
        
        itemProgress.isComplete = isComplete
        itemProgress.notes = notes
        itemProgress.lastModified = Date()
        
        if isComplete {
            itemProgress.completedAt = Date()
        } else {
            itemProgress.completedAt = nil
        }
        
        assignment.lastModified = Date()
        
        do {
            try modelContext.save()
            
            // Post notification that a checklist item was completed
            NotificationCenter.default.post(name: Notification.Name("checklistItemCompleted"), object: nil)
            print("📢 Posted checklistItemCompleted notification")
            
            // Sync ItemProgress to CloudKit shared zone if student has active share
            // This syncs ONLY the changed item, not all items (for performance)
            // CRITICAL: Only sync if student has actually accepted the share
            if let student = assignment.student {
                Task {
                    let shareService = CloudKitShareService()
                    let hasActive = await shareService.hasActiveShare(for: student)
                    if hasActive {
                        await shareService.syncSingleItemProgressToSharedZone(
                            itemProgress: itemProgress,
                            assignment: assignment,
                            student: student
                        )
                    }
                }
            }
        } catch {
            print("Failed to update item completion: \(error)")
        }
    }
    
    /// Repair broken template relationships for a student's checklist assignments
    static func repairTemplateRelationships(for student: Student, modelContext: ModelContext) {
        guard let assignmentArray = student.checklistAssignments else { return }
        
        for assignment in assignmentArray {
            if assignment.template == nil {
                print("🔧 Repairing template relationship for assignment: \(assignment.templateId)")
                
                // Try to find template by ID
                let request = FetchDescriptor<ChecklistTemplate>()
                
                do {
                    let templates = try modelContext.fetch(request)
                    if let template = templates.first(where: { $0.id == assignment.templateId }) {
                        assignment.template = template
                        print("✅ Repaired template relationship: \(template.name)")
                    } else {
                        print("❌ Template not found for ID: \(assignment.templateId)")
                    }
                } catch {
                    print("❌ Failed to fetch template for repair: \(error)")
                }
            }
        }
        
        do {
            try modelContext.save()
            print("✅ Template relationships repaired and saved")
        } catch {
            print("❌ Failed to save repaired relationships: \(error)")
        }
    }
}

// Helper struct for display
struct DisplayChecklistItem {
    let templateItemId: UUID
    let title: String
    let notes: String?
    let order: Int
    let isComplete: Bool
    let studentNotes: String?
    let completedAt: Date?
}
