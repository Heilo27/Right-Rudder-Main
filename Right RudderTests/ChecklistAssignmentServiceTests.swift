//
//  ChecklistAssignmentServiceTests.swift
//  Right RudderTests
//
//  Tests for ChecklistAssignmentService core business logic
//

import XCTest
import SwiftData
@testable import Right_Rudder

final class ChecklistAssignmentServiceTests: XCTestCase {
    var container: ModelContainer!
    var modelContext: ModelContext!
    
    override func setUp() {
        super.setUp()
        container = try! makeTestContainer()
        modelContext = ModelContext(container)
    }
    
    override func tearDown() {
        modelContext = nil
        container = nil
        super.tearDown()
    }
    
    // MARK: - Assign Template Tests
    
    func testAssignTemplate_CreatesAssignment() throws {
        // Given: A student and a template
        let student = makeTestStudent()
        let template = makeTestTemplate(name: "Test Lesson", category: "PPL", itemCount: 3)
        
        modelContext.insert(student)
        modelContext.insert(template)
        try saveContext(modelContext)
        
        // When: Assigning template to student
        ChecklistAssignmentService.assignTemplate(template, to: student, modelContext: modelContext)
        
        // Wait for async save to complete
        try awaitTask()
        
        // Then: Assignment should be created
        XCTAssertNotNil(student.checklistAssignments)
        XCTAssertEqual(student.checklistAssignments?.count, 1)
        
        let assignment = student.checklistAssignments?.first
        XCTAssertNotNil(assignment)
        XCTAssertEqual(assignment?.templateId, template.id)
        XCTAssertEqual(assignment?.templateIdentifier, template.templateIdentifier)
        XCTAssertEqual(assignment?.isCustomChecklist, false)
    }
    
    func testAssignTemplate_CreatesItemProgressRecords() throws {
        // Given: A student and a template with 5 items
        let student = makeTestStudent()
        let template = makeTestTemplate(name: "Test Lesson", category: "PPL", itemCount: 5)
        
        modelContext.insert(student)
        modelContext.insert(template)
        try saveContext(modelContext)
        
        // When: Assigning template to student
        ChecklistAssignmentService.assignTemplate(template, to: student, modelContext: modelContext)
        
        // Wait for async save to complete
        try awaitTask()
        
        // Then: ItemProgress records should be created for all template items
        let assignment = student.checklistAssignments?.first
        XCTAssertNotNil(assignment)
        XCTAssertNotNil(assignment?.itemProgress)
        XCTAssertEqual(assignment?.itemProgress?.count, 5)
        
        // Verify each ItemProgress has correct templateItemId
        if let templateItems = template.items, let itemProgress = assignment?.itemProgress {
            let templateItemIds = Set(templateItems.map { $0.id })
            let progressItemIds = Set(itemProgress.map { $0.templateItemId })
            XCTAssertEqual(templateItemIds, progressItemIds)
        }
    }
    
    func testAssignTemplate_SetsRelationships() throws {
        // Given: A student and a template
        let student = makeTestStudent()
        let template = makeTestTemplate(name: "Test Lesson", category: "PPL", itemCount: 3)
        
        modelContext.insert(student)
        modelContext.insert(template)
        try saveContext(modelContext)
        
        // When: Assigning template to student
        ChecklistAssignmentService.assignTemplate(template, to: student, modelContext: modelContext)
        
        // Wait for async save to complete
        try awaitTask()
        
        // Then: Relationships should be set correctly
        let assignment = student.checklistAssignments?.first
        XCTAssertNotNil(assignment)
        XCTAssertEqual(assignment?.student?.id, student.id)
        XCTAssertEqual(assignment?.template?.id, template.id)
        XCTAssertEqual(template.studentAssignments?.first?.id, assignment?.id)
    }
    
    func testAssignTemplate_PreventsDuplicateAssignment() throws {
        // Given: A student with an already assigned template
        let student = makeTestStudent()
        let template = makeTestTemplate(name: "Test Lesson", category: "PPL", itemCount: 3)
        
        modelContext.insert(student)
        modelContext.insert(template)
        try saveContext(modelContext)
        
        // Assign template first time
        ChecklistAssignmentService.assignTemplate(template, to: student, modelContext: modelContext)
        try awaitTask()
        
        let initialCount = student.checklistAssignments?.count ?? 0
        
        // When: Attempting to assign the same template again
        ChecklistAssignmentService.assignTemplate(template, to: student, modelContext: modelContext)
        try awaitTask()
        
        // Then: Should not create duplicate assignment
        XCTAssertEqual(student.checklistAssignments?.count, initialCount)
    }
    
