//
//  InstructorInfoView.swift
//  Right Rudder
//
//  Created by AI on 10/6/25.
//

import SwiftUI

struct InstructorInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("instructorName") private var instructorName: String = ""
    @AppStorage("instructorCFINumber") private var instructorCFINumber: String = ""
    @AppStorage("instructorCFIExpiration") private var instructorCFIExpiration: String = ""
    
    @State private var tempInstructorName: String = ""
    @State private var tempInstructorCFINumber: String = ""
    @State private var tempInstructorCFIExpiration: String = ""
    @State private var showingSavedAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Instructor Information")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Enter your information. This will be automatically added to all new student records when they are created.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Your Details") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Instructor Name")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("e.g., John Smith", text: $tempInstructorName)
                            .textContentType(.name)
                            .autocapitalization(.words)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CFI Number")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("e.g., CFI1234567890", text: $tempInstructorCFINumber)
                            .keyboardType(.default)
                            .autocapitalization(.allCharacters)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CFI Expiration Date (Optional)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("e.g., 12/31/2025", text: $tempInstructorCFIExpiration)
                            .keyboardType(.default)
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Current Information") {
                    if !instructorName.isEmpty {
                        HStack {
                            Text("Instructor Name:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(instructorName)
                                .fontWeight(.medium)
                        }
                    }
                    
                    if !instructorCFINumber.isEmpty {
                        HStack {
                            Text("CFI Number:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(instructorCFINumber)
                                .fontWeight(.medium)
                        }
                    }
                    
                    if !instructorCFIExpiration.isEmpty {
                        HStack {
                            Text("CFI Expiration:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(instructorCFIExpiration)
                                .fontWeight(.medium)
                        }
                    }
                    
                    if instructorName.isEmpty && instructorCFINumber.isEmpty {
                        Text("No instructor information saved yet")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                            .italic()
                    }
                }
                
                Section {
                    Text("This information will be automatically added to all new student records when you create them. Existing student records will not be affected.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
            }
            .navigationTitle("User Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveInstructorInfo()
                    }
                }
            }
            .alert("Information Saved", isPresented: $showingSavedAlert) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Your instructor information has been saved and will be added to all new student records.")
            }
            .onAppear {
                loadExistingInfo()
            }
        }
    }
    
    private func loadExistingInfo() {
        tempInstructorName = instructorName
        tempInstructorCFINumber = instructorCFINumber
        tempInstructorCFIExpiration = instructorCFIExpiration
    }
    
    private func saveInstructorInfo() {
        instructorName = tempInstructorName
        instructorCFINumber = tempInstructorCFINumber
        instructorCFIExpiration = tempInstructorCFIExpiration
        
        print("Instructor information saved: \(instructorName), CFI: \(instructorCFINumber), Expiration: \(instructorCFIExpiration)")
        showingSavedAlert = true
    }
}

#Preview {
    InstructorInfoView()
}

