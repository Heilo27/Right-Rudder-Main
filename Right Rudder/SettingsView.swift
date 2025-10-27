import SwiftUI
import SwiftData
import CloudKit

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var cloudKitBackupService = CloudKitBackupService()
    @State private var showingDeleteConfirmation = false
    @State private var showingRestoreConfirmation = false
    @State private var cloudKitAvailable = false
    @State private var isCheckingCloudKit = false
    @State private var showingInstructorInfo = false
    @State private var showingShareTemplates = false
    @State private var showingReceiveTemplates = false
    @State private var showingWhatsNew = false
    @AppStorage("selectedColorScheme") private var selectedColorScheme = AppColorScheme.skyBlue.rawValue
    @AppStorage("showProgressBars") private var showProgressBars = true
    @AppStorage("showStudentPhotos") private var showStudentPhotos = false
    
    var body: some View {
        NavigationView {
            List {
                // User Information Section
                Section("User Information") {
                    Button(action: {
                        showingInstructorInfo = true
                    }) {
                        HStack {
                            Image(systemName: "person.text.rectangle")
                                .foregroundColor(.blue)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Instructor Information")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Set your name and CFI number for new students")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        showingShareTemplates = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up.on.square")
                                .foregroundColor(.blue)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Share Lesson Lists with Others")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Export custom templates to share with other users")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        showingReceiveTemplates = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down.on.square")
                                .foregroundColor(.green)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Receive Lesson Lists from Others")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Import lesson templates from other users or CSV files")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
                
                Section("iCloud Backup") {
                    if cloudKitAvailable {
                        HStack {
                            Image(systemName: "icloud")
                                .foregroundColor(.blue)
                            VStack(alignment: .leading) {
                                Text("Automatic Backup")
                                    .font(.headline)
                                Text("Your data is automatically backed up to iCloud")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                        
                        // Backup Status
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Backup Status:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Spacer()
                                Text(cloudKitBackupService.backupStatus)
                                    .font(.subheadline)
                                    .foregroundColor(cloudKitBackupService.isBackingUp ? .orange : .green)
                            }
                            
                            if let lastBackup = cloudKitBackupService.lastBackupDate {
                                HStack {
                                    Text("Last Backup:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(formatDate(lastBackup))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                        
                        // Manual Backup Button
                        Button(action: {
                            Task {
                                await cloudKitBackupService.performBackup()
                            }
                        }) {
                            HStack {
                                if cloudKitBackupService.isBackingUp {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "icloud.and.arrow.up")
                                }
                                Text(cloudKitBackupService.isBackingUp ? "Backing up..." : "Backup Now")
                            }
                        }
                        .disabled(cloudKitBackupService.isBackingUp)
                        
                        // Restore Status
                        if cloudKitBackupService.isRestoring || cloudKitBackupService.restoreStatus != "Ready" {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Restore Status:")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text(cloudKitBackupService.restoreStatus)
                                        .font(.subheadline)
                                        .foregroundColor(cloudKitBackupService.isRestoring ? .orange : .green)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        
                        // Restore from Backup Button
                        Button(action: {
                            showingRestoreConfirmation = true
                        }) {
                            HStack {
                                if cloudKitBackupService.isRestoring {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "icloud.and.arrow.down")
                                }
                                Text(cloudKitBackupService.isRestoring ? "Restoring..." : "Restore from Backup")
                            }
                        }
                        .disabled(cloudKitBackupService.isRestoring || cloudKitBackupService.isBackingUp)
                        
                        Button("Delete iCloud Backup") {
                            showingDeleteConfirmation = true
                        }
                        .foregroundColor(.red)
                    } else {
                        HStack {
                            Image(systemName: "icloud.slash")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading) {
                                Text("CloudKit Not Available")
                                    .font(.headline)
                                Text("CloudKit entitlements need to be configured in Xcode")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                        
                        Button("Check CloudKit Status") {
                            checkCloudKitStatus()
                        }
                        .disabled(isCheckingCloudKit)
                    }
                }
                
                Section("Color Scheme") {
                    ForEach(AppColorScheme.allCases) { scheme in
                        Button(action: {
                            selectedColorScheme = scheme.rawValue
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(scheme.rawValue)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(scheme.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                // Color preview
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(scheme.previewGradient)
                                    .frame(width: 60, height: 40)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                
                                // Checkmark for selected scheme
                                if selectedColorScheme == scheme.rawValue {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(scheme.primaryColor)
                                        .font(.title3)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Section("UI Settings") {
                    Toggle(isOn: $showProgressBars) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.blue)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Show Progress Bars")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Display progress bars next to student names")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    
                    Toggle(isOn: $showStudentPhotos) {
                        HStack {
                            Image(systemName: "photo.circle.fill")
                                .foregroundColor(.green)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Show Student Photos")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Display profile photos in the students list")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text(buildNumber)
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        showingWhatsNew = true
                    }) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.blue)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("What's New")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("View recent updates and new features")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
                
                Section("Contact Us") {
                    Button(action: {
                        openEmail()
                    }) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.blue)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Contact Us")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("RightRudderApp@icloud.com")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Settings")
            .alert("Delete iCloud Backup", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        await cloudKitBackupService.deleteBackup()
                    }
                }
            } message: {
                Text("This will permanently delete your iCloud backup. Your local data will not be affected.")
            }
            .alert("Restore from Backup", isPresented: $showingRestoreConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Restore", role: .destructive) {
                    Task {
                        await cloudKitBackupService.restoreFromBackup()
                    }
                }
            } message: {
                Text("This will search your iCloud account for a backup and restore any data that doesn't already exist locally. Existing data will not be affected.")
            }
            .sheet(isPresented: $showingInstructorInfo) {
                InstructorInfoView()
            }
            .sheet(isPresented: $showingShareTemplates) {
                ShareTemplatesView()
            }
            .sheet(isPresented: $showingReceiveTemplates) {
                ReceiveTemplatesView()
            }
            .sheet(isPresented: $showingWhatsNew) {
                WhatsNewView()
            }
            .onAppear {
                cloudKitBackupService.setModelContext(modelContext)
                checkCloudKitStatus()
            }
        }
    }
    
    private func checkCloudKitStatus() {
        isCheckingCloudKit = true
        
        Task {
            do {
                let container = CKContainer(identifier: "iCloud.com.heiloprojects.rightrudder")
                let accountStatus = try await container.accountStatus()
                
                await MainActor.run {
                    cloudKitAvailable = (accountStatus == .available)
                    isCheckingCloudKit = false
                }
            } catch {
                await MainActor.run {
                    cloudKitAvailable = false
                    isCheckingCloudKit = false
                    print("CloudKit status check failed: \(error)")
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, yyyy 'at' HHmm" // Military time (24-hour format without colon)
        return formatter.string(from: date)
    }
    
    // Get app version from Info.plist
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    // Get build number from Info.plist
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    // Open default email app with contact email
    private func openEmail() {
        let email = "RightRudderApp@icloud.com"
        let subject = "Right Rudder App Support"
        let body = "Hello,\n\nI need help with the Right Rudder app.\n\n"
        
        if let url = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                // Fallback: copy email to clipboard
                UIPasteboard.general.string = email
                print("Email app not available. Email address copied to clipboard: \(email)")
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [Student.self, StudentChecklist.self, StudentChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}
