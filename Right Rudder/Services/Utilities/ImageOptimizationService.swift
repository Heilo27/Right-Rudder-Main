//
//  ImageOptimizationService.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - ImageOptimizationService

class ImageOptimizationService {
  // MARK: - Singleton

  static let shared = ImageOptimizationService()

  // MARK: - Properties

  private let imageCache = NSCache<NSString, UIImage>()
  private let maxCacheSize = 5  // Reduced to 5 images to save memory
  private let maxCacheSizeMB = 5  // Reduced to 5MB to save memory

  // MARK: - Initialization

  private init() {
    imageCache.countLimit = maxCacheSize
    imageCache.totalCostLimit = maxCacheSizeMB * 1024 * 1024  // 5MB limit

    // Add memory pressure handling
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(clearCache),
      name: UIApplication.didReceiveMemoryWarningNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(clearCache),
      name: UIApplication.didEnterBackgroundNotification,
      object: nil
    )

    // Add low memory handling
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleLowMemory),
      name: UIApplication.didReceiveMemoryWarningNotification,
      object: nil
    )
  }

  // MARK: - Image Optimization

  // Optimize image for display with compression
  func optimizeImage(_ image: UIImage, maxSize: CGSize = CGSize(width: 300, height: 300))
    -> UIImage?
  {
    let cacheKey = "\(image.hash)_\(maxSize.width)_\(maxSize.height)" as NSString

    // Check cache first
    if let cachedImage = imageCache.object(forKey: cacheKey) {
      return cachedImage
    }

    // Resize and compress image
    let resizedImage = resizeImage(image, to: maxSize)
    let compressedImage = compressImage(resizedImage)

    // Cache the optimized image
    if let compressedImage = compressedImage {
      imageCache.setObject(compressedImage, forKey: cacheKey)
    }

    return compressedImage
  }

  // MARK: - Private Helpers

  private func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage {
    let aspectRatio = image.size.width / image.size.height
    var newSize = size

    // Maintain aspect ratio
    if aspectRatio > 1 {
      newSize.height = size.width / aspectRatio
    } else {
      newSize.width = size.height * aspectRatio
    }

    // Use UIGraphicsImageRenderer for better memory management
    let renderer = UIGraphicsImageRenderer(size: newSize)
    return renderer.image { _ in
      image.draw(in: CGRect(origin: .zero, size: newSize))
    }
  }

  private func compressImage(_ image: UIImage, quality: CGFloat = 0.8) -> UIImage? {
    guard let imageData = image.jpegData(compressionQuality: quality) else { return nil }
    return UIImage(data: imageData)
  }

  // MARK: - Cache Management

  // Clear cache when memory pressure is detected
  @objc func clearCache() {
    imageCache.removeAllObjects()
    print("Image cache cleared due to memory pressure")
  }

  // Handle low memory warnings more aggressively
  @objc private func handleLowMemory() {
    imageCache.removeAllObjects()
    print("Image cache cleared due to low memory warning")

    // Force garbage collection
    DispatchQueue.main.async {
      // Trigger memory cleanup
      autoreleasepool {
        // This will help clean up any lingering image references
      }
    }
  }

  // MARK: - Cache Access

  // Get cached image if available
  func getCachedImage(for key: String) -> UIImage? {
    return imageCache.object(forKey: key as NSString)
  }
}
