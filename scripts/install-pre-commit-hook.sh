#!/bin/bash
#
# Installation script for pre-commit hook
# Run this once to install the pre-commit hook
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOK_SOURCE="$SCRIPT_DIR/pre-commit-hook.sh"
HOOK_TARGET="$PROJECT_ROOT/.git/hooks/pre-commit"

echo "Installing pre-commit hook..."

if [ ! -f "$HOOK_SOURCE" ]; then
  echo "Error: pre-commit-hook.sh not found at $HOOK_SOURCE"
  exit 1
fi

# Copy hook to .git/hooks/
cp "$HOOK_SOURCE" "$HOOK_TARGET"
chmod +x "$HOOK_TARGET"

echo "✓ Pre-commit hook installed successfully!"
echo ""
echo "The hook will now run automatically on every commit."
echo "To bypass the hook (not recommended), use: git commit --no-verify"

