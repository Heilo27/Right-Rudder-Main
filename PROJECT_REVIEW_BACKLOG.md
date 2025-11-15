# Right Rudder Project Review - Prioritized Backlog

**Generated:** January 2025  
**Review Date:** January 2025  
**App Store Version:** 1.6.1  
**Codebase Version:** 1.6.2

---

## Executive Summary

This backlog contains **47 prioritized work items** identified during the comprehensive project review. Items are organized by priority (Critical, High, Medium, Low) and include effort estimates, dependencies, and acceptance criteria.

**Key Statistics:**
- **Critical Issues:** 4 items
- **High Priority:** 12 items
- **Medium Priority:** 18 items
- **Low Priority:** 13 items
- **Total Estimated Effort:** ~400-500 hours

---

## Critical Priority

### CRIT-001: Fix AGENTS.md Path References
**Category:** Process / Documentation  
**Effort:** 15 minutes  
**Dependencies:** None

**Description:**
AGENTS.md references incorrect path `/Users/nitewriter/Development/HelpingRyan` instead of `/Users/nitewriter/Development/Right Rudder`. This causes all commands to fail if followed literally.

**Acceptance Criteria:**
- [x] All path references updated to `/Users/nitewriter/Development/Right Rudder`
- [x] All commands verified to work with correct path
- [x] No references to "HelpingRyan" remain

**Files:**
- `AGENTS.md` (lines 9, 24, 33)

---

### CRIT-002: Investigate and Fix Lesson Plan Syncing Issues
**Category:** Bug / CloudKit  
**Effort:** 16-24 hours  
**Dependencies:** None

**Description:**
User-reported issues with lesson plan syncing to student app. This is a core feature affecting companion app integration.

**Investigation Steps:**
1. Enable detailed CloudKit logging
2. Test sync flow end-to-end
3. Verify CloudKit schema deployment
4. Check CloudKit Dashboard for errors
5. Review sync error handling
6. Test with actual student app

**Acceptance Criteria:**
- [ ] Root cause identified
- [ ] Fix implemented and tested
- [ ] Sync works reliably end-to-end
- [ ] Error handling improved
- [ ] Documentation updated

**Files:**
- `CloudKitShareService.swift`
- `CloudKitSyncService.swift`
- `ChecklistAssignmentService.swift`

---

### CRIT-003: Set Up Test Infrastructure
**Category:** Testing / Quality Assurance  
**Effort:** 8-12 hours  
**Dependencies:** None

**Description:**
Currently 0% test coverage. Need to establish test infrastructure before making changes safely.

**Tasks:**
1. Set up SwiftData in-memory test container
2. Create CloudKit mock framework
3. Build test data factories
4. Create test utilities
5. Set up CI/CD for test execution
6. Configure code coverage reporting

**Acceptance Criteria:**
- [ ] Test infrastructure in place
- [ ] Can write and run unit tests
- [ ] Can write and run UI tests
- [ ] Code coverage reporting works
- [ ] CI/CD runs tests automatically
- [ ] Documentation for writing tests

**Files:**
- `Right_RudderTests/`
- `Right_RudderUITests/`
- New test utilities module

---

### CRIT-004: Fix Code Formatting Violations
**Category:** Code Quality  
**Effort:** 4-8 hours  
**Dependencies:** None

**Description:**
30,444 formatting violations found. Violates AGENTS.md standards and affects code readability.

**Tasks:**
1. Run `swift format --in-place --recursive "Right Rudder"`
2. Review and commit formatting changes
3. Create `.swift-format.json` configuration
4. Set up pre-commit hook or CI check
5. Document formatting standards

**Acceptance Criteria:**
- [x] All formatting violations fixed (reduced from 30,444 to 25 minor warnings)
- [x] `.swift-format.json` created
- [ ] Pre-commit hook or CI check prevents violations (next step)
- [x] Code passes `swift format lint` with only minor style warnings remaining
- [x] Formatting standards documented in `.swift-format.json`

**Files:**
- All Swift files (74 files)
- `.swift-format.json` (new)

---

## High Priority

### HIGH-001: Investigate SwiftUI Layout Issues
**Category:** Bug / UI  
**Effort:** 8-16 hours  
**Dependencies:** None

**Description:**
User-reported SwiftUI layout problems. Need to identify specific issues and fix.

**Investigation Steps:**
1. Collect specific user feedback
2. Test on multiple device sizes
3. Review state management in problematic views
4. Check for view update timing issues
5. Verify frame/padding constraints

**Acceptance Criteria:**
- [ ] Specific layout issues identified
- [ ] Root causes determined
- [ ] Fixes implemented
- [ ] Tested on iPhone and iPad
- [ ] User confirms fixes

