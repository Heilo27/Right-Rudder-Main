//
//  CloudView.swift
//  Right Rudder
//
//  Aviation-themed Snake game cloud view
//

import SwiftUI

// MARK: - CloudView

struct CloudView: View {
  // MARK: - Body

  var body: some View {
    ZStack {
      Circle()
        .fill(Color.white.opacity(0.8))
        .frame(width: 12, height: 12)
        .offset(x: -3, y: 0)

      Circle()
        .fill(Color.white.opacity(0.8))
        .frame(width: 10, height: 10)
        .offset(x: 3, y: 0)

      Circle()
        .fill(Color.white.opacity(0.8))
        .frame(width: 8, height: 8)
        .offset(x: 0, y: 2)
    }
  }
}

