//
//  EndorsementThumbnailView.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import PDFKit
import SwiftUI
import UIKit

// MARK: - EndorsementThumbnailView

struct EndorsementThumbnailView: View {
  // MARK: - Properties

  let endorsement: EndorsementImage
  let onTap: () -> Void
  @State private var uiImage: UIImage?

  // MARK: - Body

  var body: some View {
    VStack {
      Button(action: onTap) {
        if let uiImage = uiImage {
          Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 60)
            .clipped()
            .cornerRadius(8)
        } else {
          Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(height: 60)
            .cornerRadius(8)
            .overlay(
              Image(systemName: "photo")
                .foregroundColor(.gray)
            )
        }
      }
      .buttonStyle(PlainButtonStyle())
    }
    .onAppear {
      loadImage()
    }
    .onDisappear {
      // Release image when view disappears to free memory
      uiImage = nil
    }
  }

  // MARK: - Methods

  private func loadImage() {
    guard let imageData = endorsement.imageData else {
      return
    }

    // Check if this is PDF data or image data
    if endorsement.filename.hasSuffix(".pdf") {
      // For PDF files, create a PDF thumbnail - optimize for memory
      DispatchQueue.global(qos: .userInitiated).async {
        autoreleasepool {
          guard let pdfDocument = PDFDocument(data: imageData),
            let page = pdfDocument.page(at: 0)
          else {
            return
          }
          let thumbnailSize = CGSize(width: 200, height: 200)
          let thumbnail = page.thumbnail(of: thumbnailSize, for: .mediaBox)
          // Optimize thumbnail to reduce memory
          let optimizedThumbnail = ImageOptimizationService.shared.optimizeImage(
            thumbnail, maxSize: thumbnailSize)
          DispatchQueue.main.async {
            self.uiImage = optimizedThumbnail ?? thumbnail
          }
        }
      }
    } else {
      // For regular image files - optimize to reduce memory
      DispatchQueue.global(qos: .userInitiated).async {
        autoreleasepool {
          guard let originalImage = UIImage(data: imageData) else { return }
          // Optimize image to reduce memory footprint
          let optimizedImage = ImageOptimizationService.shared.optimizeImage(
            originalImage, maxSize: CGSize(width: 800, height: 800))
          DispatchQueue.main.async {
            self.uiImage = optimizedImage
          }
        }
      }
    }
  }
}

