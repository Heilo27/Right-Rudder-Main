# Feature Requirements Document: CloudKit Sharing & Student Companion App

**Feature ID:** FEAT-006  
**Feature Name:** CloudKit Sharing & Student Companion App  
**Version:** 1.0  
**Last Updated:** January 2025  
**Status:** ✅ Implemented  
**Priority:** P0 (Critical)

---

## 1. Feature Overview

### 1.1 Purpose
Secure CloudKit-based sharing that enables students to view their progress, upload documents, and receive notifications via companion app. Core feature enabling student-instructor collaboration.

### 1.2 App Store Claim
> "Introducing the student app, letting the student see their progress for a visual motivation and encouragement."

> "Student account linking to companion app"

### 1.3 User Value
- Students can see their training progress
- Visual motivation and encouragement
- Bidirectional document sharing (instructor and student can upload same document types)
- Students can mark training milestones (ground school, written tests) as complete
- Students can share training goals with instructor
- Instructor can send lesson assignments, reviews, feedback, and external study materials
- Instructor can share documents they've collected (license photos, etc.)
- Real-time progress updates
- Secure, private sharing

### 1.4 Business Value
- Key differentiator
- Enables student engagement
- Competitive advantage
- Foundation for future collaboration features

---

## 2. User Stories

### 2.1 Primary User Stories

**Instructor → Student:**
- As an instructor, I want to share a student's progress so they can see their training status
- As an instructor, I want to send lesson assignments to the student app so students know what to work on
- As an instructor, I want to send lesson reviews, feedback, and external assignments for study so students have complete information
- As an instructor, I want to send required documents, pictures of license, etc. that I've collected so students can access them
- As an instructor, I want to mark assignment items as complete so students see their progress

**Student → Instructor:**
- As a student, I want to see my assigned lessons so I know what to work on
- As a student, I want notifications when my instructor adds comments so I can respond quickly
- As a student, I want to upload required documents so my instructor can see them (bidirectional - same document types)
- As a student, I want to send my training goals so my instructor knows what I'm working toward
- As a student, I want to mark training milestones (ground school, written tests) as complete so my instructor sees my progress

### 2.2 Edge Cases
- As an instructor, I want to remove sharing so I can revoke access
- As a student, I want to accept share invites so I can view my progress

---

## 3. Functional Requirements

### 3.1 Core Requirements

**REQ-047:** Create CloudKit share for individual students
- **Priority:** Must Have
- **Status:** ✅ Complete
- **Acceptance Criteria:**
  - [x] Can create share for student
  - [x] Share created in CloudKit
  - [x] Share linked to student record

**REQ-048:** Generate share invite links
- **Priority:** Must Have
- **Status:** ✅ Complete
- **Acceptance Criteria:**
  - [x] Share link generated
  - [x] Link can be shared
  - [x] Link works in companion app

**REQ-049:** Share via Messages, Email, AirDrop, Copy Link
- **Priority:** Must Have
- **Status:** ✅ Complete
- **Acceptance Criteria:**
  - [x] iOS share sheet integration
  - [x] All sharing methods work
  - [x] Link copied correctly

**REQ-050:** Students have read-only access to checklists
- **Priority:** Must Have
- **Status:** ✅ Complete
- **Acceptance Criteria:**
  - [x] Students can view checklists
  - [x] Students cannot modify checklists
  - [x] Access controls enforced

**REQ-051:** Bidirectional document sharing
- **Priority:** Must Have
- **Status:** ✅ Complete
- **Acceptance Criteria:**
  - [x] Students can upload documents
  - [x] Instructors can upload documents
  - [x] Same document types accessible by both parties
  - [x] Documents sync bidirectionally
  - [x] Both parties can see documents uploaded by either party

**REQ-052:** Track share participants
- **Priority:** Must Have
- **Status:** ✅ Complete
- **Acceptance Criteria:**
  - [x] Participants tracked
  - [x] Participant status visible
  - [x] Share acceptance monitored

**REQ-053:** Remove/unlink sharing
- **Priority:** Must Have
- **Status:** ✅ Complete
- **Acceptance Criteria:**
  - [x] Can remove sharing
  - [x] Access revoked correctly
  - [x] Cleanup handled

**REQ-054:** Push notifications when instructor adds comments
- **Priority:** Must Have
- **Status:** ✅ Complete
- **Acceptance Criteria:**
  - [x] Notifications sent
  - [x] Notifications received
  - [x] Notifications actionable

