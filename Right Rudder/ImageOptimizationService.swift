//
//  ImageOptimizationService.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation
import UIKit
import SwiftUI

class ImageOptimizationService {
    static let shared = ImageOptimizationService()
    
    private let imageCache = NSCache<NSString, UIImage>()
    private let maxCacheSize = 10 // Further reduced maximum number of images to cache
    private let maxCacheSizeMB = 10 // Further reduced cache size to 10MB
    
    private init() {
        imageCache.countLimit = maxCacheSize
        imageCache.totalCostLimit = maxCacheSizeMB * 1024 * 1024 // 10MB limit
        
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
    
    // Optimize image for display with compression
    func optimizeImage(_ image: UIImage, maxSize: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
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
    
    // Clear cache when memory pressure is detected
    @objc func clearCache() {
        imageCache.removeAllObjects()
        print("Image cache cleared due to memory pressure")
    }
    
    // Handle low memory warnings more aggressively
    @objc func handleLowMemory() {
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
    
    // Get cached image if available
    func getCachedImage(for key: String) -> UIImage? {
        return imageCache.object(forKey: key as NSString)
    }
}

// SwiftUI View Modifier for optimized image display
struct OptimizedImage: View {
    let image: UIImage
    let maxSize: CGSize
    @State private var optimizedImage: UIImage?
    @State private var isLoading = true
    
    init(_ image: UIImage, maxSize: CGSize = CGSize(width: 300, height: 300)) {
        self.image = image
        self.maxSize = maxSize
    }
    
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
