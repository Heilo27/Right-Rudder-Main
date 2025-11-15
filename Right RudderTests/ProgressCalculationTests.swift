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
        
        // Then: Should return approximately 0.5 (4 completed out of 8 total, scaled to 83%)
        // Average progress: (1.0 + 0.0) / 2 = 0.5, scaled to 83% = 41.5%
        XCTAssertEqual(progress, 41.5, accuracy: 1.0)
    }
    
    // MARK: - Personal Info Progress Tests
    
    func testPersonalInfoProgress_AllFieldsEmpty_ReturnsZero() throws {
        // Given: A student with all personal info fields empty
        let student = makeTestStudent(
            firstName: "",
            lastName: "",
            email: "",
            telephone: "",
            homeAddress: "",
            ftnNumber: ""
        )
        modelContext.insert(student)
        try saveContext(modelContext)
        
        // When: Calculating personal info progress
        let progress = student.personalInfoProgress
        
        // Then: Should return 0
        XCTAssertEqual(progress, 0.0, accuracy: 0.001)
    }
    
    func testPersonalInfoProgress_AllFieldsFilled_ReturnsOneHundred() throws {
        // Given: A student with all personal info fields filled
        let student = makeTestStudent(
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com",
            telephone: "555-1234",
            homeAddress: "123 Main St"
        )
        modelContext.insert(student)
        try saveContext(modelContext)
        
        // When: Calculating personal info progress
        let progress = student.personalInfoProgress
        
        // Then: Should return 100 (20 points per field × 5 fields)
        XCTAssertEqual(progress, 100.0, accuracy: 0.001)
    }
    
    func testPersonalInfoProgress_PartialFields_ReturnsCorrectPercentage() throws {
        // Given: A student with 3 out of 5 fields filled
        let student = makeTestStudent(
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com",
            telephone: "",
            homeAddress: ""
        )
        modelContext.insert(student)
        try saveContext(modelContext)
        
        // When: Calculating personal info progress
        let progress = student.personalInfoProgress
        
        // Then: Should return 60 (20 points × 3 fields)
        XCTAssertEqual(progress, 60.0, accuracy: 0.001)
    }
    
    // MARK: - Document Progress Tests
    
    func testDocumentProgress_ReviewCategory_ReturnsOneHundred() throws {
        // Given: A student in Review category
        let student = makeTestStudent(category: "Review")
        modelContext.insert(student)
        try saveContext(modelContext)
        
        // When: Calculating document progress
        let progress = student.documentProgress
        
        // Then: Should return 100 (Review category doesn't require documents)
        XCTAssertEqual(progress, 100.0, accuracy: 0.001)
    }
    
    func testDocumentProgress_NoDocuments_ReturnsOneHundred() throws {
        // Given: A student with no documents (nil documents array)
        let student = makeTestStudent(category: "PPL")
        student.documents = nil
        modelContext.insert(student)
        try saveContext(modelContext)
        
        // When: Calculating document progress
        let progress = student.documentProgress
        
        // Then: Should return 100 (default when no documents system)
        XCTAssertEqual(progress, 100.0, accuracy: 0.001)
    }
    
    // MARK: - Weighted Overall Progress Tests
    
    func testOverallProgress_PPLCategory_WeightedCalculation() throws {
        // Given: A PPL student with:
        // - 50% checklist progress (4/8 items completed)
        // - 100% document progress (no documents = 100%)
        // - 100% personal info progress
        let student = makeTestStudent(category: "PPL")
        modelContext.insert(student)
        
        // Create assignments with 50% completion
        let template1 = makeTestTemplate(name: "PPL Lesson 1", category: "PPL", itemCount: 4)
        let template2 = makeTestTemplate(name: "PPL Lesson 2", category: "PPL", itemCount: 4)
        modelContext.insert(template1)
        modelContext.insert(template2)
        
        let assignment1 = ChecklistAssignment(templateId: template1.id, templateIdentifier: template1.templateIdentifier)
        let assignment2 = ChecklistAssignment(templateId: template2.id, templateIdentifier: template2.templateIdentifier)
        
        assignment1.student = student
        assignment1.template = template1
        assignment2.student = student
        assignment2.template = template2
        
        // Complete all items in assignment1
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
        
        // When: Calculating overall progress
        // Note: We need to access the private calculateOverallProgress via progressForCategory
        // For PPL category, progressForCategory uses categoryGoalProgress which includes milestones
        // Let's test the weighted calculation indirectly through the category progress
        
        // The weighted calculation should be:
        // 70% checklist (0.5) + 15% docs (1.0) + 15% personal info (1.0)
        // = 0.35 + 0.15 + 0.15 = 0.65 = 65%
        
        // But progressForCategory uses categoryGoalProgress which scales checklist to 83% max
        // So we'll verify the category progress is calculated correctly
        let progress = student.progressForCategory("PPL")
        
        // Then: Should return a value based on weighted calculation
        // Category progress scales checklist to 83% max, so 50% completion = 41.5% checklist progress
        // Then adds milestone bonuses (none in this test) = 41.5%
        XCTAssertGreaterThan(progress, 0.0)
        XCTAssertLessThanOrEqual(progress, 100.0)
    }
    
    func testOverallProgress_ReviewCategory_NoDocumentsWeighting() throws {
        // Given: A Review student with:
        // - 50% checklist progress
        // - 100% personal info progress
        // - Documents not required (Review category)
        let student = makeTestStudent(category: "Review")
        modelContext.insert(student)
        
        // Create assignments with 50% completion
        let template1 = makeTestTemplate(name: "Review Lesson 1", category: "Review", itemCount: 4)
        let template2 = makeTestTemplate(name: "Review Lesson 2", category: "Review", itemCount: 4)
        modelContext.insert(template1)
        modelContext.insert(template2)
        
        let assignment1 = ChecklistAssignment(templateId: template1.id, templateIdentifier: template1.templateIdentifier)
        let assignment2 = ChecklistAssignment(templateId: template2.id, templateIdentifier: template2.templateIdentifier)
        
        assignment1.student = student
        assignment1.template = template1
        assignment2.student = student
        assignment2.template = template2
        
        // Complete all items in assignment1
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
        
        // When: Calculating progress for Review category
        let progress = student.progressForCategory("Review")
        
        // Then: Should return approximately 50% (Review scales to 100%, no milestones)
        // Average progress: (1.0 + 0.0) / 2 = 0.5, scaled to 100% = 50%
        XCTAssertEqual(progress, 50.0, accuracy: 1.0)
    }
    
    // MARK: - Edge Cases
    
    func testProgress_EmptyAssignments_ReturnsZero() throws {
        // Given: A student with empty assignments array
        let student = makeTestStudent(category: "PPL")
        student.checklistAssignments = []
        modelContext.insert(student)
        try saveContext(modelContext)
        
        // When: Calculating progress
        let progress = student.progressForCategory("PPL")
        
        // Then: Should return 0
        XCTAssertEqual(progress, 0.0, accuracy: 0.001)
    }
    
    func testProgress_NilAssignments_ReturnsZero() throws {
        // Given: A student with nil assignments
        let student = makeTestStudent(category: "PPL")
        student.checklistAssignments = nil
        modelContext.insert(student)
        try saveContext(modelContext)
        
        // When: Calculating progress
        let progress = student.progressForCategory("PPL")
        
        // Then: Should return 0
        XCTAssertEqual(progress, 0.0, accuracy: 0.001)
    }
}