**REQ-055:** Deep linking to specific checklists from notifications
- **Priority:** Should Have
- **Status:** ✅ Complete
- **Acceptance Criteria:**
  - [x] Deep links work
  - [x] Correct checklist opened
  - [x] Navigation works

**REQ-056:** Share acceptance monitoring
- **Priority:** Must Have
- **Status:** ✅ Complete
- **Acceptance Criteria:**
  - [x] Acceptance tracked
  - [x] Status updates
  - [x] UI reflects status

**REQ-057:** Template library sync to student app
- **Priority:** Must Have
- **Status:** ✅ Complete
- **Acceptance Criteria:**
  - [x] Templates sync
  - [x] Templates readable
  - [x] Updates propagate

**REQ-065:** Instructor sends lesson assignments to student app
- **Priority:** Must Have
- **Status:** ✅ Complete
- **Acceptance Criteria:**
  - [x] Lesson assignments sync to student app
  - [x] Students can view assigned lessons
  - [x] Assignment data includes instructor comments and feedback

**REQ-066:** Instructor sends lesson reviews, feedback, and external assignments
- **Priority:** Must Have
- **Status:** ✅ Complete
- **Acceptance Criteria:**
  - [x] Instructor comments sync to student app
  - [x] Feedback visible to students
  - [x] External study materials accessible

**REQ-067:** Instructor sends collected documents to student app
- **Priority:** Must Have
- **Status:** ✅ Complete
- **Acceptance Criteria:**
  - [x] Documents uploaded by instructor sync to student app
  - [x] Students can view instructor-uploaded documents
  - [x] Bidirectional document access works

**REQ-068:** Student sends training goals to instructor app
- **Priority:** Must Have
- **Status:** ✅ Complete
- **Acceptance Criteria:**
  - [x] Training goals sync from student app
  - [x] Instructor can view student goals
  - [x] Goal updates propagate in real-time

**REQ-069:** Student marks training milestones as complete
- **Priority:** Must Have
- **Status:** ✅ Complete
- **Acceptance Criteria:**
  - [x] Students can mark ground school as complete
  - [x] Students can mark written tests as complete
  - [x] Milestone completions sync to instructor app
  - [x] Only students can mark milestones (instructor marks assignment items)

**REQ-070:** Instructor marks assignment items as complete
- **Priority:** Must Have
- **Status:** ✅ Complete
- **Acceptance Criteria:**
  - [x] Instructor can mark checklist items as complete
  - [x] Item progress syncs to student app
  - [x] Only instructor can mark assignment items (students mark milestones)

---

## 4. Non-Functional Requirements

### 4.1 Security & Privacy
- **REQ-058:** Secure CloudKit sharing
- **REQ-059:** Proper access controls
- **REQ-060:** Private data protection
- **Status:** ✅ Complete

### 4.2 Performance
- **REQ-061:** Share creation completes quickly
- **REQ-062:** Sync efficient
- **Status:** ✅ Complete

### 4.3 Reliability
- **REQ-063:** Share creation reliable
- **REQ-064:** Sync reliable
- **Status:** ⚠️ Known Issues (see 6.3)

---

## 5. Acceptance Criteria

### 5.1 Happy Path
- [x] Can create and share student profiles
- [x] Students receive read-only checklist access
- [x] Bidirectional document sharing works (instructor ↔ student)
- [x] Lesson assignments sync from instructor to student
- [x] Instructor comments and feedback sync to student app
- [x] Training goals sync from student to instructor
- [x] Students can mark training milestones as complete
- [x] Instructors can mark assignment items as complete
- [x] Notifications work correctly
- [x] Deep linking works
- [x] Share management works

### 5.2 Edge Cases
- [x] Multiple shares handled
- [x] Share removal works
- [x] Network errors handled

### 5.3 Error Cases
- [x] CloudKit errors handled
- [x] Network errors handled
- [x] Invalid shares rejected

### 5.4 App Store Compliance
- [x] Feature matches App Store description
- ⚠️ **KNOWN ISSUE:** User-reported sync issues (see 6.3)

---

## 6. Implementation Status

### 6.1 Current Status
✅ **Implemented** (with known issues)

### 6.2 Implementation Details
**Files:**
- `Services/CloudKit/CloudKitShareService.swift` - Core sharing service (3500+ lines)
- `Services/CloudKit/CloudKitSyncService.swift` - Sync service (1700+ lines)
- `Views/Student/StudentShareView.swift` - Share UI
- `Views/Conflicts/ConflictResolutionView.swift` - Conflict resolution

