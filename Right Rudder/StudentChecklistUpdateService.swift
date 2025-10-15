//
//  StudentChecklistUpdateService.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation
import SwiftData

class StudentChecklistUpdateService {
    
    /// Updates all student checklists to match new template versions
    static func updateStudentChecklists(modelContext: ModelContext) {
        do {
            // First, migrate any checklists missing templateIdentifier
            migrateLegacyChecklists(modelContext: modelContext)
            
            // Fetch all student checklists
            let descriptor = FetchDescriptor<StudentChecklist>()
            let studentChecklists = try modelContext.fetch(descriptor)
            
            var updatedCount = 0
            var skippedCount = 0
            
            for studentChecklist in studentChecklists {
                var currentTemplate: ChecklistTemplate?
                
                // Try to find template by identifier first (new method)
                if let templateIdentifier = studentChecklist.templateIdentifier {
                    let templateDescriptor = FetchDescriptor<ChecklistTemplate>(
                        predicate: #Predicate { $0.templateIdentifier == templateIdentifier }
                    )
                    let templates = try modelContext.fetch(templateDescriptor)
                    currentTemplate = templates.first
                }
                
                // If no template found by identifier, try by name (legacy method)
                if currentTemplate == nil {
                    let templateName = studentChecklist.templateName
                    let templateDescriptor = FetchDescriptor<ChecklistTemplate>(
                        predicate: #Predicate<ChecklistTemplate> { template in
                            template.name == templateName
                        }
                    )
                    let templates = try modelContext.fetch(templateDescriptor)
                    currentTemplate = templates.first
                }
                
                guard let template = currentTemplate else {
                    skippedCount += 1
                    continue
                }
                
                // All checklists should now have templateIdentifier after migration
                // This is just a safety check
                if studentChecklist.templateIdentifier == nil {
                    studentChecklist.templateIdentifier = template.templateIdentifier
                }
                
                // Check if update is needed
                if shouldUpdateChecklist(studentChecklist: studentChecklist, newTemplate: template) {
                    mergeChecklistItems(existing: studentChecklist, template: template)
                    studentChecklist.templateVersion = SmartTemplateUpdateService.getCurrentTemplateVersion()
                    updatedCount += 1
                } else {
                    skippedCount += 1
                }
            }
            
            // Save changes
            try modelContext.save()
            
            print("Template update: \(updatedCount) updated, \(skippedCount) skipped")
            
        } catch {
            print("Failed to update student checklists: \(error)")
        }
    }
    
    /// Check if a student checklist needs to be updated
    private static func shouldUpdateChecklist(studentChecklist: StudentChecklist, newTemplate: ChecklistTemplate) -> Bool {
        // If no version stored, assume it needs updating
        guard let currentVersion = studentChecklist.templateVersion else {
            return true
        }
        
        // Compare with current template version
        let latestVersion = SmartTemplateUpdateService.getCurrentTemplateVersion()
        return currentVersion != latestVersion
    }
    
    /// Smart merge of checklist items preserving all student data
    private static func mergeChecklistItems(existing: StudentChecklist, template: ChecklistTemplate) {
        guard let existingItems = existing.items,
              let templateItems = template.items else {
            return
        }
        
        // Create a map of existing items by templateItemId for quick lookup
        var existingItemsMap: [UUID: StudentChecklistItem] = [:]
        for item in existingItems {
            existingItemsMap[item.templateItemId] = item
        }
        
        // Create new items array that will replace the existing one
        var newItems: [StudentChecklistItem] = []
        
        // Process each template item
        for templateItem in templateItems {
            if let existingItem = existingItemsMap[templateItem.id] {
                // Item exists - preserve all student data but update order
                existingItem.order = templateItem.order
                newItems.append(existingItem)
            } else {
                // New item from template - create new student item
                let newStudentItem = StudentChecklistItem(
                    templateItemId: templateItem.id,
                    title: templateItem.title,
                    notes: templateItem.notes,
                    order: templateItem.order
                )
                newItems.append(newStudentItem)
            }
        }
        
        // Handle items that were removed from template (legacy items)
        for existingItem in existingItems {
            if !newItems.contains(where: { $0.templateItemId == existingItem.templateItemId }) {
                // This item was removed from template - keep it but mark as legacy
                existingItem.order = 9999 // Put at end
                newItems.append(existingItem)
            }
        }
        
        // Sort by order
        newItems.sort { $0.order < $1.order }
        
        // Replace the items array
        existing.items = newItems
        existing.lastModified = Date()
        
    }
    
    /// Migrate legacy checklists that don't have templateIdentifier set
    private static func migrateLegacyChecklists(modelContext: ModelContext) {
        do {
            // Fetch all student checklists without templateIdentifier
            let descriptor = FetchDescriptor<StudentChecklist>(
                predicate: #Predicate { $0.templateIdentifier == nil }
            )
            let legacyChecklists = try modelContext.fetch(descriptor)
            
            var migratedCount = 0
            
            for studentChecklist in legacyChecklists {
                var matchingTemplate: ChecklistTemplate?
                
                // First try exact name match
                let templateName = studentChecklist.templateName
                let exactTemplateDescriptor = FetchDescriptor<ChecklistTemplate>(
                    predicate: #Predicate<ChecklistTemplate> { template in
                        template.name == templateName
                    }
                )
                let exactTemplates = try modelContext.fetch(exactTemplateDescriptor)
                matchingTemplate = exactTemplates.first
                
                // If no exact match, try format conversion (P1L1 -> I1-L1)
                if matchingTemplate == nil {
                    let convertedName = convertLegacyTemplateName(templateName)
                    if convertedName != templateName {
                        let convertedTemplateDescriptor = FetchDescriptor<ChecklistTemplate>(
                            predicate: #Predicate<ChecklistTemplate> { template in
                                template.name == convertedName
                            }
                        )
                        let convertedTemplates = try modelContext.fetch(convertedTemplateDescriptor)
                        matchingTemplate = convertedTemplates.first
                        
                        if matchingTemplate != nil {
                            // Update the template name to match the new format
                            studentChecklist.templateName = convertedName
                        }
                    }
                }
                
                if let template = matchingTemplate {
                    // Set the templateIdentifier from the matching template
                    studentChecklist.templateIdentifier = template.templateIdentifier
                    migratedCount += 1
                }
            }
            
            // Save the migration changes
            try modelContext.save()
            
            if migratedCount > 0 {
                print("Migrated \(migratedCount) legacy checklists")
            }
            
        } catch {
            print("Failed to migrate legacy checklists: \(error)")
        }
    }
    
    /// Convert legacy template names to new format (P1L1 -> I1-L1, etc.)
    private static func convertLegacyTemplateName(_ legacyName: String) -> String {
        // Handle the specific pattern: P1L1: Title -> I1-L1: Title
        if legacyName.hasPrefix("P1L") {
            return legacyName.replacingOccurrences(of: "P1L", with: "I1-L")
        } else if legacyName.hasPrefix("P2L") {
            return legacyName.replacingOccurrences(of: "P2L", with: "I2-L")
        } else if legacyName.hasPrefix("P3L") {
            return legacyName.replacingOccurrences(of: "P3L", with: "I3-L")
        } else if legacyName.hasPrefix("P4L") {
            return legacyName.replacingOccurrences(of: "P4L", with: "I4-L")
        } else if legacyName.hasPrefix("P5L") {
            return legacyName.replacingOccurrences(of: "P5L", with: "I5-L")
        }
        
        // Return original name if no conversion needed
        return legacyName
    }
}

// Extension to access template version from SmartTemplateUpdateService
extension SmartTemplateUpdateService {
    static func getCurrentTemplateVersion() -> String {
        return templateVersion // Use the actual version from SmartTemplateUpdateService
    }
}
