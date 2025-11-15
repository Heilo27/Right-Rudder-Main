//
//  AirplaneView.swift
//  Right Rudder
//
//  Aviation-themed Snake game airplane view
//

import SwiftUI

// MARK: - AirplaneView

public struct AirplaneView: View {
  // MARK: - Properties

  public let direction: Direction

  // MARK: - Initialization

  public init(direction: Direction) {
    self.direction = direction
  }

  // MARK: - Body

  public var body: some View {
    Image(systemName: "airplane")
      .foregroundColor(.blue)
      .font(.system(size: 16, weight: .bold))
      .rotationEffect(.degrees(rotationAngle))
  }

  // MARK: - Computed Properties

  private var rotationAngle: Double {
    switch direction {
    case .up: return -90
    case .down: return 90
    case .left: return 180
    case .right: return 0
    }
  }
}

