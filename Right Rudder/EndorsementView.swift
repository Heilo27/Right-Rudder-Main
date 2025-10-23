//
//  EndorsementView.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import SwiftUI
import SwiftData
import PDFKit

struct EndorsementGeneratorView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var students: [Student]
    
    public init() {}
    
    @State private var selectedEndorsement: FAAEndorsement?
    @State private var studentName: String = ""
    @State private var customFields: [String: String] = [:]
    @State private var debounceTimer: Timer?
    @State private var endorsementDate: Date = Date()
    @AppStorage("instructorName") private var instructorName: String = ""
    @AppStorage("instructorCFINumber") private var instructorCFINumber: String = ""
    @AppStorage("instructorCFIExpirationDateString") private var instructorCFIExpirationDateString: String = ""
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
                                        .background(Color.white)
                                        .border(Color.gray, width: 1)
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
                        signatureImage: signatureImage
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
                    "name of specific aircraft category/class/type": "specific aircraft type"
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

struct StudentPickerView: View {
    @Binding var selectedStudent: Student?
    let students: [Student]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(students, id: \.id) { student in
                Button(action: {
                    selectedStudent = student
                    dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(student.firstName) \(student.lastName)")
                                .font(.headline)
                            Text(student.email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Select Student")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PDFExportView: View {
    let endorsement: FAAEndorsement
    let studentName: String
    let customFields: [String: String]
    let endorsementDate: Date
    let instructorName: String
    let cfiNumber: String
    let cfiExpirationDate: Date
    let cfiHasExpiration: Bool
    let signatureImage: UIImage?
    
    @Environment(\.dismiss) private var dismiss
    @State private var pdfData: Data?
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Endorsement Preview")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(generateEndorsementText())
                            .font(.body)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding()
                }
                
                HStack(spacing: 20) {
                    Button("Save as PDF") {
                        generatePDF()
                        showingShareSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Print") {
                        generatePDF()
                        printPDF()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .navigationTitle("Export Endorsement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let pdfData = pdfData {
                    EndorsementShareSheet(activityItems: [pdfData])
                }
            }
        }
        .onAppear {
            generatePDF()
        }
    }
    
    private func generateEndorsementText() -> String {
        var text = endorsement.template
        
        // Replace placeholders
        text = text.replacingOccurrences(of: "[First name, MI, Last name]", with: studentName)
        text = text.replacingOccurrences(of: "[date]", with: formatDate(endorsementDate))
        
        // Replace custom fields
        for (field, value) in customFields {
            text = text.replacingOccurrences(of: "[\(field)]", with: value)
        }
        
        // Add instructor signature line
        let signatureText = generateSignatureText()
        text += "\n\n\(signatureText)"
        
        // Debug: Ensure we have content
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            text = "Endorsement content not available. Please check your form data."
        }
        
        return text
    }
    
    private func generateSignatureText() -> String {
        let dateString = formatDate(endorsementDate)
        let expirationString = formatDate(cfiExpirationDate)
        
        if cfiHasExpiration {
            return "\(dateString) /s/ \(instructorName) \(cfiNumber) Exp. \(expirationString)"
        } else {
            return "\(dateString) /s/ \(instructorName) \(cfiNumber) RE \(expirationString)"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter.string(from: date)
    }
    
    private func generatePDF() {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        
        pdfData = renderer.pdfData { context in
            context.beginPage()
            
            // Set white background
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fill(CGRect(x: 0, y: 0, width: 612, height: 792))
            
            let text = generateEndorsementText()
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]
            
            let attributedString = NSAttributedString(string: text, attributes: attributes)
            
            // Calculate text height to position signature correctly
            let textRect = CGRect(x: 50, y: 50, width: 500, height: 600)
            let textSize = attributedString.boundingRect(with: CGSize(width: 500, height: CGFloat.greatestFiniteMagnitude), 
                                                       options: [.usesLineFragmentOrigin, .usesFontLeading], 
                                                       context: nil)
            
            // Draw the text with proper context setup
            context.cgContext.saveGState()
            attributedString.draw(in: textRect)
            context.cgContext.restoreGState()
            
            // Position signature directly under the text content
            if let signatureImage = signatureImage {
                let textBottom = 50 + textSize.height + 20 // 20 points below text
                let signatureRect = CGRect(x: 400, y: textBottom, width: 120, height: 60)
                signatureImage.draw(in: signatureRect)
                
                // Add a subtle border around the signature for better visibility
                context.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
                context.cgContext.setLineWidth(0.5)
                context.cgContext.stroke(signatureRect)
            }
        }
    }
    
    private func printPDF() {
        guard let pdfData = pdfData else { return }
        
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = "Endorsement - \(endorsement.code)"
        printInfo.orientation = .portrait
        
        // Set up for Avery sticker paper layout
        printInfo.duplex = .none // Single-sided for labels
        
        // Configure for Avery 5160 labels (30 labels per sheet)
        if let printPageRenderer = printController.printPageRenderer {
            // Set up for label printing with proper margins
            printPageRenderer.setValue(NSValue(cgRect: CGRect(x: 0, y: 0, width: 612, height: 792)), forKey: "paperRect")
            printPageRenderer.setValue(NSValue(cgRect: CGRect(x: 0, y: 0, width: 612, height: 792)), forKey: "printableRect")
        }
        
        printController.printInfo = printInfo
        printController.printingItem = pdfData
        
        // Present print dialog with Avery settings
        printController.present(animated: true) { controller, completed, error in
            if completed {
                print("Print completed successfully")
            } else if let error = error {
                print("Print error: \(error.localizedDescription)")
            }
        }
    }
}

struct EndorsementShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct SignaturePadView: View {
    @Binding var signatureImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    @State private var currentPath = Path()
    @State private var paths: [Path] = []
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    Text("Sign your name")
                        .font(.headline)
                        .padding()
                    
