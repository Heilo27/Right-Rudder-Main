# CloudKit Sharing & Student Companion App Guide

## Overview

This guide explains the CloudKit sharing implementation for the Right Rudder instructor app and provides guidance for building the companion student app.

## Features Implemented

### 1. Student Profile Sharing (CKShare)

The instructor app now supports sharing individual student profiles with students via CloudKit's CKShare functionality. This ensures:

- **Secure Access**: Each student only sees their own profile data
- **Read-Only Checklists**: Students can view checklists but cannot modify them
- **Document Upload**: Students can upload required documents that sync back to the instructor
- **Push Notifications**: Students receive alerts when instructors add comments

### 2. Document Management

Students can upload the following documents:
- Student Pilot Certificate (Required)
- Medical Certificate (Required)
- Passport/Birth Certificate (Required)
- LogBook (Optional)

Documents are synced via CloudKit and stored securely in the shared zone.

### 3. Push Notifications

When an instructor adds or updates comments on a student's checklist, the student receives a push notification directing them to that specific checklist.

## NEW: Reference-Based Checklist Architecture

### Overview

The instructor app now uses a **reference-based system** instead of copying checklist data to each student. This provides several benefits:

- **Eliminates Duplication**: Templates are never copied, only referenced
- **Reduces Storage**: ~90% reduction in data storage
- **Prevents Corruption**: Template integrity verification prevents data issues
- **Improves Performance**: Faster loading, smaller sync payloads
- **Better CloudKit Sync**: Only progress changes need syncing

### How It Works

1. **Templates**: Stored centrally with integrity hashes
2. **Student Progress**: Lightweight records that reference templates
3. **CloudKit Sync**: Templates and progress synced separately
4. **Student App**: Receives both template structure and progress data

### Data Flow

```
Instructor App                 CloudKit                    Student App
     │                            │                             │
     ├─ Templates ──────────────>│<────── Fetch Templates ─────┤
     ├─ Student Progress ───────>│<────── Fetch Progress ──────┤
     │                            │                             │
     │                            │<────── Upload ──────────────┤ Documents
     │<───── Fetch ───────────────┤                             │
     │                            │                             │
     ├─ Comment Update ──────────>│                             │
     │                            ├──── Notification ──────────>│
```

### Student App Implementation

The student app should:

1. **Fetch Templates**: Get ChecklistTemplate and ChecklistItem records
2. **Fetch Progress**: Get StudentChecklist and StudentChecklistItem records  
3. **Merge Data**: Combine template structure with student progress
4. **Display**: Show template items with completion status

### Example Implementation

```swift
// Fetch templates
let templateQuery = CKQuery(recordType: "ChecklistTemplate", predicate: NSPredicate(value: true))
let templates = try await database.records(matching: templateQuery)

// Fetch student progress
let progressQuery = CKQuery(recordType: "StudentChecklist", predicate: NSPredicate(format: "studentId == %@", studentId))
let progress = try await database.records(matching: progressQuery)

// Merge for display
for template in templates {
    let studentProgress = progress.first { $0["templateId"] == template.recordID }
    // Display template items with completion status from progress
}
```

## How to Use (Instructor App)

### Sending an Invite to a Student

1. Open a student's profile in the **StudentDetailView**
2. Tap the **"Send Invite"** button in the "Student App Access" section
3. The app will:
   - Create a CloudKit share for that student's record
   - Generate a unique share URL
   - Present the iOS share sheet
4. Send the invite link to the student via:
   - Email
   - Text message
   - AirDrop
   - Any messaging app

### Managing Documents

1. In the student detail view, tap **"View Documents"**
2. See all uploaded documents with status indicators
3. Documents uploaded by students automatically sync and appear here
4. Instructors can view document details, including expiration dates

### Adding Instructor Comments

1. Navigate to any student checklist
2. Add comments in the "Instructor Comments" field
3. When you sync to CloudKit, the comment triggers a push notification to the student
4. The student can tap the notification to view the specific checklist

## Student Companion App Requirements

### App Architecture

The student app should be a separate iOS app that:
- Uses the same CloudKit container identifier: `iCloud.com.heiloprojects.rightrudder`
- Implements CloudKit sharing acceptance
- Has read-only access to checklists
- Can upload documents to the shared zone
- Receives and handles push notifications

