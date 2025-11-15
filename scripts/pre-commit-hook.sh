#!/bin/bash
#
# Pre-commit hook for Right Rudder
# Runs swift format lint on staged Swift files
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Running pre-commit checks...${NC}"

# Get list of staged Swift files
STAGED_SWIFT_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.swift$' || true)

if [ -z "$STAGED_SWIFT_FILES" ]; then
  echo -e "${GREEN}No Swift files staged. Skipping format check.${NC}"
  exit 0
fi

# Count files
FILE_COUNT=$(echo "$STAGED_SWIFT_FILES" | grep -c '\.swift$' || echo "0")
echo -e "${YELLOW}Checking formatting for $FILE_COUNT Swift file(s)...${NC}"

# Run swift format lint on staged files
HAS_ERRORS=0
ERROR_OUTPUT=""

for file in $STAGED_SWIFT_FILES; do
  if [ -f "$file" ]; then
    echo -n "  Checking $file... "
    
    # Run lint and capture output
    if xcrun swift format lint "$file" 2>&1 > /dev/null; then
      echo -e "${GREEN}✓${NC}"
    else
      echo -e "${RED}✗${NC}"
      HAS_ERRORS=1
      ERROR_OUTPUT="${ERROR_OUTPUT}\n${file}"
    fi
  fi
done

if [ $HAS_ERRORS -eq 1 ]; then
  echo ""
  echo -e "${RED}❌ Formatting violations detected!${NC}"
  echo -e "${YELLOW}The following files have formatting violations:${NC}"
  echo -e "$ERROR_OUTPUT"
  echo ""
  echo -e "${YELLOW}To fix formatting violations, run:${NC}"
  echo -e "  ${GREEN}xcrun swift format --in-place --recursive \"Right Rudder\"${NC}"
  echo ""
  echo -e "${YELLOW}Or fix individual files:${NC}"
  for file in $STAGED_SWIFT_FILES; do
    if [ -f "$file" ]; then
      if ! xcrun swift format lint "$file" 2>&1 > /dev/null; then
        echo -e "  ${GREEN}xcrun swift format --in-place \"$file\"${NC}"
      fi
    fi
  done
  echo ""
  echo -e "${RED}Commit blocked. Please fix formatting violations and try again.${NC}"
  exit 1
fi

echo -e "${GREEN}✓ All Swift files are properly formatted!${NC}"
exit 0

