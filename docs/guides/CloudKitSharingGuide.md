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

**Option A: Accept from Deep Link (Automatic)**

When a student taps a share URL, iOS automatically opens the app with the share metadata:

```swift
import CloudKit

func acceptShare(metadata: CKShare.Metadata) async throws {
    let container = CKContainer(identifier: "iCloud.com.heiloprojects.rightrudder")
    let shareRecord = try await container.accept(metadata)
    // Fetch the shared student record
    await fetchSharedStudent(shareRecord)
}
```

**Option B: Accept from Manual URL Paste (CRITICAL for Student App)**

When a student manually pastes a URL into a text field, you need to fetch the metadata first:

```swift
import CloudKit

/// Accepts a share from a manually pasted URL string
/// This is the method to use when students paste URLs into a text field
func acceptShareFromURLString(_ urlString: String) async throws {
    let container = CKContainer(identifier: "iCloud.com.heiloprojects.rightrudder")
    
    // Step 1: Convert string to URL
    guard let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
        throw NSError(domain: "ShareError", code: -1, 
                    userInfo: [NSLocalizedDescriptionKey: "Invalid URL format"])
    }
    
    // Step 2: Validate URL format
    guard url.absoluteString.contains("icloud.com/share") else {
        throw NSError(domain: "ShareError", code: -1, 
                    userInfo: [NSLocalizedDescriptionKey: "Invalid CloudKit share URL"])
    }
    
    // Step 3: Check iCloud account status
    let accountStatus = try await container.accountStatus()
    guard accountStatus == .available else {
        throw NSError(domain: "ShareError", code: -1, 
                    userInfo: [NSLocalizedDescriptionKey: "iCloud account not available"])
    }
    
    // Step 4: Fetch share metadata from URL
    let metadata = try await container.shareMetadata(for: url)
    
    // Step 5: Accept the share
    let shareRecord = try await container.accept(metadata)
    
    // Step 6: Fetch the shared student record
    await fetchSharedStudent(shareRecord)
}

/// Example UI implementation for manual URL input
struct ManualShareAcceptView: View {
    @State private var urlString = ""
    @State private var isAccepting = false
    @State private var errorMessage: String?
    @State private var showSuccess = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Share Link")
                .font(.title2)
                .fontWeight(.bold)
            
            TextField("Paste share URL here", text: $urlString)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .autocorrectionDisabled()
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: {
                Task {
                    await acceptShare()
                }
            }) {
                if isAccepting {
                    ProgressView()
                } else {
                    Text("Accept Share")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(urlString.isEmpty || isAccepting)
        }
        .padding()
        .alert("Success", isPresented: $showSuccess) {
            Button("OK") { }
        } message: {
            Text("Share accepted successfully!")
        }
    }
    
    private func acceptShare() async {
        isAccepting = true
        errorMessage = nil
        
        do {
            try await acceptShareFromURLString(urlString)
            await MainActor.run {
                showSuccess = true
                urlString = ""
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
        
        isAccepting = false
    }
}
```

**Important Notes:**
- Always trim whitespace from the URL string before processing
- Validate the URL format before attempting to fetch metadata
- Check iCloud account status before accepting shares
- Provide clear error messages to users for common failure cases
- The `acceptShareFromURLString` method handles all error cases and provides user-friendly messages

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
   
   **UI Styling (Must Match Instructor App)**:
   - ✅ **Checked Items**: Green `checkmark.circle.fill` icon, strikethrough text, secondary color text
   - ⭕ **Unchecked Items**: Gray `circle` icon, normal text, primary color text
   - 📅 **Completion Date**: Shown below checked items in caption2 font
   - See "Student App Checklist Item UI" section below for exact implementation

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

## Student App Checklist Item UI

**CRITICAL**: The student app must match the instructor app's UI styling exactly for consistency. Here's the exact implementation:

### Read-Only Checklist Item Row (Student App)

```swift
import SwiftUI

/// Read-only checklist item row for student app
/// Matches instructor app styling exactly
struct StudentChecklistItemRow: View {
    let item: ChecklistItem
    let isComplete: Bool
    let completedAt: Date?
    let notes: String?
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon: Green checkmark when complete, gray circle when incomplete
            Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isComplete ? .green : .gray)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                // Item title: Strikethrough and secondary color when complete
                Text(item.title)
                    .strikethrough(isComplete)
                    .foregroundColor(isComplete ? .secondary : .primary)
                    .multilineTextAlignment(.leading)
                    .font(.body)
                
                // Notes (if any)
                if let notes = notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                // Completion date (only shown when complete)
                if isComplete, let completedAt = completedAt {
                    Text("Completed: \(completedAt, style: .date)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
```

### Key Styling Details:

1. **Icon**:
   - ✅ Complete: `checkmark.circle.fill` in `.green` color
   - ⭕ Incomplete: `circle` in `.gray` color
   - Font: `.title2`

2. **Text**:
   - Complete: `.strikethrough()` modifier, `.secondary` color
   - Incomplete: No strikethrough, `.primary` color
   - Font: `.body`

3. **Layout**:
   - HStack spacing: `12` points between icon and text
   - VStack spacing: `4` points between text elements
   - Vertical padding: `8` points

4. **Completion Date**:
   - Only shown when `isComplete == true`
   - Font: `.caption2`
   - Color: `.secondary`
   - Format: "Completed: [date]"

### Example Usage in Checklist View:

```swift
List {
    ForEach(checklistItems, id: \.id) { item in
        StudentChecklistItemRow(
            item: item,
            isComplete: item.isComplete,
            completedAt: item.completedAt,
            notes: item.notes
        )
    }
}
```

**Note**: This matches the instructor app's `ChecklistItemRow` styling exactly, ensuring visual consistency between both apps.

## Support

For issues or questions:
- Check CloudKit Dashboard for sync errors
- Review Console.app logs for CloudKit operations
- Verify container identifier matches in both apps
- Ensure all entitlements are properly configured

---

**Note**: The student companion app is a separate project that needs to be built. This document provides the architecture and implementation guidance needed to build it effectively.

