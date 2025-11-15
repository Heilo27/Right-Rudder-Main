//
//  CSVShareSheet.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import SwiftUI

// MARK: - CSVShareSheet

struct CSVShareSheet: UIViewControllerRepresentable {
  // MARK: - Properties

  let items: [Any]

  // MARK: - UIViewControllerRepresentable

  func makeUIViewController(context: Context) -> UIActivityViewController {
    UIActivityViewController(activityItems: items, applicationActivities: nil)
  }

  func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

