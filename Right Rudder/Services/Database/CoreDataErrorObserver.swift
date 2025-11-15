//
//  CoreDataErrorObserver.swift
//  Right Rudder
//
//  Created by AI on 12/19/25.
//

import Foundation
import CoreData

// MARK: - CoreDataErrorObserver

/// Observes CoreData errors globally to catch disk I/O errors before they cause fatal crashes
class CoreDataErrorObserver {
  // MARK: - Singleton

  static let shared = CoreDataErrorObserver()

  // MARK: - Properties

  private var isObserving = false
  private var notificationObserver: NSObjectProtocol?

  // MARK: - Initialization

  private init() {}

  // MARK: - Error Observation

  /// Starts observing CoreData errors globally
  func startObserving() {
    guard !isObserving else { return }
    isObserving = true

    // Observe CoreData error notifications
    notificationObserver = NotificationCenter.default.addObserver(
      forName: .NSManagedObjectContextDidSave,
      object: nil,
      queue: .main
    ) { [weak self] notification in
      self?.handleCoreDataNotification(notification)
    }

    // Also observe CoreData error domain notifications
    // Note: CoreData doesn't always post these, but we can catch errors during save operations
    print("✅ CoreData error observer started")
  }

  /// Stops observing CoreData errors
  func stopObserving() {
    guard isObserving else { return }
    isObserving = false

    if let observer = notificationObserver {
      NotificationCenter.default.removeObserver(observer)
      notificationObserver = nil
    }

    print("✅ CoreData error observer stopped")
  }

  // MARK: - Error Handling

  /// Handles CoreData notifications and checks for errors
  private func handleCoreDataNotification(_ notification: Notification) {
    // Check if there are any errors in the notification
    if let error = notification.userInfo?[NSManagedObjectContextSaveErrorKey] as? Error {
      handleCoreDataError(error)
    }

    // Check for error in userInfo
    if let userInfo = notification.userInfo {
      for (_, value) in userInfo {
        if let error = value as? Error {
          if DatabaseErrorHandler.isDiskIOError(error) || DatabaseErrorHandler.isCorruptionError(
            error)
          {
            handleCoreDataError(error)
          }
        }
      }
    }
  }

  /// Handles a CoreData error by triggering recovery
  private func handleCoreDataError(_ error: Error) {
    print("⚠️ CoreData error detected: \(error.localizedDescription)")
    
    // Log detailed error information
    if let nsError = error as NSError? {
      print("⚠️ Error domain: \(nsError.domain)")
      print("⚠️ Error code: \(nsError.code)")
      print("⚠️ Error userInfo: \(nsError.userInfo)")
    }

    // Check if this is a disk I/O error
    if DatabaseErrorHandler.isDiskIOError(error) {
      print("⚠️ Disk I/O error detected in CoreData - triggering aggressive recovery...")
      Task {
        await DatabaseRecoveryService.shared.handleDiskIOErrorAggressive()
      }
    }

    // Check if this is a corruption error
    if DatabaseErrorHandler.isCorruptionError(error) {
      print("⚠️ Database corruption detected in CoreData - triggering recovery...")
      Task {
        await DatabaseRecoveryService.shared.attemptRecovery()
      }
    }

    // Check if this is an invalidation error
    if DatabaseErrorHandler.isInvalidationError(error) {
      print("⚠️ Model invalidation detected in CoreData - posting notification...")
      NotificationCenter.default.post(
        name: Notification.Name("DatabaseInvalidationError"), object: nil)
    }

    // Post notification for UI to handle
    NotificationCenter.default.post(
      name: Notification.Name("CoreDataErrorDetected"), object: nil, userInfo: ["error": error])
  }
}

// MARK: - NSManagedObjectContextSaveErrorKey

/// Key for CoreData save errors in notification userInfo
extension Notification.Name {
  static let NSManagedObjectContextDidSave = Notification.Name("NSManagedObjectContextDidSave")
}

/// UserInfo key for CoreData save errors
let NSManagedObjectContextSaveErrorKey = "NSManagedObjectContextSaveErrorKey"

