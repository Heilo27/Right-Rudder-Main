//
//  ProgressCalculationTests.swift
//  Right RudderTests
//
//  Tests for core progress calculation logic
//

import XCTest
import SwiftData
@testable import Right_Rudder

final class ProgressCalculationTests: XCTestCase {
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
    
    // MARK: - ChecklistAssignment Progress Tests
    
    func testProgressPercentage_EmptyAssignment_ReturnsZero() throws {
        // Given: An assignment with no items
        let template = makeTestTemplate(itemCount: 0)
        modelContext.insert(template)
        
        let assignment = ChecklistAssignment(
            templateId: template.id,
            templateIdentifier: template.templateIdentifier
        )
        assignment.template = template
        modelContext.insert(assignment)
        
        try saveContext(modelContext)
        
        // When: Calculating progress
        let progress = assignment.progressPercentage
        
        // Then: Should return 0
        XCTAssertEqual(progress, 0.0, accuracy: 0.001)
    }
    
    func testProgressPercentage_NoCompletedItems_ReturnsZero() throws {
        // Given: An assignment with items but none completed
        let (_, _, assignment) = createTestScenario(
            modelContext: modelContext,
            templateItemCount: 3
        )
        
        // Ensure no items are marked complete
        assignment.itemProgress?.forEach { $0.isComplete = false }
        try saveContext(modelContext)
        
        // When: Calculating progress
        let progress = assignment.progressPercentage
        
        // Then: Should return 0
        XCTAssertEqual(progress, 0.0, accuracy: 0.001)
    }
    
    func testProgressPercentage_HalfCompleted_ReturnsFiftyPercent() throws {
        // Given: An assignment with 4 items, 2 completed
        let (_, _, assignment) = createTestScenario(
            modelContext: modelContext,
            templateItemCount: 4
        )
        
        // Mark first 2 items as complete
        assignment.itemProgress?[0].isComplete = true
        assignment.itemProgress?[1].isComplete = true
        try saveContext(modelContext)
        
        // When: Calculating progress
        let progress = assignment.progressPercentage
        
        // Then: Should return 0.5 (50%)
        XCTAssertEqual(progress, 0.5, accuracy: 0.001)
    }
    
    func testProgressPercentage_AllCompleted_ReturnsOneHundredPercent() throws {
        // Given: An assignment with all items completed
        let (_, _, assignment) = createTestScenario(
            modelContext: modelContext,
            templateItemCount: 3
        )
        
        // Mark all items as complete
        assignment.itemProgress?.forEach { $0.isComplete = true }
        try saveContext(modelContext)
        
        // When: Calculating progress
        let progress = assignment.progressPercentage
        
        // Then: Should return 1.0 (100%)
        XCTAssertEqual(progress, 1.0, accuracy: 0.001)
    }
    
    func testCompletedItemsCount_CountsOnlyCompletedItems() throws {
        // Given: An assignment with mixed completion
        let (_, _, assignment) = createTestScenario(
            modelContext: modelContext,
            templateItemCount: 5
        )
        
        // Mark items 0, 2, 4 as complete
        assignment.itemProgress?[0].isComplete = true
        assignment.itemProgress?[2].isComplete = true
        assignment.itemProgress?[4].isComplete = true
        try saveContext(modelContext)
        
        // When: Getting completed count
        let count = assignment.completedItemsCount
        
        // Then: Should return 3
        XCTAssertEqual(count, 3)
    }
    
    func testTotalItemsCount_UsesItemProgressCount() throws {
        // Given: An assignment with ItemProgress records
        let (_, _, assignment) = createTestScenario(
            modelContext: modelContext,
            templateItemCount: 5
        )
        try saveContext(modelContext)
        
        // When: Getting total count
        let count = assignment.totalItemsCount
        
        // Then: Should return 5
        XCTAssertEqual(count, 5)
    }
    
    // MARK: - Student Progress Tests (Basic)
    
    func testStudentProgressForCategory_NoAssignments_ReturnsZero() throws {
        // Given: A student with no assignments
        let student = makeTestStudent(category: "PPL")
        modelContext.insert(student)
        try saveContext(modelContext)
        
        // When: Calculating progress for category
        let progress = student.progressForCategory("PPL")
        
        // Then: Should return 0
        XCTAssertEqual(progress, 0.0, accuracy: 0.001)
    }
    
    func testStudentProgressForCategory_WithMatchingAssignments() throws {
        // Given: A student with PPL assignments
        let student = makeTestStudent(category: "PPL")
        modelContext.insert(student)
        
        let template1 = makeTestTemplate(name: "PPL Lesson 1", category: "PPL", itemCount: 4)
        let template2 = makeTestTemplate(name: "PPL Lesson 2", category: "PPL", itemCount: 4)
        modelContext.insert(template1)
        modelContext.insert(template2)
        
        // Create assignments
        let assignment1 = ChecklistAssignment(templateId: template1.id, templateIdentifier: template1.templateIdentifier)
        let assignment2 = ChecklistAssignment(templateId: template2.id, templateIdentifier: template2.templateIdentifier)
        
        assignment1.student = student
        assignment1.template = template1
        assignment2.student = student
        assignment2.template = template2
        
        // Complete all items in assignment1 (50% of total)
        if let items = template1.items {
            var progressArray: [ItemProgress] = []
            for item in items {
                let progress = ItemProgress(templateItemId: item.id)
                progress.isComplete = true
                progress.assignment = assignment1
                progressArray.append(progress)
                modelContext.insert(progress)
            }
            assignment1.itemProgress = progressArray
        }
        
        // Leave assignment2 incomplete
        if let items = template2.items {
            var progressArray: [ItemProgress] = []
            for item in items {
                let progress = ItemProgress(templateItemId: item.id)
                progress.assignment = assignment2
                progressArray.append(progress)
                modelContext.insert(progress)
            }
            assignment2.itemProgress = progressArray
        }
        
        if student.checklistAssignments == nil {
            student.checklistAssignments = []
        }
        student.checklistAssignments?.append(assignment1)
        student.checklistAssignments?.append(assignment2)
        
        modelContext.insert(assignment1)
        modelContext.insert(assignment2)
        try saveContext(modelContext)
        
        // When: Calculating progress for PPL category
        let progress = student.progressForCategory("PPL")
        
        // Then: Should return 0.5 (4 completed out of 8 total)
        XCTAssertEqual(progress, 0.5, accuracy: 0.01)
    }
}

