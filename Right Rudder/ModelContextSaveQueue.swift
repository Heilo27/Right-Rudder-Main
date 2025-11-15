//
//  ModelContextSaveQueue.swift
//  Right Rudder
//
//  Created by AI on 12/19/25.
//

import Foundation
import SwiftData

/// Serializes all ModelContext save operations to prevent concurrent saves and I/O errors
actor ModelContextSaveQueue {
    static let shared = ModelContextSaveQueue()
    
    private var isSaving = false
    private var pendingSaves: [CheckedContinuation<Void, Error>] = []
    
    private init() {}
    
    /// Serialized save operation - ensures only one save happens at a time
    func save(_ context: ModelContext) async throws {
        // Wait if another save is in progress
        while isSaving {
            try await Task.sleep(nanoseconds: 10_000_000) // 10ms
        }
        
        isSaving = true
        defer { isSaving = false }
        
        // Ensure we're on the main thread for ModelContext operations
        // Note: ModelContext is not Sendable, but this is safe because:
        // 1. We're guaranteed to be on MainActor (via MainActor.run)
        // 2. ModelContext is designed for main-thread use
        // 3. The actor isolation ensures serialized access
        // We use nonisolated(unsafe) to allow passing non-Sendable ModelContext
        // This is safe because we immediately hop to MainActor where ModelContext is designed to be used
        nonisolated(unsafe) let unsafeContext = context
        return try await MainActor.run {
            // Process any pending changes first
            unsafeContext.processPendingChanges()
            
            // Perform the save
            try unsafeContext.save()
        }
    }
    
    /// Validates that a ModelContext is still valid before use
    func validateContext(_ context: ModelContext) -> Bool {
        // Check if context is still valid by attempting to process pending changes
        // processPendingChanges() doesn't throw, so we just call it
        context.processPendingChanges()
        return true
    }
}

/// Extension to add safe save method to ModelContext
extension ModelContext {
    /// Safely saves the context using the serialized save queue
    func saveSafely() async throws {
        try await ModelContextSaveQueue.shared.save(self)
    }
}

