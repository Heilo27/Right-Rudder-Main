# Database Error Handling Guide

## Overview

This guide documents the comprehensive error handling system implemented to address CoreData/SwiftData disk I/O errors and model invalidation fatal crashes.

## Problem

The app was experiencing fatal crashes due to:
1. **Disk I/O Errors**: SQLite error codes 266, 10, and 256 indicating database corruption or inaccessible files
2. **Model Invalidation**: Fatal errors when accessing SwiftData model instances whose backing data was no longer available
3. **Unhandled CoreData Errors**: Errors propagating to fatal crashes before recovery could be attempted

## Solution Components

### 1. CoreDataErrorObserver (`CoreDataErrorObserver.swift`)

A global error observer that catches CoreData errors before they cause fatal crashes.

**Features:**
- Observes CoreData save notifications
- Detects disk I/O errors and corruption
- Triggers recovery automatically
- Posts notifications for UI handling

**Usage:**
```swift
// Automatically started in RightRudderApp.init()
CoreDataErrorObserver.shared.startObserving()
```

### 2. Enhanced DatabaseErrorHandler (`DatabaseErrorHandler.swift`)

Enhanced error detection and handling utilities.

**Improvements:**
- Added error code 256 detection (file couldn't be opened)
- Improved NSCocoaErrorDomain error detection
- Added `safeModelAccess` wrapper for safe model operations
- Enhanced invalidation error detection

**Error Codes Detected:**
- `778`: I/O error for database
- `10`: disk I/O error
- `266`: database disk image is malformed
- `11`: database locked
- `14`: unable to open database file
- `256`: file couldn't be opened (NSCocoaErrorDomain)

### 3. Improved DatabaseRecoveryService (`DatabaseRecoveryService.swift`)

Enhanced recovery handling with aggressive error recovery.

**New Methods:**
- `handleDiskIOErrorAggressive()`: Immediately triggers recovery for persistent disk I/O errors
- Improved `handleDiskIOError()`: More aggressive recovery for error codes 266, 10, 256

### 4. Safe Model Access (`SafeModelAccess.swift`)

Utilities for safely accessing SwiftData model instances.

**Features:**
- `safePropertyAccess`: Safely accesses model properties
- `safeAccess`: Safely executes operations on models
- `isValid`: Validates model instances
- `safeFetch`: Filters out invalidated models from fetch results

### 5. Enhanced ModelContextSaveQueue (`ModelContextSaveQueue.swift`)

Improved save queue with error detection and recovery.

**Improvements:**
- Catches disk I/O errors during save operations
- Triggers aggressive recovery automatically
- Better error logging

## Error Flow

1. **Error Detection**: CoreDataErrorObserver or save operations detect errors
2. **Error Classification**: DatabaseErrorHandler classifies error type
3. **Recovery Trigger**: DatabaseRecoveryService handles recovery
4. **UI Notification**: User is notified via alerts and recovery progress

## Recovery Process

1. **Detection**: Disk I/O errors trigger recovery alert
2. **Backup**: Attempts to backup data from CloudKit
3. **Cleanup**: Removes corrupted database files
4. **Recreation**: Creates fresh database
5. **Restore**: Restores data from CloudKit backup

## User Experience

- **Recovery Alert**: User is prompted to recover database
- **Progress Indicator**: Shows recovery progress
- **Error Alerts**: Informs user of errors and recovery status
- **Automatic Recovery**: Attempts automatic recovery when possible

## Best Practices

1. **Always use `saveWithRecovery`** for critical save operations
2. **Use `SafeModelAccess` utilities** when accessing model properties
3. **Handle invalidation errors gracefully** - don't access invalidated models
4. **Monitor error notifications** for UI updates

## Testing

To test error handling:
1. Simulate disk I/O errors by corrupting database files
2. Test recovery flow with corrupted database
3. Verify error detection and recovery alerts
4. Test model invalidation scenarios

## Future Improvements

- Add more granular error recovery options
- Implement automatic CloudKit sync after recovery
- Add error analytics and reporting
- Improve recovery success rates

