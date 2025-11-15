//
//  SplashScreenView.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import SwiftData
import SwiftUI

// MARK: - SplashScreenView

struct SplashScreenView: View {
  // MARK: - Properties

  @State private var isActive = false
  @State private var size = 0.8
  @State private var opacity = 0.5
  @Environment(\.modelContext) private var modelContext

  // MARK: - Body

  var body: some View {
    if isActive {
      ContentView()
    } else {
      VStack(spacing: 20) {
        VStack(spacing: 20) {
          // App Icon or Logo
          Image(systemName: "airplane")
            .font(.system(size: 80))
            .foregroundColor(.blue)

          // App Name
          Text("Right Rudder")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.primary)

          // Subtitle
          Text("Flight Instructor Data Management")
            .font(.title2)
            .fontWeight(.medium)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        }
        .scaleEffect(size)
        .opacity(opacity)
        .onAppear {
          withAnimation(.easeIn(duration: 1.2)) {
            self.size = 0.9
            self.opacity = 1.0
          }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(
        LinearGradient(
          gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.blue.opacity(0.05)]),
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
      )
      .onAppear {
        // Initialize default data during splash screen
        print("Splash screen appeared - initializing default data...")

        // Add a small delay to ensure SwiftData is fully initialized
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          print("Starting template initialization...")
          // Initialize default data with version checking
          DefaultDataService.initializeDefaultData(modelContext: modelContext)

          // Process pending changes to ensure templates are saved
          modelContext.processPendingChanges()

          // Verify templates were loaded
          let request = FetchDescriptor<ChecklistTemplate>()
          if let templates = try? modelContext.fetch(request) {
            print("✅ Template initialization completed: \(templates.count) templates loaded")
          } else {
            print("⚠️ Could not verify template count after initialization")
          }
        }

        // Wait longer to ensure templates are fully initialized before showing main app
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
          print("Transitioning to main app...")
          withAnimation(.easeInOut(duration: 0.5)) {
            self.isActive = true
          }
        }
      }
    }
  }
}

#Preview {
  SplashScreenView()
}
