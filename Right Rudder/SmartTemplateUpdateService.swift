//
//  SmartTemplateUpdateService.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation
import SwiftData

class SmartTemplateUpdateService {
    
    private static let templateVersion = "1.4.6" // Increment this when templates change
    
    /// Updates default templates while preserving user customizations
    static func updateDefaultTemplates(modelContext: ModelContext) {
        print("Starting smart template update...")
        
        do {
            // Check if we've already updated to this version
            let userDefaults = UserDefaults.standard
            let lastUpdateVersion = userDefaults.string(forKey: "lastTemplateUpdateVersion")
            
            if lastUpdateVersion == templateVersion {
                print("Templates already up to date (version \(templateVersion))")
                return
            }
            
            // Fetch all existing templates
            let descriptor = FetchDescriptor<ChecklistTemplate>()
            let existingTemplates = try modelContext.fetch(descriptor)
            
            print("Found \(existingTemplates.count) existing templates")
            
            // Delete ALL templates with templateIdentifier (default templates)
            // This ensures a clean slate for default templates
            let defaultTemplatesToDelete = existingTemplates.filter { $0.templateIdentifier != nil }
            print("Deleting ALL \(defaultTemplatesToDelete.count) existing default templates (clean slate approach)")
            
            for template in defaultTemplatesToDelete {
                print("Deleting default template: \(template.name)")
                modelContext.delete(template)
            }
            
            // Report on user-created templates (those without templateIdentifier)
            let userTemplates = existingTemplates.filter { $0.templateIdentifier == nil }
            print("Preserving \(userTemplates.count) user-created templates")
            for template in userTemplates {
                print("Preserved user-created template: \(template.name)")
            }
            
            // Get all new default templates
            let newTemplates = getAllDefaultTemplates()
            print("Adding \(newTemplates.count) new default templates")
            
            var addedCount = 0
            
            for newTemplate in newTemplates {
                guard let templateIdentifier = newTemplate.templateIdentifier else {
                    print("Warning: New template '\(newTemplate.name)' has no templateIdentifier")
                    continue
                }
                
                // Check if there's already a user-customized template with this identifier
                let existingUserTemplate = existingTemplates.first { template in
                    return template.templateIdentifier == templateIdentifier && 
                           (template.isUserCreated || template.isUserModified)
                }
                
                if let userTemplate = existingUserTemplate {
                    let reason = userTemplate.isUserCreated ? "user-created" : "user-modified"
                    print("Skipping new template '\(newTemplate.name)' - preserving \(reason) version")
                    continue
                }
                
                print("Adding new template: \(newTemplate.name) (ID: \(templateIdentifier))")
                modelContext.insert(newTemplate)
                addedCount += 1
            }
            
            // Clean up any duplicate items that might have accumulated
            cleanupDuplicateItems(modelContext: modelContext)
            
            // Save changes
            try modelContext.save()
            
            // Mark this version as completed
            userDefaults.set(templateVersion, forKey: "lastTemplateUpdateVersion")
            
            print("Smart template update completed: \(defaultTemplatesToDelete.count) deleted, \(addedCount) added")
            
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
