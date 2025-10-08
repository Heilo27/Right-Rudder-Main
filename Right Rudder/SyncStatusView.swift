import SwiftUI
import SwiftData

struct SyncStatusView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var syncService = CloudKitSyncService()
    @State private var showingSyncOptions = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "icloud")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text("iCloud Sync")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Keep your student data safe and synced across all your devices")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Sync Status
            VStack(spacing: 12) {
                HStack {
                    if syncService.isSyncing {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    
                    Text(syncService.syncStatus)
                        .font(.subheadline)
                        .foregroundColor(syncService.isSyncing ? .primary : .secondary)
                    
                    Spacer()
                }
                
                if let lastSync = syncService.lastSyncDate {
                    Text("Last synced: \(lastSync, style: .relative)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.appMutedBox)
            .cornerRadius(12)
            
            // Action Buttons
            VStack(spacing: 12) {
                Button(action: {
                    Task {
                        await syncService.syncToCloudKit()
                    }
                }) {
                    HStack {
                        Image(systemName: "icloud.and.arrow.up")
                        Text("Sync to iCloud")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(syncService.isSyncing)
                
                Button(action: {
                    Task {
                        await syncService.restoreFromCloudKit()
                    }
                }) {
                    HStack {
                        Image(systemName: "icloud.and.arrow.down")
                        Text("Restore from iCloud")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(syncService.isSyncing)
            }
            
            // Info Section
            VStack(alignment: .leading, spacing: 8) {
                Text("About iCloud Sync")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text("Automatic backup of all student profiles")
                            .font(.caption)
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text("Sync across all your devices")
                            .font(.caption)
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text("Restore data if app is reinstalled")
                            .font(.caption)
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text("Secure and private to your iCloud account")
                            .font(.caption)
                    }
                }
            }
            .padding()
            .background(Color.appMutedBox)
            .cornerRadius(12)
            
            Spacer()
        }
        .padding()
        .navigationTitle("iCloud Sync")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            syncService.setModelContext(modelContext)
        }
    }
}

#Preview {
    NavigationView {
        SyncStatusView()
    }
    .modelContainer(for: [Student.self, StudentChecklist.self, StudentChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}
