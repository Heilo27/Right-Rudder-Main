import SwiftUI
import SwiftData
import CloudKit

struct StudentShareView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let student: Student
    @StateObject private var shareService = CloudKitShareService()
    
    @State private var shareURL: URL?
    @State private var isGeneratingShare = false
    @State private var showShareSheet = false
    @State private var hasActiveShare = false
    @State private var participants: [CKShare.Participant] = []
    @State private var errorMessage: String?
    @State private var showingSuccessSplash = false
    @State private var monitoringForAcceptance = false
    
    @AppStorage("instructorName") private var instructorName: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Share Student Profile")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(student.displayName)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    // Information section
                    VStack(alignment: .leading, spacing: 16) {
                        InfoRow(icon: "info.circle", 
                               title: "What gets shared?",
                               description: "The student will have read-only access to their profile, checklists, and can upload required documents.")
                        
                        InfoRow(icon: "lock.shield", 
                               title: "Privacy & Security",
                               description: "Only this specific student can access their profile. They cannot see other students' information.")
                        
                        InfoRow(icon: "bell.badge", 
                               title: "Notifications",
                               description: "Students receive push notifications when you add instructor comments to their checklists.")
                    }
                    .padding()
                    .background(Color.appMutedBox)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Share status
                    if hasActiveShare {
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Student profile is shared")
                                    .fontWeight(.medium)
                            }
                            
                            if !participants.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Shared with:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    ForEach(participants.filter { $0.role != .owner }, id: \.userIdentity) { participant in
                                        HStack {
                                            Image(systemName: "person.circle.fill")
                                                .foregroundColor(.blue)
                                            VStack(alignment: .leading) {
                                                if let name = participant.userIdentity.nameComponents {
                                                    Text(name.formatted(.name(style: .long)))
                                                        .font(.subheadline)
                                                }
                                                Text(participantStatus(participant))
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.appMutedBox)
                                .cornerRadius(8)
                            }
                            
                            Button("Resend Invite") {
                                showShareSheet = true
                            }
                            .buttonStyle(.rounded)
                            
                            Button("Stop Sharing", role: .destructive) {
                                Task {
                                    await removeShare()
                                }
                            }
                            .buttonStyle(.rounded)
                        }
                        .padding()
                    } else {
                    Button(action: {
                        Task {
                            await createShare()
                        }
                    }) {
                        if isGeneratingShare {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                                Text("Creating Share...")
                                    .font(.system(size: 16, weight: .medium))
                            }
                        } else {
                            Label("Send Invite", systemImage: "paperplane.fill")
                        }
                    }
                    .buttonStyle(.rounded)
                    .disabled(isGeneratingShare)
                    .padding()
                }
                
                // Error message
                if let errorMessage = errorMessage {
                    VStack(spacing: 8) {
                        Text("⚠️ Error")
                            .font(.headline)
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                        Text("Check Console logs for details")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let shareURL = shareURL {
                    ActivityShareSheet(items: [shareURL], instructorName: instructorName.isEmpty ? "Your Instructor" : instructorName)
                }
            }
            .task {
                await checkShareStatus()
            }
            .overlay {
                if showingSuccessSplash {
                    SuccessSplashView()
                        .transition(.opacity.combined(with: .scale))
                }
            }
        }
    }
    
    private func checkShareStatus() async {
        hasActiveShare = await shareService.hasActiveShare(for: student)
        if hasActiveShare {
            let newParticipants = await shareService.fetchParticipants(for: student)
            
            // Check if student has accepted the share
            let hasStudentParticipant = newParticipants.contains { participant in
                participant.role != .owner && participant.acceptanceStatus == .accepted
            }
            
            // If we were monitoring and now have an accepted participant, show success
            if monitoringForAcceptance && hasStudentParticipant && participants.isEmpty {
                await MainActor.run {
                    showSuccessAndDismiss()
                }
            }
            
            participants = newParticipants
        }
    }
    
    private func showSuccessAndDismiss() {
        showingSuccessSplash = true
        
        // Show success splash for 2 seconds, then dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            dismiss()
        }
    }
    
    private func createShare() async {
        print("🎯 UI: Starting share creation for student: \(student.displayName)")
        isGeneratingShare = true
        errorMessage = nil
        
        print("🎯 UI: Calling shareService.createShareForStudent...")
        if let url = await shareService.createShareForStudent(student, modelContext: modelContext) {
            print("🎯 UI: Share creation returned URL: \(url)")
            shareURL = url
            hasActiveShare = true
            showShareSheet = true
            monitoringForAcceptance = true  // Start monitoring for student acceptance
            
            // Sync documents in background after share sheet is shown
            Task.detached { @MainActor in
                await shareService.syncStudentDocuments(student, modelContext: modelContext)
            }
            
            // Start periodic checking for acceptance
            startMonitoringForAcceptance()
        } else {
            print("🎯 UI: Share creation returned nil")
            print("🎯 UI: Error message: \(shareService.errorMessage ?? "No error message")")
            errorMessage = shareService.errorMessage ?? "Failed to create share"
        }
        
        isGeneratingShare = false
    }
    
    private func removeShare() async {
        let success = await shareService.removeShareForStudent(student, modelContext: modelContext)
        if success {
            hasActiveShare = false
            shareURL = nil
            participants = []
        } else {
            errorMessage = shareService.errorMessage ?? "Failed to remove share"
        }
    }
    
    private func participantStatus(_ participant: CKShare.Participant) -> String {
        switch participant.acceptanceStatus {
        case .accepted:
            return "Accepted"
        case .pending:
            return "Pending"
        case .removed:
            return "Removed"
        case .unknown:
            return "Unknown"
        @unknown default:
            return "Unknown"
        }
    }
    
    private func startMonitoringForAcceptance() {
        Task {
            // Check every 2 seconds for up to 5 minutes
            for _ in 0..<150 { // 150 * 2 seconds = 5 minutes
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                
                if monitoringForAcceptance {
                    await checkShareStatus()
                    
                    // Stop monitoring if we have an accepted participant
                    if !participants.isEmpty && participants.contains(where: { $0.role != .owner && $0.acceptanceStatus == .accepted }) {
                        monitoringForAcceptance = false
                        break
                    }
                } else {
                    break
                }
            }
            
            // Stop monitoring after timeout
            monitoringForAcceptance = false
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// ActivityShareSheet for presenting UIActivityViewController
struct ActivityShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    let instructorName: String
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        // Create the custom sharing message
        let shareMessage = createShareMessage(instructorName: instructorName, shareURL: items.first as? URL)
        
        let controller = UIActivityViewController(activityItems: [shareMessage], applicationActivities: nil)
        
        // Optimize for better performance
        controller.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList,
            .openInIBooks,
            .markupAsPDF
        ]
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    
    private func createShareMessage(instructorName: String, shareURL: URL?) -> String {
        let appStoreLink = "https://apps.apple.com/us/app/right-rudder-student/id6753929067"
        
        return """
        You have been invited to link apps with \(instructorName).
        
        Step 1. Download the Right Rudder - Student app: \(appStoreLink)
        
        Step 2. Click on link below to connect: \(shareURL?.absoluteString ?? "")
        
        Step 3. Fill out your information, and upload any required documents.
        """
    }
}

// Success Splash View
struct SuccessSplashView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                    .scaleEffect(scale)
                
                Text("Link Successful!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(opacity)
                
                Text("Student app is now connected")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(opacity)
            }
            .padding(40)
            .background(Color.black.opacity(0.8))
            .cornerRadius(20)
            .scaleEffect(scale)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

#Preview {
    let student = Student(firstName: "John", lastName: "Doe", email: "john@example.com", telephone: "555-1234", homeAddress: "123 Main St", ftnNumber: "123456789")
    StudentShareView(student: student)
        .modelContainer(for: [Student.self], inMemory: true)
}

