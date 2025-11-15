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

### `discover_simulators.sh`

Discovers available iOS simulators and caches them to `.simulator_cache.json`.

**Usage:**
```bash
./scripts/discover_simulators.sh
```

**Features:**
- Scans all available iOS/iPadOS simulators
- Creates `.simulator_cache.json` (gitignored - per-developer)
- Prefers newer OS versions when multiple exist
- Outputs default simulator for quick access

**When to run:**
- After installing new simulators
- When simulator-related build errors occur
- Periodically to refresh cache

---

### `get_simulator.sh`

Retrieves a simulator destination string from the cache for use in build commands.

**Usage:**
```bash
# Get a specific simulator
SIMULATOR=$(./scripts/get_simulator.sh "iPhone 15")

# Get default simulator
SIMULATOR=$(./scripts/get_simulator.sh)

# Use in build command
xcodebuild -destination "$SIMULATOR" ...
```

**Features:**
- Searches cache for matching device name
- Falls back to default if no match found
- Auto-discovers simulators if cache missing
- Returns xcodebuild-compatible destination string

**Example:**
```bash
SIMULATOR=$(./scripts/get_simulator.sh "iPhone 15" || ./scripts/get_simulator.sh)
xcodebuild \
  -project "Right Rudder.xcodeproj" \
  -scheme "Right Rudder" \
  -destination "$SIMULATOR" \
  build
```

---

**Note:** Scripts in this directory are meant to be run from Xcode Build Phases or command line. They use standard bash and Xcode environment variables.

