# Testing CloudKit Sharing - Complete Guide

## Prerequisites

### 1. Two Different iCloud Accounts
- **Instructor Account**: Your main iCloud account
- **Student Account**: A different iCloud account (can be a test account)

### 2. Both Apps Installed
- **Instructor App**: Right Rudder (main app)
- **Student App**: Right Rudder - Student (companion app)

### 3. Both Devices Signed In
- **Instructor Device**: Signed in to instructor iCloud account
- **Student Device**: Signed in to student iCloud account

## Step-by-Step Testing Process

### Step 1: Create a Share (Instructor App)

1. **Open the instructor app**
2. **Select a student** or create a new one
3. **Tap "Send Invite"** button
4. **Check console logs** for these messages:

**Expected Success Logs:**
```
Creating share for student: [Student Name]
Using custom zone: SharedStudentsZone
Share URL: https://www.icloud.com/share/[ID]
Share Record ID: [ID]
Share Zone: SharedStudentsZone
=== SHARE DEBUG INFO ===
Student Record ID: [ID]
Student Record Zone: SharedStudentsZone
Share Title: Student Profile: [Student Name]
Share Type: com.heiloprojects.rightrudder.student
=========================
Testing share URL immediately after creation...
✅ Share URL validation passed
```

### Step 2: Send the Share URL

1. **Copy the share URL** from the console logs
2. **Send it to the student** via:
   - Email
   - Text message
   - AirDrop
   - Any messaging app

### Step 3: Test Share URL (Student Device)

1. **Open the share URL** on the student device
2. **Check what happens:**
   - Does it open in Safari first?
   - Does it redirect to the student app?
   - Do you see any error messages?

### Step 4: Check Student App Console Logs

**Expected Success Logs:**
```
Received URL: https://www.icloud.com/share/[ID]
Handling URL: https://www.icloud.com/share/[ID]
✅ Share metadata received successfully
📋 Share root record ID: [ID]
👤 Owner identity: [Instructor Identity]
📝 Share title: Student Profile: [Student Name]
🏷️ Share type: com.heiloprojects.rightrudder.student
✅ Share accepted successfully
Fetched student record: [ID] from zone: SharedStudentsZone
Student profile saved: [Student Name]
```

## Troubleshooting Common Issues

### Issue 1: "Item Unavailable" Error

**Possible Causes:**
- Same iCloud account on both devices
- Student app not properly configured
- Network connectivity issues
- CloudKit container mismatch

**Solutions:**
1. **Use different iCloud accounts** (most common fix)
2. **Check network connectivity**
3. **Verify CloudKit container identifiers match**
4. **Check iCloud sign-in status**

### Issue 2: Share URL Doesn't Open Student App

**Possible Causes:**
- Student app not installed
- URL scheme not configured
- iOS not recognizing the URL

**Solutions:**
1. **Install the student app** on the student device
2. **Check URL scheme configuration** in Info.plist
3. **Try opening URL in Safari first**

### Issue 3: Student App Crashes on Share Acceptance

**Possible Causes:**
- Model schema mismatch
- Missing required fields
- Database access issues

**Solutions:**
1. **Check console logs** for specific error messages
2. **Verify model schemas match** between apps
3. **Test with a fresh student profile**

## Testing Checklist

### ✅ Prerequisites
- [ ] Two different iCloud accounts
- [ ] Both apps installed on respective devices
- [ ] Both devices signed in to iCloud
- [ ] Internet connectivity on both devices

### ✅ Share Creation
- [ ] Instructor app can create shares
- [ ] Share URL is generated successfully
- [ ] Console logs show success messages
- [ ] No CloudKit errors in logs

### ✅ Share URL Testing
- [ ] Share URL opens in Safari
- [ ] Share URL redirects to student app
- [ ] No "Item Unavailable" errors
- [ ] Student app receives the URL

### ✅ Share Acceptance
- [ ] Student app accepts the share
- [ ] Student profile appears in student app
- [ ] Checklists are visible
- [ ] Documents section is accessible

## Debugging Commands

### Check Share URL Format
```swift
// The URL should look like:
// https://www.icloud.com/share/[long-string-of-characters]
```

### Test Share Acceptance
```swift
// In student app, check console for:
// "✅ Share metadata received successfully"
// "✅ Share accepted successfully"
```

## Common Error Messages and Solutions

### "Not signed in to iCloud"
- **Solution**: Sign in to iCloud on the student device

### "The share link is invalid or has expired"
- **Solution**: Create a new share from the instructor app

### "You need to verify your identity"
- **Solution**: Check iCloud settings on student device

### "No internet connection"
- **Solution**: Check network connectivity

### "iCloud storage quota exceeded"
- **Solution**: Free up iCloud storage space

## Success Indicators

When everything is working correctly, you should see:

1. **Instructor App Console:**
   ```
   ✅ Share URL validation passed
   Share URL: https://www.icloud.com/share/[ID]
   ```

2. **Student App Console:**
   ```
   ✅ Share accepted successfully
   Student profile saved: [Student Name]
   ```

3. **Student App UI:**
   - Student profile appears
   - Checklists are visible
   - Documents section is accessible
   - No error messages displayed

## Next Steps After Successful Testing

1. **Test document upload** from student app
2. **Test instructor comment notifications**
3. **Test checklist completion sync**
4. **Test with multiple students**
5. **Test share revocation and re-sharing**

## Getting Help

If issues persist:
1. **Collect console logs** from both apps
2. **Note the exact error messages**
3. **Check CloudKit Dashboard** for any error indicators
4. **Test with a completely fresh setup** if needed
