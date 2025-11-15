//
//  DocumentTypeCard.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftData
import SwiftUI

// MARK: - DocumentTypeCard

struct DocumentTypeCard: View {
  // MARK: - Properties

  let documentType: DocumentType
  let document: StudentDocument?
  let onAddDocument: () -> Void
  let onUploadPhoto: () -> Void
  let onTakePhoto: () -> Void
  let onViewDocument: (StudentDocument) -> Void
  let onDeleteDocument: (StudentDocument) -> Void

  // MARK: - Body

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Image(systemName: documentType.icon)
          .font(.title2)
          .foregroundColor(.blue)
          .frame(width: 40)

        VStack(alignment: .leading, spacing: 4) {
          HStack {
            Text(documentType.rawValue)
              .font(.headline)

            if documentType.isOptional {
              Text("(Optional)")
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }

          if let doc = document {
            HStack {
              Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
              Text("Uploaded")
                .font(.caption)
                .foregroundColor(.secondary)

              if let expirationDate = doc.expirationDate {
                Text("• Expires: \(expirationDate.formatted(date: .abbreviated, time: .omitted))")
                  .font(.caption)
                  .foregroundColor(isExpiringSoon(expirationDate) ? .red : .secondary)
              }
            }
          } else {
            HStack {
              Image(systemName: "exclamationmark.circle")
                .foregroundColor(documentType.isOptional ? .secondary : .orange)
              Text("Not uploaded")
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }
        }

        Spacer()

        if let doc = document {
          Menu {
            Button {
              onViewDocument(doc)
            } label: {
              Label("View", systemImage: "eye")
            }

            Button(role: .destructive) {
              onDeleteDocument(doc)
            } label: {
              Label("Delete", systemImage: "trash")
            }
          } label: {
            Image(systemName: "ellipsis.circle")
              .font(.title3)
          }
        } else {
          Menu {
            Button {
              onAddDocument()
            } label: {
              Label("Upload from Files", systemImage: "folder")
            }

            Button {
              onUploadPhoto()
            } label: {
              Label("Upload Photo", systemImage: "photo.on.rectangle")
            }

            Button {
              onTakePhoto()
            } label: {
              Label("Take Photo", systemImage: "camera")
            }
          } label: {
            Image(systemName: "plus.circle.fill")
              .font(.title3)
          }
        }
      }
    }
    .padding()
    .background(Color.appAdaptiveMutedBox)
    .cornerRadius(12)
  }

  // MARK: - Private Helpers

  private func isExpiringSoon(_ date: Date) -> Bool {
    let daysUntilExpiration =
      Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
    return daysUntilExpiration <= 30
  }
}

