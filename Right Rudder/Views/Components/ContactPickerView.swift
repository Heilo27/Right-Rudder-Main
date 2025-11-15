//
//  ContactPickerView.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import Contacts
import ContactsUI
import SwiftUI

// MARK: - ContactPickerView

struct ContactPickerView: UIViewControllerRepresentable {
  // MARK: - Properties

  let onContactSelected: (CNContact) -> Void

  // MARK: - UIViewControllerRepresentable

  func makeUIViewController(context: Context) -> CNContactPickerViewController {
    let picker = CNContactPickerViewController()
    picker.delegate = context.coordinator
    return picker
  }

  func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {
    // No updates needed
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  // MARK: - Coordinator

  class Coordinator: NSObject, CNContactPickerDelegate {
    let parent: ContactPickerView

    init(_ parent: ContactPickerView) {
      self.parent = parent
    }

    // MARK: - CNContactPickerDelegate

    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
      parent.onContactSelected(contact)
    }

    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
      // Handle cancellation if needed
    }
  }
}

#Preview {
  ContactPickerView { contact in
    print("Selected contact: \(contact.givenName) \(contact.familyName)")
  }
}
