# Version Management Guide for Right Rudder

## Overview
This guide explains how to manage version numbers for the Right Rudder app using **Semantic Versioning** with automatic build number increments.

## Understanding Version Numbers

Your app has two version identifiers:

### 1. **Version Number** (CFBundleShortVersionString)
- Format: `MAJOR.MINOR.PATCH` (e.g., 2.1.3)
- **User-facing** - shown in App Store and Settings
- **Manually controlled** - you decide when to increment based on changes
- Examples: `1.0.0`, `1.5.2`, `2.0.0`

### 2. **Build Number** (CFBundleVersion)
- Format: Integer (e.g., 42, 150, 1234)
- **Internal tracking** - shown in Settings and TestFlight
- **Automatically incremented** - increases with every build
- Examples: `1`, `42`, `150`

## Semantic Versioning System

### MAJOR Version (X.0.0)
**Increment when:** Adding breaking changes or major overhauls
- Complete UI redesigns
- Major architectural changes
- Significant new core features that change how the app works
- Removing major features

**Examples:**
- `1.0.0` → `2.0.0`: Complete app redesign
- `2.5.3` → `3.0.0`: New data model requiring migration

**When to use:** Rarely - only for game-changing updates

---

### MINOR Version (1.X.0)
**Increment when:** Adding significant new features
- New major functionality (e.g., CloudKit sharing, template sharing)
- New screens or major UI sections
- Integration with new services
- Significant workflow additions

**Examples:**
- `1.0.0` → `1.1.0`: Added CloudKit student sharing
- `1.1.0` → `1.2.0`: Added template import/export feature
- `1.2.0` → `1.3.0`: Added backup/restore functionality

**When to use:** For notable feature releases that users will notice

---

### PATCH Version (1.1.X)
**Increment when:** Making bug fixes or minor improvements
- Bug fixes
- Performance improvements
- Minor UI tweaks
- Small feature refinements
- Text/copy changes
- Fixing crashes

**Examples:**
- `1.1.0` → `1.1.1`: Fixed crash in checklist view
- `1.1.1` → `1.1.2`: Improved military time display
- `1.1.2` → `1.1.3`: Fixed sorting issue in student details

**When to use:** For maintenance releases and small improvements

---

## Automatic Build Number Increment

### Setup in Xcode

1. **Open your Xcode project**
2. Select the **Right Rudder** target
3. Go to **Build Phases** tab
4. Click **+ (plus)** button → **New Run Script Phase**
5. **Drag the script phase** to be BEFORE "Compile Sources"
6. Paste this script:

```bash
# Auto-increment build number
if [ "$CONFIGURATION" = "Release" ] || [ "$CONFIGURATION" = "Debug" ]; then
    PLIST="${PROJECT_DIR}/Right Rudder/Info.plist"
    
    if [ -f "$PLIST" ]; then
        CURRENT_BUILD=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$PLIST" 2>/dev/null)
        
        if [ -z "$CURRENT_BUILD" ]; then
            CURRENT_BUILD=0
        fi
        
        NEW_BUILD=$((CURRENT_BUILD + 1))
        /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEW_BUILD" "$PLIST"
        
        echo "✅ Build number: $CURRENT_BUILD → $NEW_BUILD"
    fi
fi
```

7. Name the phase: **"Auto-Increment Build Number"**

### How It Works

- **Every time you build**: Build number increments automatically (1 → 2 → 3 → 4...)
- **Works for all builds**: Debug, Release, TestFlight, App Store
- **No manual intervention**: Set it and forget it
- **Git-friendly**: Only Info.plist changes, easy to track

---

## Practical Version Management Workflow

### Current State Assessment
Based on your recent additions, I recommend:

**Current Version:** `2.0.0` (Build: auto-increments)

**Reasoning:**
- You've added major features (CloudKit sharing, template sharing, student companion app)
- This represents a significant evolution from the original app
- Starting at 2.0.0 makes sense for a feature-rich release

### Example Version History

```
Version 1.0.0 (Build 1-50)
├─ Initial release with student management
└─ Basic checklist functionality

Version 1.1.0 (Build 51-75)
├─ Added CloudKit backup/restore
└─ Improved student detail view

Version 1.2.0 (Build 76-100)
├─ Added template sharing
└─ Added companion app integration

Version 1.2.1 (Build 101-110)
├─ Fixed military time display
├─ Fixed checklist sorting
└─ Minor UI improvements

Version 2.0.0 (Build 111+)
├─ Major CloudKit sharing overhaul
├─ Student companion app
├─ Document management
└─ Push notifications
```