    func testAssignTemplate_CustomChecklist() throws {
        // Given: A student and a custom template (no templateIdentifier)
        let student = makeTestStudent()
        let template = ChecklistTemplate(
            name: "Custom Lesson",
            category: "PPL",
            templateIdentifier: nil  // Custom checklist
        )
        
        modelContext.insert(student)
        modelContext.insert(template)
        try saveContext(modelContext)
        
        // When: Assigning custom template to student
        ChecklistAssignmentService.assignTemplate(template, to: student, modelContext: modelContext)
        try awaitTask()
        
        // Then: Assignment should be marked as custom checklist
        let assignment = student.checklistAssignments?.first
        XCTAssertNotNil(assignment)
        XCTAssertEqual(assignment?.isCustomChecklist, true)
    }
    
    // MARK: - Remove Template Tests
    
    func testRemoveTemplate_RemovesAssignment() throws {
        // Given: A student with an assigned template
        let student = makeTestStudent()
        let template = makeTestTemplate(name: "Test Lesson", category: "PPL", itemCount: 3)
        
        modelContext.insert(student)
        modelContext.insert(template)
        try saveContext(modelContext)
        
        ChecklistAssignmentService.assignTemplate(template, to: student, modelContext: modelContext)
        try awaitTask()
        
        let initialCount = student.checklistAssignments?.count ?? 0
        XCTAssertGreaterThan(initialCount, 0)
        
        // When: Removing template assignment
        ChecklistAssignmentService.removeTemplate(template, from: student, modelContext: modelContext)
        try awaitTask()
        
        // Then: Assignment should be removed
        XCTAssertEqual(student.checklistAssignments?.count, initialCount - 1)
        XCTAssertNil(student.checklistAssignments?.first(where: { $0.templateId == template.id }))
    }
    
    func testRemoveTemplate_RemovesFromTemplate() throws {
        // Given: A student with an assigned template
        let student = makeTestStudent()
        let template = makeTestTemplate(name: "Test Lesson", category: "PPL", itemCount: 3)
        
        modelContext.insert(student)
        modelContext.insert(template)
        try saveContext(modelContext)
        
        ChecklistAssignmentService.assignTemplate(template, to: student, modelContext: modelContext)
        try awaitTask()
        
        let initialTemplateCount = template.studentAssignments?.count ?? 0
        XCTAssertGreaterThan(initialTemplateCount, 0)
        
        // When: Removing template assignment
        ChecklistAssignmentService.removeTemplate(template, from: student, modelContext: modelContext)
        try awaitTask()
        
        // Then: Assignment should be removed from template
        XCTAssertEqual(template.studentAssignments?.count, initialTemplateCount - 1)
    }
    
