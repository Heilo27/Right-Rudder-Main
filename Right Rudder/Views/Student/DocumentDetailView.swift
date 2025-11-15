//
//  DocumentDetailView.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftData
import SwiftUI

// MARK: - DocumentDetailView

struct DocumentDetailView: View {
  // MARK: - Properties

  @Environment(\.dismiss) private var dismiss
  let document: StudentDocument

  @State private var uiImage: UIImage?
  @State private var isLoading = true

  // MARK: - Body

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {
          // Document preview
          if isLoading {
            VStack {
              ProgressView()
                .scaleEffect(1.2)
              Text("Loading document...")
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(Color.appAdaptiveMutedBox)
            .cornerRadius(12)
          } else if let uiImage = uiImage {
            Image(uiImage: uiImage)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .cornerRadius(12)
          } else {
            VStack(spacing: 12) {
              Image(systemName: documentIcon)
                .font(.system(size: 60))
                .foregroundColor(.blue)
              Text(document.filename)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
              Text("Tap to open in external app")
                .font(.caption2)
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(Color.appAdaptiveMutedBox)
            .cornerRadius(12)
            .onTapGesture {
              openDocumentExternally()
            }
          }

          // Document info
          VStack(alignment: .leading, spacing: 12) {
            InfoField(label: "Type", value: document.documentType.rawValue)
            InfoField(label: "Filename", value: document.filename)
            InfoField(
              label: "Uploaded", value: document.uploadedAt.formatted(date: .long, time: .shortened)
            )

            if let expirationDate = document.expirationDate {
              InfoField(
                label: "Expiration Date",
                value: expirationDate.formatted(date: .long, time: .omitted))
            }

            if let notes = document.notes, !notes.isEmpty {
              VStack(alignment: .leading, spacing: 4) {
                Text("Notes")
                  .font(.caption)
                  .foregroundColor(.secondary)
                Text(notes)
                  .font(.body)
              }
            }
          }
          .padding()
          .background(Color.appMutedBox)
          .cornerRadius(12)
        }
        .padding()
      }
      .navigationTitle("Document Details")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Done") {
            dismiss()
          }
        }
      }
    }
    .onAppear {
      print("DocumentDetailView: View appeared for document: \(document.filename)")
      loadImage()
    }
  }

  // MARK: - Private Helpers

  private var documentIcon: String {
    let filename = document.filename.lowercased()
    if filename.hasSuffix(".pdf") {
      return "doc.fill"
    } else if filename.hasSuffix(".jpg") || filename.hasSuffix(".jpeg")
      || filename.hasSuffix(".png") || filename.hasSuffix(".heic")
    {
      return "photo.fill"
    } else {
      return "doc.fill"
    }
  }

  private func loadImage() {
    guard let fileData = document.fileData else {
      print("DocumentDetailView: No file data available")
      isLoading = false
      return
    }

    print(
      "DocumentDetailView: Loading document with \(fileData.count) bytes, filename: \(document.filename)"
    )

    DispatchQueue.global(qos: .userInitiated).async {
      // Use autoreleasepool to manage memory during image processing
      let image = autoreleasepool {
        UIImage(data: fileData)
      }

      DispatchQueue.main.async {
        if let image = image {
          print("DocumentDetailView: Successfully loaded image")
          self.uiImage = image
        } else {
          print(
            "DocumentDetailView: Failed to create UIImage from data - likely not an image format")
        }
        self.isLoading = false
      }
    }
  }

  private func openDocumentExternally() {
    guard let fileData = document.fileData else { return }

    // Create a temporary file
    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(document.filename)

    do {
      try fileData.write(to: tempURL)

      let activityVC = UIActivityViewController(
        activityItems: [tempURL], applicationActivities: nil)

      if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
        let window = windowScene.windows.first
      {
        window.rootViewController?.present(activityVC, animated: true)
      }
    } catch {
      print("Failed to open document externally: \(error)")
    }
  }
}

