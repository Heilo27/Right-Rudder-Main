//
//  QuizPhotoView.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

// MARK: - QuizPhotoView

struct QuizPhotoView: View {
  // MARK: - Properties

  let endorsement: EndorsementImage

  // MARK: - Body

  var body: some View {
    VStack {
      if let imageData = endorsement.imageData,
        let originalImage = UIImage(data: imageData),
        let optimizedImage = ImageOptimizationService.shared.optimizeImage(
          originalImage, maxSize: CGSize(width: 200, height: 200))
      {
        Image(uiImage: optimizedImage)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(height: 100)
          .clipped()
          .cornerRadius(8)
      } else {
        Rectangle()
          .fill(Color.gray.opacity(0.3))
          .frame(height: 100)
          .cornerRadius(8)
          .overlay(
            Image(systemName: "photo")
              .foregroundColor(.gray)
          )
      }

      Text(endorsement.filename)
        .font(.caption)
        .lineLimit(1)
    }
  }
}

