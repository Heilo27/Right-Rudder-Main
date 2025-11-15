//
//  Point.swift
//  Right Rudder
//
//  Aviation-themed Snake game point struct
//

import Foundation

// MARK: - Point

public struct Point: Equatable {
  // MARK: - Properties

  public var x: Int
  public var y: Int

  // MARK: - Initialization

  public init(x: Int, y: Int) {
    self.x = x
    self.y = y
  }

  // MARK: - Computed Properties

  public var description: String {
    return "(\(x), \(y))"
  }
}