**Files:**
- `StudentDetailView.swift`
- `SettingsView.swift`
- `ChecklistTemplatesView.swift`
- `StudentsView.swift`

---

### HIGH-002: Write Tests for CloudKit Sync Operations
**Category:** Testing  
**Effort:** 16-24 hours  
**Dependencies:** CRIT-003

**Description:**
Critical CloudKit sync operations have no test coverage. Need comprehensive tests.

**Test Cases:**
1. Sync students to CloudKit
2. Sync checklist templates
3. Sync assignments and progress
4. Sync documents and endorsements
5. Conflict resolution
6. Offline sync queue
7. Error handling

**Acceptance Criteria:**
- [ ] Tests for all sync operations
- [ ] Mock CloudKit framework used
- [ ] Error scenarios tested
- [ ] 80%+ coverage of sync code
- [ ] Tests pass in CI/CD

**Files:**
- `CloudKitSyncService.swift`
- `CloudKitShareService.swift`
- New test files

---

### HIGH-003: Write Tests for Progress Calculation Logic
**Category:** Testing  
**Effort:** 8-12 hours  
**Dependencies:** CRIT-003

**Description:**
Complex progress calculation logic (500+ lines) has no tests. High risk of bugs.

**Test Cases:**
1. Weighted progress calculation
2. Category-specific progress
3. Edge cases (empty, complete, partial)
4. Document progress calculation
5. Personal info progress
6. Goal progress bonuses

**Acceptance Criteria:**
- [ ] Tests for all progress calculations
- [ ] Edge cases covered
- [ ] 90%+ coverage of progress logic
- [ ] Tests pass consistently

**Files:**
- `Student.swift` (progress calculation)
- New test file

---

### HIGH-004: Write Tests for Checklist Assignment Service
**Category:** Testing  
**Effort:** 6-10 hours  
**Dependencies:** CRIT-003

**Description:**
Core business logic for assigning templates to students has no tests.

**Test Cases:**
1. Assign template to student
2. Remove assignment
3. Display item resolution
4. Template relationship management
5. Custom checklist handling

**Acceptance Criteria:**
- [ ] Tests for all assignment operations
- [ ] Relationship integrity tested
- [ ] 80%+ coverage
- [ ] Tests pass

**Files:**
- `ChecklistAssignmentService.swift`
- New test file

---

### HIGH-005: Split CloudKitShareService into Smaller Services
**Category:** Technical Debt / Architecture  
**Effort:** 16-24 hours  
**Dependencies:** HIGH-002 (tests first)

**Description:**
`CloudKitShareService.swift` is 3500+ lines with multiple responsibilities. Needs refactoring.

**Proposed Split:**
1. `CloudKitShareService` - Core sharing (CKShare operations)
2. `CloudKitSchemaService` - Schema management
3. `ChecklistLibraryService` - Library resolution
4. Shared utilities module

**Acceptance Criteria:**
- [ ] Service split into 3-4 focused services
- [ ] Each service < 1000 lines
- [ ] Single responsibility per service
- [ ] All tests pass
- [ ] No functionality lost
- [ ] Documentation updated

**Files:**
- `CloudKitShareService.swift` → Split into multiple files

---

### HIGH-006: Split CloudKitSyncService into Smaller Services
**Category:** Technical Debt / Architecture  
**Effort:** 12-20 hours  
**Dependencies:** HIGH-002 (tests first)

**Description:**
`CloudKitSyncService.swift` is 1700+ lines with multiple sync responsibilities.

**Proposed Split:**
1. `CloudKitSyncService` - Core sync coordination
2. `StudentSyncService` - Student sync operations
3. `TemplateSyncService` - Template sync operations
4. Shared sync utilities

**Acceptance Criteria:**
- [ ] Service split into 2-3 focused services
- [ ] Each service < 800 lines
- [ ] Single responsibility per service
- [ ] All tests pass
- [ ] No functionality lost

**Files:**
- `CloudKitSyncService.swift` → Split into multiple files

---

### HIGH-007: Extract Progress Calculation to Service
**Category:** Architecture / Technical Debt  
**Effort:** 12-16 hours  
**Dependencies:** HIGH-003 (tests first)

**Description:**
500+ lines of progress calculation logic in `Student` model violates separation of concerns.

**Tasks:**
1. Create `StudentProgressService`
2. Move progress calculation methods
3. Update all call sites
4. Keep model lean
5. Add tests

**Acceptance Criteria:**
- [ ] Progress calculation in service
- [ ] Student model < 200 lines
- [ ] All tests pass
- [ ] No functionality lost
- [ ] Better testability

**Files:**
- `Student.swift` → Extract to `StudentProgressService.swift`

---

