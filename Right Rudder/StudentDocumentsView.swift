import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct StudentDocumentsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var student: Student
    
    @State private var showingDocumentPicker = false
    @State private var selectedDocumentType: DocumentType?
    @State private var showingCamera = false
    @State private var showingPhotoLibrary = false
    @State private var selectedDocumentForViewing: StudentDocument?
    @State private var showingDocumentDetail = false
    @State private var sortedDocuments: [StudentDocument] = []
    @State private var capturedImage: UIImage?
    
    init(student: Student) {
        self._student = State(initialValue: student)
    }
    
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
                            selectedDocumentType = docType
                            showingDocumentPicker = true
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
                            selectedDocumentForViewing = doc
                            showingDocumentDetail = true
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
            if let docType = selectedDocumentType {
                DocumentPickerView(documentType: docType) { url in
                    addDocument(type: docType, fileURL: url)
                    showingDocumentPicker = false
                }
            }
        }
        .sheet(isPresented: $showingDocumentDetail) {
            if let document = selectedDocumentForViewing {
                DocumentDetailView(document: document)
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

// Document Picker
struct DocumentPickerView: UIViewControllerRepresentable {
    let documentType: DocumentType
    let completion: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .image, .jpeg, .png, .heic], asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        picker.modalPresentationStyle = .formSheet
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let completion: (URL) -> Void
        
        init(completion: @escaping (URL) -> Void) {
            self.completion = completion
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                completion(url)
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            // Handle cancellation
        }
    }
}

struct DocumentTypeCard: View {
    let documentType: DocumentType
    let document: StudentDocument?
    let onAddDocument: () -> Void
    let onUploadPhoto: () -> Void
    let onTakePhoto: () -> Void
    let onViewDocument: (StudentDocument) -> Void
    let onDeleteDocument: (StudentDocument) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: documentType.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(documentType.rawValue)
                            .font(.headline)
                        
                        if documentType.isOptional {
                            Text("(Optional)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let doc = document {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Uploaded")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if let expirationDate = doc.expirationDate {
                                Text("• Expires: \(expirationDate.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption)
                                    .foregroundColor(isExpiringSoon(expirationDate) ? .red : .secondary)
                            }
                        }
                    } else {
                        HStack {
                            Image(systemName: "exclamationmark.circle")
                                .foregroundColor(documentType.isOptional ? .secondary : .orange)
                            Text("Not uploaded")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                if let doc = document {
                    Menu {
                        Button {
                            onViewDocument(doc)
                        } label: {
                            Label("View", systemImage: "eye")
                        }
                        
                        Button(role: .destructive) {
                            onDeleteDocument(doc)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                    }
                } else {
                    Menu {
                        Button {
                            onAddDocument()
                        } label: {
                            Label("Upload from Files", systemImage: "folder")
                        }
                        
                        Button {
                            onUploadPhoto()
                        } label: {
                            Label("Upload Photo", systemImage: "photo.on.rectangle")
                        }
                        
                        Button {
                            onTakePhoto()
                        } label: {
                            Label("Take Photo", systemImage: "camera")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
        }
        .padding()
        .background(Color.appMutedBox)
        .cornerRadius(12)
    }
    
    private func isExpiringSoon(_ date: Date) -> Bool {
        let daysUntilExpiration = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        return daysUntilExpiration <= 30
    }
}

struct DocumentDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let document: StudentDocument
    
    @State private var uiImage: UIImage?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Document preview
                    if let uiImage = uiImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12)
                    } else {
                        VStack {
                            Image(systemName: "doc.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            Text(document.filename)
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(Color.appMutedBox)
                        .cornerRadius(12)
                    }
                    
                    // Document info
                    VStack(alignment: .leading, spacing: 12) {
                        InfoField(label: "Type", value: document.documentType.rawValue)
                        InfoField(label: "Filename", value: document.filename)
                        InfoField(label: "Uploaded", value: document.uploadedAt.formatted(date: .long, time: .shortened))
                        
                        if let expirationDate = document.expirationDate {
                            InfoField(label: "Expiration Date", value: expirationDate.formatted(date: .long, time: .omitted))
                        }
                        
                        if let notes = document.notes, !notes.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Notes")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(notes)
                                    .font(.body)
                            }
                        }
                    }
                    .padding()
                    .background(Color.appMutedBox)
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Document Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        guard let fileData = document.fileData else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let image = UIImage(data: fileData)
            DispatchQueue.main.async {
                self.uiImage = image
            }
        }
    }
}

struct InfoField: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
        }
    }
}


#Preview {
    let student = Student(firstName: "John", lastName: "Doe", email: "john@example.com", telephone: "555-1234", homeAddress: "123 Main St", ftnNumber: "123456789")
    StudentDocumentsView(student: student)
        .modelContainer(for: [Student.self, StudentDocument.self], inMemory: true)
}

