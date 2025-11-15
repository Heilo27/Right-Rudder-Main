import CloudKit
import SwiftData
import SwiftUI

struct SettingsView: View {
  @Environment(\.modelContext) private var modelContext
  @StateObject private var cloudKitBackupService = CloudKitBackupService()
  @StateObject private var emergencyRecovery = EmergencyDataRecovery.shared
  @StateObject private var oldDatabaseEmulator = OldDatabaseEmulator.shared
  @State private var showingDeleteConfirmation = false
  @State private var showingEmergencyRecoveryConfirmation = false
  @State private var cloudKitAvailable = false
  @State private var isCheckingCloudKit = false
  @State private var showingInstructorInfo = false
  @State private var showingShareTemplates = false
  @State private var showingReceiveTemplates = false
  @State private var showingWhatsNew = false
  @State private var showingSnakeGame = false
  @State private var dragOffset: CGFloat = 0
  @State private var isDragging = false
  @State private var swipeOffset: CGFloat = 0
  @AppStorage("selectedColorScheme") private var selectedColorScheme = AppColorScheme.skyBlue
    .rawValue
  @AppStorage("showProgressBars") private var showProgressBars = true
  @AppStorage("showStudentPhotos") private var showStudentPhotos = false
  @State private var showingBackupRestore = false

  var body: some View {
    NavigationView {
      settingsListContent
    }
    .onAppear {
      cloudKitBackupService.setModelContext(modelContext)
      checkCloudKitStatus()
    }
    .clipShape(
      MorphingBottomShape(
        dragOffset: dragOffset,
        isDragging: isDragging
      )
    )
    .overlay(swipeInstructionOverlay)
  }

  @ViewBuilder
  private var swipeInstructionOverlay: some View {
    Group {
      if isDragging && swipeOffset < -50 {
        VStack {
          Spacer()
          HStack {
            Spacer()
            VStack(spacing: 8) {
              Image(systemName: "arrow.left")
                .font(.title2)
                .foregroundColor(.blue)

              Text("Swipe left to open Snake Game")
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
            }
            .padding(.trailing, 20)
          }
          .padding(.bottom, 100)
        }
      }
    }
  }

  @ViewBuilder
  private var settingsListContent: some View {
    settingsListWithAlerts
      .sheet(isPresented: $showingInstructorInfo) {
        InstructorInfoView()
          .presentationDetents([.medium, .large])
          .presentationDragIndicator(.visible)
      }
      .sheet(isPresented: $showingShareTemplates) {
        ShareTemplatesView()
          .presentationDetents([.medium, .large])
          .presentationDragIndicator(.visible)
      }
      .sheet(isPresented: $showingReceiveTemplates) {
        ReceiveTemplatesView()
          .presentationDetents([.medium, .large])
          .presentationDragIndicator(.visible)
      }
      .sheet(isPresented: $showingWhatsNew) {
        WhatsNewView()
          .presentationDetents([.large])
          .presentationDragIndicator(.visible)
      }
      .fullScreenCover(isPresented: $showingSnakeGame) {
        NavigationView {
          AviationSnakeGameView()
        }
      }
      .onAppear {
        cloudKitBackupService.setModelContext(modelContext)
        emergencyRecovery.setModelContext(modelContext)
        oldDatabaseEmulator.setModelContext(modelContext)
        checkCloudKitStatus()
      }
  }

  @ViewBuilder
  private var settingsListWithAlerts: some View {
    settingsListWithBasicModifiers
      .alert("Delete iCloud Backup", isPresented: $showingDeleteConfirmation) {
        Button("Cancel", role: .cancel) {}
        Button("Delete", role: .destructive) {
          Task {
            await cloudKitBackupService.deleteBackup()
          }
        }
      } message: {
        Text(
          "This will permanently delete your iCloud backup. Your local data will not be affected.")
      }
      .alert("Emergency Data Recovery", isPresented: $showingEmergencyRecoveryConfirmation) {
        Button("Cancel", role: .cancel) {}
        Button("Recover Now", role: .destructive) {
          emergencyRecovery.setModelContext(modelContext)
          Task {
            await emergencyRecovery.emergencyRecovery()
          }
        }
      } message: {
        Text(
          "This will directly access CloudKit and restore ALL available student data from any backup format. This bypasses schema checks and searches all possible record types. Your existing data will not be deleted."
        )
      }
  }

  @ViewBuilder
  private var settingsListWithBasicModifiers: some View {
    settingsList
      .navigationTitle("Settings")
      .offset(y: dragOffset)
      .overlay(swipeGestureOverlay)
  }

  @ViewBuilder
  private var settingsList: some View {
    List {
      userInformationSection
      iCloudBackupSection
      // databaseRecoverySection
      colorSchemeSection
      uiSettingsSection
      aboutSection
      contactUsSection
    }
  }

