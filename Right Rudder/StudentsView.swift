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
    @State private var students: [Student] = []
    @State private var showingAddStudent = false
    @State private var selectedStudent: Student?
    @State private var sortOption: SortOption = .lastName
    
    enum SortOption: String, CaseIterable {
        case lastName = "Last Name"
        case manual = "Manual"
    }
    
    var body: some View {
        NavigationView {
            studentsList
        }
    }
    
    private var studentsList: some View {
        List {
            ForEach(Array(students.enumerated()), id: \.element.id) { index, student in
                studentRow(index: index, student: student)
            }
            .onDelete(perform: deleteStudents)
            .onMove(perform: sortOption == .manual ? moveStudents : { _, _ in })
        }
        .navigationTitle("Students")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(false)
        .navigationBarItems(
            leading: sortMenu,
            trailing: addButton
        )
        .sheet(isPresented: $showingAddStudent) {
            AddStudentView()
        }
        .onAppear {
            sortStudents()
        }
    }
    
    private var sortMenu: some View {
        Menu {
            Button("Alphabetical Sort") {
                sortOption = .lastName
                sortStudents()
            }
            Button("Manual Sort") {
                sortOption = .manual
                sortStudents()
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
        .buttonStyle(.noHaptic)
    }
    
    private var addButton: some View {
        Button(action: { showingAddStudent = true }) {
            Image(systemName: "plus")
        }
        .buttonStyle(.noHaptic)
    }
    
    @ViewBuilder
    private func studentRow(index: Int, student: Student) -> some View {
        HStack(alignment: .center) {
            // Show picker symbol in manual sort mode
            if sortOption == .manual {
                Button(action: {
                    // Toggle manual sort mode or start reordering
                    if sortOption != .manual {
                        sortOption = .manual
                        sortStudents()
                    }
                }) {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
            
            NavigationLink(destination: StudentDetailView(student: student)) {
                HStack(alignment: .center) {
                    Text(student.displayName)
                        .font(.system(size: 20, weight: .medium))
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    // Show photo thumbnail only if photo exists
                    if let photoData = student.profilePhotoData, let uiImage = UIImage(data: photoData) {
                        OptimizedImage(uiImage, maxSize: CGSize(width: 40, height: 40))
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .clipped()
                    }
                }
                .frame(height: 50) // Fixed row height
            }
        }
        .adaptiveRowBackgroundModifier(for: index)
    }
    
    private func sortStudents() {
        switch sortOption {
        case .lastName:
            // Use the already sorted query result
            students = allStudents
        case .manual:
            // For manual sorting, maintain the current order
            students = allStudents
        }
    }
    
    private func moveStudents(from source: IndexSet, to destination: Int) {
        withAnimation {
            students.move(fromOffsets: source, toOffset: destination)
        }
    }
    
    private func deleteStudents(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(students[index])
            }
        }
    }
}

#Preview {
    StudentsView()
        .modelContainer(for: [Student.self, StudentChecklist.self, StudentChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}


