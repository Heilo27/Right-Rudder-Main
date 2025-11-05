//
//  SmartTemplateUpdateService.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation
import SwiftData

class SmartTemplateUpdateService {
    
    static let templateVersion = "1.4.7.13" // Increment this when templates change (bumped to force reinitialize with UUID mappings)
    private static var isUpdating = false // Prevent concurrent updates
    
    /// Force update all templates (useful for debugging or major changes)
    static func forceUpdateAllTemplates(modelContext: ModelContext) {
        print("Force updating all templates...")
        
        // Clear the version check to force update
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "lastTemplateUpdateVersion")
        
        // Run the update
        updateDefaultTemplates(modelContext: modelContext)
    }
    
    /// Updates default templates while preserving user customizations
    static func updateDefaultTemplates(modelContext: ModelContext) {
        // Prevent concurrent updates
        guard !isUpdating else {
            print("Template update already in progress, skipping...")
            return
        }
        
        isUpdating = true
        defer { isUpdating = false }
        
        do {
            // Check if we've already updated to this version
            let userDefaults = UserDefaults.standard
            let lastUpdateVersion = userDefaults.string(forKey: "lastTemplateUpdateVersion")
            
            // Fetch all existing templates BEFORE version check to verify templates actually exist
            let descriptor = FetchDescriptor<ChecklistTemplate>()
            let existingTemplates = try modelContext.fetch(descriptor)
            
            // On first launch, there may be no templates even if version matches (fresh install)
            let defaultTemplatesExist = existingTemplates.contains { $0.templateIdentifier != nil }
            
            if lastUpdateVersion == templateVersion && defaultTemplatesExist {
                print("Templates already up to date (version \(templateVersion)) and exist in database")
                return
            }
            
            print("Updating templates from version \(lastUpdateVersion ?? "unknown") to \(templateVersion)")
            if !defaultTemplatesExist {
                print("⚠️ No default templates found in database, initializing all templates...")
            }
            
            // Delete ALL templates with templateIdentifier (default templates)
            // This ensures a clean slate for default templates
            let defaultTemplatesToDelete = existingTemplates.filter { $0.templateIdentifier != nil }
            
            for template in defaultTemplatesToDelete {
                modelContext.delete(template)
            }
            
            // Get all new default templates
            let newTemplates = getAllDefaultTemplates()
            
            var addedCount = 0
            
            for newTemplate in newTemplates {
                guard let templateIdentifier = newTemplate.templateIdentifier else {
                    continue
                }
                
                // Assign the correct UUID from the mapping service for central library compatibility
                if let mappedID = TemplateIDMappingService.getTemplateID(for: templateIdentifier) {
                    newTemplate.id = mappedID
                    print("✅ Using mapped UUID for template: \(templateIdentifier) -> \(mappedID)")
                } else {
                    print("⚠️ No UUID mapping found for template: \(templateIdentifier), using generated UUID")
                }
                
                // Assign correct UUIDs to items for central library compatibility
                // AND ensure items are properly set up before checking for existing templates
                if let itemIDs = TemplateIDMappingService.getTemplateItemIDs(for: templateIdentifier),
                   let items = newTemplate.items {
                    for (index, item) in items.enumerated() {
                        if index < itemIDs.count {
                            item.id = itemIDs[index]
                        }
                        // Ensure item's template relationship is set
                        item.template = newTemplate
                    }
                    print("✅ Configured \(items.count) items for template: \(templateIdentifier)")
                } else {
                    print("⚠️ No item IDs mapping found for template: \(templateIdentifier)")
                }
                
                // Check if template with this ID already exists
                let existingTemplateByID = existingTemplates.first { $0.id == newTemplate.id }
                
                if existingTemplateByID != nil {
                    // Update existing template instead of creating new one
                    if let existing = existingTemplateByID {
                        updateTemplate(existing, with: newTemplate, modelContext: modelContext)
                        print("✅ Updated existing template: \(templateIdentifier)")
                        addedCount += 1
                        continue
                    }
                }
                
                // Check if there's already a user-customized template with this identifier
                let existingUserTemplate = existingTemplates.first { template in
                    return template.templateIdentifier == templateIdentifier && 
                           (template.isUserCreated || template.isUserModified)
                }
                
                if existingUserTemplate != nil {
                    continue
                }
                
                // Insert template AND all its items into the model context
                modelContext.insert(newTemplate)
                if let items = newTemplate.items {
                    for item in items {
                        modelContext.insert(item)
                    }
                }
                addedCount += 1
                print("✅ Inserted new template: \(templateIdentifier) with ID: \(newTemplate.id), items: \(newTemplate.items?.count ?? 0)")
            }
            
            // Clean up any duplicate items that might have accumulated
            cleanupDuplicateItems(modelContext: modelContext)
            
            // Save changes
            try modelContext.save()
            
            // Update all student checklist progress to match new template versions
            StudentChecklistUpdateService.updateStudentChecklistProgress(modelContext: modelContext)
            
            // Repair any broken template relationships in ChecklistAssignments
            repairAllChecklistAssignmentRelationships(modelContext: modelContext)
            
            // Mark this version as completed
            userDefaults.set(templateVersion, forKey: "lastTemplateUpdateVersion")
            
            print("Template update: \(addedCount) templates updated")
            
        } catch {
            print("Error during smart template update: \(error)")
        }
    }
    
    /// Updates an existing template with new content while preserving user customizations
    private static func updateTemplate(_ existingTemplate: ChecklistTemplate, with newTemplate: ChecklistTemplate, modelContext: ModelContext) {
        // Update basic properties
        existingTemplate.category = newTemplate.category
        existingTemplate.phase = newTemplate.phase
        existingTemplate.relevantData = newTemplate.relevantData
        existingTemplate.lastModified = Date()
        
        // Ensure template has correct ID from mapping service
        if let templateIdentifier = newTemplate.templateIdentifier,
           let mappedID = TemplateIDMappingService.getTemplateID(for: templateIdentifier) {
            existingTemplate.id = mappedID
        }
        
        // Delete existing items first to prevent accumulation
        if let existingItems = existingTemplate.items {
            for item in existingItems {
                modelContext.delete(item)
            }
            existingTemplate.items?.removeAll()
        }
        
        // Add new items in the exact order they appear in the template
        if let newItems = newTemplate.items {
            // Get item IDs from mapping service if available
            let itemIDs: [UUID]? = {
                if let templateIdentifier = newTemplate.templateIdentifier {
                    return TemplateIDMappingService.getTemplateItemIDs(for: templateIdentifier)
                }
                return nil
            }()
            
            for (index, newItem) in newItems.enumerated() {
                let item = ChecklistItem(title: newItem.title, notes: newItem.notes, order: newItem.order)
                
                // Assign correct UUID from mapping service if available
                if let itemIDs = itemIDs, index < itemIDs.count {
                    item.id = itemIDs[index]
                }
                
                item.template = existingTemplate
                existingTemplate.items?.append(item)
                // Insert item into model context
                modelContext.insert(item)
            }
        }
    }
    
    /// Cleans up duplicate items that might have accumulated
    private static func cleanupDuplicateItems(modelContext: ModelContext) {
        do {
            let descriptor = FetchDescriptor<ChecklistTemplate>()
            let templates = try modelContext.fetch(descriptor)
            
            for template in templates {
                guard let items = template.items else { continue }
                
                // Group items by title to find duplicates
                let groupedItems = Dictionary(grouping: items) { $0.title }
                
                for (_, duplicateItems) in groupedItems {
                    if duplicateItems.count > 1 {
                        // Keep the first item, remove the rest
                        let itemsToRemove = Array(duplicateItems.dropFirst())
                        for item in itemsToRemove {
                            template.items?.removeAll { $0.id == item.id }
                            modelContext.delete(item)
                        }
                        print("Removed \(itemsToRemove.count) duplicate items from template: \(template.name)")
                    }
                }
            }
        } catch {
            print("Error cleaning up duplicate items: \(error)")
        }
    }
    
    /// Returns all default templates that should be available
    private static func getAllDefaultTemplates() -> [ChecklistTemplate] {
        return DefaultTemplates.allTemplates
    }
    
    /// Repairs broken template relationships in all ChecklistAssignments
    private static func repairAllChecklistAssignmentRelationships(modelContext: ModelContext) {
        do {
            let descriptor = FetchDescriptor<ChecklistAssignment>()
            let assignments = try modelContext.fetch(descriptor)
            var repairedCount = 0
            
            for assignment in assignments {
                if assignment.template == nil {
                    // Try to find template by ID
                    let templateDescriptor = FetchDescriptor<ChecklistTemplate>()
                    let templates = try modelContext.fetch(templateDescriptor)
                    
                    if let template = templates.first(where: { $0.id == assignment.templateId }) {
                        assignment.template = template
                        repairedCount += 1
                        print("✅ Repaired template relationship for assignment: \(assignment.displayName)")
                    } else {
                        print("⚠️ Could not find template with ID: \(assignment.templateId) for assignment: \(assignment.displayName)")
                    }
                }
            }
            
            if repairedCount > 0 {
                try modelContext.save()
                print("✅ Repaired \(repairedCount) checklist assignment relationships")
            }
        } catch {
            print("❌ Error repairing checklist assignment relationships: \(error)")
        }
    }
    
    /// Validates template integrity at startup
    static func validateTemplateIntegrity(modelContext: ModelContext) {
        print("🔍 Validating template integrity...")
        
        do {
            let descriptor = FetchDescriptor<ChecklistTemplate>()
            let templates = try modelContext.fetch(descriptor)
            
            var defaultTemplateCount = 0
            var missingIdentifierCount = 0
            var missingMappingCount = 0
            var missingItemMappingCount = 0
            
            for template in templates {
                if let templateIdentifier = template.templateIdentifier {
                    // This is a default template
                    defaultTemplateCount += 1
                    
                    // Check if template ID mapping exists
                    if TemplateIDMappingService.getTemplateID(for: templateIdentifier) == nil {
                        print("❌ ERROR: Default template '\(template.name)' has templateIdentifier '\(templateIdentifier)' but no mapping found in TemplateIDMappingService")
                        missingMappingCount += 1
                    }
                    
                    // Check if item ID mappings exist
                    if let items = template.items, !items.isEmpty {
                        if let itemIDs = TemplateIDMappingService.getTemplateItemIDs(for: templateIdentifier) {
                            if itemIDs.count != items.count {
                                print("❌ ERROR: Template '\(template.name)' has \(items.count) items but only \(itemIDs.count) item ID mappings")
                                missingItemMappingCount += 1
                            }
                        } else {
                            print("❌ ERROR: Template '\(template.name)' has items but no item ID mappings found")
                            missingItemMappingCount += 1
                        }
                    }
                } else {
                    // This is a custom template - should not have templateIdentifier
                    if !template.isUserCreated && !template.isUserModified {
                        print("⚠️ WARNING: Template '\(template.name)' appears to be a default template but has no templateIdentifier")
                        missingIdentifierCount += 1
                    }
                }
            }
            
            print("📊 Template validation results:")
            print("   Default templates: \(defaultTemplateCount)")
            print("   Missing identifiers: \(missingIdentifierCount)")
            print("   Missing ID mappings: \(missingMappingCount)")
            print("   Missing item mappings: \(missingItemMappingCount)")
            
            if missingMappingCount == 0 && missingItemMappingCount == 0 && missingIdentifierCount == 0 {
                print("✅ All templates have proper identifiers and mappings")
            } else {
                print("❌ Template integrity issues found - some templates may not sync correctly")
            }
            
        } catch {
            print("❌ Failed to validate template integrity: \(error)")
        }
    }
}