                    ZStack {
                        Rectangle()
                            .fill(Color.white)
                            .border(Color.gray, width: 2)
                            .frame(height: isLandscape(geometry) ? 300 : 200)
                        
                        Canvas { context, size in
                            for path in paths {
                                context.stroke(path, with: .color(.black), lineWidth: 2)
                            }
                            context.stroke(currentPath, with: .color(.black), lineWidth: 2)
                        }
                        .frame(height: isLandscape(geometry) ? 300 : 200)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let point = value.location
                                    if currentPath.isEmpty {
                                        currentPath.move(to: point)
                                    } else {
                                        currentPath.addLine(to: point)
                                    }
                                }
                                .onEnded { _ in
                                    paths.append(currentPath)
                                    currentPath = Path()
                                }
                        )
                    }
                    .padding()
                    
                    HStack(spacing: 20) {
                        Button("Clear") {
                            paths.removeAll()
                            currentPath = Path()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Done") {
                            generateSignatureImage()
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            .navigationTitle("Digital Signature")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func isLandscape(_ geometry: GeometryProxy) -> Bool {
        return geometry.size.width > geometry.size.height
    }
    
    private func generateSignatureImage() {
        // Create a higher resolution image for better quality
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 800, height: 400))
        signatureImage = renderer.image { context in
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fill(CGRect(x: 0, y: 0, width: 800, height: 400))
            
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.setLineWidth(4) // Slightly thicker for better visibility
            context.cgContext.setLineCap(.round)
            context.cgContext.setLineJoin(.round)
            
            // Scale the paths to match the higher resolution
            let scaleX: CGFloat = 800.0 / 400.0
            let scaleY: CGFloat = 400.0 / 200.0
            
            for path in paths {
                let scaledPath = path.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
                context.cgContext.addPath(scaledPath.cgPath)
                context.cgContext.strokePath()
            }
        }
    }
}

