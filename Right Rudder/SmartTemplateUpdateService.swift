//
//  SmartTemplateUpdateService.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation
import SwiftData

class SmartTemplateUpdateService {

  static let templateVersion = "1.4.7.14"  // Increment this when templates change (bumped to fix Solo Endorsements items)
  private static var isUpdating = false  // Prevent concurrent updates

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

      print(
        "Updating templates from version \(lastUpdateVersion ?? "unknown") to \(templateVersion)")
      if !defaultTemplatesExist {
        print("⚠️ No default templates found in database, initializing all templates...")
      }

      // Get all new default templates from library
      let newTemplates = getAllDefaultTemplates()

      // Create a set of new template IDs for quick lookup
      let newTemplateIds = Set(newTemplates.map { $0.id })

      // Delete default templates that are no longer in the library
      let defaultTemplatesToDelete = existingTemplates.filter { template in
        guard template.templateIdentifier != nil else { return false }
        return !newTemplateIds.contains(template.id)
      }

      for template in defaultTemplatesToDelete {
        modelContext.delete(template)
      }

      // Process deletions before updating/inserting
      if !defaultTemplatesToDelete.isEmpty {
        modelContext.processPendingChanges()
      }

      // Fetch templates again after deletions to get fresh state
      let currentTemplates = try modelContext.fetch(FetchDescriptor<ChecklistTemplate>())
      let currentTemplateIds = Set(currentTemplates.map { $0.id })
      let currentTemplateIdentifiers = Set(currentTemplates.compactMap { $0.templateIdentifier })

      var addedCount = 0
      var updatedCount = 0

      for newTemplate in newTemplates {
        guard let templateIdentifier = newTemplate.templateIdentifier else {
          continue
        }

        // Use template/item IDs directly (no mapping needed)
        // Ensure items are properly set up before checking for existing templates
        if let items = newTemplate.items {
          for item in items {
            // Ensure item's template relationship is set
            item.template = newTemplate
          }
          print("✅ Configured \(items.count) items for template: \(templateIdentifier)")
        } else {
          print("⚠️ No item IDs mapping found for template: \(templateIdentifier)")
        }

        // Check if template with this ID already exists
        if currentTemplateIds.contains(newTemplate.id) {
          // Find the existing template
          if let existing = currentTemplates.first(where: { $0.id == newTemplate.id }) {
            // Update existing template
            updateTemplate(existing, with: newTemplate, modelContext: modelContext)
            print("✅ Updated existing template: \(templateIdentifier)")
            updatedCount += 1
            continue
          }
        }

        // Check if there's already a user-customized template with this identifier
        if currentTemplateIdentifiers.contains(templateIdentifier) {
          if let userTemplate = currentTemplates.first(where: {
            $0.templateIdentifier == templateIdentifier && ($0.isUserCreated || $0.isUserModified)
          }) {
            print(
              "⚠️ Skipping template \(templateIdentifier) - user-customized version exists: \(userTemplate.name)"
            )
            continue
          }
        }

        // Insert template AND all its items into the model context
        modelContext.insert(newTemplate)
        if let items = newTemplate.items {
          for item in items {
            modelContext.insert(item)
          }
        }
        addedCount += 1
        print(
          "✅ Inserted new template: \(templateIdentifier) with ID: \(newTemplate.id), items: \(newTemplate.items?.count ?? 0)"
        )
      }

      // Clean up any duplicate items that might have accumulated
      cleanupDuplicateItems(modelContext: modelContext)

      // Save changes
      try modelContext.save()

      // Update all student checklist progress to match new template versions
      StudentChecklistUpdateService.updateStudentChecklistProgress(modelContext: modelContext)

      // Mark this version as completed
      userDefaults.set(templateVersion, forKey: "lastTemplateUpdateVersion")

