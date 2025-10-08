#!/bin/bash

# Auto-Increment Build Number Script for Xcode
# This script automatically increments the build number (CFBundleVersion) on each successful build
# Place this in a "Run Script" build phase in Xcode

# Get the plist file path
if [ -n "$INFOPLIST_FILE" ]; then
    PLIST="${PROJECT_DIR}/${INFOPLIST_FILE}"
else
    PLIST="${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
fi

# Check if plist exists
if [ ! -f "$PLIST" ]; then
    echo "warning: Could not find Info.plist at $PLIST"
    exit 0
fi

# Get current build number
CURRENT_BUILD=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$PLIST" 2>/dev/null)

# If no build number exists, start at 1
if [ -z "$CURRENT_BUILD" ]; then
    CURRENT_BUILD=0
fi

# Increment build number
NEW_BUILD=$((CURRENT_BUILD + 1))

# Update the build number
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEW_BUILD" "$PLIST"

echo "Build number incremented from $CURRENT_BUILD to $NEW_BUILD"