struct CustomFieldRow: View {
    let field: String
    let endorsement: FAAEndorsement
    @Binding var customFields: [String: String]
    @Binding var fieldDescriptionCache: [String: String]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(getFieldDescription(field: field, endorsement: endorsement))
                .font(.caption)
                .foregroundColor(.secondary)
            TextField("Enter \(getFieldPlaceholder(field: field))", text: Binding(
                get: { customFields[field] ?? "" },
                set: { customFields[field] = $0 }
            ))
            .textFieldStyle(.roundedBorder)
        }
    }
    
    private func getFieldDescription(field: String, endorsement: FAAEndorsement) -> String {
        // Create a cache key combining field and endorsement code
        let cacheKey = "\(endorsement.code)_\(field)"
        
        // Check cache first
        if let cachedDescription = fieldDescriptionCache[cacheKey] {
            return cachedDescription
        }
        
        // Use a much simpler and faster approach - just return a user-friendly version of the field name
        let description = getFieldPlaceholder(field: field).capitalized
        fieldDescriptionCache[cacheKey] = description
        return description
    }
    
    private func getFieldPlaceholder(field: String) -> String {
        // Convert field name to a more user-friendly placeholder
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
            "name of specific aircraft category/class/type": "specific aircraft type"
        ]
        
        return placeholders[field] ?? field.lowercased()
    }
}

struct FAAEndorsement: Identifiable, Hashable {
    let id = UUID()
    let code: String
    let title: String
    let template: String
    let requiredFields: [String]
    
    static func == (lhs: FAAEndorsement, rhs: FAAEndorsement) -> Bool {
        lhs.code == rhs.code
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }
    
