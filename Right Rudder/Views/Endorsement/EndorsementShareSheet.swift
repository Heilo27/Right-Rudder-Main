//
//  EndorsementShareSheet.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

// MARK: - EndorsementShareSheet

struct EndorsementShareSheet: UIViewControllerRepresentable {
  // MARK: - Properties

  let activityItems: [Any]

  // MARK: - UIViewControllerRepresentable

  func makeUIViewController(context: Context) -> UIActivityViewController {
    UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
  }

  func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