### HIGH-008: Split NewModels.swift into Separate Files
**Category:** Code Organization  
**Effort:** 2-4 hours  
**Dependencies:** None

**Description:**
`NewModels.swift` violates one-type-per-file rule. Contains 4 model classes that should be in separate files:
- `ChecklistAssignment`
- `ItemProgress`
- `CustomChecklistDefinition`
- `CustomChecklistItem`

**Tasks:**
1. Create `ChecklistAssignment.swift`
2. Create `ItemProgress.swift`
3. Create `CustomChecklistDefinition.swift`
4. Create `CustomChecklistItem.swift`
5. Update imports across codebase
6. Delete `NewModels.swift`

**Acceptance Criteria:**
- [ ] Each model in its own file
- [ ] File names match type names
- [ ] All imports updated
- [ ] Build succeeds
- [ ] No functionality lost

**Files:**
- `NewModels.swift` → Split into 4 files

**Related Rule:** `.cursor/rules/swift-code-organization.mdc` - One Type Per File

---

### HIGH-009: Extract Subviews from StudentDetailView
**Category:** Code Organization / Architecture  
**Effort:** 8-12 hours  
**Dependencies:** None

**Description:**
`StudentDetailView.swift` is 1524 lines, exceeding the 1000-line guideline. Needs subview extraction.

**Tasks:**
1. Identify logical subview components
2. Extract subviews to separate files
3. Use MARK comments for organization
4. Maintain functionality
5. Improve testability

**Proposed Subviews:**
- `StudentHeaderView` - Student info header
- `StudentChecklistsView` - Checklist list section
- `StudentEndorsementsView` - Endorsements section
- `StudentDocumentsView` - Documents section
- `StudentProgressView` - Progress indicators

**Acceptance Criteria:**
- [ ] Main view < 500 lines
- [ ] Subviews extracted to separate files
- [ ] MARK comments organize sections
- [ ] All functionality preserved
- [ ] Build succeeds

**Files:**
- `StudentDetailView.swift` → Extract subviews

**Related Rule:** `.cursor/rules/swift-code-organization.mdc` - File Size Guidelines

---

### HIGH-010: Extract Subviews from EndorsementView
**Category:** Code Organization / Architecture  
**Effort:** 6-10 hours  
**Dependencies:** None

**Description:**
`EndorsementView.swift` is 1248 lines, exceeding the 1000-line guideline. Needs subview extraction.

**Tasks:**
1. Identify logical subview components
2. Extract subviews to separate files
3. Use MARK comments for organization
4. Maintain functionality

**Acceptance Criteria:**
- [ ] Main view < 500 lines
- [ ] Subviews extracted to separate files
- [ ] MARK comments organize sections
- [ ] All functionality preserved
- [ ] Build succeeds

**Files:**
- `EndorsementView.swift` → Extract subviews

**Related Rule:** `.cursor/rules/swift-code-organization.mdc` - File Size Guidelines

---

### HIGH-011: Refactor DefaultTemplates.swift
**Category:** Code Organization / Technical Debt  
**Effort:** 12-20 hours  
**Dependencies:** None

**Description:**
`DefaultTemplates.swift` is 6107 lines - extremely large. Contains default checklist templates that should be organized better.

**Tasks:**
1. Analyze template structure
2. Consider moving templates to JSON resource file
3. Or split into category-based files (PPL, IFR, CPL, etc.)
4. Create template loading service
5. Maintain backward compatibility

**Options:**
- **Option A:** Move templates to JSON file, load via service
- **Option B:** Split into category files (`DefaultTemplatesPPL.swift`, etc.)
- **Option C:** Extract template definitions to separate model files

**Acceptance Criteria:**
- [ ] File size reduced significantly (< 1000 lines)
- [ ] Templates still load correctly
- [ ] No functionality lost
- [ ] Better maintainability
- [ ] Build succeeds

**Files:**
- `DefaultTemplates.swift` → Refactor

**Related Rule:** `.cursor/rules/swift-code-organization.mdc` - File Size Guidelines

---

### HIGH-008: Add Accessibility Features
**Category:** Feature / Accessibility  
**Effort:** 16-24 hours  
**Dependencies:** None

**Description:**
App Store listing shows no accessibility features indicated. Need to audit and add.

**Tasks:**
1. Audit all views for accessibility
2. Add `accessibilityLabel` to all interactive elements
3. Add `accessibilityHint` where helpful
4. Add `accessibilityTraits` appropriately
5. Test with VoiceOver
6. Verify Dynamic Type support
7. Update App Store listing

**Acceptance Criteria:**
- [ ] All views accessible
- [ ] VoiceOver tested and working
- [ ] Dynamic Type supported
- [ ] App Store listing updated
- [ ] Accessibility documentation

