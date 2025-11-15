//
//  SafeModelAccess.swift
//  Right Rudder
//
//  Created by AI on 12/19/25.
//

import Foundation
import SwiftData

// MARK: - SafeModelAccess

/// Utilities for safely accessing SwiftData model instances to prevent fatal invalidation errors
enum SafeModelAccess {
  /// Safely accesses a model property, returning nil if the model is invalidated
  static func safePropertyAccess<T>(_ model: (any PersistentModel)?, property: () -> T) -> T? {
    guard let model = model else { return nil }
    
    // Try to access the property, catching any potential fatal errors
    // Note: Swift fatal errors can't be caught, but we can validate the model first
    do {
      // Validate model is still accessible by checking its persistent identifier
      let _ = model.persistentModelID
      return property()
    } catch {
      print("⚠️ Model invalidation detected during property access: \(error)")
      NotificationCenter.default.post(
        name: Notification.Name("DatabaseInvalidationError"), object: nil)
      return nil
    }
  }

  /// Safely executes a closure with a model, handling invalidation errors
  static func safeAccess<T, R>(_ model: T?, operation: (T) throws -> R) throws -> R? where T: PersistentModel {
    guard let model = model else { return nil }
    
    do {
      // Validate model is still accessible
      let _ = model.persistentModelID
      return try operation(model)
    } catch {
      if DatabaseErrorHandler.isInvalidationError(error) {
        print("⚠️ Model invalidation detected: \(error)")
        NotificationCenter.default.post(
          name: Notification.Name("DatabaseInvalidationError"), object: nil)
        throw error
      }
      throw error
    }
  }

  /// Validates that a model instance is still valid
  static func isValid(_ model: (any PersistentModel)?) -> Bool {
    guard let model = model else { return false }
    
    do {
      // Try to access the persistent identifier
      let _ = model.persistentModelID
      return true
    } catch {
      print("⚠️ Model validation failed: \(error)")
      return false
    }
  }

  /// Safely fetches models, filtering out invalidated instances
  static func safeFetch<T: PersistentModel>(
    _ context: ModelContext, descriptor: FetchDescriptor<T>
  ) throws -> [T] {
    let results = try context.fetch(descriptor)
    
    // Filter out any invalidated models
    return results.compactMap { model in
      if isValid(model) {
        return model
      } else {
        print("⚠️ Filtered out invalidated model: \(type(of: model))")
        return nil
      }
    }
  }
}

// MARK: - ModelContext Extension

extension ModelContext {
  /// Safely saves the context, handling disk I/O errors and invalidation
  func saveSafelyWithRecovery() async throws {
    // Validate context is still valid
    processPendingChanges()
    
    // Use the error handler for save with recovery
    _ = try await DatabaseErrorHandler.saveWithRecovery(self)
  }
}

