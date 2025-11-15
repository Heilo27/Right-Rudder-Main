# Checklist Library

Reference data for the checklist library system, used for syncing between the instructor and student apps.

## Files

### `DefaultChecklistLibrary.json`

The student app's checklist library definition. This file contains:
- Template definitions with library UUIDs
- Checklist items with their library UUIDs
- Used by `CloudKitShareService` to resolve library IDs when syncing assignments

**Usage:**
- Loaded at runtime by `CloudKitShareService.loadStudentLibrary()`
- Used to map instructor app template/item IDs to student app library IDs
- Ensures compatibility between instructor and student apps

### `item_mappings_new.txt`

A Swift dictionary mapping template identifiers to arrays of item UUIDs. This file contains:
- Template identifier keys (e.g., `"default_p1_l1_straight_and_level_flight"`)
- Arrays of UUIDs representing checklist item IDs for each template

**Purpose:**
- Reference mapping for template-to-UUID relationships
- Possibly used for migration or data integrity checks
- May serve as a backup/alternative to JSON-based library resolution

**Note:** This file is currently not directly referenced in the codebase. It may be:
- A work-in-progress migration tool
- A reference for manual ID resolution
- A backup mapping for data integrity verification

---

**See also:**
- `CloudKitShareService.swift` - Uses `DefaultChecklistLibrary.json` for ID resolution
- `SmartTemplateUpdateService.swift` - Loads templates from library JSON
- `.cursor/rules/cloudkit.mdc` - CloudKit integration guidelines