---

## How to Change Version Numbers

### Method 1: Xcode UI
1. Select your project in Project Navigator
2. Select the **Right Rudder** target
3. Go to **General** tab
4. Under **Identity**, find:
   - **Version**: Change this manually (e.g., `2.0.0` → `2.1.0`)
   - **Build**: Auto-increments (leave it)

### Method 2: Info.plist
1. Open `Right Rudder/Info.plist`
2. Find or add:
   - `CFBundleShortVersionString`: Your version (e.g., `2.0.0`)
   - `CFBundleVersion`: Build number (auto-increments)

---

## Decision Guide: "What Version Should This Be?"

### Use this flowchart:

```
Does this change break compatibility or completely overhaul the app?
├─ YES → Increment MAJOR (e.g., 1.5.2 → 2.0.0)
└─ NO ↓

Is this a significant new feature users will notice?
├─ YES → Increment MINOR (e.g., 1.5.2 → 1.6.0)
└─ NO ↓

Is this a bug fix or small improvement?
├─ YES → Increment PATCH (e.g., 1.5.2 → 1.5.3)
└─ NO → No version change needed
```

### Real Examples from Your App:

| Change | Version Change | Reasoning |
|--------|---------------|-----------|
| Added template sharing feature | 1.0.0 → 1.1.0 | New major feature (MINOR) |
| Fixed military time format | 1.1.0 → 1.1.1 | Bug fix (PATCH) |
| Fixed checklist sorting | 1.1.1 → 1.1.2 | Bug fix (PATCH) |
| Added CloudKit student sharing | 1.1.2 → 1.2.0 or 2.0.0 | Major feature (MINOR or MAJOR) |
| Fixed typo in button text | No change | Too minor, just build increment |
| Complete UI redesign | 2.0.0 → 3.0.0 | Breaking change (MAJOR) |

---

## Best Practices

### ✅ DO:
- Update version BEFORE submitting to App Store
- Keep build numbers incrementing automatically
- Document version changes in release notes
- Use consistent versioning across all targets
- Commit version changes to git with descriptive messages

### ❌ DON'T:
- Manually edit build numbers (let the script handle it)
- Skip version increments (1.0.0 → 1.2.0)
- Use version 0.x.x in production
- Reset build numbers (they should always increase)

---

## Quick Reference

| Scenario | Action | Example |
|----------|--------|---------|
| Fixed a crash | Increment PATCH | 1.2.3 → 1.2.4 |
| Added new screen/feature | Increment MINOR | 1.2.3 → 1.3.0 |
| Major redesign | Increment MAJOR | 1.2.3 → 2.0.0 |
| Building for testing | Do nothing | Build auto-increments |
| Submitting to App Store | Check version is correct | Ensure version reflects changes |

---

## Setting Your Current Version

Based on everything you've added, I recommend:

### Right Rudder Instructor App
```
Version: 2.0.0
Build: (auto-increments)
```

### To set this:
1. Open Xcode
2. Select Right Rudder target → General tab
3. Set Version to: `2.0.0`
4. Leave Build as-is (script will handle it)
5. Add the auto-increment script to Build Phases
6. Build the project → Build number will auto-increment

---

## Future Versioning Examples

**Next bug fix release:**
- Version: `2.0.0` → `2.0.1`
- Changes: "Fixed backup timestamp, improved sorting"

**Next feature release:**
- Version: `2.0.1` → `2.1.0`
- Changes: "Added student progress reports"

**Next major release:**
- Version: `2.1.0` → `3.0.0`
- Changes: "Complete iPad optimization, new data architecture"

---

## Troubleshooting

### Build number not incrementing
- Check the script is in Build Phases
- Ensure script runs BEFORE "Compile Sources"
- Check Info.plist path is correct
- Clean build folder (Cmd+Shift+K) and rebuild

### Version not showing correctly
- Check Info.plist has `CFBundleShortVersionString`
- Verify value is in X.Y.Z format
- Clean and rebuild project

### Version conflicts in git
- Version changes are normal - commit them
- Use meaningful commit messages: "Bump version to 2.0.0 for major release"

---

## Summary

- **Version (2.0.0)**: Manual, semantic, user-facing
- **Build (123)**: Automatic, internal tracking
- **MAJOR**: Breaking changes, complete overhauls
- **MINOR**: Significant new features
- **PATCH**: Bug fixes and small improvements
- **Script handles builds**: Set it up once, forget it

Your app is now set for professional version management! 🚀

