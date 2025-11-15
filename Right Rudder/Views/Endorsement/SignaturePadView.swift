//
//  SignaturePadView.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

// MARK: - SignaturePadView

struct SignaturePadView: View {
  // MARK: - Properties

  @Binding var signatureImage: UIImage?
  @Environment(\.dismiss) private var dismiss
  @State private var currentPath = Path()
  @State private var paths: [Path] = []

  // MARK: - Body

  var body: some View {
    NavigationView {
      GeometryReader { geometry in
        VStack {
          Text("Sign your name")
            .font(.headline)
            .padding()

          ZStack {
            Rectangle()
              .fill(Color.white)
              .border(Color.gray, width: 2)
              .frame(height: isLandscape(geometry) ? 300 : 200)

            Canvas { context, size in
              for path in paths {
                context.stroke(path, with: .color(.black), lineWidth: 2)
              }
              context.stroke(currentPath, with: .color(.black), lineWidth: 2)
            }
            .frame(height: isLandscape(geometry) ? 300 : 200)
            .gesture(
              DragGesture(minimumDistance: 0)
                .onChanged { value in
                  let point = value.location
                  if currentPath.isEmpty {
                    currentPath.move(to: point)
                  } else {
                    currentPath.addLine(to: point)
                  }
                }
                .onEnded { _ in
                  paths.append(currentPath)
                  currentPath = Path()
                }
            )
          }
          .padding()

          HStack(spacing: 20) {
            Button("Clear") {
              paths.removeAll()
              currentPath = Path()
            }
            .buttonStyle(.bordered)

            Button("Done") {
              generateSignatureImage()
              dismiss()
            }
            .buttonStyle(.borderedProminent)
          }
          .padding()
        }
      }
      .navigationTitle("Digital Signature")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            dismiss()
          }
        }
      }
    }
  }

  // MARK: - Private Helpers

  private func isLandscape(_ geometry: GeometryProxy) -> Bool {
    return geometry.size.width > geometry.size.height
  }

  private func generateSignatureImage() {
    // Create a higher resolution image for better quality
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 800, height: 400))
    signatureImage = renderer.image { context in
      context.cgContext.setFillColor(UIColor.white.cgColor)
      context.cgContext.fill(CGRect(x: 0, y: 0, width: 800, height: 400))

      context.cgContext.setStrokeColor(UIColor.black.cgColor)
      context.cgContext.setLineWidth(4)  // Slightly thicker for better visibility
      context.cgContext.setLineCap(.round)
      context.cgContext.setLineJoin(.round)

      // Scale the paths to match the higher resolution
      let scaleX: CGFloat = 800.0 / 400.0
      let scaleY: CGFloat = 400.0 / 200.0

      for path in paths {
        let scaledPath = path.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
        context.cgContext.addPath(scaledPath.cgPath)
        context.cgContext.strokePath()
      }
    }
  }
}

