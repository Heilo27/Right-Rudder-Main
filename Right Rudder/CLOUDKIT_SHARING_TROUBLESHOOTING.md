# CloudKit Sharing Troubleshooting Guide

## "Item Unavailable" Error - Common Causes & Solutions

When a student receives "Item Unavailable. The owner stopped sharing or you don't have permission to open it" error, here are the most likely causes and solutions:

### 1. **CloudKit Container Configuration Issues**

**Problem**: The CloudKit container isn't properly configured or the student app doesn't have access to the same container.

**Solutions**:
- Verify both instructor and student apps use the same CloudKit container identifier: `iCloud.com.heiloprojects.rightrudder`
- Check that the CloudKit container exists in the CloudKit Dashboard
- Ensure the container is configured for both Development and Production environments

**Check**:
```swift
// In both apps, verify this matches:
let container = CKContainer(identifier: "iCloud.com.heiloprojects.rightrudder")
```

### 2. **Share Record Not Properly Created**

**Problem**: The CKShare record wasn't created correctly or is missing required fields.

**Solutions**:
- Check console logs for CloudKit errors during share creation
- Verify the share is created in a custom zone (not the default zone)
- Ensure the share has proper permissions set

**Debug Steps**:
1. Open Xcode Console and look for CloudKit error messages
2. Check if the share URL is being generated correctly
3. Verify the share record exists in CloudKit Dashboard

### 3. **Zone Configuration Problems**

**Problem**: The custom zone required for sharing doesn't exist or isn't accessible.

**Solutions**:
- Ensure the custom zone "SharedStudentsZone" is created
- Check that the zone is in the private database
- Verify the zone has proper sharing capabilities

**Check in CloudKit Dashboard**:
1. Go to CloudKit Dashboard → Your Container → Private Database
2. Look for "SharedStudentsZone" in the Zones section
3. If missing, the app will create it automatically on first share

### 4. **Entitlements Missing**

**Problem**: Required CloudKit entitlements are missing or incorrectly configured.

**Solutions**:
- Verify entitlements file includes CloudKit capability
- Check that iCloud container identifier is correct
- Ensure push notifications are enabled

**Required Entitlements**:
```xml
<key>com.apple.developer.icloud-container-identifiers</key>
<array>
    <string>iCloud.com.heiloprojects.rightrudder</string>
</array>
<key>com.apple.developer.icloud-services</key>
<array>
    <string>CloudKit</string>
</array>
```

### 5. **Timing Issues with Share Creation**

**Problem**: The share URL is generated before the share record is fully saved to CloudKit.

**Solutions**:
- Added validation step to ensure share is accessible before presenting URL
- Implemented retry logic for share creation
- Added comprehensive error logging

### 6. **Student App Not Configured**

**Problem**: The student app doesn't exist or isn't properly configured to accept shares.

**Solutions**:
- The student app must be built and configured with the same CloudKit container
- The student app must implement share acceptance flow
- The student app must be signed in to the same iCloud account

### 7. **Network and Authentication Issues**

**Problem**: Network connectivity or iCloud authentication problems.

**Solutions**:
- Ensure both devices have internet connectivity
- Verify both users are signed in to iCloud
- Check that iCloud Drive is enabled
- Try creating a new share if the current one has expired

## Debugging Steps

### 1. Check Console Logs
Look for these specific error messages in Xcode Console:
- "CloudKit error: [error code]"
- "Failed to create share"
- "Share validation failed"
- "iCloud account not available"

### 2. Verify Share URL
Test the share URL by:
1. Opening it in Safari on the same device
2. Checking if it redirects to the app
3. Looking for CloudKit error messages in the browser

### 3. Check CloudKit Dashboard
1. Go to [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard)
2. Select your container: `iCloud.com.heiloprojects.rightrudder`
3. Check Private Database → Records for your student records
4. Look for CKShare records in the SharedStudentsZone

### 4. Test Share Validation
The app now includes share validation that will:
- Test if the share URL is accessible
- Provide specific error messages
- Log detailed debugging information

## Common Error Codes and Solutions

| Error Code | Meaning | Solution |
|------------|---------|----------|
| `unknownItem` | Share doesn't exist or expired | Create a new share |
| `notAuthenticated` | Not signed in to iCloud | Sign in to iCloud |
| `quotaExceeded` | iCloud storage full | Free up iCloud storage |
| `networkUnavailable` | No internet connection | Check network connection |
| `serviceUnavailable` | CloudKit temporarily down | Wait and try again |
| `participantMayNeedVerification` | Student needs to verify identity | Student should check iCloud settings |

## Prevention Tips

1. **Always validate shares** before sending them to students
2. **Test with a different iCloud account** to simulate student experience
3. **Check CloudKit Dashboard** regularly to ensure records are syncing
4. **Monitor console logs** for any CloudKit errors
5. **Keep CloudKit container** in sync between Development and Production

## Testing Checklist

- [ ] Instructor app can create shares successfully
- [ ] Share URL is generated and accessible
- [ ] Share validation passes
- [ ] Student app can accept shares (when built)
- [ ] Both apps use same CloudKit container
- [ ] Both users are signed in to iCloud
- [ ] Network connectivity is stable
- [ ] CloudKit Dashboard shows records and shares

## Getting Help

If the issue persists:
1. Check the console logs for specific CloudKit error codes
2. Verify all configuration steps in this guide
3. Test with a fresh CloudKit container if needed
4. Contact Apple Developer Support for CloudKit-specific issues
