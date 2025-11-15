//
//  EndorsementView.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import SwiftData
import SwiftUI

// MARK: - EndorsementGeneratorView

struct EndorsementGeneratorView: View {
  // MARK: - Properties

  @Environment(\.modelContext) private var modelContext
  @Query private var students: [Student]

  @State private var selectedEndorsement: FAAEndorsement?
  @State private var studentName: String = ""
  @State private var customFields: [String: String] = [:]
  @State private var debounceTimer: Timer?
  @State private var endorsementDate: Date = Date()
  @AppStorage("instructorName") private var instructorName: String = ""
  @AppStorage("instructorCFINumber") private var instructorCFINumber: String = ""
  @AppStorage("instructorCFIExpirationDateString") private var instructorCFIExpirationDateString:
    String = ""
  @AppStorage("instructorCFIHasExpiration") private var instructorCFIHasExpiration: Bool = false
  @State private var showingPDFExport = false
  @State private var showingStudentPicker = false
  @State private var showingSignaturePad = false
  @State private var selectedStudent: Student?
  @State private var signatureImage: UIImage?

  private let endorsements = FAAEndorsement.allEndorsements

  // Cache for field descriptions to avoid repeated regex operations
  @State private var fieldDescriptionCache: [String: String] = [:]

  // Memoized computed properties for better performance
  @State private var memoizedCFIStatusText: String = ""
  @State private var memoizedCFIStatusColor: Color = .orange

  // MARK: - Initialization

  init() {}

  // MARK: - Computed Properties

  private var instructorCFIExpirationDate: Date {
    if instructorCFIExpirationDateString.isEmpty {
      return Date()
    }
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.date(from: instructorCFIExpirationDateString) ?? Date()
  }

  // MARK: - Body

  var body: some View {
    NavigationView {
      Form {
        Section("Endorsement Selection") {
          Picker("Select Endorsement", selection: $selectedEndorsement) {
            Text("Select an endorsement...").tag(nil as FAAEndorsement?)
            ForEach(endorsements, id: \.code) { endorsement in
              Text("\(endorsement.code): \(endorsement.title)")
                .tag(endorsement as FAAEndorsement?)
            }
          }
          .onChange(of: selectedEndorsement) { _, newValue in
            updateCustomFields()
            // Pre-compute field descriptions asynchronously to avoid UI blocking
            if let endorsement = newValue {
              Task {
                await precomputeFieldDescriptions(for: endorsement)
              }
            }
          }
        }

        if let endorsement = selectedEndorsement {
          Section("Student Information") {
            HStack {
              Text("Student Name")
              Spacer()
              Button("Select Student") {
                showingStudentPicker = true
              }
              .buttonStyle(.bordered)
            }

            TextField("Enter student name", text: $studentName)
              .textFieldStyle(.roundedBorder)
          }

          Section("Custom Fields") {
            ForEach(endorsement.requiredFields, id: \.self) { field in
              CustomFieldRow(
                field: field,
                endorsement: endorsement,
                customFields: $customFields,
                fieldDescriptionCache: $fieldDescriptionCache
              )
            }
          }

          Section("Date") {
            DatePicker("Endorsement Date", selection: $endorsementDate, displayedComponents: .date)
          }

          Section("Instructor Information") {
            HStack {
              Text("Instructor Name:")
                .foregroundColor(.secondary)
              Spacer()
              Text(instructorName.isEmpty ? "Not set" : instructorName)
                .fontWeight(.medium)
            }

            HStack {
              Text("CFI Number:")
                .foregroundColor(.secondary)
              Spacer()
              Text(instructorCFINumber.isEmpty ? "Not set" : instructorCFINumber)
                .fontWeight(.medium)
            }

            HStack {
              Text("CFI Status:")
                .foregroundColor(.secondary)
              Spacer()
              Text(memoizedCFIStatusText)
                .fontWeight(.medium)
                .foregroundColor(memoizedCFIStatusColor)
            }

            if !instructorName.isEmpty && !instructorCFINumber.isEmpty {
              Text("Go to Settings to update instructor information")
                .font(.caption)
                .foregroundColor(.secondary)
            } else {
              Text("Please set your instructor information in Settings first")
                .font(.caption)
                .foregroundColor(.orange)
            }
          }

          Section("Digital Signature") {
            if let signatureImage = signatureImage {
              VStack(alignment: .leading, spacing: 8) {
                Text("Signature Preview")
                  .font(.caption)
                  .foregroundColor(.secondary)

                HStack {
                  Image(uiImage: signatureImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 80)
                    .background(Color.appAdaptiveMutedBox)
                    .border(Color.gray.opacity(0.3), width: 1)
                    .cornerRadius(4)

                  Spacer()

                  Button("Clear") {
                    self.signatureImage = nil
                  }
                  .foregroundColor(.red)
                  .buttonStyle(.bordered)
                }
              }
            } else {
              Button("Add Digital Signature") {
                showingSignaturePad = true
              }
              .frame(maxWidth: .infinity)
              .buttonStyle(.bordered)
            }
          }

          Section {
            Button("Export Endorsement") {
              showingPDFExport = true
            }
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
            .disabled(!isFormValid)
          }
        }
      }
      .navigationTitle("Endorsement Generator")
      .sheet(isPresented: $showingStudentPicker) {
        StudentPickerView(selectedStudent: $selectedStudent, students: students)
      }
      .sheet(isPresented: $showingSignaturePad) {
        SignaturePadView(signatureImage: $signatureImage)
      }
      .sheet(isPresented: $showingPDFExport) {
        if let endorsement = selectedEndorsement {
          PDFExportView(
            endorsement: endorsement,
            studentName: studentName,
            customFields: customFields,
            endorsementDate: endorsementDate,
            instructorName: instructorName,
            cfiNumber: instructorCFINumber,
            cfiExpirationDate: instructorCFIExpirationDate,
            cfiHasExpiration: instructorCFIHasExpiration,
            signatureImage: signatureImage,
            selectedStudent: selectedStudent
          )
        }
      }
      .onChange(of: selectedStudent) { _, newValue in
        if let student = newValue {
          studentName = "\(student.firstName) \(student.lastName)"
        }
      }
      .onAppear {
        updateMemoizedCFIStatus()
      }
      .onChange(of: instructorName) { _, _ in
        updateMemoizedCFIStatus()
      }
      .onChange(of: instructorCFINumber) { _, _ in
        updateMemoizedCFIStatus()
      }
      .onChange(of: instructorCFIExpirationDateString) { _, _ in
        updateMemoizedCFIStatus()
      }
      .onChange(of: instructorCFIHasExpiration) { _, _ in
        updateMemoizedCFIStatus()
      }
    }
  }