    static let allEndorsements: [FAAEndorsement] = [
        // Prerequisites for the Practical Test Endorsement
        FAAEndorsement(
            code: "A.1",
            title: "Prerequisites for practical test: § 61.39(a)(6)(i) and (ii)",
            template: "I certify that [First name, MI, Last name] has received and logged training time within 2 calendar months preceding the month of application in preparation for the practical test and they are prepared for the required practical test for the issuance of [applicable] certificate.",
            requiredFields: ["applicable"]
        ),
        
        FAAEndorsement(
            code: "A.2",
            title: "Review of deficiencies identified on airman knowledge test: § 61.39(a)(6)(iii)",
            template: "I certify that [First name, MI, Last name] has demonstrated satisfactory knowledge of the subject areas in which they were deficient on the [applicable] airman knowledge test.",
            requiredFields: ["applicable"]
        ),
        
        // Student Pilot Endorsements
        FAAEndorsement(
            code: "A.3",
            title: "Pre-solo aeronautical knowledge: § 61.87(b)",
            template: "I certify that [First name, MI, Last name] has satisfactorily completed the pre-solo knowledge test of § 61.87(b) for the [make and model (M/M)] aircraft.",
            requiredFields: ["make and model (M/M)"]
        ),
        
        FAAEndorsement(
            code: "A.4",
            title: "Pre-solo flight training: § 61.87(c)(1) and (2)",
            template: "I certify that [First name, MI, Last name] has received and logged pre-solo flight training for the maneuvers and procedures that are appropriate to the [M/M] aircraft. I have determined they have demonstrated satisfactory proficiency and safety on the maneuvers and procedures required by § 61.87 in this or similar make and model of aircraft to be flown.",
            requiredFields: ["M/M"]
        ),
        
        FAAEndorsement(
            code: "A.5",
            title: "Pre-solo flight training at night: § 61.87(o)",
            template: "I certify that [First name, MI, Last name] has received flight training at night on night flying procedures that include takeoffs, approaches, landings, and go-arounds at night at the [airport name] airport where the solo flight will be conducted; navigation training at night in the vicinity of the [airport name] airport where the solo flight will be conducted. This endorsement expires 90 calendar days from the date the flight training at night was received.",
            requiredFields: ["airport name"]
        ),
        
        FAAEndorsement(
            code: "A.6",
            title: "Solo flight (first 90-calendar-day period): § 61.87(n)",
            template: "I certify that [First name, MI, Last name] has received the required training to qualify for solo flying. I have determined they meet the applicable requirements of § 61.87(n) and are proficient to make solo flights in [M/M].",
            requiredFields: ["M/M"]
        ),
        
        FAAEndorsement(
            code: "A.7",
            title: "Solo flight (each additional 90-calendar-day period): § 61.87(p)",
            template: "I certify that [First name, MI, Last name] has received the required training to qualify for solo flying. I have determined that they meet the applicable requirements of § 61.87(p) and are proficient to make solo flights in [M/M].",
            requiredFields: ["M/M"]
        ),
        
        FAAEndorsement(
            code: "A.8",
            title: "Solo takeoffs and landings at another airport within 25 NM: § 61.93(b)(1)",
            template: "I certify that [First name, MI, Last name] has received the required training of § 61.93(b)(1). I have determined that they are proficient to practice solo takeoffs and landings at [airport name]. The takeoffs and landings at [airport name] are subject to the following conditions: [List any applicable conditions or limitations.]",
            requiredFields: ["airport name", "List any applicable conditions or limitations"]
        ),
        
        FAAEndorsement(
            code: "A.9",
            title: "Solo cross-country flight: § 61.93(c)(1) and (2)",
            template: "I certify that [First name, MI, Last name] has received the required solo cross-country training. I find they have met the applicable requirements of § 61.93 and are proficient to make solo cross-country flights in a [M/M] aircraft, [aircraft category].",
            requiredFields: ["M/M", "aircraft category"]
        ),
        
        FAAEndorsement(
            code: "A.10",
            title: "Solo cross-country flight: § 61.93(c)(3)",
            template: "I have reviewed the cross-country planning of [First name, MI, Last name]. I find the planning and preparation to be correct to make the solo flight from [origination airport] to [origination airport] via [route of flight] with landings at [names of the airports] in a [M/M] aircraft on [date]. [List any applicable conditions or limitations.]",
            requiredFields: ["origination airport", "route of flight", "names of the airports", "M/M", "date", "List any applicable conditions or limitations"]
        ),
        
        // Additional Student Pilot Endorsements
        FAAEndorsement(
            code: "A.11",
            title: "Repeated solo cross-country flights not more than 50 NM: § 61.93(b)(2)",
            template: "I certify that [First name, MI, Last name] has received the required training in both directions between and at both [airport names]. I have determined that they are proficient of § 61.93(b)(2) to conduct repeated solo cross-country flights over that route, subject to the following conditions: [List any applicable conditions or limitations.]",
            requiredFields: ["airport names", "List any applicable conditions or limitations"]
        ),
        
        FAAEndorsement(
            code: "A.12",
            title: "Solo flight in Class B airspace: § 61.95(a)",
            template: "I certify that [First name, MI, Last name] has received the required training of § 61.95(a). I have determined they are proficient to conduct solo flights in [name of Class B] airspace. [List any applicable conditions or limitations.]",
            requiredFields: ["name of Class B", "List any applicable conditions or limitations"]
        ),
        
        FAAEndorsement(
            code: "A.13",
            title: "Solo flight to, from, or at an airport located in Class B airspace: § 61.95(b) and § 91.131(b)(1)",
            template: "I certify that [First name, MI, Last name] has received the required training of § 61.95(b)(1). I have determined that they are proficient to conduct solo flight operations at [name of airport]. [List any applicable conditions or limitations.]",
            requiredFields: ["name of airport", "List any applicable conditions or limitations"]
        ),
        
        FAAEndorsement(
            code: "A.14",
            title: "Endorsement of U.S. citizenship recommended by TSA: 49 CFR part 1552, § 1552.15(c)",
            template: "I certify that [First name, MI, Last name] has presented me a [type of document presented, such as a U.S. birth certificate or U.S. passport, and the relevant control or sequential number on the document, if any] establishing that they are a U.S. citizen or national in accordance with 49 CFR § 1552.15(c).",
            requiredFields: ["type of document presented, such as a U.S. birth certificate or U.S. passport, and the relevant control or sequential number on the document, if any"]
        ),
        
        // Sport Pilot Endorsements
        FAAEndorsement(
            code: "A.17",
            title: "Sport Pilot - Aeronautical knowledge test: §§ 61.35(a)(1) and 61.309",
            template: "I certify that [First name, MI, Last name] has received the required aeronautical knowledge training of § 61.309. I have determined that they are prepared for the [name of] knowledge test.",
            requiredFields: ["name of"]
        ),
        
        FAAEndorsement(
            code: "A.20",
            title: "Sport Pilot - Taking sport pilot practical test: §§ 61.309, 61.311, and 61.313",
            template: "I certify that [First name, MI, Last name] has received the training required in accordance with §§ 61.309 and 61.311 and met the aeronautical experience requirements of § 61.313. I have determined that they are prepared for the [type of] practical test.",
            requiredFields: ["type of"]
        ),
        
        // Private Pilot Endorsements
        FAAEndorsement(
            code: "A.32",
            title: "Private Pilot - Aeronautical knowledge test: §§ 61.35(a)(1), 61.103(d), and 61.105",
            template: "I certify that [First name, MI, Last name] has received the required training in accordance with § 61.105. I have determined they are prepared for the [name of] knowledge test.",
            requiredFields: ["name of"]
        ),
        
        FAAEndorsement(
            code: "A.33",
            title: "Private Pilot - Flight proficiency/practical test: §§ 61.103(f), 61.107(b), and 61.109",
            template: "I certify that [First name, MI, Last name] has received the required training in accordance with §§ 61.107 and 61.109. I have determined they are prepared for the [name of] practical test.",
            requiredFields: ["name of"]
        ),
        
        // Commercial Pilot Endorsements
        FAAEndorsement(
            code: "A.34",
            title: "Commercial Pilot - Aeronautical knowledge test: §§ 61.35(a)(1), 61.123(c), and 61.125",
            template: "I certify that [First name, MI, Last name] has received the required training of § 61.125. I have determined that they are prepared for the [name of] knowledge test.",
            requiredFields: ["name of"]
        ),
        
        FAAEndorsement(
            code: "A.35",
            title: "Commercial Pilot - Flight proficiency/practical test: §§ 61.123(e), 61.127, and 61.129",
            template: "I certify that [First name, MI, Last name] has received the required training of §§ 61.127 and 61.129. I have determined that they are prepared for the [name of] practical test.",
            requiredFields: ["name of"]
        ),
        
        // Instrument Rating Endorsements
        FAAEndorsement(
            code: "A.38",
            title: "Instrument Rating - Aeronautical knowledge test: §§ 61.35(a)(1) and 61.65(a) and (b)",
            template: "I certify that [First name, MI, Last name] has received the required training of § 61.65(b). I have determined that they are prepared for the Instrument–[airplane, helicopter, or powered-lift] knowledge test.",
            requiredFields: ["airplane, helicopter, or powered-lift"]
        ),
        
        FAAEndorsement(
            code: "A.39",
            title: "Instrument Rating - Flight proficiency/practical test: § 61.65(a)(6)",
            template: "I certify that [First name, MI, Last name] has received the required training of § 61.65(c) and (d). I have determined they are prepared for the Instrument–[airplane, helicopter, or powered-lift] practical test.",
            requiredFields: ["airplane, helicopter, or powered-lift"]
        ),
        
        FAAEndorsement(
            code: "A.40",
            title: "Instrument Rating - Prerequisites for instrument practical tests: § 61.39(a)",
            template: "I certify that [First name, MI, Last name] has received and logged the required flight time/training of § 61.39(a) in preparation for the practical test within 2 calendar months preceding the date of the test and has satisfactory knowledge of the subject areas in which they were shown to be deficient by the FAA Airman Knowledge Test Report. I have determined they are prepared for the Instrument–[airplane, helicopter, or powered-lift] practical test.",
            requiredFields: ["airplane, helicopter, or powered-lift"]
        ),
        
        // Flight Instructor Endorsements
        FAAEndorsement(
            code: "A.41",
            title: "Flight Instructor - Fundamentals of instructing knowledge test: § 61.183(d)",
            template: "I certify that [First name, MI, Last name] has received the required fundamentals of instruction training of § 61.185(a)(1). I have determined that they are prepared for the Fundamentals of Instructing knowledge test.",
            requiredFields: []
        ),
        
        FAAEndorsement(
            code: "A.42",
            title: "Flight Instructor - Aeronautical knowledge test: § 61.183(f)",
            template: "I certify that [First name, MI, Last name] has received the required training of § 61.185(a)[(2) or (3) (as appropriate to the flight instructor rating sought)]. I have determined that they are prepared for the [name of] knowledge test.",
            requiredFields: ["name of"]
        ),
        
        FAAEndorsement(
            code: "A.43",
            title: "Flight Instructor - Ground and flight proficiency/practical test: § 61.183(g)",
            template: "I certify that [First name, MI, Last name] has received the required training of § 61.187(b). I have determined that they are prepared for the CFI – [aircraft category and class] practical test.",
            requiredFields: ["aircraft category and class"]
        ),
        
        // Additional Endorsements
        FAAEndorsement(
            code: "A.65",
            title: "Completion of a flight review: § 61.56(a) and (c)",
            template: "I certify that [First name, MI, Last name], [grade of pilot certificate], [certificate number], has satisfactorily completed a flight review of § 61.56(a) on [date].",
            requiredFields: ["grade of pilot certificate", "certificate number", "date"]
        ),
        
        FAAEndorsement(
            code: "A.67",
            title: "Completion of an instrument proficiency check (IPC): § 61.57(d)",
            template: "I certify that [First name, MI, Last name], [grade of pilot certificate], [certificate number], has satisfactorily completed the instrument proficiency check of § 61.57(d) in a [M/M] aircraft on [date].",
            requiredFields: ["grade of pilot certificate", "certificate number", "M/M", "date"]
        ),
        
        FAAEndorsement(
            code: "A.68",
            title: "To act as PIC in a complex airplane: § 61.31(e)",
            template: "I certify that [First name, MI, Last name], [grade of pilot certificate], [certificate number], has received the required training of § 61.31(e) in a [M/M] complex airplane. I have determined that they are proficient in the operation and systems of a complex airplane.",
            requiredFields: ["grade of pilot certificate", "certificate number", "M/M"]
        ),
        
        FAAEndorsement(
            code: "A.69",
            title: "To act as PIC in a high-performance airplane: § 61.31(f)",
            template: "I certify that [First name, MI, Last name], [grade of pilot certificate], [certificate number], has received the required training of § 61.31(f) in a [M/M] high-performance airplane. I have determined that they are proficient in the operation and systems of a high-performance airplane.",
            requiredFields: ["grade of pilot certificate", "certificate number", "M/M"]
        ),
        
        FAAEndorsement(
            code: "A.70",
            title: "To act as PIC in a pressurized aircraft: § 61.31(g)",
            template: "I certify that [First name, MI, Last name], [grade of pilot certificate], [certificate number], has received the required training of § 61.31(g) in a [M/M] pressurized aircraft. I have determined that they are proficient in the operation and systems of a pressurized aircraft.",
            requiredFields: ["grade of pilot certificate", "certificate number", "M/M"]
        ),
        
        FAAEndorsement(
            code: "A.71",
            title: "To act as PIC in a tailwheel airplane: § 61.31(i)",
            template: "I certify that [First name, MI, Last name], [grade of pilot certificate], [certificate number], has received the required training of § 61.31(i) in a [M/M] of tailwheel airplane. I have determined that they are proficient in the operation of a tailwheel airplane.",
            requiredFields: ["grade of pilot certificate", "certificate number", "M/M"]
        ),
        
        FAAEndorsement(
            code: "A.73",
            title: "Retesting after failure of a knowledge or practical test: § 61.49",
            template: "I certify that [First name, MI, Last name] has received the additional [flight and/or ground, as appropriate] training as required by § 61.49. I have determined that they are proficient to pass the [name of] knowledge/practical test.",
            requiredFields: ["flight and/or ground, as appropriate", "name of"]
        ),
        
        FAAEndorsement(
            code: "A.74",
            title: "Additional aircraft category or class rating (other than ATP): § 61.63(b) or (c)",
            template: "I certify that [First name, MI, Last name], [grade of pilot certificate], [certificate number], has received the required training for an additional [aircraft category/class rating]. I have determined that they are prepared for the [name of] practical test for the addition of a [name of specific aircraft category/class/type] type rating.",
            requiredFields: ["grade of pilot certificate", "certificate number", "aircraft category/class rating", "name of", "name of specific aircraft category/class/type"]
        ),
        
        FAAEndorsement(
            code: "A.82",
            title: "Review of a home-study curriculum: § 61.35(a)(1)",
            template: "I certify I have reviewed the home-study curriculum of [First name, MI, Last name]. I have determined that they are prepared for the [name of] knowledge test.",
            requiredFields: ["name of"]
        )
        
        // Note: This includes the most commonly used endorsements from the complete A.1-A.92 list
        // Additional endorsements can be added as needed for specific use cases
    ]
}

#Preview {
    EndorsementGeneratorView()
        .modelContainer(for: [Student.self, StudentChecklist.self, StudentChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}