### CloudKit Record Types to Access

The student app needs to fetch and display:

1. **Student** (Root record - shared via CKShare)
   - Fields: firstName, lastName, email, telephone, homeAddress, ftnNumber
   - Biography and background notes
   
2. **StudentChecklist** (Child records - NEW REFERENCE-BASED SYSTEM)
   - Fields: templateName, templateIdentifier, instructorComments, dualGivenHours
   - Fields: isComplete, completionPercentage, completedItemsCount, totalItemsCount
   - Read-only display - references template data
   
3. **StudentChecklistItem** (Child records - NEW REFERENCE-BASED SYSTEM)
   - Fields: templateItemId, title, isComplete, notes, completedAt, order
   - Read-only display - references template item data
   
4. **ChecklistTemplate** (NEW - Shared for student app access)
   - Fields: name, category, phase, relevantData, templateIdentifier, contentHash
   - Read-only access to template structure
   
5. **ChecklistItem** (NEW - Child of ChecklistTemplate)
   - Fields: title, notes, order
   - Read-only access to template item structure
   
6. **StudentDocument** (Child records - student can create/upload)
   - Fields: documentType, filename, fileData, uploadedAt, expirationDate, notes
   - Full write access for students

### Key Implementation Steps

#### 1. Accept Share Invitation

```swift
import CloudKit

func acceptShare(metadata: CKShare.Metadata) async throws {
    let container = CKContainer(identifier: "iCloud.com.heiloprojects.rightrudder")
    let shareRecord = try await container.accept(metadata)
    // Fetch the shared student record
    await fetchSharedStudent(shareRecord)
}
```

#### 2. Fetch Shared Student Data

```swift
func fetchSharedStudent(_ share: CKShare) async {
    let database = CKContainer.default().sharedCloudDatabase
    
    // Fetch the student record
    guard let studentRecordID = share.rootRecordID else { return }
    let studentRecord = try await database.record(for: studentRecordID)
    
    // Fetch related checklists
    let query = CKQuery(recordType: "StudentChecklist", 
                       predicate: NSPredicate(format: "studentId == %@", 
                                            studentRecordID.recordName))
    let results = try await database.records(matching: query)
    // Process results...
}
```

#### 3. Upload Documents

```swift
func uploadDocument(documentType: DocumentType, fileData: Data, filename: String) async {
    let database = CKContainer.default().sharedCloudDatabase
    
    let recordID = CKRecord.ID(recordName: UUID().uuidString)
    let record = CKRecord(recordType: "StudentDocument", recordID: recordID)
    
    record["documentType"] = documentType.rawValue
    record["filename"] = filename
    record["fileData"] = fileData
    record["uploadedAt"] = Date()
    record["studentId"] = currentStudent.id.uuidString
    record["lastModified"] = Date()
    
    // Add to shared zone by setting parent
    record.setParent(shareReference)
    
    try await database.save(record)
}
```

#### 4. Subscribe to Notifications

```swift
func setupNotifications() async {
    // Request permission
    let granted = try await UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .sound, .badge])
    
    if granted {
        UIApplication.shared.registerForRemoteNotifications()
        
        // Subscribe to instructor comments
        let database = CKContainer.default().sharedCloudDatabase
        let predicate = NSPredicate(format: "instructorComments != nil")
        let subscription = CKQuerySubscription(
            recordType: "StudentChecklist",
            predicate: predicate,
            subscriptionID: "student-checklist-updates",
            options: [.firesOnRecordUpdate]
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.alertBody = "New comment from your instructor"
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        try await database.save(subscription)
    }
}
```

#### 5. Handle Notification Deep Links

```swift
func handleNotification(userInfo: [AnyHashable: Any]) {
    guard let ckNotification = CKNotification(fromRemoteNotificationDictionary: userInfo),
          let queryNotification = ckNotification as? CKQueryNotification,
          let recordFields = queryNotification.recordFields else { return }
    
    // Extract checklist information
    let checklistName = recordFields["templateName"] as? String
    let checklistId = queryNotification.recordID?.recordName
    
    // Navigate to the specific checklist
    navigateToChecklist(checklistId)
}
```

