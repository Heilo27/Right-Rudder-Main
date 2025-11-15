//
//  PhotoLibraryView.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import SwiftUI
import UIKit

// MARK: - PhotoLibraryView

struct PhotoLibraryView: UIViewControllerRepresentable {
  // MARK: - Properties

  let onImageSelected: (UIImage) -> Void
  @Environment(\.dismiss) private var dismiss

  // MARK: - UIViewControllerRepresentable

  func makeUIViewController(context: Context) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.delegate = context.coordinator
    picker.sourceType = .photoLibrary
    picker.allowsEditing = true
    return picker
  }

  func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  // MARK: - Coordinator

  class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - Properties

    let parent: PhotoLibraryView

    // MARK: - Initialization

    init(_ parent: PhotoLibraryView) {
      self.parent = parent
    }

    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(
      _ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
      if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
        parent.onImageSelected(image)
      }
      parent.dismiss()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      parent.dismiss()
    }
  }
}

#Preview {
  PhotoLibraryView { _ in }
}
