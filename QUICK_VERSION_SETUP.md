# Quick Version Setup - 5 Minutes

## Step 1: Set Current Version (2 minutes)

1. **Open Xcode** → Right Rudder project
2. Select **Right Rudder target** (blue icon)
3. Click **General** tab
4. Under **Identity**, set:
   - **Version**: `2.0.0` (for all your major features)
   - **Build**: Leave as-is

## Step 2: Add Auto-Increment Script (3 minutes)

1. Stay in **Right Rudder target**
2. Click **Build Phases** tab
3. Click **+ (plus)** button at top left
4. Select **New Run Script Phase**
5. **Drag the new script phase** UP to be **BEFORE** "Compile Sources"
6. Click the triangle to expand it
7. Paste this script:

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

8. **Rename** the phase: Double-click "Run Script" → type `Auto-Increment Build Number`
9. **Build your project** (Cmd+B) → Watch build number increment!

## Step 3: Understand the System

### Automatic (Build Number)
- Increments **every build** automatically
- You never touch this
- Shows as "Build 42" in Settings

### Manual (Version Number)
Use Semantic Versioning:

#### 🔴 **MAJOR** (1.0.0 → 2.0.0)
**Use for:** Huge changes
- Complete redesign
- Major new core features
- **Example:** Adding the entire companion app system

#### 🟡 **MINOR** (2.0.0 → 2.1.0)
**Use for:** Significant new features
- New screens
- Major functionality additions
- **Example:** Template sharing, CloudKit backup

#### 🟢 **PATCH** (2.1.0 → 2.1.1)
**Use for:** Fixes and tweaks
- Bug fixes
- UI improvements
- **Example:** Military time fix, sorting fix

## Step 4: When to Update Version

### Before Submitting to App Store:
1. **Decide:** Is this a major feature (MINOR) or a fix (PATCH)?
2. **Update Version** in Xcode General tab
3. **Build** → Build number auto-increments
4. **Submit** to App Store Connect

### Daily Development:
- Just build normally
- Build number increments automatically
- Only change version when ready for release

## Quick Examples

| What You Did | Change Version To | Why |
|--------------|-------------------|-----|
| Added CloudKit sharing, companion app, templates | `2.0.0` | Major features (MINOR or MAJOR) |
| Fixed military time display | `2.0.1` | Bug fix (PATCH) |
| Adding student progress reports | `2.1.0` | New feature (MINOR) |
| Fixed a crash | `2.1.1` | Bug fix (PATCH) |
| Just testing changes | Leave alone | Build auto-increments |

## That's It! 🎉

Now:
- ✅ Build number increments automatically
- ✅ Version shows correctly in Settings
- ✅ You control version based on changes
- ✅ Professional version management

Build your project now to test it!

