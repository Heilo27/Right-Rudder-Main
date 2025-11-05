import SwiftUI
import SwiftData
import Combine

/// View that displays offline sync status and pending operations
struct OfflineSyncStatusView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var offlineSyncManager = OfflineSyncManager()
    @State private var showingPendingOperations = false
    
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
                    
                    Text("\(offlineSyncManager.pendingOperationsCount) operations will sync when connectivity is restored")
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

/// View that shows detailed pending operations
struct PendingOperationsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var offlineSyncManager: OfflineSyncManager
    @State private var pendingOperations: [OfflineSyncOperation] = []
    
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

#Preview {
    OfflineSyncStatusView()
        .modelContainer(for: [OfflineSyncOperation.self], inMemory: true)
}
