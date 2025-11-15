# Build Number Auto-Increment Script Setup Guide

## Current Status

**Script Location:** `scripts/auto_increment_build.sh` ✅  
**Script Status:** Script exists and is syntactically correct ✅  
**Xcode Configuration:** ⚠️ **NOT CONFIGURED** - Script not added to Build Phases

## Verification Results

### Script File
- ✅ Script exists at `scripts/auto_increment_build.sh`
- ✅ Script syntax is valid
- ✅ Script uses Xcode environment variables (`INFOPLIST_FILE`, `PROJECT_DIR`)
- ✅ Script handles missing Info.plist gracefully

### Xcode Project Configuration
- ⚠️ **Build Phases:** No Run Script Phase found for auto-increment
- ✅ **Build Settings:** 
  - `CURRENT_PROJECT_VERSION = 2` (build number)
  - `MARKETING_VERSION = 1.6.2` (version)
  - `GENERATE_INFOPLIST_FILE = YES` (Info.plist is auto-generated)

### Current Build Number
- **Current Build:** 2
- **Version:** 1.6.2

---

## Setup Instructions

Since the project uses `GENERATE_INFOPLIST_FILE = YES`, the Info.plist is auto-generated. The script needs to be configured to work with the generated Info.plist.

### Option 1: Use Script File (Recommended)

1. **Open Xcode** → Right Rudder project
2. Select **Right Rudder target** (blue icon)
3. Click **Build Phases** tab
4. Click **+ (plus)** button at top left
5. Select **New Run Script Phase**
6. **Drag the new script phase** UP to be **BEFORE** "Compile Sources"
7. Click the triangle to expand it
8. **Rename** the phase: Double-click "Run Script" → type `Auto-Increment Build Number`
9. In the script box, enter:
   ```bash
   "${SRCROOT}/scripts/auto_increment_build.sh"
   ```
10. **Uncheck** "Show environment variables in build log" (optional, cleaner output)
11. **Build your project** (Cmd+B) → Watch build number increment!

### Option 2: Inline Script (Alternative)

If you prefer an inline script:

1. Follow steps 1-6 above
2. In the script box, paste:
   ```bash
   # Auto-increment build number
   if [ -n "$INFOPLIST_FILE" ]; then
       PLIST="${PROJECT_DIR}/${INFOPLIST_FILE}"
   else
       # For generated Info.plist, use build settings
       PLIST="${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
   fi
   
   if [ -f "$PLIST" ]; then
       CURRENT_BUILD=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$PLIST" 2>/dev/null)
       
       if [ -z "$CURRENT_BUILD" ]; then
           CURRENT_BUILD=0
       fi
       
       NEW_BUILD=$((CURRENT_BUILD + 1))
       /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEW_BUILD" "$PLIST"
       
       echo "✅ Build number: $CURRENT_BUILD → $NEW_BUILD"
   else
       # For generated Info.plist, update build settings directly
       CURRENT_BUILD=$(xcodebuild -project "${PROJECT_FILE_PATH}" -target "${TARGET_NAME}" -showBuildSettings | grep "CURRENT_PROJECT_VERSION" | head -1 | awk '{print $3}')
       
       if [ -z "$CURRENT_BUILD" ]; then
           CURRENT_BUILD=0
       fi
       
       NEW_BUILD=$((CURRENT_BUILD + 1))
       # Note: This requires modifying project.pbxproj or using a different approach
       echo "⚠️ Generated Info.plist detected. Build number increment may require manual update."
   fi
   ```

**Note:** Option 1 (using the script file) is recommended as it's simpler and the script handles both cases.

---

## Testing the Configuration

After setting up the script:

1. **Note current build number:** Check in Xcode → Right Rudder target → General tab → Build
2. **Build the project:** Cmd+B or Product → Build
3. **Check build log:** Look for "Build number incremented from X to Y"
4. **Verify increment:** Check General tab → Build number should have increased

### Expected Output

When the script runs successfully, you should see in the build log:
```
Build number incremented from 2 to 3
```

---

## Troubleshooting

### Script Not Running

**Problem:** Build number doesn't increment  
**Solutions:**
- Verify script phase is BEFORE "Compile Sources"
- Check script path is correct: `"${SRCROOT}/scripts/auto_increment_build.sh"`
- Ensure script phase is enabled (checkbox checked)
- Check build log for errors

### Generated Info.plist Issues

**Problem:** Script can't find Info.plist  
**Solutions:**
- The script handles this automatically via `INFOPLIST_FILE` environment variable
- If issues persist, verify `GENERATE_INFOPLIST_FILE = YES` in build settings
- The script will use `BUILT_PRODUCTS_DIR` as fallback

### Build Number Not Updating

**Problem:** Build number stays the same  
**Solutions:**
- Check if script is running (look for output in build log)
- Verify script has correct permissions: `chmod +x scripts/auto_increment_build.sh`
- Check Xcode build settings for `CURRENT_PROJECT_VERSION`
- Ensure script runs before compilation

### Script Errors

**Problem:** Script fails with errors  
**Solutions:**
- Verify PlistBuddy is available: `/usr/libexec/PlistBuddy -h`
- Check script syntax: `bash -n scripts/auto_increment_build.sh`
- Verify Xcode environment variables are available
- Check file permissions

---

## Verification Checklist

After setup, verify:

- [ ] Script phase added to Build Phases
- [ ] Script phase positioned BEFORE "Compile Sources"
- [ ] Script path correct: `"${SRCROOT}/scripts/auto_increment_build.sh"`
- [ ] Script phase enabled (checkbox checked)
- [ ] Build succeeds
- [ ] Build number increments on each build
- [ ] Build log shows increment message
- [ ] Version number unchanged (only build increments)

---

## Current Configuration Status

**Status:** ⚠️ **Needs Manual Configuration**

**Action Required:**
1. Open Xcode
2. Add Run Script Phase to Right Rudder target
3. Configure script as described above
4. Test build number increment
5. Document completion

**Estimated Time:** 5-10 minutes

---

## Related Documentation

- [Version Management Guide](../.cursor/rules/version-management.mdc) - Complete version management guidelines
- [Setup Versioning Command](../.cursor/commands/setup-versioning.md) - Quick setup guide
- [Scripts README](../scripts/README.md) - Scripts directory documentation

---

**Last Updated:** January 2025  
**Next Review:** After script is configured

