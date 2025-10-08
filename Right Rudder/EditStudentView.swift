//
//  EditStudentView.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import SwiftUI
import SwiftData
import Contacts
import ContactsUI

struct EditStudentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var student: Student
    @State private var firstName: String
    @State private var lastName: String
    @State private var email: String
    @State private var telephone: String
    @State private var homeAddress: String
    @State private var ftnNumber: String
    @State private var biography: String
    @State private var backgroundNotes: String
    @State private var showingContactPicker = false

    init(student: Student) {
        self._student = State(initialValue: student)
        self._firstName = State(initialValue: student.firstName)
        self._lastName = State(initialValue: student.lastName)
        self._email = State(initialValue: student.email)
        self._telephone = State(initialValue: student.telephone)
        self._homeAddress = State(initialValue: student.homeAddress.isEmpty ? "Enter home address (optional)" : student.homeAddress)
        self._ftnNumber = State(initialValue: student.ftnNumber.isEmpty ? "Enter FTN number (optional)" : student.ftnNumber)
        self._biography = State(initialValue: student.biography ?? "")
        self._backgroundNotes = State(initialValue: student.backgroundNotes ?? "")
    }

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
            .navigationTitle("Edit Student")
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
        homeAddress != "Enter home address (optional)" && ftnNumber != "Enter FTN number (optional)"
    }
    
    private func saveStudent() {
        student.firstName = firstName
        student.lastName = lastName
        student.email = email
        student.telephone = telephone
        student.homeAddress = homeAddress == "Enter home address (optional)" ? "" : homeAddress
        student.ftnNumber = ftnNumber == "Enter FTN number (optional)" ? "" : ftnNumber
        student.biography = biography.isEmpty ? nil : biography
        student.backgroundNotes = backgroundNotes.isEmpty ? nil : backgroundNotes
        
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
    let student = Student(firstName: "John", lastName: "Doe", email: "john@example.com", telephone: "555-1234", homeAddress: "123 Main St", ftnNumber: "123456789")
    EditStudentView(student: student)
        .modelContainer(for: [Student.self, StudentChecklist.self, StudentChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}

