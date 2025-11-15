//
//  DocumentPickerView.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - DocumentPickerView

/// Document Picker
struct DocumentPickerView: UIViewControllerRepresentable {
  // MARK: - Properties

  let documentType: DocumentType
  let completion: (URL) -> Void

  // MARK: - UIViewControllerRepresentable

  func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
    print("DocumentPickerView: Creating UIDocumentPickerViewController")
    let picker = UIDocumentPickerViewController(
      forOpeningContentTypes: [.pdf, .image, .jpeg, .png, .heic], asCopy: true)
    picker.delegate = context.coordinator
    picker.allowsMultipleSelection = false
    picker.modalPresentationStyle = .formSheet
    print("DocumentPickerView: Picker created with delegate set")
    return picker
  }

  func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context)
  {}

  func makeCoordinator() -> Coordinator {
    Coordinator(completion: completion)
  }

  // MARK: - Coordinator

  class Coordinator: NSObject, UIDocumentPickerDelegate {
    let completion: (URL) -> Void

    init(completion: @escaping (URL) -> Void) {
      self.completion = completion
    }

    // MARK: - UIDocumentPickerDelegate

    func documentPicker(
      _ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]
    ) {
      print("DocumentPickerView: didPickDocumentsAt called with \(urls.count) URLs")
      if let url = urls.first {
        print("DocumentPickerView: Calling completion with URL: \(url)")
        completion(url)
      } else {
        print("DocumentPickerView: No URLs provided")
      }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
      print("DocumentPickerView: User cancelled document picker")
    }
  }
}

