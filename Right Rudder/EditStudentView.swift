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
    @State private var showingCamera = false
    @State private var showingPhotoLibrary = false
    @State private var capturedImage: UIImage?
    @State private var selectedCategory: String
    @State private var isInactive: Bool
    @State private var hasChanges: Bool = false
    @State private var hasExplicitlySaved: Bool = false
    
    // CloudKit sync service
    private let cloudKitShareService = CloudKitShareService.shared
    
    // Store original values for comparison
    private let originalCategory: String
    private let originalInactive: Bool
    
    private let categories = ["PPL", "IFR", "CPL", "CFI", "Review"]

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
        self._selectedCategory = State(initialValue: student.assignedCategory ?? "PPL")
        self._isInactive = State(initialValue: student.isInactive)
        
        // Store original values for comparison
        self.originalCategory = student.assignedCategory ?? "PPL"
        self.originalInactive = student.isInactive
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
                        .modifier(ResponsiveTextFieldModifier())
                    TextField("Last Name", text: $lastName)
                        .modifier(ResponsiveTextFieldModifier())
                    TextField("Email Address", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .modifier(ResponsiveTextFieldModifier())
                    TextField("Telephone Number", text: $telephone)
                        .keyboardType(.phonePad)
                        .modifier(ResponsiveTextFieldModifier())
                    TextField("Home Address", text: $homeAddress)
                        .foregroundColor(homeAddress == "Enter home address (optional)" ? .secondary : .primary)
                        .modifier(ResponsiveTextFieldModifier())
                    TextField("FTN Number", text: $ftnNumber)
                        .foregroundColor(ftnNumber == "Enter FTN number (optional)" ? .secondary : .primary)
                        .modifier(ResponsiveTextFieldModifier())
                }
                
                Section("Background") {
                    TextField("Biography", text: $biography, axis: .vertical)
                        .lineLimit(3...6)
                        .modifier(ResponsiveTextFieldModifier())
                    TextField("Background Notes", text: $backgroundNotes, axis: .vertical)
                        .lineLimit(3...6)
                        .modifier(ResponsiveTextFieldModifier())
                }
                
                Section("Student Category") {
                    Picker("Training Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedCategory) { checkForChanges() }
                }
                
                Section("Status") {
                    Toggle("Inactive Student", isOn: $isInactive)
                        .foregroundColor(isInactive ? .red : .primary)
                }
                
                Section("ID Photo") {
                    if let photoData = student.profilePhotoData, let uiImage = UIImage(data: photoData) {
                        HStack {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading) {
                                Text("Current Photo")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("Tap to change or remove")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button("Remove") {
                                student.profilePhotoData = nil
                            }
                            .foregroundColor(.red)
                        }
                    } else {
                        HStack {
                            Image(systemName: "person.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            VStack(alignment: .leading) {
                                Text("No Photo")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("Tap to add a photo")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    HStack(spacing: 16) {
                        Button("Take Photo") {
                            showingCamera = true
                        }
                        .buttonStyle(.rounded)
                        
                        Button("Choose from Library") {
                            showingPhotoLibrary = true
                        }
                        .buttonStyle(.rounded)
                    }
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
                        Task {
                            await saveStudent()
                            hasExplicitlySaved = true
                            dismiss()
                        }
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
        .sheet(isPresented: $showingCamera) {
            CameraView { image in
                student.profilePhotoData = image.jpegData(compressionQuality: 0.8)
            }
        }
        .sheet(isPresented: $showingPhotoLibrary) {
            PhotoLibraryView { image in
                student.profilePhotoData = image.jpegData(compressionQuality: 0.8)
            }
        }
        .onChange(of: firstName) { checkForChanges() }
        .onChange(of: lastName) { checkForChanges() }
        .onChange(of: email) { checkForChanges() }
        .onChange(of: telephone) { checkForChanges() }
        .onChange(of: homeAddress) { checkForChanges() }
        .onChange(of: ftnNumber) { checkForChanges() }
        .onChange(of: biography) { checkForChanges() }
        .onChange(of: backgroundNotes) { checkForChanges() }
        .onChange(of: selectedCategory) { checkForChanges() }
        .onChange(of: isInactive) { checkForChanges() }
        .onAppear {
            cloudKitShareService.setModelContext(modelContext)
        }
        .onDisappear {
            print("🔵 DEBUG: EditStudentView.onDisappear called - Checking for changes")
            if hasChanges && !hasExplicitlySaved {
                print("🔵 DEBUG: Changes detected but not explicitly saved, triggering auto-save")
                Task {
                    await saveStudent()
                }
            } else if hasExplicitlySaved {
                print("🔵 DEBUG: Changes were explicitly saved, skipping auto-save")
            } else {
                print("🔵 DEBUG: No changes detected, skipping save")
            }
        }
    }
    
    private var isFormValid: Bool {
        // Check basic required fields
        guard !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !telephone.isEmpty else {
            return false
        }
        
        // Only check for changes if basic fields are valid
        return hasChanges
    }
    
    private func checkForChanges() {
        let categoryChanged = selectedCategory != originalCategory
        let inactiveChanged = isInactive != originalInactive
        
        hasChanges = firstName != student.firstName ||
                    lastName != student.lastName ||
                    email != student.email ||
                    telephone != student.telephone ||
                    (homeAddress == "Enter home address (optional)" ? "" : homeAddress) != student.homeAddress ||
                    (ftnNumber == "Enter FTN number (optional)" ? "" : ftnNumber) != student.ftnNumber ||
                    (biography.isEmpty ? nil : biography) != student.biography ||
                    (backgroundNotes.isEmpty ? nil : backgroundNotes) != student.backgroundNotes ||
                    categoryChanged ||
                    inactiveChanged
    }
    
    private func saveStudent() async {
        print("🔵 DEBUG: EditStudentView.saveStudent() called - Personal info save triggered")
        print("🔵 DEBUG: Student: \(student.displayName), Changes detected: \(hasChanges)")
        
        student.firstName = firstName
        student.lastName = lastName
        student.email = email
        student.telephone = telephone
        student.homeAddress = homeAddress == "Enter home address (optional)" ? "" : homeAddress
        student.ftnNumber = ftnNumber == "Enter FTN number (optional)" ? "" : ftnNumber
        student.biography = biography.isEmpty ? nil : biography
        student.backgroundNotes = backgroundNotes.isEmpty ? nil : backgroundNotes
        student.assignedCategory = selectedCategory
        student.isInactive = isInactive
        student.lastModified = Date()
        
        do {
            let saveSuccessful = try await DatabaseErrorHandler.saveWithRecovery(modelContext, maxAttempts: 3)
            
            if saveSuccessful {
                print("✅ Student personal info saved successfully")
                print("🔍 Saved category: '\(student.assignedCategory ?? "nil")' for student: \(student.displayName)")
                
                // Post notification to update StudentsView
                NotificationCenter.default.post(name: NSNotification.Name("StudentUpdated"), object: nil)
                
                // Sync to CloudKit and refresh progress
                Task {
                    await cloudKitShareService.syncStudentPersonalInfo(student, modelContext: modelContext)
                    await refreshStudentProgress()
                }
            } else {
                print("❌ Failed to save student after recovery attempts")
            }
        } catch {
            print("❌ Failed to save student: \(error)")
            
            // Check if this is a model invalidation error
            if DatabaseErrorHandler.isInvalidationError(error) {
                print("⚠️ Model invalidation detected - data may have been lost. User should restart the app.")
                NotificationCenter.default.post(name: Notification.Name("DatabaseInvalidationError"), object: nil)
            }
        }
    }
    
    private func refreshStudentProgress() async {
        // Force refresh of progress calculations by updating lastModified
        await MainActor.run {
            student.lastModified = Date()
            // This will trigger SwiftUI to recalculate weightedCategoryProgress
            // and update the progress bars in StudentsView
        }
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
        .modelContainer(for: [Student.self, ChecklistAssignment.self, ItemProgress.self, CustomChecklistDefinition.self, CustomChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}

