//
//  ContentView.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var students: [Student]
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            StudentsView()
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Students")
                }
                .tag(0)
            
            ChecklistTemplatesView()
                .tabItem {
                    Image(systemName: "list.bullet.clipboard")
                    Text("Lessons")
                }
                .tag(1)
            
            EndorsementGeneratorView()
                .tabItem {
                    Image(systemName: "signature")
                    Text("Endorsement")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(3)
            
        }
        .onAppear {
            // Start performance monitoring in debug builds
            #if DEBUG
            PerformanceMonitor.shared.startMonitoring()
            #endif
        }
        .onDisappear {
            #if DEBUG
            PerformanceMonitor.shared.stopMonitoring()
            #endif
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Student.self, StudentChecklist.self, StudentChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}
