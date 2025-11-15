//
//  TemplateShareSheet.swift
//  Right Rudder
//
//  Created by AI on 10/6/25.
//

import SwiftUI

// MARK: - TemplateShareSheet

struct TemplateShareSheet: UIViewControllerRepresentable {
  // MARK: - Properties

  let items: [Any]
  let onComplete: (Bool) -> Void

  // MARK: - UIViewControllerRepresentable

  func makeUIViewController(context: Context) -> UIActivityViewController {
    let controller = UIActivityViewController(
      activityItems: items,
      applicationActivities: nil
    )

    // Prioritize email, messages, and AirDrop
    controller.excludedActivityTypes = [
      .addToReadingList,
      .assignToContact,
      .openInIBooks,
      .markupAsPDF,
      .saveToCameraRoll,
    ]

    // Set completion handler
    controller.completionWithItemsHandler = { activityType, completed, returnedItems, error in
      if completed {
        print("Share completed successfully")
        onComplete(true)
      } else if let error = error {
        print("Share error: \(error.localizedDescription)")
      }
    }

    return controller
  }

  func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

