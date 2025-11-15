import Foundation
import SwiftData

class ChecklistIntegrityService {
    
    /// Main entry point - verify and repair all checklist integrity issues
    static func verifyAndRepairAllChecklists(modelContext: ModelContext) {
        print("🔍 Starting checklist integrity verification...")
        
        let startTime = Date()
        var issuesFound = 0
        var issuesRepaired = 0
        
        do {
            // 1. Clean up blank templates
            let blankTemplateIssues = cleanupBlankTemplates(modelContext: modelContext)
            issuesFound += blankTemplateIssues.count
            issuesRepaired += blankTemplateIssues.count
            
            // 2. Verify template integrity
            let templateIssues = verifyTemplateIntegrity(modelContext: modelContext)
            issuesFound += templateIssues
            
            // 2. Check for orphaned progress records
            let orphanedIssues = fixOrphanedProgressRecords(modelContext: modelContext)
            issuesFound += orphanedIssues.count
            issuesRepaired += orphanedIssues.count
            
            // 3. Verify progress record integrity
            let progressIssues = verifyProgressRecordIntegrity(modelContext: modelContext)
            issuesFound += progressIssues.count
            issuesRepaired += progressIssues.count
            
            // 4. Check for missing progress records
            let missingIssues = fixMissingProgressRecords(modelContext: modelContext)
            issuesFound += missingIssues.count
            issuesRepaired += missingIssues.count
            
            try modelContext.save()
            
            let duration = Date().timeIntervalSince(startTime)
            print("✅ Integrity check completed in \(String(format: "%.2f", duration))s")
            print("📊 Found \(issuesFound) issues, repaired \(issuesRepaired)")
            
        } catch {
            print("❌ Error during integrity check: \(error)")
        }
    }
    
    /// Clean up templates with blank or invalid names
    private static func cleanupBlankTemplates(modelContext: ModelContext) -> [UUID] {
        do {
            let descriptor = FetchDescriptor<ChecklistTemplate>()
            let templates = try modelContext.fetch(descriptor)
            
            var removedIds: [UUID] = []
            
            for template in templates {
                let trimmedName = template.name.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Remove templates with empty names
                if trimmedName.isEmpty {
                    print("🗑️ Removing blank template with ID: \(template.id)")
                    modelContext.delete(template)
                    removedIds.append(template.id)
                }
            }
            
            if !removedIds.isEmpty {
                print("✅ Cleaned up \(removedIds.count) blank templates")
            }
            
            return removedIds
            
        } catch {
            print("Error cleaning up blank templates: \(error)")
            return []
        }
    }
    
    /// Verify template content integrity using hashes
    private static func verifyTemplateIntegrity(modelContext: ModelContext) -> Int {
        do {
            let descriptor = FetchDescriptor<ChecklistTemplate>()
            let templates = try modelContext.fetch(descriptor)
            
            var issuesFound = 0
            
            for template in templates {
                let currentHash = template.computeContentHash()
                
                if template.contentHash == nil {
                    // First time - set the hash
                    template.contentHash = currentHash
                    issuesFound += 1
                } else if template.contentHash != currentHash {
                    // Hash mismatch - template may have been corrupted
                    print("⚠️ Template integrity issue detected: \(template.name)")
                    template.contentHash = currentHash
                    issuesFound += 1
                }
            }
            
            return issuesFound
            
        } catch {
            print("Error verifying template integrity: \(error)")
            return 0
        }
    }
    
    /// Fix orphaned assignment records (template deleted but assignment remains)
    private static func fixOrphanedProgressRecords(modelContext: ModelContext) -> [UUID] {
        do {
            let descriptor = FetchDescriptor<ChecklistAssignment>()
            let allAssignments = try modelContext.fetch(descriptor)
            
            let templateDescriptor = FetchDescriptor<ChecklistTemplate>()
            let allTemplates = try modelContext.fetch(templateDescriptor)
            let templateIds = Set(allTemplates.map { $0.id })
            
            var orphanedIds: [UUID] = []
            
            for assignment in allAssignments {
                if !templateIds.contains(assignment.templateId) {
                    print("🗑️ Removing orphaned assignment record for template \(assignment.templateId)")
                    modelContext.delete(assignment)
                    orphanedIds.append(assignment.id)
                }
            }
            
            return orphanedIds
            
        } catch {
            print("Error fixing orphaned progress records: \(error)")
            return []
        }
    }
    
