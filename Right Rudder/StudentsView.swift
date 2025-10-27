//
//  StudentsView.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import SwiftUI
import SwiftData

struct StudentsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var allStudents: [Student] = []
    @State private var showingAddStudent = false
    @State private var selectedStudent: Student?
    @State private var selectedCategory: String? = nil
    @State private var showingInactiveStudents = false
    @State private var cachedFilteredStudents: [Student] = []
    
    // Settings for progress bars and photos
    @AppStorage("showProgressBars") private var showProgressBars = true
    @AppStorage("showStudentPhotos") private var showStudentPhotos = false
    
    private let categories = ["PPL", "IFR", "CPL", "CFI", "Review"]
    
    init() {
        print("🏗️ StudentsView INIT")
    }
    
    private var filteredStudents: [Student] {
        return cachedFilteredStudents
    }
    
    var body: some View {
        NavigationView {
            studentsList
        }
        .onAppear {
            print("👁️ StudentsView APPEARED")
            loadStudents()
            updateFilteredStudents()
        }
        .onChange(of: selectedCategory) { _, _ in
            updateFilteredStudents()
        }
        .onChange(of: showingInactiveStudents) { _, _ in
            updateFilteredStudents()
        }
    }
    
    private func loadStudents() {
        let request = FetchDescriptor<Student>(
            sortBy: [SortDescriptor(\.lastName, order: .forward)]
        )
        do {
            allStudents = try modelContext.fetch(request)
        } catch {
            print("Failed to load students: \(error)")
            allStudents = []
        }
    }
    
    private func updateFilteredStudents() {
        let baseStudents = showingInactiveStudents ? 
            allStudents.filter { $0.isInactive } : 
            allStudents.filter { !$0.isInactive }
        
        if let category = selectedCategory {
            cachedFilteredStudents = baseStudents.filter { $0.primaryCategory == category }
                .sorted { $0.sortKey < $1.sortKey }
        } else {
            cachedFilteredStudents = baseStudents.sorted { $0.sortKey < $1.sortKey }
        }
    }
    
    private var studentsList: some View {
        VStack(spacing: 0) {
            if !showingInactiveStudents {
                categoryFilterBar
                    .padding(.vertical, 8)
            }
            
            List {
                ForEach(Array(filteredStudents.enumerated()), id: \.element.id) { index, student in
                    studentRow(index: index, student: student)
                }
                .onDelete(perform: deleteStudents)
            }
            
            // Inactive Students button at bottom
            if !showingInactiveStudents {
                Button(action: {
                    showingInactiveStudents = true
                    selectedCategory = nil
                }) {
                    HStack {
                        Image(systemName: "person.crop.circle.badge.minus")
                        Text("Inactive Students")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                }
                .buttonStyle(.plain)
            } else {
                Button(action: {
                    showingInactiveStudents = false
                    selectedCategory = nil
                }) {
                    HStack {
                        Image(systemName: "person.crop.circle")
                        Text("Active Students")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle(showingInactiveStudents ? "Inactive Students" : "Students")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(false)
        .navigationBarItems(trailing: addButton)
        .sheet(isPresented: $showingAddStudent) {
            AddStudentView()
        }
    }
    
    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        if selectedCategory == category {
                            selectedCategory = nil // Deselect to show all
                        } else {
                            selectedCategory = category
                        }
                    }) {
                        Text(category)
                            .font(.subheadline)
                            .fontWeight(selectedCategory == category ? .semibold : .regular)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedCategory == category ? .white : .primary)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    
    private var addButton: some View {
        Button(action: { showingAddStudent = true }) {
            Image(systemName: "plus")
        }
        .buttonStyle(.noHaptic)
    }
    
    @ViewBuilder
    private func studentRow(index: Int, student: Student) -> some View {
        NavigationLink(destination: StudentDetailView(student: student)) {
            HStack(alignment: .center, spacing: 12) {
                // Progress indicators on the left side
                if showProgressBars {
                    HStack(spacing: 8) {
                        if student.currentActiveCategory != nil {
                            let progress = student.currentActiveProgress
                            HStack(spacing: 6) {
                                // Vertical progress bar
                                VStack {
                                    Spacer()
                                    Rectangle()
                                        .fill(progressColor(for: progress))
                                        .frame(width: 4, height: max(4, CGFloat(progress) * 26))
                                        .cornerRadius(2)
                                }
                                .frame(width: 4, height: 30)
                                
                                // Percentage text
                                Text("\(Int(progress * 100))%")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(progressColor(for: progress))
                                    .frame(width: 32, alignment: .leading)
                            }
                        } else {
                            // Show placeholder for students with no checklists
                            HStack(spacing: 6) {
                                VStack {
                                    Spacer()
                                    Rectangle()
                                        .fill(.gray)
                                        .frame(width: 4, height: 4)
                                        .cornerRadius(2)
                                }
                                .frame(width: 4, height: 30)
                                
                                Text("0%")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gray)
                                    .frame(width: 32, alignment: .leading)
                            }
                        }
                    }
                }
                
                Text(student.displayName)
                    .font(.system(size: 22, weight: .medium))
                    .fontWeight(.medium)
                
                Spacer()
                
                // Show photo thumbnail only if photo exists and setting is enabled
                if let photoData = student.profilePhotoData, let uiImage = UIImage(data: photoData), showStudentPhotos {
                    OptimizedImage(uiImage, maxSize: CGSize(width: 40, height: 40))
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .clipped()
                        .offset(x: -3) // Shift photo left by 3 points
                        .id("photo-\(student.id)") // Add ID for better memory management
                }
            }
            .frame(height: 35) // Back to original height since progress bars are now compact
        }
        .adaptiveRowBackgroundModifier(for: index)
    }
    
    // Helper function to determine progress bar color
    private func progressColor(for progress: Double) -> Color {
        switch progress {
        case 0.0..<0.3:
            return .red
        case 0.3..<0.7:
            return .orange
        case 0.7..<1.0:
            return .green
        case 1.0:
            return .blue
        default:
            return .gray
        }
    }
    
    
    private func deleteStudents(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredStudents[index])
        }
    }
}

#Preview {
    StudentsView()
        .modelContainer(for: [Student.self, StudentChecklist.self, StudentChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}