**Files:**
- All view files (37+ files)

---

### HIGH-009: Align Version Numbers
**Category:** Process  
**Effort:** 30 minutes  
**Dependencies:** None

**Description:**
Codebase version (1.6.2) ahead of published version (1.6.1). Process not followed.

**Tasks:**
1. Determine correct version
2. Update project.pbxproj if needed
3. Review version management process
4. Document version update workflow

**Acceptance Criteria:**
- [ ] Versions aligned
- [ ] Process documented
- [ ] Version management guide followed

**Files:**
- `Right Rudder.xcodeproj/project.pbxproj`

---

### HIGH-010: Verify Build Number Auto-Increment Script
**Category:** Process  
**Effort:** 1-2 hours  
**Dependencies:** None

**Description:**
VERSION_MANAGEMENT_GUIDE.md describes auto-increment script but may not be configured.

**Tasks:**
1. Check Build Phases for script
2. Verify script is before "Compile Sources"
3. Test build number increments
4. Configure if missing
5. Document configuration

**Acceptance Criteria:**
- [ ] Script configured correctly
- [ ] Build number increments automatically
- [ ] Script documented
- [ ] Process verified

**Files:**
- Xcode project Build Phases
- `VERSION_MANAGEMENT_GUIDE.md`

---

### HIGH-011: Set Up CI/CD Pipeline
**Category:** Process / Infrastructure  
**Effort:** 8-16 hours  
**Dependencies:** CRIT-003, CRIT-004

**Description:**
No CI/CD configuration found. Need automated quality gates.

**Tasks:**
1. Set up Xcode Cloud or GitHub Actions
2. Configure build and test execution
3. Add formatting checks
4. Add code coverage reporting
5. Set quality gates
6. Document CI/CD process

**Acceptance Criteria:**
- [ ] CI/CD configured
- [ ] Tests run automatically
- [ ] Formatting checked
- [ ] Coverage reported
- [ ] Quality gates enforced
- [ ] Documentation

---

### HIGH-012: Improve Error Handling in CloudKit Services
**Category:** Code Quality / Reliability  
**Effort:** 8-12 hours  
**Dependencies:** HIGH-002 (tests)

**Description:**
Error handling in CloudKit services may be inconsistent. Need standardization.

**Tasks:**
1. Audit error handling in CloudKit services
2. Create error type hierarchy
3. Standardize error handling patterns
4. Improve user-facing error messages
5. Add error logging
6. Test error scenarios

**Acceptance Criteria:**
- [ ] Consistent error handling
- [ ] User-friendly error messages
- [ ] Error logging in place
- [ ] Error scenarios tested
- [ ] Documentation updated

**Files:**
- `CloudKitShareService.swift`
- `CloudKitSyncService.swift`
- `CloudKitBackupService.swift`

---

## Medium Priority

### MED-001: Write Tests for Student Management
**Category:** Testing  
**Effort:** 8-12 hours  
**Dependencies:** CRIT-003

**Description:**
Core student CRUD operations have no test coverage.

**Test Cases:**
1. Create student
2. Edit student
3. Delete student
4. Student filtering
5. Progress tracking

**Acceptance Criteria:**
- [ ] Tests for all CRUD operations
- [ ] 80%+ coverage
- [ ] Tests pass

---

### MED-002: Write Tests for Template Management
**Category:** Testing  
**Effort:** 6-10 hours  
**Dependencies:** CRIT-003

**Description:**
Template creation, updates, and sharing have no tests.

**Test Cases:**
1. Create template
2. Edit template
3. Delete template
4. Template sharing
5. Template import

**Acceptance Criteria:**
- [ ] Tests for template operations
- [ ] 70%+ coverage
- [ ] Tests pass

---

### MED-003: Write Tests for Data Model Relationships
**Category:** Testing  
**Effort:** 4-8 hours  
**Dependencies:** CRIT-003

**Description:**
SwiftData model relationships need testing to ensure integrity.

**Test Cases:**
1. Relationship creation
2. Delete rules (cascade, nullify)
3. Inverse relationships
4. Relationship integrity

**Acceptance Criteria:**
- [ ] Tests for all relationships
- [ ] Delete rules verified
- [ ] 90%+ coverage
- [ ] Tests pass

---

### MED-004: Organize Code into Logical Directories
**Category:** Code Organization  
**Effort:** 4-6 hours  
**Dependencies:** HIGH-008, HIGH-009, HIGH-010 (complete file splits first)

**Description:**
Views and services are mixed in same directory. Need better organization.

