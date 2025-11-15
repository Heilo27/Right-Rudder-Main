import Combine
import SwiftData
import SwiftUI

// MARK: - OfflineSyncStatusView

/// View that displays offline sync status and pending operations
struct OfflineSyncStatusView: View {
  // MARK: - Properties

  @Environment(\.modelContext) private var modelContext
  @StateObject private var offlineSyncManager = OfflineSyncManager()
  @State private var showingPendingOperations = false

  // MARK: - Body

  var body: some View {
    VStack(spacing: 12) {
      HStack {
        Image(systemName: offlineSyncManager.isOfflineMode ? "wifi.slash" : "wifi")
          .foregroundColor(offlineSyncManager.isOfflineMode ? .red : .green)

        Text(offlineSyncManager.isOfflineMode ? "Offline Mode" : "Online")
          .font(.headline)
          .foregroundColor(offlineSyncManager.isOfflineMode ? .red : .green)

        Spacer()

        if offlineSyncManager.pendingOperationsCount > 0 {
          Button(action: {
            showingPendingOperations = true
          }) {
            HStack(spacing: 4) {
              Image(systemName: "clock")
              Text("\(offlineSyncManager.pendingOperationsCount)")
            }
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(8)
          }
        }
      }

      if offlineSyncManager.pendingOperationsCount > 0 {
        VStack(alignment: .leading, spacing: 4) {
          Text("Pending Sync Operations")
            .font(.subheadline)
            .fontWeight(.medium)

          Text(
            "\(offlineSyncManager.pendingOperationsCount) operations will sync when connectivity is restored"
          )
          .font(.caption)
          .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
      }

      if let lastSync = offlineSyncManager.lastSyncAttempt {
        HStack {
          Image(systemName: "clock")
            .foregroundColor(.secondary)

          Text("Last sync attempt: \(lastSync, formatter: dateFormatter)")
            .font(.caption)
            .foregroundColor(.secondary)

          Spacer()
        }
      }
    }
    .padding()
    .background(Color.appAdaptiveMutedBox)
    .cornerRadius(12)
    .onAppear {
      offlineSyncManager.setModelContext(modelContext)
    }
    .sheet(isPresented: $showingPendingOperations) {
      PendingOperationsView(offlineSyncManager: offlineSyncManager)
    }
  }

  private var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
  }
}

#Preview {
  OfflineSyncStatusView()
    .modelContainer(for: [OfflineSyncOperation.self], inMemory: true)
}
