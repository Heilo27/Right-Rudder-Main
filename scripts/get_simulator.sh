#!/bin/bash
#
# get_simulator.sh
# Reads the cached simulator list and returns a destination string
# Usage: get_simulator.sh [device_name_filter]
# Example: get_simulator.sh "iPhone 15"
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CACHE_FILE="$PROJECT_ROOT/.simulator_cache.json"

# Check if cache exists, if not, discover simulators
if [ ! -f "$CACHE_FILE" ]; then
    echo "⚠️  Simulator cache not found. Discovering simulators..." >&2
    "$SCRIPT_DIR/discover_simulators.sh" >&2
fi

# Read cache file
if [ ! -f "$CACHE_FILE" ]; then
    echo "❌ Failed to create simulator cache" >&2
    exit 1
fi

# If filter provided, search for matching device
if [ -n "$1" ]; then
    FILTER="$1"
    RESULT=$(python3 -c "
import json
import sys

with open('$CACHE_FILE', 'r') as f:
    data = json.load(f)

# Search for matching simulator
for sim in data.get('simulators', []):
    if '$FILTER' in sim['name']:
        print(sim['destination'])
        sys.exit(0)

# If no match found, use default
print(data.get('default', ''))
" 2>/dev/null)
    
    if [ -n "$RESULT" ]; then
        echo "$RESULT"
    else
        echo "❌ No simulator found matching: $FILTER" >&2
        exit 1
    fi
else
    # Return default simulator
    python3 -c "
import json
with open('$CACHE_FILE', 'r') as f:
    data = json.load(f)
    print(data.get('default', ''))
" 2>/dev/null
fi