**Proposed Structure:**
```
Right Rudder/
├── Models/
│   ├── Student.swift
│   ├── ChecklistTemplate.swift
│   ├── ChecklistAssignment.swift
│   ├── ItemProgress.swift
│   ├── CustomChecklistDefinition.swift
│   ├── CustomChecklistItem.swift
│   ├── StudentDocument.swift
│   └── EndorsementImage.swift
├── Views/
│   ├── Student/
│   │   ├── StudentsView.swift
│   │   ├── StudentDetailView.swift
│   │   ├── StudentHeaderView.swift
│   │   ├── StudentChecklistsView.swift
│   │   └── ...
│   ├── Checklist/
│   ├── Endorsement/
│   └── Settings/
├── Services/
│   ├── CloudKit/
│   ├── Database/
│   └── Utilities/
└── Documentation/
```

**Acceptance Criteria:**
- [ ] Files organized logically
- [ ] Easy to find files
- [ ] No broken imports
- [ ] Build succeeds
- [ ] Follows code organization rules

**Related Rule:** `.cursor/rules/swift-code-organization.mdc` - Directory Organization

---

### MED-009: Add MARK Comments to All Files
**Category:** Code Organization  
**Effort:** 4-8 hours  
**Dependencies:** None

**Description:**
Only 14 of 74 files use MARK comments. All files should be organized with MARK comments for better navigation.

**Tasks:**
1. Audit files without MARK comments
2. Add MARK comments to organize sections:
   - Properties
   - Initialization
   - Body/Computed Properties
   - Subviews
   - Methods
   - Extensions
3. Ensure consistent MARK format

**Acceptance Criteria:**
- [ ] All files have MARK comments
- [ ] Consistent MARK format
- [ ] Logical section organization
- [ ] Improved Xcode navigation

**Files:**
- All Swift files (60 files need MARK comments)

**Related Rule:** `.cursor/rules/swift-code-organization.mdc` - MARK Comment Guidelines

---

### MED-010: Review and Improve Access Control
**Category:** Code Organization / Security  
**Effort:** 6-10 hours  
**Dependencies:** None

**Description:**
Review access control across codebase. Ensure private by default, public only when needed.

**Tasks:**
1. Audit access levels in all files
2. Make properties/methods private by default
3. Use internal for module-level access
4. Use public only for APIs
5. Document access control decisions

**Acceptance Criteria:**
- [ ] Private by default principle followed
- [ ] Public APIs clearly identified
- [ ] Access control documented
- [ ] No unnecessary public exposure

**Files:**
- All Swift files

**Related Rule:** `.cursor/rules/swift-code-organization.mdc` - Access Control

---

### MED-005: Create .swift-format.json Configuration
**Category:** Code Quality  
**Effort:** 1-2 hours  
**Dependencies:** CRIT-004

**Description:**
Need configuration file for consistent formatting across team.

**Configuration:**
- Line length: 100
- Indentation: 2 spaces
- Rules: Based on project needs

**Acceptance Criteria:**
- [ ] Configuration file created
- [ ] Team standards documented
- [ ] Works with swift format

**Files:**
- `.swift-format.json` (new)

---

### MED-006: Standardize Error Handling Patterns
**Category:** Code Quality  
**Effort:** 8-12 hours  
**Dependencies:** None

**Description:**
Error handling is inconsistent across codebase. Need standardization.

**Tasks:**
1. Create error type hierarchy
2. Define error handling patterns
3. Update services to use patterns
4. Improve user-facing messages
5. Document patterns

**Acceptance Criteria:**
- [ ] Error type hierarchy created
- [ ] Patterns documented
- [ ] Services updated
- [ ] User-friendly messages

---

### MED-007: Improve Code Documentation
**Category:** Documentation  
**Effort:** 8-16 hours  
**Dependencies:** None

**Description:**
Need doc comments on public APIs and complex algorithms.

**Tasks:**
1. Add doc comments to public APIs
2. Document complex algorithms
3. Update inline comments
4. Create API documentation

**Acceptance Criteria:**
- [ ] Public APIs documented
- [ ] Complex logic explained
- [ ] Documentation complete

---

### MED-008: Enhance PDF Export Functionality
**Category:** Feature Enhancement  
**Effort:** 12-20 hours  
**Dependencies:** None

**Description:**
PDF export appears minimal. App Store claims "professional, comprehensive files" - may need enhancement.

**Tasks:**
1. Review current PDF export
2. Enhance if needed
3. Test export functionality
4. Update App Store description if inaccurate

**Acceptance Criteria:**
- [ ] PDF export meets App Store claims
- [ ] Professional formatting
- [ ] All data included
- [ ] Tested and working

**Files:**
- `PDFExportService.swift`
- `StudentRecordWebView.swift`

---

### MED-009: Create Architecture Documentation
**Category:** Documentation  
**Effort:** 4-8 hours  
**Dependencies:** None

