//
//  PendingOperationsView.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Combine
import SwiftData
import SwiftUI

// MARK: - PendingOperationsView

/// View that shows detailed pending operations
struct PendingOperationsView: View {
  // MARK: - Properties

  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  @ObservedObject var offlineSyncManager: OfflineSyncManager
  @State private var pendingOperations: [OfflineSyncOperation] = []

  // MARK: - Body

  var body: some View {
    NavigationView {
      List {
        ForEach(pendingOperations, id: \.id) { operation in
          VStack(alignment: .leading, spacing: 8) {
            HStack {
              Text(operationTypeDisplayName(operation.operationType))
                .font(.headline)

              Spacer()

              Text("Retry \(operation.retryCount)/\(operation.maxRetries)")
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Text("Student ID: \(operation.studentId.uuidString.prefix(8))...")
              .font(.caption)
              .foregroundColor(.secondary)

            if let checklistId = operation.checklistId {
              Text("Checklist ID: \(checklistId.uuidString.prefix(8))...")
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Text("Created: \(operation.createdAt, formatter: dateFormatter)")
              .font(.caption)
              .foregroundColor(.secondary)

            if let lastAttempt = operation.lastAttemptedAt {
              Text("Last attempt: \(lastAttempt, formatter: dateFormatter)")
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }
          .padding(.vertical, 4)
        }
      }
      .navigationTitle("Pending Operations")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Done") {
            dismiss()
          }
        }

        ToolbarItem(placement: .navigationBarLeading) {
          Button("Retry All") {
            Task {
              await offlineSyncManager.processPendingOperations()
              loadPendingOperations()
            }
          }
          .disabled(offlineSyncManager.isOfflineMode)
        }
      }
    }
    .onAppear {
      loadPendingOperations()
    }
  }

  // MARK: - Private Helpers

  private func loadPendingOperations() {
    let request = FetchDescriptor<OfflineSyncOperation>(
      predicate: #Predicate<OfflineSyncOperation> { operation in
        !operation.isCompleted
      }
    )

    do {
      pendingOperations = try modelContext.fetch(request)
    } catch {
      print("Failed to load pending operations: \(error)")
    }
  }

  private func operationTypeDisplayName(_ type: String) -> String {
    switch type {
    case "checklist_update":
      return "Checklist Update"
    case "checklist_add":
      return "Add Checklist"
    case "comment_add":
      return "Add Comment"
    case "completion_change":
      return "Completion Change"
    default:
      return type.capitalized
    }
  }

  private var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
  }
}

