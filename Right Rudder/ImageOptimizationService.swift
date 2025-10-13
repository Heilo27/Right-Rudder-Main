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
    private let maxCacheSize = 50 // Maximum number of images to cache
    
    private init() {
        imageCache.countLimit = maxCacheSize
        imageCache.totalCostLimit = 50 * 1024 * 1024 // 50MB limit
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
        
        if aspectRatio > 1 {
            newSize.height = size.width / aspectRatio
        } else {
            newSize.width = size.height * aspectRatio
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }
    
    private func compressImage(_ image: UIImage, quality: CGFloat = 0.8) -> UIImage? {
        guard let imageData = image.jpegData(compressionQuality: quality) else { return nil }
        return UIImage(data: imageData)
    }
    
    // Clear cache when memory pressure is detected
    func clearCache() {
        imageCache.removeAllObjects()
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
            } else {
                ProgressView()
                    .frame(width: maxSize.width, height: maxSize.height)
            }
        }
        .onAppear {
            loadOptimizedImage()
        }
    }
    
    private func loadOptimizedImage() {
        Task {
            let optimized = ImageOptimizationService.shared.optimizeImage(image, maxSize: maxSize)
            await MainActor.run {
                self.optimizedImage = optimized
            }
        }
    }
}