**Description:**
Need visual architecture diagram and documentation.

**Tasks:**
1. Create architecture diagram
2. Document service responsibilities
3. Document data flow
4. Create developer onboarding guide

**Acceptance Criteria:**
- [ ] Architecture diagram created
- [ ] Services documented
- [ ] Data flow documented
- [ ] Onboarding guide complete

---

### MED-010: Reduce Code Duplication
**Category:** Technical Debt  
**Effort:** 8-16 hours  
**Dependencies:** None

**Description:**
Some code duplication exists. Need to extract shared utilities.

**Areas:**
1. Progress calculation (instructor + student apps)
2. CloudKit sync patterns
3. View patterns

**Acceptance Criteria:**
- [ ] Shared utilities created
- [ ] Duplication reduced
- [ ] Code reuse improved

---

### MED-011: Add Pre-Commit Hooks
**Category:** Process  
**Effort:** 2-4 hours  
**Dependencies:** CRIT-004

**Description:**
Prevent formatting violations before commit.

**Tasks:**
1. Set up pre-commit hook
2. Run swift format lint
3. Block commits with violations
4. Document setup

**Acceptance Criteria:**
- [ ] Pre-commit hook configured
- [ ] Violations blocked
- [ ] Documentation

---

### MED-012: Write UI Tests for Critical Flows
**Category:** Testing  
**Effort:** 16-24 hours  
**Dependencies:** CRIT-003

**Description:**
Critical user flows need UI test coverage.

**Test Flows:**
1. Create student → Assign checklist → Complete items
2. Share student with companion app
3. Upload document → Sync
4. Export student record

**Acceptance Criteria:**
- [ ] Critical flows tested
- [ ] Tests pass consistently
- [ ] 20%+ UI test coverage

---

### MED-013: Review and Fix Conflict Resolution
**Category:** Bug / CloudKit  
**Effort:** 4-8 hours  
**Dependencies:** HIGH-002

**Description:**
TODO comment indicates resolved changes may not sync back to CloudKit.

**Tasks:**
1. Review conflict resolution flow
2. Implement CloudKit sync for resolved changes
3. Test conflict resolution
4. Remove TODO comment

**Acceptance Criteria:**
- [ ] Resolved changes sync to CloudKit
- [ ] Conflict resolution tested
- [ ] TODO removed

**Files:**
- `ConflictResolutionView.swift`

---

### MED-014: Implement Library Check in CloudKitShareService
**Category:** Bug / CloudKit  
**Effort:** 4-8 hours  
**Dependencies:** HIGH-002

**Description:**
TODO comment indicates library check may not be fully implemented.

**Tasks:**
1. Review library check logic
2. Implement if incomplete
3. Test library resolution
4. Remove TODO comment

**Acceptance Criteria:**
- [ ] Library check fully implemented
- [ ] Tested and working
- [ ] TODO removed

**Files:**
- `CloudKitShareService.swift`

---

### MED-015: Clean Up Debug Code
**Category:** Code Quality  
**Effort:** 2-4 hours  
**Dependencies:** None

**Description:**
Debug print statements and comments left in production code.

**Tasks:**
1. Find all debug code
2. Remove or wrap in #if DEBUG
3. Clean up debug comments
4. Review for sensitive information

**Acceptance Criteria:**
- [ ] Debug code removed/wrapped
- [ ] No sensitive info in logs
- [ ] Code cleaned up

---

### MED-016: Improve Memory Management
**Category:** Performance  
**Effort:** 8-12 hours  
**Dependencies:** None

**Description:**
Review and optimize memory usage patterns.

**Tasks:**
1. Profile memory usage
2. Identify memory leaks
3. Optimize image caching
4. Improve memory pressure handling

**Acceptance Criteria:**
- [ ] Memory leaks fixed
- [ ] Memory usage optimized
- [ ] Performance improved

---

### MED-017: Optimize CloudKit Queries
**Category:** Performance  
**Effort:** 8-12 hours  
**Dependencies:** HIGH-002

**Description:**
Review and optimize CloudKit query performance.

**Tasks:**
1. Profile CloudKit queries
2. Optimize query predicates
3. Add proper indexes
4. Reduce query frequency

**Acceptance Criteria:**
- [ ] Queries optimized
- [ ] Performance improved
- [ ] Indexes verified

---

### MED-018: Set Up Code Coverage Thresholds
**Category:** Process / Testing  
**Effort:** 2-4 hours  
**Dependencies:** CRIT-003

**Description:**
Set minimum code coverage thresholds for quality gates.

**Thresholds:**
- Overall: 60% (short term), 80% (long term)
- Critical paths: 90%
- CloudKit operations: 80%

