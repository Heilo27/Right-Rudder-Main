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
        case category = "Category"
        case manual = "Manual"
    }
    
    struct StudentGroup {
        let category: String
        let students: [Student]
    }
    
    private var groupedStudents: [StudentGroup] {
        let grouped = Dictionary(grouping: students) { $0.primaryCategory }
        return grouped.map { StudentGroup(category: $0.key, students: $0.value.sorted { 
            sortOption == .manual ? $0.customOrder < $1.customOrder : $0.sortKey < $1.sortKey 
        }) }
            .sorted { $0.category < $1.category }
    }
    
    @ViewBuilder
    private func categoryHeader(for category: String) -> some View {
        HStack {
            Text(category)
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    var body: some View {
        NavigationView {
            studentsList
        }
    }
    
    private var studentsList: some View {
        List {
            if sortOption == .lastName {
                // Simple list for alphabetical sort (no dividers)
                ForEach(Array(students.enumerated()), id: \.element.id) { index, student in
                    studentRow(index: index, student: student)
                }
                .onDelete(perform: deleteStudents)
            } else if sortOption == .manual {
                // Simple list for manual sort (no dividers, with drag handles)
                ForEach(Array(students.enumerated()), id: \.element.id) { index, student in
                    studentRow(index: index, student: student)
                }
                .onDelete(perform: deleteStudents)
                .onMove(perform: moveStudents)
            } else {
                // Group students by category for sectioned display (Category sort only)
                ForEach(groupedStudents, id: \.category) { group in
                    Section(header: categoryHeader(for: group.category)) {
                        ForEach(Array(group.students.enumerated()), id: \.element.id) { index, student in
                            studentRow(index: index, student: student)
                        }
                        .onDelete(perform: deleteStudents)
                    }
                }
            }
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
            initializeCustomOrderIfNeeded()
            sortStudents()
        }
    }
    
    private var sortMenu: some View {
        Menu {
            Button("Alphabetical Sort") {
                sortOption = .lastName
                sortStudents()
            }
            Button("Category Sort") {
                sortOption = .category
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
        }
        .adaptiveRowBackgroundModifier(for: index)
    }
    
    private func initializeCustomOrderIfNeeded() {
        // Initialize custom order for students that don't have it set
        let studentsNeedingOrder = allStudents.filter { $0.customOrder == 0 }
        if !studentsNeedingOrder.isEmpty {
            for (index, student) in studentsNeedingOrder.enumerated() {
                student.customOrder = index
            }
            do {
                try modelContext.save()
            } catch {
                print("Failed to initialize custom order: \(error)")
            }
        }
    }
    
    private func sortStudents() {
        switch sortOption {
        case .lastName:
            // Use the already sorted query result
            students = allStudents
        case .category:
            // Sort by category first, then by last name within each category
            students = allStudents.sorted { student1, student2 in
                let category1 = student1.primaryCategory
                let category2 = student2.primaryCategory
                
                if category1 != category2 {
                    return category1 < category2
                } else {
                    return student1.sortKey < student2.sortKey
                }
            }
        case .manual:
            // For manual sorting, use the custom order field
            students = allStudents.sorted { $0.customOrder < $1.customOrder }
        }
    }
    
    private func moveStudents(from source: IndexSet, to destination: Int) {
        // Move items in the students array
        students.move(fromOffsets: source, toOffset: destination)
        
        // Update custom order values to persist the manual sorting
        for (index, student) in students.enumerated() {
            student.customOrder = index
        }
        
        // Save the changes to the database
        do {
            try modelContext.save()
        } catch {
            print("Failed to save student order: \(error)")
        }
    }
    
    private func deleteStudents(offsets: IndexSet) {
        if sortOption == .lastName || sortOption == .manual {
            // For alphabetical and manual sort, use the regular students array
            for index in offsets {
                modelContext.delete(students[index])
            }
        } else {
            // For category sort, we need to find the actual student in the grouped data
            var studentIndex = 0
            for group in groupedStudents {
                for student in group.students {
                    if offsets.contains(studentIndex) {
                        modelContext.delete(student)
                    }
                    studentIndex += 1
                }
            }
        }
    }
}

#Preview {
    StudentsView()
        .modelContainer(for: [Student.self, StudentChecklist.self, StudentChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}



