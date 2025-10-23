//
//  ReceiveTemplatesView.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ReceiveTemplatesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingDocumentPicker = false
    @State private var showingCSVGenerator = false
    @State private var selectedFileURL: URL?
    @State private var importStatus = ""
    @State private var showingImportAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header info
                VStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.down.on.square")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                    
                    Text("Receive Lesson Lists")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Import lesson checklists from other Right Rudder users or create new lessons from CSV files")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                
                // Action buttons
                VStack(spacing: 16) {
                    Button(action: {
                        showingDocumentPicker = true
                    }) {
                        HStack {
                            Image(systemName: "doc.badge.plus")
                                .font(.title2)
                                .foregroundColor(.white)
                            VStack(alignment: .leading) {
                                Text("Import Lesson File")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("Select a Right Rudder lesson file or CSV file")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        showingCSVGenerator = true
                    }) {
                        HStack {
                            Image(systemName: "tablecells")
                                .font(.title2)
                                .foregroundColor(.white)
                            VStack(alignment: .leading) {
                                Text("Generate Lesson File")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("Create a CSV file for organizing new lessons")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                
                // Status message
                if !importStatus.isEmpty {
                    Text(importStatus)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Import Lessons")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $showingDocumentPicker,
            allowedContentTypes: [UTType.data, UTType.commaSeparatedText, UTType.plainText],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result: result)
        }
        .sheet(isPresented: $showingCSVGenerator) {
            CSVTemplateGeneratorView()
        }
        .alert("Import Status", isPresented: $showingImportAlert) {
            Button("OK") { }
        } message: {
            Text(importStatus)
        }
    }
    
    private func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { 
                importStatus = "No file selected"
                showingImportAlert = true
                return 
            }
            selectedFileURL = url
            
            Task {
                await importTemplate(from: url)
            }
        case .failure(let error):
            importStatus = "Failed to select file: \(error.localizedDescription)"
            showingImportAlert = true
        }
    }
    
    private func importTemplate(from url: URL) async {
        // Start accessing the security-scoped resource
        let success = url.startAccessingSecurityScopedResource()
        defer {
            if success {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            let data = try Data(contentsOf: url)
            
            // Try to parse as CSV first (more common format)
            let csvString = String(data: data, encoding: .utf8) ?? ""
            if csvString.contains(",") && csvString.contains("Title") {
                await importCSVTemplate(csvString: csvString)
            } else {
                // Try to parse as JSON template file
                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let _ = jsonObject["name"] as? String,
                   let _ = jsonObject["category"] as? String {
                    await importJSONTemplate(jsonObject: jsonObject)
                } else {
                    await MainActor.run {
                        importStatus = "Unsupported file format. Please use a CSV file or Right Rudder template file."
                        showingImportAlert = true
                    }
                }
            }
        } catch {
            await MainActor.run {
                if success {
                    importStatus = "Failed to import file: \(error.localizedDescription)"
                } else {
                    importStatus = "Failed to access file. Please try selecting the file again."
                }
                showingImportAlert = true
            }
        }
    }
    
    private func importCSVTemplate(csvString: String) async {
        let lines = csvString.components(separatedBy: .newlines)
        guard lines.count > 1 else {
            await MainActor.run {
                importStatus = "Invalid CSV format"
                showingImportAlert = true
            }
            return
        }
        
        // Parse CSV header
        let header = lines[0].components(separatedBy: ",")
        guard header.count >= 2 else {
            await MainActor.run {
                importStatus = "CSV must have at least 'Title' and 'Notes' columns"
                showingImportAlert = true
            }
            return
        }
        
        // Find column indices
        let titleIndex = header.firstIndex(of: "Title") ?? 0
        let notesIndex = header.firstIndex(of: "Notes") ?? 1
        
        // Parse items
        var items: [ChecklistItem] = []
        for (index, line) in lines.dropFirst().enumerated() {
            let columns = line.components(separatedBy: ",")
            if columns.count > max(titleIndex, notesIndex) {
                let title = columns[titleIndex].trimmingCharacters(in: .whitespacesAndNewlines)
                let notes = columns.count > notesIndex ? columns[notesIndex].trimmingCharacters(in: .whitespacesAndNewlines) : ""
                
                if !title.isEmpty {
                    let item = ChecklistItem(
                        title: title,
                        notes: notes.isEmpty ? nil : notes,
                        order: index
                    )
                    items.append(item)
                }
            }
        }
        
        await MainActor.run {
            // Create new template from CSV
            let templateName = "Imported Template \(Date().formatted(date: .abbreviated, time: .omitted))"
            let newTemplate = ChecklistTemplate(
                name: templateName,
                category: "Custom",
                phase: "Custom",
                templateIdentifier: "csv_imported_\(UUID().uuidString)",
                items: items
            )
            newTemplate.isUserCreated = true
            
            modelContext.insert(newTemplate)
            
            do {
                try modelContext.save()
                importStatus = "Successfully imported CSV template with \(items.count) items"
                showingImportAlert = true
            } catch {
                importStatus = "Failed to save CSV template: \(error.localizedDescription)"
                showingImportAlert = true
            }
        }
    }
    
    private func importJSONTemplate(jsonObject: [String: Any]) async {
        await MainActor.run {
            guard let name = jsonObject["name"] as? String,
                  let category = jsonObject["category"] as? String else {
                importStatus = "Invalid template format"
                showingImportAlert = true
                return
            }
            
            let phase = jsonObject["phase"] as? String
            let relevantData = jsonObject["relevantData"] as? String
            let templateIdentifier = "imported_\(UUID().uuidString)"
            
            // Parse items if they exist
            var items: [ChecklistItem] = []
            if let itemsArray = jsonObject["items"] as? [[String: Any]] {
                for (index, itemDict) in itemsArray.enumerated() {
                    if let title = itemDict["title"] as? String {
                        let notes = itemDict["notes"] as? String
                        let order = itemDict["order"] as? Int ?? index
                        let item = ChecklistItem(title: title, notes: notes, order: order)
                        items.append(item)
                    }
                }
            }
            
            // Create new template
            let newTemplate = ChecklistTemplate(
                name: name,
                category: category,
                phase: phase,
                relevantData: relevantData,
                templateIdentifier: templateIdentifier,
                items: items
            )
            newTemplate.isUserCreated = true
            
            modelContext.insert(newTemplate)
            
            do {
                try modelContext.save()
                importStatus = "Successfully imported '\(name)' template with \(items.count) items"
                showingImportAlert = true
            } catch {
                importStatus = "Failed to save template: \(error.localizedDescription)"
                showingImportAlert = true
            }
        }
    }
}

struct CSVTemplateGeneratorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var templateName = ""
    @State private var templateCategory = "Custom"
    @State private var templatePhase = "Custom"
    @State private var showingShareSheet = false
    @State private var generatedCSVURL: URL?
    
    let categories = ["PPL", "Instrument", "Commercial", "Custom"]
    let phases = ["Phase 1", "Phase 2", "Phase 3", "Phase 4", "Custom"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Template Information") {
                    TextField("Template Name", text: $templateName)
                    Picker("Category", selection: $templateCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    Picker("Phase", selection: $templatePhase) {
                        ForEach(phases, id: \.self) { phase in
                            Text(phase).tag(phase)
                        }
                    }
                }
                
                Section("CSV Format") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("The generated CSV will have the following format:")
                            .font(.subheadline)
                        
                        Text("Title,Notes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("1. Preflight Inspection,Complete aircraft inspection")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("2. Engine Start,Start engine following checklist")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("3. Taxi Procedures,Follow taxi procedures")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                Section {
                    Button("Generate CSV Template") {
                        generateCSVTemplate()
                    }
                    .disabled(templateName.isEmpty)
                }
            }
            .navigationTitle("CSV Template Generator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = generatedCSVURL {
                CSVShareSheet(items: [url])
            }
        }
    }
    
    private func generateCSVTemplate() {
        let csvContent = """
        Title,Notes
        1. Preflight Inspection,Complete aircraft inspection following checklist
        2. Engine Start,Start engine following proper procedures
        3. Taxi Procedures,Follow taxi procedures and communications
        4. Pre-Takeoff Checks,Complete pre-takeoff checklist
        5. Takeoff,Execute normal takeoff procedures
        6. Climb,Establish climb configuration and procedures
        7. Cruise,Maintain cruise flight procedures
        8. Descent,Execute descent procedures
        9. Approach,Follow approach procedures
        10. Landing,Execute landing procedures
        11. After Landing,Complete after landing procedures
        12. Post-Flight,Complete post-flight procedures
        """
        
        // Create temporary file
        let fileName = "\(templateName.replacingOccurrences(of: " ", with: "_"))_Template.csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
            generatedCSVURL = tempURL
            showingShareSheet = true
        } catch {
            print("Failed to create CSV file: \(error)")
        }
    }
}

struct CSVShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ReceiveTemplatesView()
        .modelContainer(for: [Student.self, StudentChecklist.self, StudentChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}
