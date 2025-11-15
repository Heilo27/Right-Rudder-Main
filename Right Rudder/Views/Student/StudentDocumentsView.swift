import SwiftData
import SwiftUI
import UniformTypeIdentifiers

// MARK: - StudentDocumentsView

struct StudentDocumentsView: View {
  // MARK: - Properties

  @Environment(\.modelContext) private var modelContext
  @State private var student: Student

  @State private var showingDocumentPicker = false
  @State private var selectedDocumentType: DocumentType?
  @State private var documentPickerDocumentType: DocumentType?
  @State private var showingCamera = false
  @State private var showingPhotoLibrary = false
  @State private var selectedDocumentForViewing: StudentDocument?
  @State private var showingDocumentDetail = false
  @State private var sortedDocuments: [StudentDocument] = []
  @State private var capturedImage: UIImage?

  // MARK: - Initialization

  init(student: Student) {
    self._student = State(initialValue: student)
  }

  // MARK: - Body

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        // Header
        VStack(alignment: .leading, spacing: 8) {
          Text("Required Documents")
            .font(.title2)
            .fontWeight(.bold)
          Text("Upload required aviation documents for \(student.displayName)")
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()

        // Document types
        ForEach(DocumentType.allCases, id: \.self) { docType in
          DocumentTypeCard(
            documentType: docType,
            document: getDocument(for: docType),
            onAddDocument: {
              print("StudentDocumentsView: onAddDocument called for type: \(docType.rawValue)")
              selectedDocumentType = docType
              documentPickerDocumentType = docType
              print(
                "StudentDocumentsView: selectedDocumentType set to: \(selectedDocumentType?.rawValue ?? "nil")"
              )
              print(
                "StudentDocumentsView: documentPickerDocumentType set to: \(documentPickerDocumentType?.rawValue ?? "nil")"
              )
              showingDocumentPicker = true
              print("StudentDocumentsView: showingDocumentPicker set to: \(showingDocumentPicker)")
            },
            onUploadPhoto: {
              selectedDocumentType = docType
              showingPhotoLibrary = true
            },
            onTakePhoto: {
              selectedDocumentType = docType
              showingCamera = true
            },
            onViewDocument: { doc in
              print("StudentDocumentsView: onViewDocument called with document: \(doc.filename)")
              selectedDocumentForViewing = doc
              print(
                "StudentDocumentsView: selectedDocumentForViewing set to: \(selectedDocumentForViewing?.filename ?? "nil")"
              )
              showingDocumentDetail = true
              print("StudentDocumentsView: showingDocumentDetail set to: \(showingDocumentDetail)")
            },
            onDeleteDocument: { doc in
              deleteDocument(doc)
            }
          )
          .padding(.horizontal)
        }
      }
      .padding(.vertical)
    }
    .navigationTitle("Documents")
    .navigationBarTitleDisplayMode(.inline)
    .sheet(isPresented: $showingDocumentPicker) {
      if let docType = documentPickerDocumentType {
        DocumentPickerView(documentType: docType) { url in
          print("StudentDocumentsView: DocumentPickerView completion called with URL: \(url)")
          addDocument(type: docType, fileURL: url)
          showingDocumentPicker = false
        }
      } else {
        VStack {
          Text("No document type selected")
            .foregroundColor(.red)
          Text("documentPickerDocumentType is nil")
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
    }
    .sheet(isPresented: $showingDocumentDetail) {
      if let document = selectedDocumentForViewing {
        DocumentDetailView(document: document)
      } else {
        VStack {
          Text("No document selected")
            .foregroundColor(.red)
          Text("selectedDocumentForViewing is nil")
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
    }
    .sheet(isPresented: $showingCamera) {
      CameraView { image in
        capturedImage = image
        if let docType = selectedDocumentType {
          addDocumentFromImage(type: docType, image: image)
        }
      }
    }
    .sheet(isPresented: $showingPhotoLibrary) {
      PhotoLibraryView { image in
        capturedImage = image
        if let docType = selectedDocumentType {
          addDocumentFromImage(type: docType, image: image)
        }
      }
    }
    .onAppear {
      updateSortedDocuments()
    }
    .onChange(of: showingDocumentDetail) { _, isShowing in
      if isShowing {
        print(
          "StudentDocumentsView: showingDocumentDetail changed to true, selectedDocumentForViewing: \(selectedDocumentForViewing?.filename ?? "nil")"
        )
      }
    }
    .onChange(of: showingDocumentPicker) { _, isShowing in
      if isShowing {
        print(
          "StudentDocumentsView: showingDocumentPicker changed to true, selectedDocumentType: \(selectedDocumentType?.rawValue ?? "nil")"
        )
        print(
          "StudentDocumentsView: showingDocumentPicker changed to true, documentPickerDocumentType: \(documentPickerDocumentType?.rawValue ?? "nil")"
        )
      }
    }
  }

  private func updateSortedDocuments() {
    sortedDocuments = student.documents ?? []
  }

  private func getDocument(for type: DocumentType) -> StudentDocument? {
    return sortedDocuments.first { $0.documentType == type }
  }

  private func addDocument(type: DocumentType, fileURL: URL) {
    Task {
      do {
        let fileData = try Data(contentsOf: fileURL)
        let filename = fileURL.lastPathComponent

        // If document of this type already exists, update it
        if let existingDoc = getDocument(for: type) {
          existingDoc.fileData = fileData
          existingDoc.filename = filename
          existingDoc.uploadedAt = Date()
          existingDoc.lastModified = Date()
        } else {
          // Create new document
          let document = StudentDocument(
            documentType: type,
            filename: filename,
            fileData: fileData
          )

          modelContext.insert(document)
          document.student = student

          if student.documents == nil {
            student.documents = []
          }
          student.documents?.append(document)
        }

        student.lastModified = Date()
        try modelContext.save()
        updateSortedDocuments()

      } catch {
        print("Failed to add document: \(error)")
      }
    }
  }

  private func addDocumentFromImage(type: DocumentType, image: UIImage) {
    Task {
      do {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
          print("Failed to convert image to data")
          return
        }

        let filename = "\(type.rawValue)_\(Date().timeIntervalSince1970).jpg"

        // If document of this type already exists, update it
        if let existingDoc = getDocument(for: type) {
          existingDoc.fileData = imageData
          existingDoc.filename = filename
          existingDoc.uploadedAt = Date()
          existingDoc.lastModified = Date()
        } else {
          // Create new document
          let document = StudentDocument(
            documentType: type,
            filename: filename,
            fileData: imageData
          )

          modelContext.insert(document)
          document.student = student

          if student.documents == nil {
            student.documents = []
          }
          student.documents?.append(document)
        }

        student.lastModified = Date()
        try modelContext.save()
        updateSortedDocuments()

      } catch {
        print("Failed to add document from image: \(error)")
      }
    }
  }

  private func deleteDocument(_ document: StudentDocument) {
    if let index = student.documents?.firstIndex(where: { $0.id == document.id }) {
      student.documents?.remove(at: index)
    }

    modelContext.delete(document)

    do {
      try modelContext.save()
      updateSortedDocuments()
    } catch {
      print("Failed to delete document: \(error)")
    }
  }

}

#Preview {
  let student = Student(
    firstName: "John", lastName: "Doe", email: "john@example.com", telephone: "555-1234",
    homeAddress: "123 Main St", ftnNumber: "123456789")
  StudentDocumentsView(student: student)
    .modelContainer(for: [Student.self, StudentDocument.self], inMemory: true)
}
