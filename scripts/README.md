# Scripts Directory

Build and utility scripts for Right Rudder.

## Available Scripts

### `auto_increment_build.sh`

Automatically increments the build number (CFBundleVersion) on each successful build.

**Usage in Xcode:**
1. Add a "Run Script Phase" to your target's Build Phases
2. Position it BEFORE "Compile Sources"
3. Reference the script: `"${SRCROOT}/scripts/auto_increment_build.sh"`

**Features:**
- Uses Xcode environment variables (`INFOPLIST_FILE`, `PROJECT_DIR`)
- Handles missing Info.plist gracefully
- Works with Debug and Release configurations
- Outputs build number increment confirmation

**See also:**
- `.cursor/commands/setup-versioning.md` - Quick setup guide
- `.cursor/rules/version-management.mdc` - Version management guidelines

---

**Note:** Scripts in this directory are meant to be run from Xcode Build Phases or command line. They use standard bash and Xcode environment variables.