**Acceptance Criteria:**
- [ ] Thresholds configured
- [ ] CI/CD enforces thresholds
- [ ] Documentation

---

## Low Priority

### LOW-001: Rename Right_RudderApp.swift
**Category:** Code Quality  
**Effort:** 1 hour  
**Dependencies:** None

**Description:**
File uses underscore naming (legacy). Should be `RightRudderApp.swift`.

**Acceptance Criteria:**
- [ ] File renamed
- [ ] All references updated
- [ ] Build succeeds

---

### LOW-002: Rename NewModels.swift
**Category:** Code Quality  
**Effort:** 1 hour  
**Dependencies:** HIGH-008 (will be split, so rename not needed)

**Description:**
File name is generic. Should be more specific (e.g., `ChecklistModels.swift`). **Note:** This will be addressed by HIGH-008 which splits the file into separate model files.

**Status:** Superseded by HIGH-008

**Acceptance Criteria:**
- [x] Addressed by HIGH-008

---

### LOW-003: Create Test Data Factories
**Category:** Testing  
**Effort:** 4-6 hours  
**Dependencies:** CRIT-003

**Description:**
Reusable test data builders for consistent tests.

**Acceptance Criteria:**
- [ ] Factories created
- [ ] Easy to use
- [ ] Documented

---

### LOW-004: Create Mock CloudKit Framework
**Category:** Testing  
**Effort:** 8-12 hours  
**Dependencies:** CRIT-003

**Description:**
Mock framework for testing CloudKit operations without network.

**Acceptance Criteria:**
- [ ] Mock framework created
- [ ] Easy to use
- [ ] Documented

---

### LOW-005: Add Integration Tests
**Category:** Testing  
**Effort:** 16-24 hours  
**Dependencies:** CRIT-003, MED-004

**Description:**
End-to-end integration tests for critical workflows.

**Acceptance Criteria:**
- [ ] Integration tests written
- [ ] Critical workflows covered
- [ ] Tests pass

---

### LOW-006: Set Up Performance Monitoring
**Category:** Performance  
**Effort:** 4-8 hours  
**Dependencies:** None

**Description:**
Enhanced performance monitoring and reporting.

**Acceptance Criteria:**
- [ ] Monitoring enhanced
- [ ] Reports generated
- [ ] Alerts configured

---

### LOW-007: Create Developer Onboarding Guide
**Category:** Documentation  
**Effort:** 4-8 hours  
**Dependencies:** MED-009

**Description:**
Guide for new developers joining the project.

**Acceptance Criteria:**
- [ ] Guide created
- [ ] Covers setup, architecture, workflows
- [ ] Easy to follow

---

### LOW-008: Document API Contracts
**Category:** Documentation  
**Effort:** 8-12 hours  
**Dependencies:** None

**Description:**
Document service APIs and contracts.

**Acceptance Criteria:**
- [ ] APIs documented
- [ ] Contracts defined
- [ ] Examples provided

---

### LOW-009: Set Up Automated Dependency Updates
**Category:** Process  
**Effort:** 2-4 hours  
**Dependencies:** None

**Description:**
Automate checking for dependency updates (when dependencies added).

**Acceptance Criteria:**
- [ ] Automation configured
- [ ] Updates checked regularly
- [ ] Alerts configured

---

### LOW-010: Create Release Checklist
**Category:** Process  
**Effort:** 2-4 hours  
**Dependencies:** None

**Description:**
Checklist for releasing new versions to App Store.

**Acceptance Criteria:**
- [ ] Checklist created
- [ ] Covers all steps
- [ ] Easy to follow

---

### LOW-011: Add Code Complexity Metrics
**Category:** Process  
**Effort:** 4-6 hours  
**Dependencies:** None

**Description:**
Track code complexity over time.

**Acceptance Criteria:**
- [ ] Metrics configured
- [ ] Reports generated
- [ ] Thresholds set

---

### LOW-012: Improve Error Messages
**Category:** UX  
**Effort:** 4-8 hours  
**Dependencies:** MED-006

**Description:**
Make all error messages user-friendly and actionable.

**Acceptance Criteria:**
- [ ] All errors user-friendly
- [ ] Actionable messages
- [ ] Tested with users

---

### LOW-013: Refactor Legacy Code
**Category:** Technical Debt  
**Effort:** 8-16 hours  
**Dependencies:** HIGH-002, HIGH-003

**Description:**
Refactor legacy code patterns as opportunities arise.

**Acceptance Criteria:**
- [ ] Legacy patterns identified
- [ ] Refactored incrementally
- [ ] Tests added

---

## Backlog Summary

### By Category

**Bugs:** 3 items
- CRIT-002: Lesson plan syncing
- MED-013: Conflict resolution
- MED-014: Library check

