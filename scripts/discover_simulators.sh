#!/bin/bash
#
# discover_simulators.sh
# Discovers available iOS simulators and caches them to .simulator_cache.json
# This avoids build errors from unavailable simulators
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CACHE_FILE="$PROJECT_ROOT/.simulator_cache.json"

echo "🔍 Discovering available iOS simulators..."

# Get available simulators in JSON format
SIMULATORS_JSON=$(xcrun simctl list devices available --json 2>/dev/null || echo '{"devices":{}}')

# Extract iOS simulators and format for easy use
# We'll create a simple structure: name, OS version, and destination string
SIMULATOR_LIST=$(echo "$SIMULATORS_JSON" | python3 -c "
import json
import sys

data = json.load(sys.stdin)
simulators = []

for runtime_id, devices in data.get('devices', {}).items():
    if 'iOS' in runtime_id or 'iPadOS' in runtime_id:
        # Extract OS version from runtime ID (e.g., iOS-18-2)
        os_version = runtime_id.split('.')[-1].replace('iOS-', '').replace('-', '.')
        
        for device in devices:
            if device.get('isAvailable', False):
                name = device.get('name', 'Unknown')
                # Create destination string format: 'platform=iOS Simulator,name=iPhone 15,OS=18.0'
                destination = f\"platform=iOS Simulator,name={name},OS={os_version}\"
                simulators.append({
                    'name': name,
                    'os': os_version,
                    'destination': destination,
                    'udid': device.get('udid', '')
                })

# Sort by name, then by OS version (newest first for same device)
# This ensures we prefer newer OS versions when multiple exist
simulators.sort(key=lambda x: (x['name'], -float(x['os'].split('.')[0]) if '.' in x['os'] else -float(x['os'])), reverse=False)

# Output as JSON
print(json.dumps({
    'simulators': simulators,
    'default': simulators[0]['destination'] if simulators else None,
    'updated': '$(date -u +"%Y-%m-%dT%H:%M:%SZ")'
}, indent=2))
")

# Write to cache file
echo "$SIMULATOR_LIST" > "$CACHE_FILE"

# Count simulators
SIMULATOR_COUNT=$(echo "$SIMULATOR_LIST" | python3 -c "import json, sys; print(len(json.load(sys.stdin).get('simulators', [])))")

echo "✅ Found $SIMULATOR_COUNT available simulator(s)"
echo "📝 Cached to: $CACHE_FILE"

# Show default simulator
DEFAULT=$(echo "$SIMULATOR_LIST" | python3 -c "import json, sys; print(json.load(sys.stdin).get('default', 'None'))")
if [ "$DEFAULT" != "None" ] && [ -n "$DEFAULT" ]; then
    echo "🎯 Default simulator: $DEFAULT"
fi