    /// Verify assignment record integrity
    private static func verifyProgressRecordIntegrity(modelContext: ModelContext) -> [UUID] {
        do {
            let descriptor = FetchDescriptor<ChecklistAssignment>()
            let allAssignments = try modelContext.fetch(descriptor)
            
            var issuesFixed: [UUID] = []
            
            for assignment in allAssignments {
                // Check if template still exists
                let templateDescriptor = FetchDescriptor<ChecklistTemplate>()
                let allTemplates = try modelContext.fetch(templateDescriptor)
                let template = allTemplates.first { $0.id == assignment.templateId }
                
                guard let template = template else {
                    continue // Will be handled by orphaned records fix
                }
                
                // Check if assignment records match template items
                // Extract data safely to avoid accessing invalidated objects
                let templateItems = template.items ?? []
                let itemData = ChecklistAssignmentService.extractItemDataSafely(items: templateItems)
                let templateItemIds = Set(itemData.map { $0.id })
                let progressItemIds = Set(assignment.itemProgress?.map { $0.templateItemId } ?? [])
                
                // Add missing progress records
                for itemSnapshot in itemData {
                    if !progressItemIds.contains(itemSnapshot.id) {
                        let newItemProgress = ItemProgress(
                            templateItemId: itemSnapshot.id
                        )
                        assignment.itemProgress?.append(newItemProgress)
                        issuesFixed.append(assignment.id)
                    }
                }
                
                // Remove obsolete progress records
                if let itemProgress = assignment.itemProgress {
                    for item in itemProgress {
                        if !templateItemIds.contains(item.templateItemId) {
                            assignment.itemProgress?.removeAll { $0.id == item.id }
                            modelContext.delete(item)
                            issuesFixed.append(assignment.id)
                        }
                    }
                }
            }
            
            return issuesFixed
            
        } catch {
            print("Error verifying progress record integrity: \(error)")
            return []
        }
    }
    
    /// Fix missing progress records for assigned templates
    private static func fixMissingProgressRecords(modelContext: ModelContext) -> [UUID] {
        do {
            let studentDescriptor = FetchDescriptor<Student>()
            let students = try modelContext.fetch(studentDescriptor)
            
            var issuesFixed: [UUID] = []
            
            for student in students {
                guard let assignments = student.checklistAssignments else { continue }
                
                for assignment in assignments {
                    guard let template = assignment.template else { continue }
                    
                    // Check if all template items have progress records
                    // Extract data safely to avoid accessing invalidated objects
                    let templateItems = template.items ?? []
                    let itemData = ChecklistAssignmentService.extractItemDataSafely(items: templateItems)
                    let templateItemIds = Set(itemData.map { $0.id })
                    let progressItemIds = Set(assignment.itemProgress?.map { $0.templateItemId } ?? [])
                    
                    let missingIds = templateItemIds.subtracting(progressItemIds)
                    
                    if !missingIds.isEmpty {
                        for templateItemId in missingIds {
                            // Verify the item exists in our safe snapshot
                            guard itemData.first(where: { $0.id == templateItemId }) != nil else {
                                continue
                            }
                            
                            let newItemProgress = ItemProgress(
                                templateItemId: templateItemId
                            )
                            assignment.itemProgress?.append(newItemProgress)
                            issuesFixed.append(assignment.id)
                        }
                    }
                }
            }
            
            return issuesFixed
            
        } catch {
            print("Error fixing missing progress records: \(error)")
            return []
        }
    }
    
    /// Manual repair function for Settings
    static func manualIntegrityCheck(modelContext: ModelContext) -> (found: Int, repaired: Int) {
        let startTime = Date()
        var found = 0
        var repaired = 0
        
        do {
            // Count issues before repair
            let templateDescriptor = FetchDescriptor<ChecklistTemplate>()
            let templates = try modelContext.fetch(templateDescriptor)
            
            for template in templates {
                let currentHash = template.computeContentHash()
                if template.contentHash != currentHash {
                    found += 1
                }
            }
            
            // Run repair
            verifyAndRepairAllChecklists(modelContext: modelContext)
            repaired = found // Assume all found issues were repaired
            
            let duration = Date().timeIntervalSince(startTime)
            print("Manual integrity check completed in \(String(format: "%.2f", duration))s")
            
        } catch {
            print("Error during manual integrity check: \(error)")
        }
        
        return (found: found, repaired: repaired)
    }
}
