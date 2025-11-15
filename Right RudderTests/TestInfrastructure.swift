//
//  TestInfrastructure.swift
//  Right RudderTests
//
//  Minimal test infrastructure for high-efficacy testing
//

import Foundation
import SwiftData
@testable import Right_Rudder

// MARK: - Test Container

/// Creates an in-memory ModelContainer for testing
/// Uses the same schema as the production app
func makeTestContainer() throws -> ModelContainer {
    let schema = Schema([
        Student.self,
        ChecklistAssignment.self,
        ItemProgress.self,
        CustomChecklistDefinition.self,
        CustomChecklistItem.self,
        EndorsementImage.self,
        ChecklistTemplate.self,
        ChecklistItem.self,
        StudentDocument.self,
        OfflineSyncOperation.self,
    ])
    
    let config = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: true
    )
    
    return try ModelContainer(for: schema, configurations: [config])
}

// MARK: - Test Data Factories

/// Creates a test student with minimal required data
func makeTestStudent(
    firstName: String = "Test",
    lastName: String = "Student",
    email: String = "test@example.com",
    telephone: String = "555-1234",
    homeAddress: String = "123 Test St",
    ftnNumber: String = "TEST123",
    category: String? = nil
) -> Student {
    let student = Student(
        firstName: firstName,
        lastName: lastName,
        email: email,
        telephone: telephone,
        homeAddress: homeAddress,
        ftnNumber: ftnNumber
    )
    student.assignedCategory = category
    return student
}

/// Creates a test checklist template with specified number of items
func makeTestTemplate(
    name: String = "Test Template",
    category: String = "PPL",
    phase: String? = nil,
    itemCount: Int = 3
) -> ChecklistTemplate {
    let template = ChecklistTemplate(
        name: name,
        category: category,
        phase: phase,
        templateIdentifier: "test_\(UUID().uuidString)"
    )
    
    // Create items
    var items: [ChecklistItem] = []
    for i in 0..<itemCount {
        let item = ChecklistItem(title: "Item \(i + 1)", order: i)
        item.template = template
        items.append(item)
    }
    
    template.items = items
    return template
}

/// Creates a test checklist item
func makeTestChecklistItem(
    title: String = "Test Item",
    order: Int = 0
) -> ChecklistItem {
    return ChecklistItem(title: title, order: order)
}

/// Creates a complete test scenario: student, template, and assignment
func createTestScenario(
    modelContext: ModelContext,
    templateItemCount: Int = 3
) -> (student: Student, template: ChecklistTemplate, assignment: ChecklistAssignment) {
    let student = makeTestStudent()
    let template = makeTestTemplate(itemCount: templateItemCount)
    
    modelContext.insert(student)
    modelContext.insert(template)
    
    // Create assignment
    let assignment = ChecklistAssignment(
        templateId: template.id,
        templateIdentifier: template.templateIdentifier,
        isCustomChecklist: false
    )
    
    // Create ItemProgress records for all template items
    if let templateItems = template.items {
        var itemProgressArray: [ItemProgress] = []
        for templateItem in templateItems {
            let itemProgress = ItemProgress(templateItemId: templateItem.id)
            itemProgress.assignment = assignment
            itemProgressArray.append(itemProgress)
            modelContext.insert(itemProgress)
        }
        assignment.itemProgress = itemProgressArray
    }
    
    // Set relationships
    assignment.student = student
    assignment.template = template
    
    // Initialize arrays if nil
    if student.checklistAssignments == nil {
        student.checklistAssignments = []
    }
    student.checklistAssignments?.append(assignment)
    
    if template.studentAssignments == nil {
        template.studentAssignments = []
    }
    template.studentAssignments?.append(assignment)
    
    modelContext.insert(assignment)
    
    return (student, template, assignment)
}

// MARK: - Test Utilities

/// Helper to save model context in tests
func saveContext(_ context: ModelContext) throws {
    try context.save()
}

/// Helper to fetch all instances of a type
func fetchAll<T: PersistentModel>(
    _ type: T.Type,
    from context: ModelContext
) throws -> [T] {
    let descriptor = FetchDescriptor<T>()
    return try context.fetch(descriptor)
}

