//
//  AsyncLock.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import os.lock

// MARK: - AsyncLock

/// Async-safe lock wrapper for Swift 6 concurrency
final class AsyncLock {
  // MARK: - Properties

  private var _lock = os_unfair_lock()

  // MARK: - Methods

  func lock() {
    os_unfair_lock_lock(&_lock)
  }

  func unlock() {
    os_unfair_lock_unlock(&_lock)
  }

  func withLock<T>(_ body: () throws -> T) rethrows -> T {
    lock()
    defer { unlock() }
    return try body()
  }
}

