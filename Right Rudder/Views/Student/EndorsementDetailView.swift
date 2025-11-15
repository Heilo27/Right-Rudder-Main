//
//  EndorsementDetailView.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import PDFKit
import SwiftUI
import UIKit

// MARK: - EndorsementDetailView

struct EndorsementDetailView: View {
  // MARK: - Properties

  let endorsement: EndorsementImage
  let onDelete: () -> Void
  @Environment(\.dismiss) private var dismiss
  @State private var uiImage: UIImage?
  @State private var showingDeleteConfirmation = false
  @State private var scale: CGFloat = 1.0
  @State private var lastScale: CGFloat = 1.0
  @State private var offset: CGSize = .zero
  @State private var lastOffset: CGSize = .zero

  // MARK: - Body

  var body: some View {
    NavigationView {
      ZStack {
        Color.black.ignoresSafeArea()

        if let uiImage = uiImage {
          Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaleEffect(scale)
            .offset(offset)
            .gesture(
              SimultaneousGesture(
                MagnificationGesture()
                  .onChanged { value in
                    scale = lastScale * value
                  }
                  .onEnded { value in
                    lastScale = scale
                    withAnimation(.easeInOut(duration: 0.2)) {
                      if scale < 1.0 {
                        scale = 1.0
                        offset = .zero
                        lastOffset = .zero
                      }
                    }
                  },
                DragGesture()
                  .onChanged { value in
                    offset = CGSize(
                      width: lastOffset.width + value.translation.width,
                      height: lastOffset.height + value.translation.height
                    )
                  }
                  .onEnded { value in
                    lastOffset = offset
                  }
              )
            )
        } else {
          VStack {
            Image(systemName: "photo")
              .font(.system(size: 60))
              .foregroundColor(.white)
            Text("Loading...")
              .foregroundColor(.white)
            Text("Debug: \(endorsement.filename)")
              .foregroundColor(.white)
              .font(.caption)
          }
        }
      }
      .navigationTitle("Endorsement")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Done") {
            dismiss()
          }
          .foregroundColor(.white)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          Button(role: .destructive) {
            showingDeleteConfirmation = true
          } label: {
            Label("Delete", systemImage: "trash")
              .foregroundColor(.white)
          }
        }
      }
    }
    .onAppear {
      loadImage()
    }
    .onDisappear {
      // Release image when view disappears to free memory
      uiImage = nil
    }
    .alert("Delete Endorsement", isPresented: $showingDeleteConfirmation) {
      Button("Cancel", role: .cancel) {}
      Button("Delete", role: .destructive) {
        onDelete()
      }
    } message: {
      Text("Are you sure you want to delete this endorsement? This action cannot be undone.")
    }
  }

  // MARK: - Methods

  private func loadImage() {
    guard let imageData = endorsement.imageData else {
      return
    }

    // Check if this is PDF data or image data
    if endorsement.filename.hasSuffix(".pdf") {
      // For PDF files - optimize rendering to reduce memory
      DispatchQueue.global(qos: .userInitiated).async {
        autoreleasepool {
          guard let pdfDocument = PDFDocument(data: imageData) else {
            return
          }

          guard let page = pdfDocument.page(at: 0) else {
            return
          }

          let pageBounds = page.bounds(for: .mediaBox)

          // Use lower scale for memory efficiency (1.5 instead of 2.0)
          let scale: CGFloat = 1.5
          // Limit maximum size to prevent excessive memory usage
          let maxDimension: CGFloat = 2000
          let rawWidth = pageBounds.width * scale
          let rawHeight = pageBounds.height * scale

          let finalWidth = min(rawWidth, maxDimension)
          let finalHeight = min(rawHeight, maxDimension)
          let size = CGSize(width: finalWidth, height: finalHeight)

          let renderer = UIGraphicsImageRenderer(size: size)
          let image = renderer.image { context in
            // Set white background
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: size))

            // Scale and draw the page
            let actualScale = min(finalWidth / pageBounds.width, finalHeight / pageBounds.height)
            context.cgContext.scaleBy(x: actualScale, y: actualScale)
            page.draw(with: .mediaBox, to: context.cgContext)
          }

          // Optimize the rendered image to reduce memory
          let optimizedImage = ImageOptimizationService.shared.optimizeImage(image, maxSize: size)

          DispatchQueue.main.async {
            self.uiImage = optimizedImage ?? image
          }
        }
      }
    } else {
      // For regular image files - optimize to reduce memory
      DispatchQueue.global(qos: .userInitiated).async {
        autoreleasepool {
          guard let originalImage = UIImage(data: imageData) else { return }
          // Optimize image to reduce memory footprint (larger size for detail view)
          let optimizedImage = ImageOptimizationService.shared.optimizeImage(
            originalImage, maxSize: CGSize(width: 1200, height: 1200))
          DispatchQueue.main.async {
            self.uiImage = optimizedImage
          }
        }
      }
    }
  }
}

