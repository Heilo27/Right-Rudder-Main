//
//  WhatsNewView.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

struct WhatsNewView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentFeatureIndex = 0
    
    let features = [
        FeatureInfo(
            title: "CloudKit Student Sharing",
            description: "Share student profiles and checklists with a companion student app. Students can view their progress and upload documents securely.",
            icon: "person.2.circle"
        ),
        FeatureInfo(
            title: "Document Management System",
            description: "Upload and track student documents including pilot certificates, medical certificates, passports, and logbooks with expiration date tracking.",
            icon: "doc.text.image"
        ),
        FeatureInfo(
            title: "Template Sharing & Import",
            description: "Share your custom checklist templates with other instructors and import templates from colleagues using .rrtl files.",
            icon: "square.and.arrow.up.on.square"
        ),
        FeatureInfo(
            title: "Smart Template Updates",
            description: "The app automatically updates default checklists when new versions are released, while preserving your custom checklists.",
            icon: "arrow.triangle.2.circlepath"
        ),
        FeatureInfo(
            title: "Push Notifications",
            description: "Students receive instant notifications when you add comments to their checklists, keeping them engaged in their training.",
            icon: "bell.badge"
        ),
        FeatureInfo(
            title: "Enhanced Student Records",
            description: "Student profiles now include document management, sharing status, and comprehensive record keeping with visual indicators.",
            icon: "person.crop.circle.badge.plus"
        ),
        FeatureInfo(
            title: "Fluid Swipe Gestures",
            description: "Swipe left on any checked item to uncheck it. The entire row follows your finger for a smooth, intuitive experience.",
            icon: "hand.draw"
        ),
        FeatureInfo(
            title: "Color Scheme Options",
            description: "Choose from multiple color schemes including Sky Blue, Aviation Orange, Professional Navy, and Forest Green.",
            icon: "paintpalette"
        ),
        FeatureInfo(
            title: "Improved Checklist Interaction",
            description: "Tap to check items instantly, swipe left to uncheck. No more accidental changes with improved gesture recognition.",
            icon: "checkmark.circle"
        ),
        FeatureInfo(
            title: "Comprehensive Training Templates",
            description: "37 default templates covering all phases of flight training from First Steps through Checkride preparation.",
            icon: "list.bullet.clipboard"
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("What's New in Right Rudder")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Version 1.3")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                
                // Feature carousel
                TabView(selection: $currentFeatureIndex) {
                    ForEach(0..<features.count, id: \.self) { index in
                        FeatureCard(feature: features[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .frame(height: 400)
                .padding(.horizontal, 20)
                
                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<features.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentFeatureIndex ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.vertical, 20)
                
                Spacer()
                
                // Continue button
                Button("Continue") {
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue)
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
    }
}

struct FeatureInfo {
    let title: String
    let description: String
    let icon: String
}

struct FeatureCard: View {
    let feature: FeatureInfo
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: feature.icon)
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text(feature.title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(feature.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

#Preview {
    WhatsNewView()
}