### UI Components Needed

1. **Profile View**
   - Display student information
   - Show total dual given hours
   - List all checklists with completion status

2. **Checklist View**
   - Read-only display of checklist items
   - Show completion status
   - Display instructor comments prominently
   - Highlight when new comments are added

3. **Document Upload View**
   - Upload interface for required documents
   - Photo/camera integration for scanning documents
   - Document preview
   - Expiration date tracking

4. **Notifications View**
   - List of notifications from instructor
   - Direct links to relevant checklists

### Security Considerations

- The student app only has access to the shared student record
- CloudKit automatically enforces permissions - students cannot modify checklists
- Documents uploaded by students are only visible to the instructor and that student
- Share can be revoked by instructor at any time

## CloudKit Container Setup

### Required Capabilities

In both apps, ensure you have:

1. **iCloud Capability**
   - CloudKit
   - Container: `iCloud.com.heiloprojects.rightrudder`

2. **Push Notifications Capability**
   - Remote notifications
   - Background modes: Remote notifications

3. **Background Modes**
   - Remote notifications
   - Background fetch (for syncing)

### CloudKit Dashboard Configuration

1. **Record Types**
   - Ensure all record types (Student, StudentChecklist, StudentChecklistItem, StudentDocument) are defined
   - Set appropriate indexes for query performance

2. **Security Roles**
   - World: None
   - Authenticated: Read/Write (for own records)
   - Creator: Read/Write

3. **Subscriptions**
   - Enable push notifications in production environment

## Testing

### Testing Sharing

1. Run the instructor app on one device
2. Create a student and tap "Send Invite"
3. Send the share URL to another device (can be via email)
4. Open the link on the student device
5. Accept the share invitation
6. Verify student can only see their profile

### Testing Notifications

1. Add a comment to a checklist in the instructor app
2. Sync to CloudKit
3. Verify student receives push notification
4. Tap notification to ensure it opens the correct checklist

### Testing Document Upload

1. From student app, upload a document
2. Verify it appears in CloudKit Dashboard
3. Verify it syncs to instructor app
4. Check file integrity by opening the document

## Troubleshooting

### Share Not Working
- Verify both apps use the same container identifier
- Check iCloud is enabled on both devices
- Ensure user is signed into iCloud

### Notifications Not Received
- Verify push notification capability is enabled
- Check subscription was created successfully
- Ensure device has internet connection
- Check notification permissions

### Documents Not Syncing
- Verify record is being saved to shared database (not private)
- Check file size limits (CloudKit has 10MB limit per asset)
- Ensure parent reference is set correctly

## API Reference

### CloudKitShareService

```swift
// Create share for a student
let shareService = CloudKitShareService()
let shareURL = await shareService.createShareForStudent(student, modelContext: context)

// Remove sharing
let success = await shareService.removeShareForStudent(student, modelContext: context)

// Check if share is active
let hasShare = await shareService.hasActiveShare(for: student)

// Sync documents
await shareService.syncStudentDocuments(student, modelContext: context)
```

### PushNotificationService

```swift
// Request permission
await PushNotificationService.shared.requestNotificationPermission()

// Subscribe to comments
await PushNotificationService.shared.subscribeToInstructorComments()

// Handle notification
let info = PushNotificationService.shared.handleNotificationDeepLink(userInfo: userInfo)
```

## Future Enhancements

Potential features for future versions:

1. **Real-time Sync**: Use CloudKit subscriptions for real-time updates
2. **Chat Feature**: Allow students to message instructors
3. **Flight Logging**: Students can log flights that auto-populate in logbook
4. **Progress Tracking**: Visual progress indicators for training phases
5. **Calendar Integration**: Schedule lessons and send reminders
6. **Document OCR**: Automatically extract information from uploaded documents
7. **Multi-instructor**: Support for students training with multiple instructors

## Support

For issues or questions:
- Check CloudKit Dashboard for sync errors
- Review Console.app logs for CloudKit operations
- Verify container identifier matches in both apps
- Ensure all entitlements are properly configured

---

**Note**: The student companion app is a separate project that needs to be built. This document provides the architecture and implementation guidance needed to build it effectively.