    func testRemoveTemplate_DeletesAssignmentRecord() throws {
        // Given: A student with an assigned template
        let student = makeTestStudent()
        let template = makeTestTemplate(name: "Test Lesson", category: "PPL", itemCount: 3)
        
        modelContext.insert(student)
        modelContext.insert(template)
        try saveContext(modelContext)
        
        ChecklistAssignmentService.assignTemplate(template, to: student, modelContext: modelContext)
        try awaitTask()
        
        let assignment = student.checklistAssignments?.first
        let assignmentId = assignment?.id
        XCTAssertNotNil(assignmentId)
        
        // When: Removing template assignment
        ChecklistAssignmentService.removeTemplate(template, from: student, modelContext: modelContext)
        try awaitTask()
        
        // Then: Assignment record should be deleted
        guard let assignmentId = assignmentId else {
            XCTFail("Assignment ID should not be nil")
            return
        }
        let descriptor = FetchDescriptor<ChecklistAssignment>(
            predicate: #Predicate<ChecklistAssignment> { assignment in
                assignment.id == assignmentId
            }
        )
        let remainingAssignments = try modelContext.fetch(descriptor)
        XCTAssertEqual(remainingAssignments.count, 0)
    }
    
    func testRemoveTemplate_NonExistentAssignment_DoesNothing() throws {
        // Given: A student without the template assigned
        let student = makeTestStudent()
        let template = makeTestTemplate(name: "Test Lesson", category: "PPL", itemCount: 3)
        
        modelContext.insert(student)
        modelContext.insert(template)
        try saveContext(modelContext)
        
        let initialCount = student.checklistAssignments?.count ?? 0
        
        // When: Attempting to remove non-existent assignment
        ChecklistAssignmentService.removeTemplate(template, from: student, modelContext: modelContext)
        try awaitTask()
        
        // Then: Should not change anything
        XCTAssertEqual(student.checklistAssignments?.count, initialCount)
    }
    
    // MARK: - Display Items Tests
    
    func testGetDisplayItems_ReturnsItemsFromTemplate() throws {
        // Given: An assignment with a template
        let (_, _, assignment) = createTestScenario(
            modelContext: modelContext,
            templateItemCount: 4
        )
        try saveContext(modelContext)
        
        // When: Getting display items
        let displayItems = ChecklistAssignmentService.getDisplayItems(for: assignment)
        
        // Then: Should return items from template
        XCTAssertEqual(displayItems.count, 4)
        XCTAssertEqual(displayItems[0].title, "Item 1")
        XCTAssertEqual(displayItems[1].title, "Item 2")
    }
    
    func testGetDisplayItems_NoTemplate_ReturnsEmpty() throws {
        // Given: An assignment without a template relationship
        let assignment = ChecklistAssignment(
            templateId: UUID(),
            templateIdentifier: "test_template"
        )
        modelContext.insert(assignment)
        try saveContext(modelContext)
        
        // When: Getting display items
        let displayItems = ChecklistAssignmentService.getDisplayItems(for: assignment)
        
        // Then: Should return empty array
        XCTAssertEqual(displayItems.count, 0)
    }
    
    func testGetDisplayItems_MapsItemProgressCorrectly() throws {
        // Given: An assignment with completed items
        let (_, _, assignment) = createTestScenario(
            modelContext: modelContext,
            templateItemCount: 3
        )
        
        // Mark first item as complete
        assignment.itemProgress?[0].isComplete = true
        try saveContext(modelContext)
        
        // When: Getting display items
        let displayItems = ChecklistAssignmentService.getDisplayItems(for: assignment)
        
        // Then: First item should be marked as complete
        XCTAssertEqual(displayItems.count, 3)
        XCTAssertTrue(displayItems[0].isComplete)
        XCTAssertFalse(displayItems[1].isComplete)
        XCTAssertFalse(displayItems[2].isComplete)
    }
    
    // MARK: - Relationship Integrity Tests
    
    func testAssignment_StudentRelationship_Bidirectional() throws {
        // Given: A student and assignment
        let student = makeTestStudent()
        let template = makeTestTemplate(itemCount: 3)
        
        modelContext.insert(student)
        modelContext.insert(template)
        try saveContext(modelContext)
        
        ChecklistAssignmentService.assignTemplate(template, to: student, modelContext: modelContext)
        try awaitTask()
        
        // When: Accessing relationship from assignment
        let assignment = student.checklistAssignments?.first
        
        // Then: Should be able to access student from assignment
        XCTAssertNotNil(assignment)
        XCTAssertNotNil(assignment?.student)
        XCTAssertEqual(assignment?.student?.id, student.id)
    }
    
    func testAssignment_TemplateRelationship_Bidirectional() throws {
        // Given: A template and assignment
        let student = makeTestStudent()
        let template = makeTestTemplate(itemCount: 3)
        
        modelContext.insert(student)
        modelContext.insert(template)
        try saveContext(modelContext)
        
        ChecklistAssignmentService.assignTemplate(template, to: student, modelContext: modelContext)
        try awaitTask()
        
        // When: Accessing relationship from template
        let assignment = template.studentAssignments?.first
        
        // Then: Should be able to access template from assignment
        XCTAssertNotNil(assignment)
        XCTAssertNotNil(assignment?.template)
        XCTAssertEqual(assignment?.template?.id, template.id)
    }
    
    func testItemProgress_AssignmentRelationship_Bidirectional() throws {
        // Given: An assignment with ItemProgress records
        let (_, _, assignment) = createTestScenario(
            modelContext: modelContext,
            templateItemCount: 3
        )
        try saveContext(modelContext)
        
        // When: Accessing ItemProgress from assignment
        let itemProgress = assignment.itemProgress?.first
        
        // Then: Should be able to access assignment from ItemProgress
        XCTAssertNotNil(itemProgress)
        XCTAssertNotNil(itemProgress?.assignment)
        XCTAssertEqual(itemProgress?.assignment?.id, assignment.id)
    }
    
    // MARK: - Helper Methods
    
    /// Helper to wait for async Task completion
    private func awaitTask() throws {
        // Small delay to allow async operations to complete
        let expectation = expectation(description: "Async operation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}

