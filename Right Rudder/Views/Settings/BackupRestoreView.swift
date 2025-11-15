import SwiftData
import SwiftUI

// MARK: - BackupRestoreView

struct BackupRestoreView: View {
  // MARK: - Properties

  @ObservedObject var backupService: CloudKitBackupService
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @State private var selectedBackup: BackupSnapshot?
  @State private var showingRestoreConfirmation = false
  @State private var isLoading = true

  // MARK: - Body

  var body: some View {
    NavigationView {
      List {
        Section {
          if isLoading {
            HStack {
              ProgressView()
              Text("Loading backups...")
                .foregroundColor(.secondary)
            }
          } else if backupService.availableBackups.isEmpty {
            VStack(spacing: 12) {
              Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
              Text("No Backups Available")
                .font(.headline)
              Text("Backups will appear here once created")
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
          } else {
            ForEach(backupService.availableBackups) { backup in
              BackupRow(backup: backup, isSelected: selectedBackup?.id == backup.id)
                .contentShape(Rectangle())
                .onTapGesture {
                  selectedBackup = backup
                }
            }
          }
        } header: {
          Text("Available Backups (Last 14 Days)")
        } footer: {
          Text("Select a backup to restore from. Only one backup is created per day.")
        }
      }
      .navigationTitle("Restore from Backup")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Restore") {
            if selectedBackup != nil {
              showingRestoreConfirmation = true
            }
          }
          .disabled(selectedBackup == nil || backupService.isRestoring || isLoading)
        }
      }
      .confirmationDialog(
        "Restore Backup",
        isPresented: $showingRestoreConfirmation,
        presenting: selectedBackup
      ) { backup in
        Button("Restore", role: .destructive) {
          Task {
            await backupService.restoreFromBackup(snapshotDate: backup.id)
            dismiss()
          }
        }
        Button("Cancel", role: .cancel) {}
      } message: { backup in
        Text(
          "This will restore data from \(backup.date, style: .date). This action cannot be undone.")
      }
      .task {
        isLoading = true
        await backupService.loadAvailableBackups()
        isLoading = false
      }
      .onChange(of: backupService.isRestoring) { _, isRestoring in
        if !isRestoring {
          // Restore completed, dismiss view
          dismiss()
        }
      }
    }
  }
}

#Preview {
  let backupService = CloudKitBackupService()
  return BackupRestoreView(backupService: backupService)
    .modelContainer(for: [Student.self, ChecklistTemplate.self], inMemory: true)
}