      print("Template update: \(addedCount) templates inserted, \(updatedCount) templates updated")

    } catch {
      print("Error during smart template update: \(error)")
    }
  }

  /// Updates an existing template with new content while preserving user customizations
  private static func updateTemplate(
    _ existingTemplate: ChecklistTemplate, with newTemplate: ChecklistTemplate,
    modelContext: ModelContext
  ) {
    // Update basic properties
    existingTemplate.name = newTemplate.name
    existingTemplate.category = newTemplate.category
    existingTemplate.phase = newTemplate.phase
    existingTemplate.relevantData = newTemplate.relevantData
    existingTemplate.lastModified = Date()

    // Delete existing items first to prevent accumulation
    // CRITICAL: Extract item data before deletion to avoid accessing invalidated objects
    if let existingItems = existingTemplate.items {
      // Extract IDs before deletion to avoid invalidated object access
      let _ = existingItems.map { $0.id }

      // Delete items
      for item in existingItems {
        modelContext.delete(item)
      }
      existingTemplate.items?.removeAll()

      // Process pending changes to ensure deletions are committed atomically
      // This prevents other code from accessing invalidated items during the update
      modelContext.processPendingChanges()
    }

    // Add new items in the exact order they appear in the template
    if let newItems = newTemplate.items {
      // Ensure items array is initialized
      if existingTemplate.items == nil {
        existingTemplate.items = []
      }

      for newItem in newItems {
        let item = ChecklistItem(title: newItem.title, notes: newItem.notes, order: newItem.order)

        // Preserve the item ID from the library
        item.id = newItem.id
        item.template = existingTemplate
        existingTemplate.items?.append(item)
        // Insert item into model context
        modelContext.insert(item)
      }

      // Process pending changes after insertion to ensure new items are available
      modelContext.processPendingChanges()
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
  /// Loads from DefaultChecklistLibrary.json to ensure UUIDs match student app
  private static func getAllDefaultTemplates() -> [ChecklistTemplate] {
    // First try to load from the central library JSON
    if let libraryTemplates = loadTemplatesFromLibrary() {
      print("✅ Loaded \(libraryTemplates.count) templates from DefaultChecklistLibrary.json")
      return libraryTemplates
    }

    // Fallback to DefaultTemplates if JSON not found
    print("⚠️ Could not load from library JSON, falling back to DefaultTemplates.swift")
    return DefaultTemplates.allTemplates
  }

  /// Loads templates from DefaultChecklistLibrary.json with proper UUIDs
  private static func loadTemplatesFromLibrary() -> [ChecklistTemplate]? {
    guard
      let url = Bundle.main.url(
        forResource: "DefaultChecklistLibrary", withExtension: "json",
        subdirectory: "ChecklistLibrary")
        ?? Bundle.main.url(forResource: "DefaultChecklistLibrary", withExtension: "json")
    else {
      print("⚠️ Could not find DefaultChecklistLibrary.json")
      return nil
    }

    do {
      let data = try Data(contentsOf: url)
      let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
      guard let checklistsArray = json?["checklists"] as? [[String: Any]] else {
        print("❌ Invalid library JSON structure")
        return nil
      }

      var templates: [ChecklistTemplate] = []

      for checklistDict in checklistsArray {
        guard let idString = checklistDict["id"] as? String,
          let id = UUID(uuidString: idString),
          let name = checklistDict["name"] as? String,
          let category = checklistDict["category"] as? String,
          let itemsArray = checklistDict["items"] as? [[String: Any]]
        else {
          print("⚠️ Skipping invalid checklist entry")
          continue
        }

        let templateIdentifier = checklistDict["templateIdentifier"] as? String
        let phase = checklistDict["phase"] as? String

        // Create template with library UUID
        let template = ChecklistTemplate(
          name: name,
          category: category,
          phase: phase,
          relevantData: nil,
          templateIdentifier: templateIdentifier,
          items: nil
        )

        // Set the template ID to match the library UUID
        template.id = id

        // Create items with library UUIDs
        var items: [ChecklistItem] = []
        for itemDict in itemsArray {
          guard let itemIdString = itemDict["id"] as? String,
            let itemId = UUID(uuidString: itemIdString),
            let title = itemDict["title"] as? String,
            let order = itemDict["order"] as? Int
          else {
            continue
          }

          let notes = itemDict["notes"] as? String
          let item = ChecklistItem(
            title: title,
            notes: notes,
            order: order
          )
          // Set the item ID to match the library UUID
          item.id = itemId
          item.template = template
          items.append(item)
        }

        // Sort items by order
        items.sort { $0.order < $1.order }
        template.items = items
        templates.append(template)
      }

      return templates

    } catch {
      print("❌ Failed to load library JSON: \(error)")
      return nil
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

      for template in templates {
        if template.templateIdentifier != nil {
          // This is a default template
          defaultTemplateCount += 1

          // Template validation - no mapping service needed
          // Templates use their own IDs directly
        } else {
          // This is a custom template - should not have templateIdentifier
          if !template.isUserCreated && !template.isUserModified {
            print(
              "⚠️ WARNING: Template '\(template.name)' appears to be a default template but has no templateIdentifier"
            )
            missingIdentifierCount += 1
          }
        }
      }

      print("📊 Template validation results:")
      print("   Default templates: \(defaultTemplateCount)")
      print("   Missing identifiers: \(missingIdentifierCount)")

      if missingIdentifierCount == 0 {
        print("✅ All templates have proper identifiers")
      } else {
        print("❌ Template integrity issues found - some templates may not sync correctly")
      }

    } catch {
      print("❌ Failed to validate template integrity: \(error)")
    }
  }
}
