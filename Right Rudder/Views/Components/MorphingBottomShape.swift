//
//  MorphingBottomShape.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

// MARK: - MorphingBottomShape

struct MorphingBottomShape: Shape {
  // MARK: - Properties

  let dragOffset: CGFloat
  let isDragging: Bool

  // MARK: - Shape

  func path(in rect: CGRect) -> Path {
    var path = Path()

    // Start from top-left
    path.move(to: CGPoint(x: 0, y: 0))

    // Top edge
    path.addLine(to: CGPoint(x: rect.width, y: 0))

    // Right edge
    path.addLine(to: CGPoint(x: rect.width, y: rect.height))

    // Bottom edge with morphing effect
    if isDragging && dragOffset < 0 {
      let morphAmount = min(abs(dragOffset) / 100.0, 1.0)  // 0 to 1
      let curveHeight = morphAmount * 50  // Max 50 points of curve
      let stretchAmount = morphAmount * 30  // Max 30 points of stretch
      let waveAmplitude = morphAmount * 15  // Wave effect

      // Create a wavy, curved bottom edge
      let startPoint = CGPoint(x: 0, y: rect.height)
      let endPoint = CGPoint(x: rect.width, y: rect.height + stretchAmount)

      // Add multiple curves for a more organic wave effect
      let controlPoint1 = CGPoint(
        x: rect.width * 0.2,
        y: rect.height + curveHeight + waveAmplitude
      )
      let controlPoint2 = CGPoint(
        x: rect.width * 0.4,
        y: rect.height + curveHeight - waveAmplitude
      )
      let controlPoint3 = CGPoint(
        x: rect.width * 0.6,
        y: rect.height + curveHeight + waveAmplitude
      )
      let controlPoint4 = CGPoint(
        x: rect.width * 0.8,
        y: rect.height + curveHeight - waveAmplitude
      )

      path.addLine(to: startPoint)
      path.addCurve(
        to: CGPoint(x: rect.width * 0.5, y: rect.height + curveHeight),
        control1: controlPoint1,
        control2: controlPoint2
      )
      path.addCurve(
        to: endPoint,
        control1: controlPoint3,
        control2: controlPoint4
      )
    } else {
      // Normal straight bottom edge
      path.addLine(to: CGPoint(x: rect.width, y: rect.height))
    }

    // Left edge
    path.addLine(to: CGPoint(x: 0, y: rect.height))

    // Close the path
    path.closeSubpath()

    return path
  }
}