**Services:**
- `CloudKitShareService.swift` - CKShare operations
- `CloudKitSyncService.swift` - Data sync
- `PushNotificationService.swift` - Notifications

**Models:**
- CloudKit schema for sharing
- Shared database zones

### 6.3 Known Issues
- ⚠️ **CRITICAL:** User-reported lesson plan syncing issues (CRIT-002 in backlog)
- Large service files (3500+ and 1700+ lines) need refactoring
- Sync reliability issues reported

### 6.4 Gaps vs. App Store Claims
- ⚠️ **GAP:** Sync issues may prevent reliable student app integration
- Feature works but has reliability concerns

---

## 7. Testing Requirements

### 7.1 Unit Tests
- [ ] Test share creation
- [ ] Test share removal
- [ ] Test access controls
- **Status:** ❌ Not Implemented (0% coverage)

### 7.2 Integration Tests
- [ ] Test end-to-end sharing flow
- [ ] Test document upload
- [ ] Test notifications
- **Status:** ❌ Not Implemented

### 7.3 UI Tests
- [ ] Test share creation flow
- [ ] Test student app integration
- **Status:** ❌ Not Implemented

### 7.4 Manual Testing Checklist
- [x] Create share
- [x] Share link
- [x] Student accepts share
- [x] Student views progress
- [x] Student views assigned lessons
- [x] Instructor sends lesson assignments
- [x] Instructor adds comments/feedback
- [x] Student receives instructor comments
- [x] Student uploads document
- [x] Instructor uploads document
- [x] Both parties see documents from either source
- [x] Student sets training goals
- [x] Instructor views student training goals
- [x] Student marks ground school/written test as complete
- [x] Instructor marks assignment items as complete
- [x] Notifications work
- ⚠️ Sync reliability needs verification

---

## 8. Documentation Requirements

### 8.1 User Documentation
- [x] CloudKit sharing guide
- [x] Troubleshooting guide

### 8.2 Developer Documentation
- [x] Implementation guide
- [x] Schema documentation

---

## 9. Dependencies

### 9.1 External Dependencies
- CloudKit (Apple's service)
- iCloud account (required)
- Student Companion App (separate app)

### 9.2 Internal Dependencies
- Student Management (FEAT-001)
- Checklist Templates (FEAT-002)
- Document Management (FEAT-005)

### 9.3 Blocking Dependencies
- None

---

## 10. Risks & Mitigations

### 10.1 Technical Risks
**Risk:** CloudKit sync failures  
**Impact:** High - Core functionality  
**Mitigation:** Error handling, offline queue, recovery services

**Risk:** Large service files  
**Impact:** Medium - Maintenance difficulty  
**Mitigation:** Refactor into smaller services (HIGH-005, HIGH-006 in backlog)

### 10.2 Product Risks
**Risk:** User-reported sync issues  
**Impact:** High - Core feature broken  
**Mitigation:** Investigate and fix immediately (CRIT-002 in backlog)

---

## 11. Future Enhancements

### 11.1 Planned Enhancements
- Real-time sync improvements
- Multi-instructor support
- In-app messaging
- Enhanced notifications

### 11.2 Priority Enhancements
1. **Fix sync issues** - Critical priority
2. **Refactor services** - Improve maintainability
3. **Add tests** - Improve reliability

---

## 12. References

### 12.1 Related Documents
- [PRD.md](../PRD.md) - Section 3.6 CloudKit Sharing
- [PROJECT_REVIEW_BACKLOG.md](../review/PROJECT_REVIEW_BACKLOG.md) - CRIT-002: Sync Issues
- [CloudKitSharingGuide.md](../guides/CloudKitSharingGuide.md) - Implementation guide

### 12.2 App Store Listing
- [Right Rudder App Store](https://apps.apple.com/us/app/right-rudder/id6753633792)

### 12.3 Related Features
- [FEAT-001](../features/FEAT-001_Student_Management.md) - Student Management
- [FEAT-005](../features/FEAT-005_Document_Management.md) - Document Management

---

## Document Maintenance

**Owner:** Product Team  
**Review Frequency:** Monthly (due to known issues)  
**Last Reviewed:** January 2025  
**Next Review:** February 2025

---

**FRD Status:** ✅ Implemented (with known issues)  
**Version:** 1.1  
**Last Updated:** January 2025

**Action Required:** Investigate and fix sync issues (CRIT-002)

