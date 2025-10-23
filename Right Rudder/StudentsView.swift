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
    @Query(sort: \Student.lastName, order: .forward) private var allStudents: [Student]
    @State private var showingAddStudent = false
    @State private var selectedStudent: Student?
    @State private var selectedCategory: String? = nil
    @State private var showingInactiveStudents = false
    
    private let categories = ["PPL", "IFR", "CPL", "CFI", "Review"]
    
    private var filteredStudents: [Student] {
        let baseStudents = showingInactiveStudents ? 
            allStudents.filter { $0.isInactive } : 
            allStudents.filter { !$0.isInactive }
        
        guard let category = selectedCategory else {
            return baseStudents.sorted { $0.sortKey < $1.sortKey }
        }
        return baseStudents.filter { $0.primaryCategory == category }
            .sorted { $0.sortKey < $1.sortKey }
    }
    
    var body: some View {
        NavigationView {
            studentsList
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
            HStack(alignment: .center) {
                Text(student.displayName)
                    .font(.system(size: 22, weight: .medium))
                    .fontWeight(.medium)
                
                Spacer()
                
                // Show photo thumbnail only if photo exists
                if let photoData = student.profilePhotoData, let uiImage = UIImage(data: photoData) {
                    OptimizedImage(uiImage, maxSize: CGSize(width: 40, height: 40))
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .clipped()
                        .offset(x: -3) // Shift photo left by 3 points
                        .id("photo-\(student.id)") // Add ID for better memory management
                }
            }
            .frame(height: 35) // Fixed row height (reduced by 10% from 39)
        }
        .adaptiveRowBackgroundModifier(for: index)
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



