//
//  ActivityShareSheet.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

// MARK: - ActivityShareSheet

// ActivityShareSheet for presenting UIActivityViewController
struct ActivityShareSheet: UIViewControllerRepresentable {
  // MARK: - Properties

  let items: [Any]
  let instructorName: String

  // MARK: - UIViewControllerRepresentable

  func makeUIViewController(context: Context) -> UIActivityViewController {
    // Create the custom sharing message
    let shareMessage = createShareMessage(
      instructorName: instructorName, shareURL: items.first as? URL)

    let controller = UIActivityViewController(
      activityItems: [shareMessage], applicationActivities: nil)

    // Optimize for better performance
    controller.excludedActivityTypes = [
      .assignToContact,
      .addToReadingList,
      .openInIBooks,
      .markupAsPDF,
    ]

    return controller
  }

  func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}

  // MARK: - Private Helpers

  private func createShareMessage(instructorName: String, shareURL: URL?) -> String {
    let appStoreLink = "https://apps.apple.com/us/app/right-rudder-student/id6753929067"

    return """
      You have been invited to link apps with \(instructorName).

      Step 1. Download the Right Rudder - Student app: \(appStoreLink)

      Step 2. Copy URL, and Paste in app: \(shareURL?.absoluteString ?? "")

      Step 3. Fill out your information, and upload any required documents.
      """
  }
}

