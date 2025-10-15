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
            icon: "icloud.and.arrow.up",
            title: "CloudKit Student Sharing",
            description: "Share student profiles and checklists with students via secure CloudKit sharing. Students can view their progress and upload documents.",
            color: .blue
        ),
        FeatureItem(
            icon: "doc.text.fill",
            title: "Student Document Management",
            description: "Students can upload and manage required documents: Pilot Certificate, Medical Certificate, Passport/Birth Certificate, and LogBook with expiration tracking.",
            color: .green
        ),
        FeatureItem(
            icon: "bell.badge.fill",
            title: "Push Notifications",
            description: "Real-time notifications when instructors add comments or updates. Students receive instant alerts about their training progress.",
            color: .orange
        ),
        FeatureItem(
            icon: "checkmark.circle.fill",
            title: "Enhanced Flight Reviews",
            description: "New Biennial Flight Review checklist with 94 detailed items covering all FAA AC 61-98E requirements and comprehensive IPC checklists.",
            color: .purple
        ),
        FeatureItem(
            icon: "paintbrush.fill",
            title: "Improved UI & Accessibility",
            description: "Enhanced Light/Dark mode support, high contrast color schemes, better legibility, and streamlined navigation for all users.",
            color: .red
        ),
        FeatureItem(
            icon: "square.and.arrow.up",
            title: "Template Sharing & Export",
            description: "Share custom checklist templates with other instructors and export student records as PDFs for record keeping.",
            color: .indigo
        )
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
                        
                        Text("What's New in v1.5")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Major CloudKit Integration & Student Features")
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
                autoAdvanceTimer = Timer.scheduledTimer(withTimeInterval: 6.0, repeats: true) { _ in
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