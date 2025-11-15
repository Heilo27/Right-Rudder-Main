//
//  SuccessSplashView.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

// MARK: - SuccessSplashView

// Success Splash View
struct SuccessSplashView: View {
  // MARK: - Properties

  @State private var scale: CGFloat = 0.5
  @State private var opacity: Double = 0

  // MARK: - Body

  var body: some View {
    ZStack {
      Color.black.opacity(0.3)
        .ignoresSafeArea()

      VStack(spacing: 20) {
        Image(systemName: "checkmark.circle.fill")
          .font(.system(size: 80))
          .foregroundColor(.green)
          .scaleEffect(scale)

        Text("Link Successful!")
          .font(.title)
          .fontWeight(.bold)
          .foregroundColor(.white)
          .opacity(opacity)

        Text("Student app is now connected")
          .font(.subheadline)
          .foregroundColor(.white.opacity(0.8))
          .opacity(opacity)
      }
      .padding(40)
      .background(Color.black.opacity(0.8))
      .cornerRadius(20)
      .scaleEffect(scale)
    }
    .onAppear {
      withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
        scale = 1.0
        opacity = 1.0
      }
    }
  }
}

