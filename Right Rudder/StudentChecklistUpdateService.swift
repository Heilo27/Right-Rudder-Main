//
//  StudentChecklistUpdateService.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//  Updated for reference-based checklist system
//

import Foundation
import SwiftData

class StudentChecklistUpdateService {
    
    /// Updates all student checklist progress records to match template changes
    static func updateStudentChecklistProgress(modelContext: ModelContext) {
        do {
            // Fetch all student checklist assignment records
            let descriptor = FetchDescriptor<ChecklistAssignment>()
            let assignmentRecords = try modelContext.fetch(descriptor)
            
            var updatedCount = 0
            var skippedCount = 0
            
            for assignment in assignmentRecords {
                // Find the corresponding template
                guard let template = assignment.template else {
                    print("⚠️ No template found for assignment record: \(assignment.displayName)")
                    skippedCount += 1
                    continue
                }
                
                // Sync assignment with template
                let wasUpdated = syncProgressWithTemplate(assignment: assignment, template: template, modelContext: modelContext)
                if wasUpdated {
                    updatedCount += 1
                } else {
                    skippedCount += 1
                }
            }
            
            print("✅ Template sync completed: \(updatedCount) updated, \(skippedCount) skipped")
            
            // Run integrity check after updates
            ChecklistIntegrityService.verifyAndRepairAllChecklists(modelContext: modelContext)
            
        } catch {
            print("❌ Failed to update student checklist progress: \(error)")
        }
    }
    
    /// Syncs an assignment record with its template, adding/removing items as needed
    private static func syncProgressWithTemplate(assignment: ChecklistAssignment, template: ChecklistTemplate, modelContext: ModelContext) -> Bool {
        var wasUpdated = false
        
        // Get current template items
        let templateItems = template.items?.sorted { $0.order < $1.order } ?? []
        
        // Get current progress items
        let currentProgressItems = assignment.itemProgress ?? []
        
        // Create a map of existing progress items by template item ID
        let existingProgressMap = Dictionary(uniqueKeysWithValues: currentProgressItems.map { ($0.templateItemId, $0) })
        
        // Add missing progress items for new template items
        for templateItem in templateItems {
            if existingProgressMap[templateItem.id] == nil {
                let newProgressItem = ItemProgress(
                    templateItemId: templateItem.id
                )
                assignment.itemProgress?.append(newProgressItem)
                wasUpdated = true
                print("➕ Added progress item for template item: \(templateItem.title)")
            }
        }
        
        // Remove orphaned progress items (template items that no longer exist)
        let templateItemIds = Set(templateItems.map { $0.id })
        let progressItemsToRemove = currentProgressItems.filter { !templateItemIds.contains($0.templateItemId) }
        
        for progressItem in progressItemsToRemove {
            if let index = assignment.itemProgress?.firstIndex(where: { $0.id == progressItem.id }) {
                assignment.itemProgress?.remove(at: index)
                modelContext.delete(progressItem)
                wasUpdated = true
                print("➖ Removed orphaned progress item: \(progressItem.templateItemId)")
            }
        }
        
        // Update order values to match template
        for templateItem in templateItems {
            if existingProgressMap[templateItem.id] != nil {
                // Note: ItemProgress doesn't have order field, so we skip this update
                // The order is maintained by the template
            }
        }
        
        // Update last modified
        if wasUpdated {
            assignment.lastModified = Date()
        }
        
        return wasUpdated
    }
    
    /// Adds missing progress items for a specific assignment record
    static func addMissingProgressItems(for assignment: ChecklistAssignment, modelContext: ModelContext) {
        guard let template = assignment.template else { return }
        
        let templateItems = template.items?.sorted { $0.order < $1.order } ?? []
        let currentProgressItems = assignment.itemProgress ?? []
        let existingTemplateItemIds = Set(currentProgressItems.map { $0.templateItemId })
        
        for templateItem in templateItems {
            if !existingTemplateItemIds.contains(templateItem.id) {
                let newProgressItem = ItemProgress(
                    templateItemId: templateItem.id
                )
                assignment.itemProgress?.append(newProgressItem)
                print("➕ Added missing progress item for: \(templateItem.title)")
            }
        }
        
        assignment.lastModified = Date()
    }
    
    /// Removes orphaned progress items for a specific assignment record
    static func removeOrphanedProgressItems(for assignment: ChecklistAssignment, modelContext: ModelContext) {
        guard let template = assignment.template else { return }
        
        let templateItems = template.items ?? []
        let templateItemIds = Set(templateItems.map { $0.id })
        let currentProgressItems = assignment.itemProgress ?? []
        
        let orphanedItems = currentProgressItems.filter { !templateItemIds.contains($0.templateItemId) }
        
        for orphanedItem in orphanedItems {
            if let index = assignment.itemProgress?.firstIndex(where: { $0.id == orphanedItem.id }) {
                assignment.itemProgress?.remove(at: index)
                modelContext.delete(orphanedItem)
                print("➖ Removed orphaned progress item: \(orphanedItem.templateItemId)")
            }
        }
        
        assignment.lastModified = Date()
    }
    
    /// Updates progress records when a template is modified
    static func updateProgressForTemplateChange(template: ChecklistTemplate, modelContext: ModelContext) {
        do {
            // Find all assignment records for this template
            let descriptor = FetchDescriptor<ChecklistAssignment>()
            let allAssignments = try modelContext.fetch(descriptor)
            
            let relevantAssignments = allAssignments.filter { $0.templateId == template.id }
            
            print("🔄 Updating \(relevantAssignments.count) assignment records for template: \(template.name)")
            
            for assignment in relevantAssignments {
                _ = syncProgressWithTemplate(assignment: assignment, template: template, modelContext: modelContext)
            }
            
            // Run integrity check
            ChecklistIntegrityService.verifyAndRepairAllChecklists(modelContext: modelContext)
            
        } catch {
            print("❌ Failed to update progress for template change: \(error)")
        }
    }
    
    /// Checks if a template has been modified since the last assignment update
    static func hasTemplateChanged(template: ChecklistTemplate, assignment: ChecklistAssignment) -> Bool {
        // Compare last modified dates since ChecklistAssignment doesn't have templateVersion
        return template.lastModified > assignment.lastModified
    }
    
    /// Migrates legacy checklist data to the new reference-based system
    static func migrateLegacyChecklists(modelContext: ModelContext) {
        // This function is kept for compatibility but should not be needed
        // since we're implementing the new system directly
        print("ℹ️ Legacy migration not needed - implementing reference-based system directly")
    }
}