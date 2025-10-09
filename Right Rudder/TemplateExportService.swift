//
//  TemplateExportService.swift
//  Right Rudder
//
//  Created by AI on 10/6/25.
//

import Foundation
import SwiftData

// Codable structs for export/import
struct ExportableTemplate: Codable {
    let id: String
    let name: String
    let category: String
    let phase: String?
    let relevantData: String?
    let items: [ExportableTemplateItem]
    let isUserCreated: Bool
    let isUserModified: Bool
    let originalAuthor: String?
    let createdAt: Date
    let lastModified: Date
}

struct ExportableTemplateItem: Codable {
    let id: String
    let title: String
    let notes: String?
}

struct TemplateSharePackage: Codable {
    let templates: [ExportableTemplate]
    let exportDate: Date
    let exportedBy: String?
    let appVersion: String
}

class TemplateExportService {
    
    /// Exports selected templates to a shareable file URL
    static func exportTemplates(_ templates: [ChecklistTemplate], authorName: String?) -> URL? {
        let exportableTemplates = templates.map { template -> ExportableTemplate in
            let exportableItems = (template.items ?? []).map { item in
                ExportableTemplateItem(
                    id: item.id.uuidString,
                    title: item.title,
                    notes: item.notes
                )
            }
            
            return ExportableTemplate(
                id: template.id.uuidString,
                name: template.name,
                category: template.category,
                phase: template.phase,
                relevantData: template.relevantData,
                items: exportableItems,
                isUserCreated: template.isUserCreated,
                isUserModified: template.isUserModified,
                originalAuthor: template.originalAuthor ?? authorName,
                createdAt: template.createdAt,
                lastModified: template.lastModified
            )
        }
        
        let sharePackage = TemplateSharePackage(
            templates: exportableTemplates,
            exportDate: Date(),
            exportedBy: authorName,
            appVersion: "1.3"
        )
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(sharePackage)
            
            // Create temporary file with .rrtl extension (Right Rudder Template List)
            let temporaryDirectory = FileManager.default.temporaryDirectory
            let fileName = "RightRudderTemplates_\(Date().timeIntervalSince1970).rrtl"
            let fileURL = temporaryDirectory.appendingPathComponent(fileName)
            
            try data.write(to: fileURL)
            
            print("Exported \(templates.count) templates to: \(fileURL.path)")
            return fileURL
            
        } catch {
            print("Failed to export templates: \(error)")
            return nil
        }
    }
    
    /// Imports templates from a share package file
    static func importTemplates(from url: URL, modelContext: ModelContext, instructorName: String?) throws -> Int {
        let data = try Data(contentsOf: url)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let sharePackage = try decoder.decode(TemplateSharePackage.self, from: data)
        
        var importedCount = 0
        
        for exportableTemplate in sharePackage.templates {
            // Check if template with same ID already exists
            let templateId = UUID(uuidString: exportableTemplate.id) ?? UUID()
            let request = FetchDescriptor<ChecklistTemplate>(
                predicate: #Predicate<ChecklistTemplate> { $0.id == templateId }
            )
            
            let existingTemplates = try modelContext.fetch(request)
            
            if existingTemplates.isEmpty {
                // Create new template
                let template = ChecklistTemplate(
                    name: exportableTemplate.name,
                    category: exportableTemplate.category,
                    phase: exportableTemplate.phase,
                    relevantData: exportableTemplate.relevantData
                )
                template.id = templateId
                template.isUserCreated = exportableTemplate.isUserCreated
                template.isUserModified = exportableTemplate.isUserModified
                template.originalAuthor = exportableTemplate.originalAuthor
                template.createdAt = exportableTemplate.createdAt
                template.lastModified = exportableTemplate.lastModified
                
                // Create items
                var items: [ChecklistItem] = []
                for exportableItem in exportableTemplate.items {
                    let item = ChecklistItem(
                        title: exportableItem.title,
                        notes: exportableItem.notes
                    )
                    item.id = UUID(uuidString: exportableItem.id) ?? UUID()
                    item.template = template
                    items.append(item)
                    modelContext.insert(item)
                }
                
                template.items = items
                modelContext.insert(template)
                importedCount += 1
                
                print("Imported template: \(template.name)")
            } else {
                print("Template already exists: \(exportableTemplate.name), skipping")
            }
        }
        
        if importedCount > 0 {
            try modelContext.save()
        }
        
        return importedCount
    }
    
    /// Gets a display-friendly description of the templates in a file
    static func previewTemplates(from url: URL) throws -> [String] {
        let data = try Data(contentsOf: url)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let sharePackage = try decoder.decode(TemplateSharePackage.self, from: data)
        
        return sharePackage.templates.map { $0.name }
    }
}

