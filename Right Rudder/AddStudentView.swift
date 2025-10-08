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
                    TextField("Last Name", text: $lastName)
                    TextField("Email Address", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Telephone Number", text: $telephone)
                        .keyboardType(.phonePad)
                    TextField("Home Address", text: $homeAddress)
                        .foregroundColor(homeAddress == "Enter home address (optional)" ? .secondary : .primary)
                    TextField("FTN Number", text: $ftnNumber)
                        .foregroundColor(ftnNumber == "Enter FTN number (optional)" ? .secondary : .primary)
                }
                
                Section("Background") {
                    TextField("Biography", text: $biography, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Background Notes", text: $backgroundNotes, axis: .vertical)
                        .lineLimit(3...6)
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
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !telephone.isEmpty && 
        homeAddress != "Enter home address" && ftnNumber != "Enter FTN number"
    }
    
    private func saveStudent() {
        let student = Student(
            firstName: firstName,
            lastName: lastName,
            email: email,
            telephone: telephone,
            homeAddress: homeAddress == "Enter home address" ? "" : homeAddress,
            ftnNumber: ftnNumber == "Enter FTN number" ? "" : ftnNumber
        )
        student.biography = biography.isEmpty ? nil : biography
        student.backgroundNotes = backgroundNotes.isEmpty ? nil : backgroundNotes
        
        // Automatically add instructor information from settings
        student.instructorName = instructorName.isEmpty ? nil : instructorName
        student.instructorCFINumber = instructorCFINumber.isEmpty ? nil : instructorCFINumber
        
        modelContext.insert(student)
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
        .modelContainer(for: [Student.self, StudentChecklist.self, StudentChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}

