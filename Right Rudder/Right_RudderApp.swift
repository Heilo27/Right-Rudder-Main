//
//  Right_RudderApp.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import SwiftUI
import SwiftData
import CloudKit

@main
struct RightRudderApp: App {
    let modelContainer: ModelContainer
    @AppStorage("selectedColorScheme") private var selectedColorScheme = AppColorScheme.skyBlue.rawValue
    @StateObject private var pushNotificationService = PushNotificationService.shared
    @State private var shouldShowWhatsNew = false
    @State private var shouldShowCFIWarning = false
    
    init() {
        // Initialize memory monitoring
        _ = MemoryMonitor.shared
        
        // Set up memory pressure handling
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { _ in
            print("Memory warning received - clearing caches")
            ImageOptimizationService.shared.clearCache()
        }
        
        do {
            // Initialize with CloudKit support
            print("Initializing ModelContainer with CloudKit support...")
            
            let schema = Schema([
                Student.self,
                StudentChecklist.self,
                StudentChecklistItem.self,
                EndorsementImage.self,
                ChecklistTemplate.self,
                ChecklistItem.self,
                StudentDocument.self,
                OfflineSyncOperation.self
            ])
            
            // Configure CloudKit container with optimized settings
            let cloudKitConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .private("iCloud.com.heiloprojects.rightrudder")
            )
            
            modelContainer = try ModelContainer(for: schema, configurations: cloudKitConfiguration)
            print("ModelContainer initialized successfully with CloudKit")
        } catch {
            print("Failed to initialize ModelContainer with CloudKit: \(error)")
            
            // Check if this is a CoreData corruption error
            if Self.isCoreDataCorruptionError(error) {
                print("⚠️ CoreData corruption detected. Attempting recovery...")
                try? Self.recoverFromCorruption()
            }
            print("Attempting to create local container as fallback...")
            
            // Fallback to local container if CloudKit fails
            do {
                let schema = Schema([
                    Student.self,
                    StudentChecklist.self,
                    StudentChecklistItem.self,
                    EndorsementImage.self,
                    ChecklistTemplate.self,
                    ChecklistItem.self,
                    StudentDocument.self,
                    OfflineSyncOperation.self
                ])
                
                let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
                modelContainer = try ModelContainer(for: schema, configurations: modelConfiguration)
                print("ModelContainer initialized successfully with local storage")
            } catch {
                print("Failed to initialize local ModelContainer: \(error)")
                print("Attempting to create in-memory container as final fallback...")
                
                // Final fallback to in-memory container
                do {
                    modelContainer = try ModelContainer(for: 
                        Student.self, 
                        StudentChecklist.self, 
                        StudentChecklistItem.self, 
                        EndorsementImage.self,
                        ChecklistTemplate.self, 
                        ChecklistItem.self,
                        StudentDocument.self,
                        OfflineSyncOperation.self,
                        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
                    )
                    print("ModelContainer initialized with in-memory storage")
                } catch {
                    fatalError("Could not initialize ModelContainer even with in-memory storage: \(error)")
                }
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if shouldShowCFIWarning {
                    CFIExpirationWarningView {
                        shouldShowCFIWarning = false
                    }
                } else if shouldShowWhatsNew {
                    WhatsNewView()
                } else {
                    SplashScreenView()
                }
            }
            .tint(currentColorScheme.primaryColor)
            .task {
                await pushNotificationService.checkNotificationPermission()
                if pushNotificationService.notificationPermissionGranted {
                    await pushNotificationService.subscribeToInstructorComments()
                }
                
                // Check if we should show CFI warning
                shouldShowCFIWarning = CFIExpirationWarningService.shared.shouldShowWarning()
                
                // Check if we should show What's New screen (only if no CFI warning)
                if !shouldShowCFIWarning {
                    shouldShowWhatsNew = WhatsNewService.shouldShowWhatsNew()
                }
            }
            .onOpenURL { url in
                handleIncomingURL(url)
            }
        }
        .modelContainer(modelContainer)
    }
    
    private func handleIncomingURL(_ url: URL) {
        print("Received URL: \(url)")
        
        // Check if this is a template import file (.rrtl)
        guard url.pathExtension.lowercased() == "rrtl" else {
            print("Not a Right Rudder Template List file")
            return
        }
        
        // Get modelContext BEFORE entering async context
        let context = modelContainer.mainContext
        
        Task { @MainActor in
            do {
                let count = try TemplateExportService.importTemplates(
                    from: url,
                    modelContext: context,
                    instructorName: nil
                )
                print("Successfully imported \(count) templates")
                
                // Show alert to user
                // Note: In a production app, you'd want to show a more sophisticated UI
                // For now, the console log will confirm the import
                
            } catch {
                print("Failed to import templates: \(error)")
            }
        }
    }
    
    private var currentColorScheme: AppColorScheme {
        AppColorScheme(rawValue: selectedColorScheme) ?? .skyBlue
    }
    
    /// Checks if an error indicates CoreData corruption
    private static func isCoreDataCorruptionError(_ error: Error) -> Bool {
        let errorString = error.localizedDescription.lowercased()
        return errorString.contains("disk i/o error") ||
               errorString.contains("sqlite error code:266") ||
               errorString.contains("sqlite error code:10") ||
               errorString.contains("couldn't be opened")
    }
    
    /// Attempts to recover from CoreData corruption by deleting corrupted files
    private static func recoverFromCorruption() throws {
        print("🔄 Attempting CoreData corruption recovery...")
        
        // Get the application support directory
        let fileManager = FileManager.default
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let storeURL = appSupportURL.appendingPathComponent("default.store")
        
        // Check if the corrupted store exists
        if fileManager.fileExists(atPath: storeURL.path) {
            print("🗑️ Removing corrupted database file: \(storeURL.path)")
            try fileManager.removeItem(at: storeURL)
            
            // Also remove any associated files
            let storeShmURL = appSupportURL.appendingPathComponent("default.store-shm")
            let storeWalURL = appSupportURL.appendingPathComponent("default.store-wal")
            
            if fileManager.fileExists(atPath: storeShmURL.path) {
                try? fileManager.removeItem(at: storeShmURL)
            }
            if fileManager.fileExists(atPath: storeWalURL.path) {
                try? fileManager.removeItem(at: storeWalURL)
            }
            
            print("✅ Corrupted database files removed. App will restart with fresh database.")
        }
    }
}
