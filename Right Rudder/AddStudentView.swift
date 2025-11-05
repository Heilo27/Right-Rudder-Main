//
//  AddStudentView.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import SwiftUI
import SwiftData
import Contacts
import ContactsUI

struct AddStudentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var telephone = ""
    @State private var homeAddress = "Enter home address (optional)"
    @State private var ftnNumber = "Enter FTN number (optional)"
    @State private var biography = ""
    @State private var backgroundNotes = ""
    @State private var showingContactPicker = false
    
    // Get instructor information from settings
    @AppStorage("instructorName") private var instructorName: String = ""
    @AppStorage("instructorCFINumber") private var instructorCFINumber: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Personal Information") {
                    HStack {
                        Text("Import from Contacts")
                        Spacer()
                        Button("Choose Contact") {
                            showingContactPicker = true
                        }
                        .buttonStyle(.rounded)
                    }
                    
                    TextField("First Name", text: $firstName)
                        .modifier(ResponsiveTextFieldModifier())
                    TextField("Last Name", text: $lastName)
                        .modifier(ResponsiveTextFieldModifier())
                    TextField("Email Address", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .modifier(ResponsiveTextFieldModifier())
                    TextField("Telephone Number (Optional)", text: $telephone)
                        .keyboardType(.phonePad)
                        .modifier(ResponsiveTextFieldModifier())
                    TextField("Home Address (Optional)", text: $homeAddress)
                        .foregroundColor(homeAddress == "Enter home address (optional)" ? .secondary : .primary)
                        .modifier(ResponsiveTextFieldModifier())
                    TextField("FTN Number (Optional)", text: $ftnNumber)
                        .foregroundColor(ftnNumber == "Enter FTN number (optional)" ? .secondary : .primary)
                        .modifier(ResponsiveTextFieldModifier())
                }
                
                Section("Background") {
                    TextField("Biography (Optional)", text: $biography, axis: .vertical)
                        .lineLimit(3...6)
                        .modifier(ResponsiveTextFieldModifier())
                    TextField("Background Notes (Optional)", text: $backgroundNotes, axis: .vertical)
                        .lineLimit(3...6)
                        .modifier(ResponsiveTextFieldModifier())
                }
            }
            .navigationTitle("Add Student")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveStudent()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
        .sheet(isPresented: $showingContactPicker) {
            ContactPickerView { contact in
                importContact(contact)
            }
        }
    }
    
    private var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func saveStudent() {
        let student = Student(
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            telephone: telephone.trimmingCharacters(in: .whitespacesAndNewlines),
            homeAddress: homeAddress == "Enter home address (optional)" ? "" : homeAddress.trimmingCharacters(in: .whitespacesAndNewlines),
            ftnNumber: ftnNumber == "Enter FTN number (optional)" ? "" : ftnNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        student.biography = biography.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : biography.trimmingCharacters(in: .whitespacesAndNewlines)
        student.backgroundNotes = backgroundNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : backgroundNotes.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Automatically add instructor information from settings
        student.instructorName = instructorName.isEmpty ? nil : instructorName
        student.instructorCFINumber = instructorCFINumber.isEmpty ? nil : instructorCFINumber
        
        // Set default values for new fields
        student.assignedCategory = "PPL"  // Default to PPL for new students
        student.isInactive = false  // New students are active by default
        
        // Insert student into context
        modelContext.insert(student)
        
        // Explicitly save to ensure persistence
        do {
            try modelContext.save()
            print("✅ Successfully saved new student: \(student.displayName) (ID: \(student.id))")
            
            // Verify the save worked by fetching
            let verifyDescriptor = FetchDescriptor<Student>()
            let allStudents = try modelContext.fetch(verifyDescriptor)
            let found = allStudents.contains { $0.id == student.id }
            
            if !found {
                print("⚠️ WARNING: Student was saved but fetch returned empty!")
            } else {
                print("✅ Verification: Student found in database after save (total students: \(allStudents.count))")
            }
            
        } catch {
            print("❌ CRITICAL: Failed to save student: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("❌ Error domain: \(nsError.domain)")
                print("❌ Error code: \(nsError.code)")
                print("❌ User info: \(nsError.userInfo)")
            }
            // Don't dismiss if save failed - user should see the error
            return
        }
        
        dismiss()
    }
    
    private func importContact(_ contact: CNContact) {
        // Extract name
        firstName = contact.givenName
        lastName = contact.familyName
        
        // Extract email (use first email if available)
        if let emailAddress = contact.emailAddresses.first {
            email = emailAddress.value as String
        }
        
        // Extract phone number (use first phone if available)
        if let phoneNumber = contact.phoneNumbers.first {
            telephone = phoneNumber.value.stringValue
        }
        
        // Extract address (use first postal address if available)
        if let postalAddress = contact.postalAddresses.first {
            let address = postalAddress.value
            homeAddress = "\(address.street), \(address.city), \(address.state) \(address.postalCode)"
        }
        
        // FTN Number will need to be entered manually as it's not a standard contact field
    }
}

#Preview {
    AddStudentView()
        .modelContainer(for: [Student.self, ChecklistAssignment.self, ItemProgress.self, CustomChecklistDefinition.self, CustomChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}

