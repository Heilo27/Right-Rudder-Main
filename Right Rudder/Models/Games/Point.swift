//
//  Point.swift
//  Right Rudder
//
//  Aviation-themed Snake game point struct
//

import Foundation

// MARK: - Point

struct Point: Equatable {
  // MARK: - Properties

  var x: Int
  var y: Int

  // MARK: - Initialization

  init(x: Int, y: Int) {
    self.x = x
    self.y = y
  }

  // MARK: - Computed Properties

  var description: String {
    return "(\(x), \(y))"
  }
}

