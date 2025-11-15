# Update Product Requirements Document (PRD)

Update the PRD.md file to reflect changes in the application. This command helps maintain the PRD as a living document that accurately reflects the current state of Right Rudder.

## When to Use This Command

Use this command when:
- Adding new features to the application
- Modifying existing features
- Fixing bugs that change feature behavior
- Updating App Store description
- Releasing new versions
- Changing technical requirements
- Resolving known limitations

## How to Use

1. Describe what changed in the application (new feature, bug fix, enhancement, etc.)
2. The command will:
   - Review the current PRD.md
   - Identify sections that need updates
   - Update feature requirements, user stories, acceptance criteria
   - Update version history if needed
   - Update known limitations if resolved
   - Update roadmap if priorities changed
   - Maintain PRD structure and formatting

## Example Usage

**Scenario 1: New Feature Added**
```
@update-prd.md We just added a new feature that allows instructors to export student progress reports as CSV files. This is in addition to the existing PDF export. The feature is accessible from the student detail view.
```

**Scenario 2: Bug Fix**
```
@update-prd.md Fixed the lesson plan syncing issue. Templates now sync reliably to the student app. The issue was in CloudKitShareService template resolution logic.
```

**Scenario 3: Feature Enhancement**
```
@update-prd.md Enhanced PDF export to include charts showing progress over time and better formatting. The export now meets the "professional, comprehensive" claim in the App Store.
```

**Scenario 4: Version Release**
```
@update-prd.md Released version 1.6.2 with bug fixes for layout issues and improved CloudKit sync reliability.
```

## What Gets Updated

The command will update:
- **Feature sections** - Add/modify feature requirements, user stories, acceptance criteria
- **Version history** - Add new version entry with changes
- **Known limitations** - Remove limitations that are resolved
- **Roadmap** - Update priorities based on completed work
- **Technical requirements** - Update if architecture changes
- **Success criteria** - Update if metrics change
- **Change log** - Document what changed in PRD

## PRD Structure Reference

The PRD follows this structure:
1. Product Overview (vision, mission, users, positioning)
2. Product Description (what it is/isn't, value props)
3. Product Features (12 major features with requirements)
4. User Experience Requirements
5. Technical Requirements
6. Non-Functional Requirements
7. Success Criteria
8. Known Limitations
9. Dependencies
10. Risks & Mitigations
11. Release History
12. Roadmap
13. Appendices

## Requirements Format

When adding requirements, use this format:
- **REQ-XXX:** Requirement description
- Number sequentially (currently goes up to REQ-161)
- Include acceptance criteria
- Include user stories
- Include technical notes if relevant

## Feature Format

When adding/modifying features, include:
- **Feature ID:** FEAT-XXX (number sequentially)
- **Priority:** P0 (Critical), P1 (High), P2 (Medium), P3 (Low)
- **Status:** ✅ Implemented, ⚠️ Partial, ❌ Not Implemented, 🔄 In Progress
- **Description:** What the feature does
- **Requirements:** List of REQ-XXX items
- **User Stories:** As a... I want... So that...
- **Acceptance Criteria:** Checklist format
- **Technical Notes:** Implementation details

## Maintenance Guidelines

- **Keep requirements specific and testable**
- **Update status when features are completed**
- **Remove limitations when resolved**
- **Update version history for each release**
- **Keep roadmap realistic and prioritized**
- **Maintain consistency with App Store listing**
- **Cross-reference with PROJECT_REVIEW_*.md files**

## Version History Format

When adding version entries:
```
### Version X.Y.Z (Date)
- Feature/change description
- Feature/change description
- Bug fix description
```

## Important Notes

- Always verify changes against actual codebase
- Cross-check with App Store listing for accuracy
- Update change log in Appendix C
- Maintain requirement numbering sequence
- Keep user stories in standard format
- Preserve existing structure and formatting

## Related Documents

- `PROJECT_REVIEW_FEATURE_INVENTORY.md` - Feature completeness
- `PROJECT_REVIEW_BACKLOG.md` - Work items
- `AGENTS.md` - Development standards
- App Store listing - Marketing claims

---

**Command Purpose:** Maintain PRD.md as accurate, up-to-date product documentation that reflects the current state of Right Rudder.

