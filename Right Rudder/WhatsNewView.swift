//
//  WhatsNewView.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

struct WhatsNewView: View {
  @State private var isActive = false
  @State private var currentPage = 0
  @State private var opacity = 0.0
  @State private var autoAdvanceTimer: Timer?
  @Environment(\.modelContext) private var modelContext

  private let features = [
    FeatureItem(
      icon: "iphone.gen3",
      title: "🎉 NEW: Student Companion App",
      description:
        "Introducing the Right Rudder Student App! Students can now download their own dedicated app to view their training progress, upload documents, receive notifications, and track their flight hours independently.",
      color: .blue
    ),
    FeatureItem(
      icon: "person.2.fill",
      title: "Student-Instructor Collaboration",
      description:
        "Students can view their assigned checklists, see instructor comments, upload required documents, and track their training milestones in real-time through the companion app.",
      color: .green
    ),
    FeatureItem(
      icon: "doc.text.fill",
      title: "Document Management",
      description:
        "Students can upload and manage all required documents: Pilot Certificate, Medical Certificate, Passport/Birth Certificate, and LogBook with automatic expiration tracking and alerts.",
      color: .orange
    ),
    FeatureItem(
      icon: "chart.line.uptrend.xyaxis",
      title: "Progress Tracking",
      description:
        "Students can view their training progress, completed lessons, upcoming requirements, and track their journey toward certification goals.",
      color: .red
    ),
    FeatureItem(
      icon: "icloud.and.arrow.up",
      title: "Secure CloudKit Sync",
      description:
        "All student data syncs securely through CloudKit, ensuring students always have access to their latest training information across all devices.",
      color: .indigo
    ),
  ]

  var body: some View {
    if isActive {
      ContentView()
    } else {
      ZStack {
        // Background
        LinearGradient(
          gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.blue.opacity(0.05)]),
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack(spacing: 0) {
          // Header
          VStack(spacing: 16) {
            Image(systemName: "airplane")
              .font(.system(size: 60))
              .foregroundColor(.blue)

            Text("What's New in v1.6")
              .font(.largeTitle)
              .fontWeight(.bold)
              .foregroundColor(.primary)

            Text("🎉 Introducing the Student Companion App!")
              .font(.title2)
              .fontWeight(.medium)
              .foregroundColor(.secondary)
          }
          .padding(.top, 40)
          .padding(.horizontal, 20)

          // Feature Cards
          TabView(selection: $currentPage) {
            ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
              FeatureCard(feature: feature)
                .tag(index)
            }
          }
          .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
          .frame(height: 400)
          .padding(.horizontal, 20)

          // Page Indicator
          HStack(spacing: 8) {
            ForEach(0..<features.count, id: \.self) { index in
              Circle()
                .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.3))
                .frame(width: 8, height: 8)
                .animation(.easeInOut(duration: 0.3), value: currentPage)
            }
          }
          .padding(.top, 20)

          Spacer()

          // Continue Button
          Button(action: {
            // Mark What's New as shown
            WhatsNewService.markAsShown()

            withAnimation(.easeInOut(duration: 0.5)) {
              self.isActive = true
            }
          }) {
            HStack {
              Text("Continue to App")
                .font(.headline)
                .fontWeight(.semibold)
              Image(systemName: "arrow.right")
                .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
              LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                startPoint: .leading,
                endPoint: .trailing
              )
            )
            .cornerRadius(25)
          }
          .padding(.horizontal, 40)
          .padding(.bottom, 40)
        }
        .opacity(opacity)
      }
      .onAppear {
        // Initialize default data during splash screen
        print("What's New screen appeared - initializing default data...")

        // Add a small delay to ensure SwiftData is fully initialized
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          // Force update templates to ensure instrument templates are available
          DefaultDataService.forceUpdateTemplates(modelContext: modelContext)
        }

        // Animate in
        withAnimation(.easeIn(duration: 0.8)) {
          self.opacity = 1.0
        }

        // Auto-advance pages
        autoAdvanceTimer = Timer.scheduledTimer(withTimeInterval: 9.0, repeats: true) { _ in
          withAnimation(.easeInOut(duration: 0.5)) {
            self.currentPage = (self.currentPage + 1) % self.features.count
          }
        }
      }
      .onDisappear {
        // Clean up timer to prevent memory leaks
        autoAdvanceTimer?.invalidate()
        autoAdvanceTimer = nil
      }
    }
  }
}

struct FeatureItem {
  let icon: String
  let title: String
  let description: String
  let color: Color
}

struct FeatureCard: View {
  let feature: FeatureItem

  var body: some View {
    VStack(spacing: 20) {
      // Icon
      Image(systemName: feature.icon)
        .font(.system(size: 50))
        .foregroundColor(feature.color)
        .padding(.top, 20)

      // Title
      Text(feature.title)
        .font(.title2)
        .fontWeight(.bold)
        .foregroundColor(.primary)
        .multilineTextAlignment(.center)

      // Description
      Text(feature.description)
        .font(.body)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
        .lineLimit(nil)
        .padding(.horizontal, 20)

      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 20)
        .fill(Color(.systemBackground))
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    )
    .padding(.horizontal, 10)
  }
}

#Preview {
  WhatsNewView()
}
