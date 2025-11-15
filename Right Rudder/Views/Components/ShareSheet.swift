//
//  ShareSheet.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

// MARK: - ShareSheet

struct ShareSheet: UIViewControllerRepresentable {
  // MARK: - Properties

  let htmlContent: String
  let studentName: String

  // MARK: - UIViewControllerRepresentable

  func makeUIViewController(context: Context) -> UIActivityViewController {
    // Share HTML content directly as string for maximum speed
    let activityViewController = UIActivityViewController(
      activityItems: [htmlContent],
      applicationActivities: nil
    )

    // Set the subject for email sharing
    activityViewController.setValue("Student Pilot Record - \(studentName)", forKey: "subject")

    return activityViewController
  }

  func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    // No updates needed
  }
}

