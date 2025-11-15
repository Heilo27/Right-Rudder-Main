# Pre-Commit Hooks Guide

## Overview

Right Rudder uses Git pre-commit hooks to automatically check code formatting before commits are allowed. This prevents formatting violations from entering the codebase.

## Installation

The pre-commit hook is automatically installed when you clone the repository. If you need to reinstall it:

```bash
./scripts/install-pre-commit-hook.sh
```

Or manually:

```bash
cp scripts/pre-commit-hook.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## How It Works

The pre-commit hook runs automatically on every `git commit`. It:

1. **Checks staged Swift files** - Only files that are staged for commit are checked
2. **Runs `swift format lint`** - Validates formatting against `.swift-format.json`
3. **Blocks commits with violations** - If violations are found, the commit is rejected
4. **Provides helpful error messages** - Shows which files have violations and how to fix them

## Example Output

### ✅ Success (No Violations)
```
Running pre-commit checks...
Checking formatting for 3 Swift file(s)...
  Checking Right Rudder/Models/Student.swift... ✓
  Checking Right Rudder/Views/StudentsView.swift... ✓
  Checking Right Rudder/Services/StudentService.swift... ✓
✓ All Swift files are properly formatted!
```

### ❌ Failure (Violations Found)
```
Running pre-commit checks...
Checking formatting for 2 Swift file(s)...
  Checking Right Rudder/Models/Student.swift... ✓
  Checking Right Rudder/Views/StudentsView.swift... ✗

❌ Formatting violations detected!
The following files have formatting violations:

Right Rudder/Views/StudentsView.swift

To fix formatting violations, run:
  xcrun swift format --in-place --recursive "Right Rudder"

Or fix individual files:
  xcrun swift format --in-place "Right Rudder/Views/StudentsView.swift"

Commit blocked. Please fix formatting violations and try again.
```

## Fixing Violations

When violations are detected, you have two options:

### Option 1: Auto-fix All Files
```bash
xcrun swift format --in-place --recursive "Right Rudder"
```

### Option 2: Fix Individual Files
```bash
xcrun swift format --in-place "Right Rudder/Views/StudentsView.swift"
```

After fixing violations, stage the changes and commit again:

```bash
git add -u
git commit -m "Your commit message"
```

## Bypassing the Hook (Not Recommended)

If you absolutely need to bypass the hook (e.g., for emergency hotfixes), use:

```bash
git commit --no-verify -m "Emergency fix"
```

**⚠️ Warning:** Only bypass the hook in exceptional circumstances. All code should be properly formatted before committing.

## Troubleshooting

### Hook Not Running

If the hook doesn't run:

1. **Check if it's installed:**
   ```bash
   ls -la .git/hooks/pre-commit
   ```

2. **Verify it's executable:**
   ```bash
   chmod +x .git/hooks/pre-commit
   ```

3. **Reinstall:**
   ```bash
   ./scripts/install-pre-commit-hook.sh
   ```

### Swift Format Not Found

If you see errors about `swift-format` not found:

1. **Verify Xcode is installed:**
   ```bash
   xcode-select -p
   ```

2. **Check swift-format is available:**
   ```bash
   xcrun swift format --version
   ```

3. **If missing, install Xcode Command Line Tools:**
   ```bash
   xcode-select --install
   ```

## Configuration

The hook uses the `.swift-format.json` configuration file in the project root. This file defines:

- Line length: 100 characters
- Indentation: 2 spaces
- Maximum blank lines: 1
- Other formatting rules

See `.swift-format.json` for the complete configuration.

## Related Documentation

- [AGENTS.md](../AGENTS.md) - Development practices and standards
- [.swift-format.json](../.swift-format.json) - Formatting configuration
- [Code Organization Rules](../.cursor/rules/swift-code-organization.mdc) - Code organization standards

