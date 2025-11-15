//
//  OptimizedImage.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - OptimizedImage View

/// SwiftUI View Modifier for optimized image display
struct OptimizedImage: View {
  // MARK: - Properties

  let image: UIImage
  let maxSize: CGSize
  @State private var optimizedImage: UIImage?
  @State private var isLoading = true

  // MARK: - Initialization

  init(_ image: UIImage, maxSize: CGSize = CGSize(width: 300, height: 300)) {
    self.image = image
    self.maxSize = maxSize
  }

  // MARK: - Body

  var body: some View {
    Group {
      if let optimizedImage = optimizedImage {
        Image(uiImage: optimizedImage)
          .resizable()
          .aspectRatio(contentMode: .fit)
      } else if isLoading {
        ProgressView()
          .frame(width: maxSize.width, height: maxSize.height)
      } else {
        Rectangle()
          .fill(Color.gray.opacity(0.3))
          .frame(width: maxSize.width, height: maxSize.height)
      }
    }
    .onAppear {
      loadOptimizedImage()
    }
    .onDisappear {
      // Clear optimized image when view disappears to free memory
      optimizedImage = nil
    }
  }

  // MARK: - Methods

  private func loadOptimizedImage() {
    Task {
      // Use autoreleasepool to manage memory during image processing
      let optimized = autoreleasepool {
        ImageOptimizationService.shared.optimizeImage(image, maxSize: maxSize)
      }

      await MainActor.run {
        self.optimizedImage = optimized
        self.isLoading = false
      }
    }
  }
}

