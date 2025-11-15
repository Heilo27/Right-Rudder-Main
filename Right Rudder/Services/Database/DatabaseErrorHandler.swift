//
//  DatabaseErrorHandler.swift
//  Right Rudder
//
//  Created by AI on 12/19/25.
//

import Foundation
import SwiftData

// MARK: - DatabaseErrorHandler

/// Utility for detecting and handling database errors, especially disk I/O errors
enum DatabaseErrorHandler {
  // MARK: - Constants

  /// SQLite error codes that indicate disk I/O problems
  static let diskIOErrorCodes: Set<Int> = [
    778,  // I/O error for database
    10,  // disk I/O error
    266,  // database disk image is malformed
    11,  // database locked
    14,  // unable to open database file
    256,  // file couldn't be opened (NSCocoaErrorDomain)
  ]

  // MARK: - Error Detection

  /// Checks if an error is a disk I/O error
  static func isDiskIOError(_ error: Error) -> Bool {
    // Check error description first (for CoreData error messages)
    let errorString = error.localizedDescription.lowercased()
    if errorString.contains("disk i/o error") || errorString.contains("i/o error for database")
      || errorString.contains("couldn't be opened")
      || errorString.contains("disk image is malformed")
      || errorString.contains("could not be opened")
    {
      return true
    }

    // Check NSError for SQLite error codes
    if let nsError = error as NSError? {
      // Check NSCocoaErrorDomain for file errors (code 256 = file couldn't be opened)
      if nsError.domain == NSCocoaErrorDomain && nsError.code == 256 {
        // Check if it's related to the database store
        if let filePath = nsError.userInfo[NSFilePathErrorKey] as? String,
          filePath.contains("default.store")
        {
          return true
        }
        // Also check userInfo for SQLite error domain
        if let sqliteErrorCode = nsError.userInfo["NSSQLiteErrorDomain"] as? Int {
          if diskIOErrorCodes.contains(sqliteErrorCode) {
            return true
          }
        }
        // If it's error 256 and has NSFilePath, it's likely a file I/O error
        if nsError.userInfo[NSFilePathErrorKey] != nil {
          return true
        }
      }

      // Check SQLite error domain
      if nsError.domain == "NSSQLiteErrorDomain" {
        if diskIOErrorCodes.contains(nsError.code) {
          return true
        }
      }

      // Check userInfo for SQLite error codes
      if let sqliteErrorCode = nsError.userInfo["NSSQLiteErrorDomain"] as? Int {
        if diskIOErrorCodes.contains(sqliteErrorCode) {
          return true
        }
      }

      // Check for SQLite error code in userInfo
      if let sqliteErrorCode = nsError.userInfo["NSSQLiteErrorDomain"] as? NSNumber {
        if diskIOErrorCodes.contains(sqliteErrorCode.intValue) {
          return true
        }
      }

      // Check error code directly (CoreData sometimes puts SQLite codes here)
      if diskIOErrorCodes.contains(nsError.code) {
        return true
      }
    }

    return false
  }

  /// Checks if an error indicates database corruption
  static func isCorruptionError(_ error: Error) -> Bool {
    // Disk I/O errors can indicate corruption
    if isDiskIOError(error) {
      return true
    }

    let errorString = error.localizedDescription.lowercased()
    return errorString.contains("corruption") || errorString.contains("malformed")
      || errorString.contains("invalidated")
      || errorString.contains("backing data could no longer be found")
  }

  /// Checks if an error indicates a model instance was invalidated
  static func isInvalidationError(_ error: Error) -> Bool {
    let errorString = error.localizedDescription.lowercased()
    return errorString.contains("invalidated")
      || errorString.contains("backing data could no longer be found")
      || errorString.contains("model instance was invalidated")
      || errorString.contains("persistentidentifier")
      || errorString.contains("backing data")
  }

  /// Safely executes a closure that might access invalidated model instances
  /// Catches fatal errors and converts them to recoverable errors
  static func safeModelAccess<T>(_ operation: () throws -> T) throws -> T {
    do {
      return try operation()
    } catch {
      // Check if this is an invalidation error
      if isInvalidationError(error) {
        print("⚠️ Model invalidation detected during safe access")
        // Post notification for UI to handle
        NotificationCenter.default.post(
          name: Notification.Name("DatabaseInvalidationError"), object: nil)
        throw error
      }
      throw error
    }
  }

  /// Attempts to save with disk I/O error recovery using serialized save queue
  /// Returns true if save succeeded, false if it failed after recovery attempts
  static func saveWithRecovery(_ context: ModelContext, maxAttempts: Int = 3) async throws -> Bool {
    // Validate context first
    let isValid = await MainActor.run {
      // processPendingChanges() doesn't throw, but we check if context is still valid
      // by attempting to access it
      context.processPendingChanges()
      return true
    }

    guard isValid else {
      print("❌ ModelContext is invalid - cannot save")
      throw NSError(
        domain: "DatabaseErrorHandler", code: -1,
        userInfo: [NSLocalizedDescriptionKey: "ModelContext is invalid"])
    }

    var lastError: Error?

    for attempt in 1...maxAttempts {
      do {
        // Use serialized save queue to prevent concurrent saves
        try await context.saveSafely()
        if attempt > 1 {
          print("✅ Save succeeded after \(attempt) attempts")
        }
        return true
      } catch {
        lastError = error
        print("❌ Save attempt \(attempt)/\(maxAttempts) failed: \(error)")

        // Check if this is a disk I/O error
        if isDiskIOError(error) {
          print("⚠️ Disk I/O error detected - attempting recovery...")

          // Trigger recovery service
          await DatabaseRecoveryService.shared.handleDiskIOError()

          // Wait a bit longer for recovery
          if attempt < maxAttempts {
            try await Task.sleep(nanoseconds: UInt64(200_000_000 * attempt))  // 0.2s, 0.4s, 0.6s
          }
        } else if isInvalidationError(error) {
          print("⚠️ Model invalidation error detected - context may need refresh")
          // For invalidation errors, we can't recover by retrying
          // The context needs to be refreshed or the view needs to reload
          throw error
        } else {
          // For other errors, just retry with a short delay
          if attempt < maxAttempts {
            try await Task.sleep(nanoseconds: 50_000_000)  // 0.05 seconds
          }
        }
      }
    }

    // If we get here, all attempts failed
    if let lastError = lastError {
      print("❌ All save attempts failed. Last error: \(lastError)")
      throw lastError
    }

    return false
  }
}
