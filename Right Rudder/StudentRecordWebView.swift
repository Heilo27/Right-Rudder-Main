// StudentRecordWebView.swift
// Right Rudder
//
// Created to resolve missing symbol.

import SwiftUI

struct StudentRecordWebView: View {
    let student: Student
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Student Record")
                .font(.title)
                .fontWeight(.bold)
            Text("Record for: \(student.displayName)")
                .font(.headline)
            Text("(PDF/record export UI placeholder)")
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    let student = Student(firstName: "John", lastName: "Doe", email: "john@example.com", telephone: "555-1234", homeAddress: "123 Main St", ftnNumber: "123456789")
    StudentRecordWebView(student: student)
        .modelContainer(for: [Student.self, StudentChecklist.self, StudentChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}
