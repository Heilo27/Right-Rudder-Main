//
//  BannerSegmentView.swift
//  Right Rudder
//
//  Aviation-themed Snake game banner segment view
//

import SwiftUI

// MARK: - BannerSegmentView

public struct BannerSegmentView: View {
  // MARK: - Properties

  public let position: Point
  public let index: Int
  public let total: Int
  public let isLast: Bool
  public let direction: Direction

  // MARK: - Initialization

  public init(position: Point, index: Int, total: Int, isLast: Bool, direction: Direction) {
    self.position = position
    self.index = index
    self.total = total
    self.isLast = isLast
    self.direction = direction
  }

  // MARK: - Body

  public var body: some View {
    ZStack {
      // Banner segment - orient based on direction
      Rectangle()
        .fill(bannerColor)
        .frame(
          width: (direction == .up || direction == .down) ? 3 : 12,
          height: (direction == .up || direction == .down) ? 12 : 3
        )
        .cornerRadius(1)

      // Text on banner (if long enough and showing message)
      if total >= 22 {
        let textStartIndex = max(0, total - 22)
        if index >= textStartIndex {
          let textIndex = index - textStartIndex
          let messageWithoutSpaces = bannerText.replacingOccurrences(of: " ", with: "")
          let bannerCharacters = Array(messageWithoutSpaces)

          // Map text characters to banner segments (stretch text across available segments)
          let textLength = bannerCharacters.count
          let availableSegments = total - textStartIndex
          let segmentRatio = Double(textLength) / Double(availableSegments)
          let charIndex = Int(Double(textIndex) * segmentRatio)

          if charIndex < textLength {
            Text(String(bannerCharacters[charIndex]))
              .font(.system(size: 7, weight: .bold))
              .foregroundColor(.white)
              .frame(
                width: (direction == .up || direction == .down) ? 3 : 12,
                height: (direction == .up || direction == .down) ? 12 : 3
              )
          }
        }
      }
    }
  }

  // MARK: - Computed Properties

  private var bannerColor: Color {
    // Make banner segments slightly different shades
    let ratio = Double(index) / Double(max(total, 1))
    return Color.blue.opacity(0.7 - ratio * 0.3)
  }

  private var bannerText = "Thank you for your support"
}

