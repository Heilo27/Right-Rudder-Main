//
//  CameraView.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import SwiftUI
import UIKit

// MARK: - CameraView

struct CameraView: UIViewControllerRepresentable {
  // MARK: - Properties

  let onImageCaptured: (UIImage) -> Void
  @Environment(\.dismiss) private var dismiss

  // MARK: - UIViewControllerRepresentable

  func makeUIViewController(context: Context) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.delegate = context.coordinator
    picker.sourceType = .camera
    picker.allowsEditing = true
    return picker
  }

  func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  // MARK: - Coordinator

  class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let parent: CameraView

    init(_ parent: CameraView) {
      self.parent = parent
    }

    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(
      _ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
      if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
        parent.onImageCaptured(image)
      }
      parent.dismiss()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      parent.dismiss()
    }
  }
}

#Preview {
  CameraView { _ in }
}
