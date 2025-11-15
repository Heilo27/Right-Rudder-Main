# Focused Testing Strategy - High Efficacy Approach

**Date:** January 2025  
**Goal:** Test foundational, stable core capabilities that must work correctly

---

## Philosophy

**Test what matters, not everything.** Focus on:
1. **Core business logic** that's unlikely to be refactored away
2. **Foundational calculations** that must be correct
3. **Critical relationships** that form the app's foundation
4. **Avoid** testing implementation details that may change

---

## Core Capabilities to Test (Priority Order)

### 1. Progress Calculation Logic ⭐⭐⭐
**Why:** Core feature, complex logic (500+ lines), high bug risk  
**Stability:** Very stable - unlikely to be removed or drastically refactored  
**Location:** `Student.swift` - `progressForCategory()`, `calculateOverallProgress()`, etc.

**What to Test:**
- Weighted progress calculation (70% checklist, 15% docs, 15% personal info)
- Category-specific progress (PPL, IFR, CPL, Review)
- Edge cases (empty, complete, partial progress)
- Document progress calculation
- Personal info progress
- Review category (no documents required)

**Risk if Broken:** High - Progress display is core feature

---

### 2. Checklist Assignment Service ⭐⭐⭐
**Why:** Core business logic for assigning lessons to students  
**Stability:** Stable API - core functionality unlikely to change  
**Location:** `ChecklistAssignmentService.swift`

**What to Test:**
- Assign template to student (creates assignment + ItemProgress records)
- Remove assignment (cleanup relationships)
- Prevent duplicate assignments
- ItemProgress record creation (one per template item)
- Relationship integrity (student ↔ assignment ↔ template)

**Risk if Broken:** High - Can't assign lessons to students

---

### 3. ChecklistAssignment Computed Properties ⭐⭐
**Why:** Simple but critical calculations  
**Stability:** Very stable - simple computed properties  
**Location:** `ChecklistAssignment.swift`

**What to Test:**
- `progressPercentage` calculation
- `completedItemsCount` calculation
- `totalItemsCount` calculation (handles empty/nil cases)
- `isComplete` calculation

**Risk if Broken:** Medium - Progress display incorrect

---

### 4. Data Model Relationships ⭐
**Why:** Foundation of the app - relationships must work  
**Stability:** Very stable - SwiftData relationships  
**Location:** All model files

**What to Test:**
- Student → ChecklistAssignment relationship
- ChecklistAssignment → ItemProgress relationship
- ChecklistAssignment → ChecklistTemplate relationship
- Cascade delete rules (Student deleted → assignments deleted)
- Nullify delete rules (Template deleted → assignments remain)

**Risk if Broken:** Medium - Data integrity issues

---

## What NOT to Test (For Now)

### ❌ CloudKit Sync Operations
**Why:** Will be refactored (HIGH-005, HIGH-006)  
**Risk:** Tests would be thrown away

### ❌ UI Components
**Why:** User preference - focus on unit tests  
**Risk:** UI may change significantly

### ❌ Template Management
**Why:** May be refactored  
**Risk:** Lower priority than core calculations

### ❌ PDF Export
**Why:** Minimal implementation, may be enhanced  
**Risk:** Lower priority

---

## Minimal Test Infrastructure Needed

### 1. SwiftData In-Memory Container
**Purpose:** Test data persistence and relationships  
**Effort:** 1-2 hours  
**Reusable:** Yes - foundation for all tests

```swift
func makeTestContainer() throws -> ModelContainer {
    let schema = Schema([
        Student.self,
        ChecklistTemplate.self,
        ChecklistItem.self,
        ChecklistAssignment.self,
        ItemProgress.self,
        // ... other models
    ])
    
    let config = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: true
    )
    
    return try ModelContainer(for: schema, configurations: [config])
}
```

### 2. Test Data Factories
**Purpose:** Create test objects quickly  
**Effort:** 2-3 hours  
**Reusable:** Yes - used by all tests

```swift
// Minimal factories - just what's needed
func makeTestStudent() -> Student
func makeTestTemplate(items: Int) -> ChecklistTemplate
func makeTestAssignment(student: Student, template: ChecklistTemplate) -> ChecklistAssignment
```

### 3. Test Utilities
**Purpose:** Common test helpers  
**Effort:** 1 hour  
**Reusable:** Yes

```swift
// Helper to create complete test scenarios
func createTestScenario() -> (student: Student, template: ChecklistTemplate, assignment: ChecklistAssignment)
```

---

## Implementation Plan

### Phase 1: Minimal Infrastructure (2-3 hours)
1. Set up SwiftData in-memory container
2. Create minimal test data factories
3. Write one example test to verify setup

### Phase 2: Progress Calculation Tests (4-6 hours)
1. Test weighted progress calculation
2. Test category-specific progress
3. Test edge cases
4. Use tests to verify correctness and drive fixes

### Phase 3: Assignment Service Tests (3-4 hours)
1. Test assignment creation
2. Test relationship integrity
3. Test ItemProgress record creation
4. Test removal/cleanup

### Phase 4: Computed Properties Tests (1-2 hours)
1. Test ChecklistAssignment progress calculations
2. Test edge cases (empty, nil, etc.)

**Total Effort:** 10-15 hours (vs. 8-12 hours for full infrastructure)

---

## Success Criteria

✅ **Tests verify correctness** of core calculations  
✅ **Tests catch regressions** before they reach production  
✅ **Tests drive refactoring** with confidence  
✅ **Minimal infrastructure** - no over-engineering  
✅ **High efficacy** - tests things that matter

---

## Next Steps

1. Set up minimal test infrastructure
2. Write first test for progress calculation
3. Use test to verify/fix any issues found
4. Expand to other core capabilities

---

**Last Updated:** January 2025  
**Review:** After Phase 1 completion

