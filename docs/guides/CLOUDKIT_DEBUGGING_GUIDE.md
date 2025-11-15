# CloudKit Sharing Debugging Guide

## "Item Unavailable" Error - Step-by-Step Troubleshooting

### Step 1: Check Console Logs

When you create a share, look for these specific log messages:

**Expected Success Logs:**
```
Creating share for student: [Student Name]
Using custom zone: SharedStudentsZone
Share URL: https://www.icloud.com/share/[ID]
Share Record ID: [ID]
Share Zone: SharedStudentsZone
```

**If you see errors, note the specific error codes and messages.**

### Step 2: Verify CloudKit Container Configuration

1. **Check Container Identifier:**
   - Instructor app: `iCloud.com.heiloprojects.rightrudder`
   - Student app: `iCloud.com.heiloprojects.rightrudder`
   - Both must be identical

2. **Check CloudKit Dashboard:**
   - Go to [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard)
   - Select container: `iCloud.com.heiloprojects.rightrudder`
   - Check both Development and Production environments

### Step 3: Test Share URL Manually

1. **Copy the share URL** from the console logs
2. **Open it in Safari** on the same device
3. **Check what happens:**
   - Does it redirect to the student app?
   - Do you see any error messages?
   - Does it show "Item Unavailable"?

### Step 4: Check iCloud Account Status

**On Instructor Device:**
1. Go to Settings > [Your Name] > iCloud
2. Ensure iCloud Drive is enabled
3. Check that you're signed in to the same account

**On Student Device:**
1. Must be signed in to a different iCloud account
2. Must have the student app installed
3. Must be signed in to iCloud

### Step 5: Test with Fresh Share

1. **Delete existing share** (if any)
2. **Create a new share** for the same student
3. **Check console logs** for any differences
4. **Test the new URL** immediately

### Step 6: Check CloudKit Dashboard Records

1. Go to CloudKit Dashboard
2. Navigate to Private Database > Records
3. Look for:
   - Student records in `SharedStudentsZone`
   - CKShare records
   - Check if records are being created

### Step 7: Test with Different Accounts

1. **Create a test iCloud account** for the student
2. **Test sharing** between instructor and test student accounts
3. **This isolates account-specific issues**

## Common Causes and Solutions

### Cause 1: Different CloudKit Containers
**Solution:** Ensure both apps use identical container identifiers

### Cause 2: Student App Not Properly Configured
**Solution:** Verify student app has correct entitlements and container

### Cause 3: Share Created in Wrong Zone
**Solution:** Ensure shares are created in the custom zone, not default zone

### Cause 4: Network/Authentication Issues
**Solution:** Check internet connection and iCloud sign-in status

### Cause 5: Share URL Expired or Invalid
**Solution:** Create a fresh share and test immediately

## Debugging Commands

### Check Share URL Format
```swift
// The URL should look like:
// https://www.icloud.com/share/[long-string-of-characters]
```

### Test Share Acceptance
```swift
// In student app, check console for:
// "Share metadata received: [Metadata]"
// "Share accepted successfully"
```

## Next Steps

1. **Run through each step** systematically
2. **Note any error messages** in console logs
3. **Test with a fresh share** after each fix
4. **Check CloudKit Dashboard** for record creation

## Getting Help

If the issue persists after following all steps:
1. **Collect console logs** from both apps
2. **Note the exact error messages**
3. **Check CloudKit Dashboard** for any error indicators
4. **Test with a completely fresh CloudKit container** if needed