  private var isFormValid: Bool {
    guard let endorsement = selectedEndorsement else { return false }
    guard !studentName.isEmpty else { return false }
    guard !instructorName.isEmpty else { return false }
    guard !instructorCFINumber.isEmpty else { return false }

    // Check if all required fields are filled
    for field in endorsement.requiredFields {
      if customFields[field]?.isEmpty ?? true {
        return false
      }
    }

    return true
  }

  private func updateCustomFields() {
    customFields.removeAll()
    if let endorsement = selectedEndorsement {
      for field in endorsement.requiredFields {
        customFields[field] = ""
      }
    }
    // Clear cache when switching endorsements to ensure fresh data
    fieldDescriptionCache.removeAll()
  }

  private func getCFIStatusText() -> String {
    if instructorName.isEmpty || instructorCFINumber.isEmpty {
      return "Not configured"
    }

    let now = Date()
    let calendar = Calendar.current
    let monthsAgo = calendar.date(byAdding: .month, value: -24, to: now) ?? now

    if instructorCFIHasExpiration {
      if instructorCFIExpirationDate > now {
        return "Valid (Exp: \(formatDate(instructorCFIExpirationDate)))"
      } else {
        return "Expired (\(formatDate(instructorCFIExpirationDate)))"
      }
    } else {
      if instructorCFIExpirationDate >= monthsAgo {
        return "Valid (RE: \(formatDate(instructorCFIExpirationDate)))"
      } else {
        return "Expired (RE: \(formatDate(instructorCFIExpirationDate)))"
      }
    }
  }

  private func getCFIStatusColor() -> Color {
    if instructorName.isEmpty || instructorCFINumber.isEmpty {
      return .orange
    }

    let now = Date()
    let calendar = Calendar.current
    let monthsAgo = calendar.date(byAdding: .month, value: -24, to: now) ?? now

    if instructorCFIHasExpiration {
      return instructorCFIExpirationDate > now ? .green : .red
    } else {
      return instructorCFIExpirationDate >= monthsAgo ? .green : .red
    }
  }

  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd/yyyy"
    return formatter.string(from: date)
  }

  private func precomputeFieldDescriptions(for endorsement: FAAEndorsement) async {
    // Pre-compute field descriptions in background to avoid UI blocking
    for field in endorsement.requiredFields {
      let cacheKey = "\(endorsement.code)_\(field)"
      if fieldDescriptionCache[cacheKey] == nil {
        let placeholders: [String: String] = [
          "M/M": "aircraft make and model",
          "airport name": "airport name",
          "name of": "test name",
          "applicable": "certificate type",
          "aircraft category": "aircraft category",
          "aircraft category and class": "aircraft category and class",
          "airplane, helicopter, or powered-lift": "aircraft type",
          "grade of pilot certificate": "pilot certificate grade",
          "certificate number": "certificate number",
          "date": "date",
          "type of": "type",
          "flight and/or ground, as appropriate": "training type",
          "aircraft category/class rating": "aircraft category/class rating",
          "name of specific aircraft category/class/type": "specific aircraft type",
        ]
        let description = (placeholders[field] ?? field.lowercased()).capitalized
        fieldDescriptionCache[cacheKey] = description
      }
    }
  }

  private func updateMemoizedCFIStatus() {
    memoizedCFIStatusText = getCFIStatusText()
    memoizedCFIStatusColor = getCFIStatusColor()
  }
}

#Preview {
  EndorsementGeneratorView()
    .modelContainer(
      for: [
        Student.self, ChecklistAssignment.self, ItemProgress.self, CustomChecklistDefinition.self,
        CustomChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self,
      ], inMemory: true)
}