**Testing:** 10 items
- CRIT-003: Test infrastructure
- HIGH-002, HIGH-003, HIGH-004: Core tests
- MED-001, MED-002, MED-003: Additional tests
- MED-012: UI tests
- LOW-003, LOW-004, LOW-005: Test infrastructure

**Code Quality:** 8 items
- CRIT-004: Formatting violations
- HIGH-005, HIGH-006, HIGH-007, HIGH-008, HIGH-009, HIGH-010, HIGH-011: Refactoring and code organization
- MED-004, MED-005, MED-006, MED-009, MED-010: Organization and code quality
- LOW-001, LOW-002: Naming

**Process:** 6 items
- CRIT-001: AGENTS.md fix
- HIGH-009, HIGH-010, HIGH-011: Process setup
- MED-011: Pre-commit hooks
- LOW-009, LOW-010: Process improvements

**Architecture:** 5 items
- HIGH-005, HIGH-006, HIGH-007: Service refactoring
- MED-009: Documentation
- MED-010: Code reuse

**Features:** 4 items
- HIGH-008: Accessibility
- MED-008: PDF export
- MED-016, MED-017: Performance

**Documentation:** 4 items
- MED-007: Code docs
- MED-009: Architecture docs
- LOW-007, LOW-008: Developer docs

**Other:** 7 items
- Various improvements and optimizations

### By Effort

**Quick Wins (< 2 hours):** 5 items
- CRIT-001: AGENTS.md fix (15 min)
- HIGH-009: Version alignment (30 min)
- MED-005: Format config (1-2 hours)
- LOW-001, LOW-002: Renames (1 hour each)

**Medium Effort (2-8 hours):** 18 items
- Various testing, documentation, and process items

**Large Effort (8-16 hours):** 15 items
- Major refactoring, testing, and feature work

**Very Large Effort (16+ hours):** 9 items
- Complex refactoring, comprehensive testing, major features

---

## Recommended Implementation Order

### Phase 1: Foundation (Weeks 1-2)
1. CRIT-001: Fix AGENTS.md paths
2. CRIT-004: Fix formatting violations
3. CRIT-003: Set up test infrastructure
4. HIGH-009: Align versions
5. HIGH-010: Verify build script

### Phase 2: Critical Fixes (Weeks 3-4)
1. CRIT-002: Fix sync issues
2. HIGH-001: Fix layout issues
3. HIGH-002: Write sync tests
4. HIGH-003: Write progress tests
5. HIGH-004: Write assignment tests

### Phase 3: Quality & Testing (Weeks 5-8)
1. HIGH-011: Set up CI/CD
2. MED-001, MED-002, MED-003: Write more tests
3. HIGH-008: Add accessibility
4. MED-005: Create format config
5. MED-011: Add pre-commit hooks

### Phase 4: Refactoring (Weeks 9-12)
1. HIGH-005: Split CloudKitShareService
2. HIGH-006: Split CloudKitSyncService
3. HIGH-007: Extract progress calculation
4. HIGH-008: Split NewModels.swift
5. HIGH-009: Extract StudentDetailView subviews
6. HIGH-010: Extract EndorsementView subviews
7. HIGH-011: Refactor DefaultTemplates.swift

### Phase 5: Code Organization (Weeks 13-14)
1. MED-004: Organize code into directories
2. MED-009: Add MARK comments to all files
3. MED-010: Review access control
4. MED-004: Organize code
5. MED-006: Standardize errors

### Phase 5: Enhancement (Weeks 13-16)
1. MED-008: Enhance PDF export
2. MED-009: Architecture docs
3. MED-012: UI tests
4. MED-016, MED-017: Performance optimization
5. Various low-priority items

---

## Success Metrics

### Short Term (3 months)
- ✅ Zero formatting violations
- ✅ 40% test coverage
- ✅ All critical bugs fixed
- ✅ Process compliance 80%+

### Medium Term (6 months)
- ✅ 60% test coverage
- ✅ Large services refactored
- ✅ Architecture documented
- ✅ Process compliance 90%+

### Long Term (12 months)
- ✅ 80% test coverage
- ✅ All technical debt addressed
- ✅ Full process compliance
- ✅ High code quality maintained

---

## Notes

- **Effort estimates** are rough and may vary based on complexity discovered during implementation
- **Dependencies** should be respected to avoid rework
- **Priority** may shift based on user feedback and business needs
- **Testing** should be done incrementally, not all at once
- **Refactoring** should be done with tests in place to prevent regressions

---

**Backlog Status:** ✅ Updated with Code Organization Rules  
**Total Items:** 52 (added 5 items based on Swift code organization rules)  
**Next Review:** After Phase 1 completion (2 weeks)

