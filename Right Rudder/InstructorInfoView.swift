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
    @AppStorage("instructorCFIExpirationDateString") private var instructorCFIExpirationDateString: String = ""
    @AppStorage("instructorCFIHasExpiration") private var instructorCFIHasExpiration: Bool = false
    
    @State private var tempInstructorName: String = ""
    @State private var tempInstructorCFINumber: String = ""
    @State private var tempInstructorCFIExpirationDate: Date = Date()
    @State private var tempInstructorCFIHasExpiration: Bool = false
    @State private var showingSavedAlert = false
    
    private var instructorCFIExpirationDate: Date {
        if instructorCFIExpirationDateString.isEmpty {
            return Date()
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: instructorCFIExpirationDateString) ?? Date()
    }
    
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
                        Toggle("CFI Has Expiration Date", isOn: $tempInstructorCFIHasExpiration)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if tempInstructorCFIHasExpiration {
                            DatePicker("CFI Expiration Date", selection: $tempInstructorCFIExpirationDate, displayedComponents: .date)
                                .font(.caption)
                        } else {
                            DatePicker("CFI Recent Experience Date", selection: $tempInstructorCFIExpirationDate, displayedComponents: .date)
                                .font(.caption)
                        }
                        
                        Text(getCFIDateDescription())
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .italic()
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
                    
                    if instructorCFIHasExpiration {
                        HStack {
                            Text("CFI Expiration:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(formatDate(instructorCFIExpirationDate))
                                .fontWeight(.medium)
                        }
                    } else {
                        HStack {
                            Text("CFI Recent Experience:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(formatDate(instructorCFIExpirationDate))
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
        tempInstructorCFIExpirationDate = instructorCFIExpirationDate
        tempInstructorCFIHasExpiration = instructorCFIHasExpiration
    }
    
    private func saveInstructorInfo() {
        instructorName = tempInstructorName
        instructorCFINumber = tempInstructorCFINumber
        
        // Convert date to string for storage
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        instructorCFIExpirationDateString = formatter.string(from: tempInstructorCFIExpirationDate)
        
        instructorCFIHasExpiration = tempInstructorCFIHasExpiration
        
        print("Instructor information saved: \(instructorName), CFI: \(instructorCFINumber), Expiration: \(instructorCFIHasExpiration ? "Yes" : "No"), Date: \(instructorCFIExpirationDateString)")
        showingSavedAlert = true
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
    
    private func getCFIDateDescription() -> String {
        let now = Date()
        let calendar = Calendar.current
        let monthsAgo = calendar.date(byAdding: .month, value: -24, to: now) ?? now
        
        if tempInstructorCFIHasExpiration {
            if tempInstructorCFIExpirationDate > now {
                return "Expiration Date: Certificate expires on this date"
            } else {
                return "Expiration Date: Certificate has expired"
            }
        } else {
            if tempInstructorCFIExpirationDate >= monthsAgo {
                return "Recent Experience: Valid within 24 months"
            } else {
                return "Recent Experience: Expired (over 24 months old)"
            }
        }
    }
}

#Preview {
    InstructorInfoView()
}


