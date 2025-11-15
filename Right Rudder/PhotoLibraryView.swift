//
//  PhotoLibraryView.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import SwiftUI
import UIKit

struct PhotoLibraryView: UIViewControllerRepresentable {
  let onImageSelected: (UIImage) -> Void
  @Environment(\.dismiss) private var dismiss

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

  class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let parent: PhotoLibraryView

    init(_ parent: PhotoLibraryView) {
      self.parent = parent
    }

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