  @ViewBuilder
  private var swipeGestureOverlay: some View {
    GeometryReader { geometry in
      HStack {
        Spacer()
        Rectangle()
          .fill(Color.clear)
          .frame(width: 60, height: geometry.size.height)
          .offset(x: swipeOffset)
          .contentShape(Rectangle())
          .gesture(
            DragGesture()
              .onChanged { value in
                print("🎮 Drag detected: \(value.translation)")
                if value.translation.width < 0 {
                  isDragging = true
                  swipeOffset = value.translation.width

                  if value.translation.width < -80 {
                    openSnakeGame()
                  }
                }
              }
              .onEnded { _ in
                print("🎮 Drag ended")
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                  swipeOffset = 0
                  isDragging = false
                }
              }
          )
      }
    }
  }

  @ViewBuilder
  private var iCloudBackupSection: some View {
    Section("iCloud Backup") {
      if cloudKitAvailable {
        iCloudBackupAvailableContent
      } else {
        iCloudBackupUnavailableContent
      }
    }
  }

  @ViewBuilder
  private var iCloudBackupAvailableContent: some View {
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
      showingBackupRestore = true
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
    .sheet(isPresented: $showingBackupRestore) {
      BackupRestoreView(backupService: cloudKitBackupService)
        .onAppear {
          cloudKitBackupService.setModelContext(modelContext)
        }
    }

    Button("Delete iCloud Backup") {
      showingDeleteConfirmation = true
    }
    .foregroundColor(.red)
  }

  @ViewBuilder
  private var iCloudBackupUnavailableContent: some View {
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

  @ViewBuilder
  private var userInformationSection: some View {
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
  }

  @ViewBuilder
  private var databaseRecoverySection: some View {
    Section("Database Recovery") {
      Button(action: {
        DatabaseRecoveryService.shared.presentRecoveryAlert()
      }) {
        HStack {
          Image(systemName: "externaldrive.badge.exclamationmark")
            .foregroundColor(.orange)
            .font(.title3)
          VStack(alignment: .leading, spacing: 4) {
            Text("Recover Database")
              .font(.headline)
              .foregroundColor(.primary)
            Text("Fix database corruption and restore from CloudKit")
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
        showingEmergencyRecoveryConfirmation = true
      }) {
        HStack {
          Image(systemName: "exclamationmark.triangle.fill")
            .foregroundColor(.red)
            .font(.title3)
          VStack(alignment: .leading, spacing: 4) {
            Text("Emergency Data Recovery")
              .font(.headline)
              .foregroundColor(.primary)
            Text("Directly access CloudKit and restore all available student data")
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
        emergencyRecovery.setModelContext(modelContext)
        Task {
          await emergencyRecovery.fixCorruptedStudents()
        }
      }) {
        HStack {
          Image(systemName: "wrench.and.screwdriver")
            .foregroundColor(.orange)
            .font(.title3)
          VStack(alignment: .leading, spacing: 4) {
            Text("Fix Corrupted Students")
              .font(.headline)
              .foregroundColor(.primary)
            Text("Fix duplicate IDs and empty names in existing students")
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
      .disabled(emergencyRecovery.isRecovering)

      Button(action: {
        oldDatabaseEmulator.setModelContext(modelContext)
        Task {
          await oldDatabaseEmulator.migrateOldDatabaseToNewSchema()
        }
      }) {
        HStack {
          Image(systemName: "arrow.triangle.2.circlepath")
            .foregroundColor(.blue)
            .font(.title3)
          VStack(alignment: .leading, spacing: 4) {
            Text("Migrate Old Database")
              .font(.headline)
              .foregroundColor(.primary)
            Text("Read old database format and convert to new schema")
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
      .disabled(oldDatabaseEmulator.isMigrating)

      Button(action: {
        emergencyRecovery.setModelContext(modelContext)
        Task {
          await emergencyRecovery.removeTemporaryNamedStudents()
        }
      }) {
        HStack {
          Image(systemName: "trash")
            .foregroundColor(.red)
            .font(.title3)
          VStack(alignment: .leading, spacing: 4) {
            Text("Remove Temporary Students")
              .font(.headline)
              .foregroundColor(.primary)
            Text("Delete students with temporary names (Student + ID)")
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
      .disabled(emergencyRecovery.isRecovering)

      Button(action: {
        DefaultDataService.forceUpdateTemplates(modelContext: modelContext)
      }) {
        HStack {
          Image(systemName: "arrow.clockwise")
            .foregroundColor(.blue)
            .font(.title3)
          VStack(alignment: .leading, spacing: 4) {
            Text("Reinitialize Templates")
              .font(.headline)
              .foregroundColor(.primary)
            Text("Reload all checklist templates with central library IDs")
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

      if oldDatabaseEmulator.isMigrating {
        VStack(alignment: .leading, spacing: 8) {
          HStack {
            ProgressView()
              .scaleEffect(0.8)
            Text("Migration in progress...")
              .font(.subheadline)
              .foregroundColor(.orange)
          }

          Text(oldDatabaseEmulator.migrationProgress)
            .font(.caption)
            .foregroundColor(.secondary)

          if oldDatabaseEmulator.studentsMigrated > 0 {
            Text("Migrated: \(oldDatabaseEmulator.studentsMigrated) students")
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
        .padding(.vertical, 4)
      }

      if DatabaseRecoveryService.shared.isRecovering {
        HStack {
          ProgressView()
            .scaleEffect(0.8)
          Text("Recovery in progress...")
            .font(.subheadline)
            .foregroundColor(.orange)
        }
        .padding(.vertical, 4)
      }

      if emergencyRecovery.isRecovering {
        VStack(alignment: .leading, spacing: 8) {
          HStack {
            ProgressView()
              .scaleEffect(0.8)
            Text("Emergency Recovery in progress...")
              .font(.subheadline)
              .foregroundColor(.orange)
          }

          Text(emergencyRecovery.recoveryProgress)
            .font(.caption)
            .foregroundColor(.secondary)

          if emergencyRecovery.studentsFound > 0 {
            HStack {
              Text("Found: \(emergencyRecovery.studentsFound)")
                .font(.caption)
              Text("Restored: \(emergencyRecovery.studentsRestored)")
                .font(.caption)
            }
            .foregroundColor(.secondary)
          }
        }
        .padding(.vertical, 4)
      }
    }
  }

  @ViewBuilder
  private var colorSchemeSection: some View {
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
  }

  @ViewBuilder
  private var uiSettingsSection: some View {
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
  }

  @ViewBuilder
  private var aboutSection: some View {
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
  }

  @ViewBuilder
  private var contactUsSection: some View {
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
    formatter.dateFormat = "MMM d, yyyy 'at' HHmm"  // Military time (24-hour format without colon)
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

    if let url = URL(
      string:
        "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
    ) {
      if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
      } else {
        // Fallback: copy email to clipboard
        UIPasteboard.general.string = email
        print("Email app not available. Email address copied to clipboard: \(email)")
      }
    }
  }

  // Handle swipe-left gesture to open snake game
  private func openSnakeGame() {
    print("🎮 Swipe-left gesture detected! Opening Snake Game! 🐍✈️")
    showingSnakeGame = true
    isDragging = false
    swipeOffset = 0
  }
}

// MARK: - Morphing Shape

struct MorphingBottomShape: Shape {
  let dragOffset: CGFloat
  let isDragging: Bool

  func path(in rect: CGRect) -> Path {
    var path = Path()

    // Start from top-left
    path.move(to: CGPoint(x: 0, y: 0))

    // Top edge
    path.addLine(to: CGPoint(x: rect.width, y: 0))

    // Right edge
    path.addLine(to: CGPoint(x: rect.width, y: rect.height))

    // Bottom edge with morphing effect
    if isDragging && dragOffset < 0 {
      let morphAmount = min(abs(dragOffset) / 100.0, 1.0)  // 0 to 1
      let curveHeight = morphAmount * 50  // Max 50 points of curve
      let stretchAmount = morphAmount * 30  // Max 30 points of stretch
      let waveAmplitude = morphAmount * 15  // Wave effect

      // Create a wavy, curved bottom edge
      let startPoint = CGPoint(x: 0, y: rect.height)
      let endPoint = CGPoint(x: rect.width, y: rect.height + stretchAmount)

      // Add multiple curves for a more organic wave effect
      let controlPoint1 = CGPoint(
        x: rect.width * 0.2,
        y: rect.height + curveHeight + waveAmplitude
      )
      let controlPoint2 = CGPoint(
        x: rect.width * 0.4,
        y: rect.height + curveHeight - waveAmplitude
      )
      let controlPoint3 = CGPoint(
        x: rect.width * 0.6,
        y: rect.height + curveHeight + waveAmplitude
      )
      let controlPoint4 = CGPoint(
        x: rect.width * 0.8,
        y: rect.height + curveHeight - waveAmplitude
      )

      path.addLine(to: startPoint)
      path.addCurve(
        to: CGPoint(x: rect.width * 0.5, y: rect.height + curveHeight),
        control1: controlPoint1,
        control2: controlPoint2
      )
      path.addCurve(
        to: endPoint,
        control1: controlPoint3,
        control2: controlPoint4
      )
    } else {
      // Normal straight bottom edge
      path.addLine(to: CGPoint(x: rect.width, y: rect.height))
    }

    // Left edge
    path.addLine(to: CGPoint(x: 0, y: rect.height))

    // Close the path
    path.closeSubpath()

    return path
  }
}

#Preview {
  SettingsView()
    .modelContainer(
      for: [
        Student.self, ChecklistAssignment.self, ItemProgress.self, CustomChecklistDefinition.self,
        CustomChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self,
      ], inMemory: true)
}
