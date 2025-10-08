# Quick Start Guide - CloudKit Sharing

## For Instructors

### Sharing a Student Profile

1. **Navigate to Student**
   - Open Students tab
   - Select a student from the list

2. **Send Invite**
   - Look for "Student App Access" section at the top
   - Tap the **"Send Invite"** button
   - A share sheet will appear with the invite URL

3. **Share the Link**
   - Send via:
     - ✉️ Email
     - 💬 Text Message
     - 🔗 Copy Link
     - 📱 AirDrop
   
4. **Track Status**
   - Tap "Send Invite" again to see who accepted
   - View participants and their acceptance status
   - Resend invite or stop sharing anytime

### Managing Documents

1. **View Documents**
   - In student detail view, tap **"View Documents"**
   - See 4 document types with status indicators:
     - ✅ Green checkmark = Uploaded
     - ⚠️ Orange warning = Not uploaded (required)
     - ⏱️ Red warning = Expiring soon (within 30 days)

2. **Document Types**
   - 📄 Student Pilot Certificate (Required)
   - ❤️ Medical Certificate (Required)
   - 🪪 Passport/Birth Certificate (Required)
   - 📖 LogBook (Optional)

3. **Wait for Student Uploads**
   - Students upload documents from their app
   - Automatically syncs to your app
   - Tap any document to view details

### Adding Comments That Notify Students

1. **Open Any Checklist**
   - Navigate to student → checklist

2. **Add Comment**
   - Scroll to "Instructor Comments" section
   - Type your comment

3. **Sync to CloudKit**
   - Comment is saved locally immediately
   - Sync to CloudKit to trigger notification
   - Student receives push notification

4. **Student Experience**
   - Gets notification: "New comment from your instructor"
   - Taps notification
   - Opens directly to that checklist

## For Students (Once Companion App is Built)

### IMPORTANT: Install Student App First

**Before accepting an invite, the student app MUST be installed on the device:**

1. Build and install "Right Rudder - Student" app from Xcode
2. Launch it at least once
3. Sign into the same iCloud account
4. THEN accept the instructor's invitation

If you try to accept an invite without the app installed, you'll see "need a newer version" error.

### Accepting an Invite

1. **Receive Invite**
   - Instructor sends you a link
   - Open link on your iPhone/iPad

2. **Accept Share**
   - Tap "Accept" when prompted
   - Grant necessary permissions
   - Profile loads automatically

3. **View Your Profile**
   - See your training information
   - View all checklists (read-only)
   - Check your progress

### Uploading Documents

1. **Open Documents**
   - Tap "Documents" in your profile

2. **Upload Required Documents**
   - Tap the + button on any document type
   - Choose from:
     - 📷 Take Photo (scan document)
     - 🖼️ Photo Library
     - 📁 Files app

3. **Add Details (Optional)**
   - Set expiration date (for medical, certificates)
   - Add notes

4. **Auto-Sync**
   - Document automatically uploads
   - Instructor receives it immediately

### Viewing Checklists

1. **Browse Checklists**
   - See all your assigned checklists
   - View completion percentage
   - Read-only (can't modify)

2. **Check for Comments**
   - Look for "Instructor Comments" section
   - 🔔 Badge shows new comments
   - Read instructor feedback

### Managing Notifications

1. **Enable Notifications**
   - App will request permission on first launch
   - Tap "Allow" to receive updates

2. **When You Get a Notification**
   - Tap notification to open app
   - Directly view the checklist with new comment
   - Mark as read after viewing

## UI Overview

### Instructor App - New Screens

```
Student Detail View
├── 📋 Student Info
├── ✈️ Student App Access
│   └── [Send Invite] button
├── 📄 Documents
│   └── [View Documents] button
├── 📝 Checklists
└── 🖼️ Endorsements

Document View
├── Student Pilot Certificate [Status]
├── Medical Certificate [Status]
├── Passport/Birth Certificate [Status]
└── LogBook [Status]

Share View
├── 👤 Profile Preview
├── ℹ️ What's Shared
├── 🔒 Privacy Info
├── 🔔 Notification Info
├── [Send Invite] button
└── Participants List (if shared)
```

### Student App - Screens to Build

```
Home View
├── 👤 My Profile
├── 📊 Progress Overview
├── 📋 Checklists
└── 📄 Documents

Checklist Detail (Read-Only)
├── ✅ Items with completion status
├── 💬 Instructor Comments
└── 🔔 New comment indicator

Documents View
├── Upload interface
├── Document preview
├── Status indicators
└── Expiration warnings

Notifications View
├── Notification list
├── Direct links to checklists
└── Read/unread status
```

## Troubleshooting

### "Send Invite" Not Working

**Check:**
- ✓ Device has internet connection
- ✓ Signed into iCloud
- ✓ iCloud Drive is enabled
- ✓ Student record exists

**Fix:**
- Sign out and back into iCloud
- Restart app
- Try again

### Documents Not Appearing

**Check:**
- ✓ Student uploaded the document
- ✓ Internet connection on both devices
- ✓ CloudKit sync completed

**Fix:**
- Pull to refresh
- Force sync from settings
- Check CloudKit Dashboard

### Student Not Getting Notifications

**Check:**
- ✓ Notifications enabled in Settings
- ✓ Student accepted the share
- ✓ Instructor synced after adding comment

**Fix:**
- Re-enable notifications in iOS Settings
- Check notification settings in app
- Ensure instructor synced to CloudKit

## Best Practices

### For Instructors

1. **Sync Regularly**
   - Sync after adding important comments
   - Ensures students get timely notifications

2. **Use Comments Effectively**
   - Be specific and constructive
   - Reference specific items in checklist
   - Students can't reply (yet), so be clear

3. **Check Documents Early**
   - Remind students to upload required docs
   - Check expiration dates
   - Request updates before they expire

4. **Manage Shares**
   - Stop sharing when student completes training
   - Regularly review participant list
   - Resend invites if student changes device

### For Students

1. **Upload Documents Promptly**
   - Don't wait until last minute
   - Keep documents up to date
   - Set reminders for expiring documents

2. **Check Regularly**
   - Look for instructor comments
   - Review checklist progress
   - Respond to feedback in person

3. **Protect Your Data**
   - Use strong device passcode
   - Enable Face ID/Touch ID
   - Don't share login credentials

4. **Enable Notifications**
   - Stay informed of updates
   - Respond promptly to instructor feedback
   - Check notification settings if missing updates

## Support

### Getting Help

**Instructor App Issues:**
- Check CloudKit Dashboard for sync errors
- Review Console logs for detailed errors
- Verify entitlements are correct

**Student App Issues:**
- Ensure using same CloudKit container
- Verify share was accepted
- Check notification permissions

**CloudKit Issues:**
- Visit: https://icloud.developer.apple.com/dashboard
- Check for service disruptions
- Review quota limits

## What's Next?

### Instructor App ✅
- Implementation complete
- Ready for testing
- Needs Background Modes capability added

### Student App 🚧
- Needs to be built
- See `CloudKitSharingGuide.md` for details
- All backend infrastructure ready

---

**Ready to Share!** 🎉

Your instructor app is now equipped with powerful CloudKit sharing capabilities. Once the student app is built, you'll have a complete end-to-end training management system.

For detailed technical information, see:
- `CloudKitSharingGuide.md` - Complete implementation guide
- `SETUP_CHECKLIST.md` - Setup and configuration
- `IMPLEMENTATION_SUMMARY.md` - Technical overview

