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
    @Query(sort: \Student.lastName, order: .forward) private var students: [Student]
    @State private var showingAddStudent = false
    @State private var selectedStudent: Student?

    var body: some View {
        NavigationView {
            List {
                ForEach(Array(students.enumerated()), id: \.element.id) { index, student in
                    NavigationLink(destination: StudentDetailView(student: student)) {
                        Text(student.displayName)
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                    .listRowBackground(index.isMultiple(of: 2) ? Color.appMutedBox : Color.clear)
                }
                .onDelete(perform: deleteStudents)
            }
            .navigationTitle("Students")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddStudent = true }) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.noHaptic)
                }
            }
            .sheet(isPresented: $showingAddStudent) {
                AddStudentView()
            }
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


