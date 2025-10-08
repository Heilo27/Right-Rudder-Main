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
    
    init() {
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
                StudentDocument.self
            ])
            
            // Configure CloudKit container
            let cloudKitConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .private("iCloud.com.heiloprojects.rightrudder")
            )
            
            modelContainer = try ModelContainer(for: schema, configurations: cloudKitConfiguration)
            print("ModelContainer initialized successfully with CloudKit")
        } catch {
            print("Failed to initialize ModelContainer with CloudKit: \(error)")
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
                    StudentDocument.self
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
            SplashScreenView()
                .tint(currentColorScheme.primaryColor)
                .task {
                    await pushNotificationService.checkNotificationPermission()
                    if pushNotificationService.notificationPermissionGranted {
                        await pushNotificationService.subscribeToInstructorComments()
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
}
