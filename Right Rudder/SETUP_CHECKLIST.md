# CloudKit Sharing Setup Checklist

## Xcode Project Configuration

### 1. Signing & Capabilities

Verify the following capabilities are enabled in your Xcode project:

#### Instructor App (Right Rudder)

- [x] **iCloud**
  - [x] CloudKit
  - [x] Container: `iCloud.com.heiloprojects.rightrudder`

- [x] **Push Notifications**
  - Already configured in entitlements (aps-environment: development)

- [ ] **Background Modes** (Need to add if not present)
  - [ ] Remote notifications
  - [ ] Background fetch

### 2. Info.plist Updates

Add the following keys to your Info.plist if not already present:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
    <string>fetch</string>
</array>

<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to upload documents and endorsements.</string>

<key>NSCameraUsageDescription</key>
<string>We need access to your camera to capture documents and endorsements.</string>

<key>NSFileProviderDomainUsageDescription</key>
<string>We need access to files to upload student documents.</string>
```

### 3. AppDelegate or App Struct

Ensure your app handles remote notifications. The current implementation already includes this in `Right_RudderApp.swift`.

## CloudKit Dashboard Configuration

### 1. Container Setup

1. Go to [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard)
2. Select container: `iCloud.com.heiloprojects.rightrudder`
3. Select **Development** environment initially, then repeat for **Production**

### 2. Record Types

Verify all record types exist with correct fields:

#### Student
- firstName (String)
- lastName (String)
- email (String)
- telephone (String)
- homeAddress (String)
- ftnNumber (String)
- biography (String)
- backgroundNotes (String)
- lastModified (Date/Time)

#### StudentChecklist
- templateId (String)
- templateName (String)
- instructorComments (String)
- studentId (String) - **Add Index: Queryable**
- dualGivenHours (Double)
- lastModified (Date/Time)

#### StudentChecklistItem
- templateItemId (String)
- title (String)
- isComplete (Int64) - Boolean stored as 0/1
- notes (String)
- completedAt (Date/Time)
- order (Int64)
- checklistId (String) - **Add Index: Queryable**
- lastModified (Date/Time)

#### StudentDocument
- documentType (String)
- filename (String)
- fileData (Bytes) - Asset
- uploadedAt (Date/Time)
- expirationDate (Date/Time)
- notes (String)
- studentId (String) - **Add Index: Queryable**
- lastModified (Date/Time)

#### ChecklistTemplate
- name (String)
- category (String)
- phase (String)
- relevantData (String)
- lastModified (Date/Time)

#### ChecklistItem
- title (String)
- notes (String)
- templateId (String) - **Add Index: Queryable**
- lastModified (Date/Time)

#### EndorsementImage
- filename (String)
- imageData (Bytes) - Asset
- createdAt (Date/Time)
- studentId (String) - **Add Index: Queryable**
- lastModified (Date/Time)

### 3. Indexes

Add indexes for efficient querying:

- **StudentChecklist**: Index on `studentId`
- **StudentChecklistItem**: Index on `checklistId`
- **StudentDocument**: Index on `studentId`
- **ChecklistItem**: Index on `templateId`
- **EndorsementImage**: Index on `studentId`

### 4. Security Roles

For the **Private Database**:
- **World**: No Access
- **Authenticated Users**: Read/Write Own Records
- **Creator**: Read/Write

For the **Shared Database** (automatically configured when using CKShare):
- Students will have read access to shared records
- Students will have write access only to StudentDocument records

### 5. Subscription Types

Enable the following subscription:
- **Query Subscriptions**: Allowed
- This enables push notifications for record changes

## Testing Checklist

### Phase 1: Basic Sharing
- [ ] Create a student in the instructor app
- [ ] Tap "Send Invite" button
- [ ] Verify share URL is generated
- [ ] Share URL can be sent via share sheet

### Phase 2: Document Management
- [ ] Navigate to student documents view
- [ ] All 4 document types are displayed
- [ ] Can view document upload interface
- [ ] Document status indicators work

### Phase 3: CloudKit Sync
- [ ] Manual sync uploads student data
- [ ] Student records appear in CloudKit Dashboard
- [ ] Checklists sync correctly
- [ ] Documents sync to CloudKit

### Phase 4: Notifications (Once Student App is Built)
- [ ] Student app receives share invitation
- [ ] Student can accept share
- [ ] Student sees only their profile
- [ ] Instructor comment triggers notification
- [ ] Notification opens correct checklist

## Deployment Steps

### Development Testing
1. Use Development environment in CloudKit Dashboard
2. Test with TestFlight builds or development builds
3. Verify all features work end-to-end

### Production Release
1. **Important**: Configure Production environment in CloudKit Dashboard
2. Ensure all record types are in Production schema
3. Test share functionality in production environment
4. Submit to App Store with proper entitlements

## Important Notes

### For Instructor App
- ✅ CloudKit sharing is implemented
- ✅ Document management is ready
- ✅ Push notification support is configured
- ✅ All UI components are built
- ⚠️ Need to add Background Modes capability in Xcode

### For Student Companion App
- ❌ Needs to be built as separate project
- ❌ See `CloudKitSharingGuide.md` for implementation details
- ❌ Use same CloudKit container identifier
- ❌ Implement share acceptance flow
- ❌ Build read-only checklist views
- ❌ Implement document upload UI
- ❌ Configure push notifications

## Common Issues & Solutions

### Issue: "CloudKit account not available"
**Solution**: 
- Ensure device is signed into iCloud
- Verify iCloud Drive is enabled
- Check container identifier is correct

### Issue: Share URL not generating
**Solution**: 
- Verify student record exists in CloudKit
- Check internet connection
- Ensure proper entitlements are configured
- **Important**: Shares must be created in a custom zone (not the default zone)
  - The app automatically creates "SharedStudentsZone" for this purpose

### Issue: Push notifications not working
**Solution**:
- Verify aps-environment in entitlements
- Enable Background Modes in Xcode
- Check subscription was created in CloudKit
- Ensure device allows notifications

### Issue: Documents not syncing
**Solution**:
- Check file size (CloudKit max 10MB per asset)
- Verify proper parent reference for shared zone
- Ensure sharedCloudDatabase is used in student app

## Additional Resources

- [CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)
- [CKShare Documentation](https://developer.apple.com/documentation/cloudkit/ckshare)
- [Push Notifications Guide](https://developer.apple.com/documentation/usernotifications)
- [Background Modes](https://developer.apple.com/documentation/xcode/configuring-background-execution-modes)

## Next Steps

1. **Add Background Modes in Xcode**
   - Open project in Xcode
   - Go to target → Signing & Capabilities
   - Add "Background Modes" capability
   - Enable "Remote notifications"

2. **Test Sharing Flow**
   - Create test student
   - Generate share invite
   - Verify CloudKit Dashboard shows shared record

3. **Build Student Companion App**
   - Create new iOS project
   - Use `CloudKitSharingGuide.md` as reference
   - Implement core features
   - Test end-to-end with instructor app

4. **Deploy to TestFlight**
   - Test with real users
   - Gather feedback
   - Iterate on UX

---

**Status**: Instructor app CloudKit sharing implementation is complete and ready for testing. Student companion app needs to be built separately.

