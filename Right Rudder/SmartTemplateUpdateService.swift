//
//  SmartTemplateUpdateService.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation
import SwiftData

class SmartTemplateUpdateService {
    
    static let templateVersion = "1.4.7.11" // Increment this when templates change
    
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
        do {
            // Check if we've already updated to this version
            let userDefaults = UserDefaults.standard
            let lastUpdateVersion = userDefaults.string(forKey: "lastTemplateUpdateVersion")
            
            if lastUpdateVersion == templateVersion {
                return
            }
            
            // Fetch all existing templates
            let descriptor = FetchDescriptor<ChecklistTemplate>()
            let existingTemplates = try modelContext.fetch(descriptor)
            
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
                
                // Check if there's already a user-customized template with this identifier
                let existingUserTemplate = existingTemplates.first { template in
                    return template.templateIdentifier == templateIdentifier && 
                           (template.isUserCreated || template.isUserModified)
                }
                
                if existingUserTemplate != nil {
                    continue
                }
                
                modelContext.insert(newTemplate)
                addedCount += 1
            }
            
            // Clean up any duplicate items that might have accumulated
            cleanupDuplicateItems(modelContext: modelContext)
            
            // Save changes
            try modelContext.save()
            
            // Update all student checklists to match new template versions
            StudentChecklistUpdateService.updateStudentChecklists(modelContext: modelContext)
            
            // Mark this version as completed
            userDefaults.set(templateVersion, forKey: "lastTemplateUpdateVersion")
            
            print("Template update: \(addedCount) templates updated")
            
        } catch {
            print("Error during smart template update: \(error)")
        }
    }
    
    /// Updates an existing template with new content while preserving user customizations
    private static func updateTemplate(_ existingTemplate: ChecklistTemplate, with newTemplate: ChecklistTemplate) {
        // Update basic properties
        existingTemplate.category = newTemplate.category
        existingTemplate.phase = newTemplate.phase
        existingTemplate.relevantData = newTemplate.relevantData
        existingTemplate.lastModified = Date()
        
        // Clear ALL existing items first to prevent accumulation
        existingTemplate.items?.removeAll()
        
        // Add new items in the exact order they appear in the template
        if let newItems = newTemplate.items {
            for newItem in newItems {
                let item = ChecklistItem(title: newItem.title, notes: newItem.notes, order: newItem.order)
                item.template = existingTemplate
                existingTemplate.items?.append(item)
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
}
