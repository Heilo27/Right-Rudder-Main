// StudentRecordWebView.swift
// Right Rudder
//
// Created to resolve missing symbol.

import SwiftUI
import WebKit
import SwiftData
import PDFKit

struct StudentRecordWebView: View {
    let student: Student
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    @State private var showingShareSheet = false
    @State private var htmlContent = ""
    
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        
                        Text("Generating Student Record")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    WebViewRepresentable(htmlContent: htmlContent)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Student Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .buttonStyle(.noHaptic)
                    .font(.body)
                    .foregroundColor(.appPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.appAdaptiveMutedBox)
                    .cornerRadius(20)
                    .frame(minWidth: 80)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Share") {
                        showingShareSheet = true
                    }
                    .buttonStyle(.noHaptic)
                    .font(.body)
                    .foregroundColor(.appPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.appAdaptiveMutedBox)
                    .cornerRadius(20)
                    .frame(minWidth: 80)
                    .disabled(isLoading)
                }
            }
        }
        .onAppear {
            generateHTMLContentAsync()
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(htmlContent: htmlContent, studentName: student.displayName)
        }
    }
    
    private func generateHTMLContentAsync() {
        Task.detached(priority: .userInitiated) {
            // Create date formatter locally to avoid main actor isolation issues
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            let currentDate = dateFormatter.string(from: Date())
            
            // Generate HTML in chunks to avoid blocking
            let html = await self.generateHTMLContentOptimized(currentDate: currentDate)
            
            await MainActor.run {
                self.htmlContent = html
                self.isLoading = false
            }
        }
    }
    
    private func generateHTMLContentOptimized(currentDate: String) async -> String {
        // Ultra-minimal HTML for maximum speed
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <title>Student Record - \(student.displayName)</title>
            <style>
                body{font-family:-apple-system,sans-serif;margin:20px;background:#f8f9fa}
                .container{max-width:800px;margin:0 auto;background:white;padding:20px;border-radius:8px}
                .header{text-align:center;border-bottom:2px solid #007AFF;padding-bottom:15px;margin-bottom:20px}
                .header h1{color:#007AFF;margin:0;font-size:24px}
                .header p{color:#666;margin:5px 0 0 0;font-size:12px}
                .section{margin-bottom:20px}
                .section h2{color:#333;border-bottom:1px solid #007AFF;padding-bottom:5px;margin-bottom:10px;font-size:18px}
                .info-item{padding:8px;background:#f8f9fa;border-radius:4px;margin-bottom:8px;border-left:3px solid #007AFF}
                .info-label{font-weight:bold;color:#333;font-size:11px;text-transform:uppercase}
                .info-value{color:#555;margin-top:3px}
                .checklist{margin-bottom:15px;border:1px solid #ddd;border-radius:6px}
                .checklist-header{background:#007AFF;color:white;padding:10px;font-weight:bold;font-size:14px}
                .checklist-item{padding:8px 10px;border-bottom:1px solid #eee;display:flex;align-items:center;gap:8px}
                .checklist-item:last-child{border-bottom:none}
                .checklist-item.completed{background:#f0f8f0}
                .status-icon{font-size:16px;font-weight:bold}
                .status-completed{color:#28a745}
                .status-pending{color:#dc3545}
                .item-title{flex:1;font-weight:500}
                .completion-date{font-size:10px;color:#666;font-style:italic}
                .instructor-comments{background:#fff3cd;border:1px solid #ffeaa7;border-radius:4px;padding:8px;margin-top:8px;font-style:italic;font-size:12px}
                .endorsement-item{border:1px solid #ddd;border-radius:6px;padding:8px;background:white;width:100%;box-sizing:border-box}
                .endorsement-filename{font-size:11px;color:#666;text-align:center}
                .endorsement-photo{max-width:100px;max-height:100px;width:auto;height:auto;border-radius:4px;margin-bottom:8px}
                .document-item{border:1px solid #ddd;border-radius:6px;padding:10px;background:white;width:100%;box-sizing:border-box}
                .document-icon{font-size:20px;color:#007AFF}
                .document-info{flex:1}
                .document-type{font-weight:bold;color:#333;font-size:14px}
                .document-filename{font-size:12px;color:#666;margin-top:2px}
                .document-date{font-size:11px;color:#999;margin-top:2px}
                .document-photo{max-width:100%;height:auto;border-radius:4px;margin-bottom:8px}
                .footer{text-align:center;margin-top:30px;padding-top:15px;border-top:1px solid #ddd;color:#666;font-size:10px}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>Student Pilot Record</h1>
                    <p>Generated on \(currentDate)</p>
                </div>
        """
        
        // Generate all content in one ultra-fast string interpolation
        let biographySection = student.biography?.isEmpty == false ? """
                <div class="info-item">
                    <div class="info-label">Biography</div>
                    <div class="info-value">\(student.biography!)</div>
                </div>
        """ : ""
        
        let backgroundSection = student.backgroundNotes?.isEmpty == false ? """
                <div class="info-item">
                    <div class="info-label">Background Notes</div>
                    <div class="info-value">\(student.backgroundNotes!)</div>
                </div>
        """ : ""
        
        let checklistsSection = (student.checklistAssignments?.isEmpty ?? true) ? "" : generateChecklistsSection()
        
        let endorsementsSection = (student.endorsements?.isEmpty ?? true) ? "" : generateEndorsementsSection()
        
        let documentsSection = (student.documents?.isEmpty ?? true) ? "" : generateDocumentsSection()
        
        return html + """
                <div class="section">
                    <h2>Student Information</h2>
                    <div class="info-item">
                        <div class="info-label">Full Name</div>
                        <div class="info-value">\(student.displayName)</div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Telephone</div>
                        <div class="info-value">\(student.telephone)</div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">FTN Number</div>
                        <div class="info-value">\(student.ftnNumber)</div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Email Address</div>
                        <div class="info-value">\(student.email)</div>
                    </div>
                       <div class="info-item">
                           <div class="info-label">Home Address</div>
                           <div class="info-value">\(student.homeAddress)</div>
                       </div>
                       <div class="info-item">
                           <div class="info-label">Total Dual Given Hours</div>
                           <div class="info-value">\(String(format: "%.1f", student.totalDualGivenHours)) hours</div>
                       </div>
                       \(biographySection)
                       \(backgroundSection)
                </div>
                \(checklistsSection)
                \(endorsementsSection)
                \(documentsSection)
                <div class="footer">
                    <p>Generated by Right Rudder Flight Training Management System</p>
                    <p>Generated on \(currentDate)</p>
                </div>
            </div>
        </body>
        </html>
        """
    }
    
    private func generateChecklistsSection() -> String {
        // Sort assignment records by phase and lesson number for proper ordering
        let sortedAssignments = (student.checklistAssignments ?? []).sorted { assignment1, assignment2 in
            // First sort by phase (First Steps, Phase 1, Phase 1.5 Pre-Solo/Solo, Phase 2, etc.)
            let phase1 = extractPhase(assignment1.displayName)
            let phase2 = extractPhase(assignment2.displayName)
            
            if phase1 != phase2 {
                return phase1 < phase2
            }
            
            // Within the same phase, sort by lesson number
            let lesson1 = extractLessonNumber(assignment1.displayName)
            let lesson2 = extractLessonNumber(assignment2.displayName)
            
            return lesson1 < lesson2
        }
        
        let checklistHTML = sortedAssignments.map { assignment in
            let completedCount = assignment.completedItemsCount
            let totalCount = assignment.totalItemsCount
            let percentage = totalCount > 0 ? Int((Double(completedCount) / Double(totalCount)) * 100) : 0
            
            // Get display items for this assignment record
            let displayItems = ChecklistAssignmentService.getDisplayItems(for: assignment)
            let sortedItems = displayItems.sorted { $0.order < $1.order }
            let itemsHTML = sortedItems.map { item in
                let statusClass = item.isComplete ? "completed" : ""
                let statusIcon = item.isComplete ? "✓" : "○"
                let statusIconClass = item.isComplete ? "status-completed" : "status-pending"
                let completionDate = item.isComplete && item.completedAt != nil ? 
                    "<span class=\"completion-date\">Completed: \(DateFormatter.localizedString(from: item.completedAt!, dateStyle: .long, timeStyle: .short))</span>" : ""
                
                return """
                    <div class="checklist-item \(statusClass)">
                        <span class="status-icon \(statusIconClass)">\(statusIcon)</span>
                        <span class="item-title">\(removeNumberFromTitle(item.title))</span>
                        \(completionDate)
                    </div>
                """
            }.joined()
            
               let dualGivenHTML = assignment.dualGivenHours > 0 ? """
                   <div class="instructor-comments">
                       <strong>Dual Given Hours:</strong> \(String(format: "%.1f", assignment.dualGivenHours)) hours
                   </div>
               """ : ""
               
               let commentsHTML = assignment.instructorComments?.isEmpty == false ? """
                   <div class="instructor-comments">
                       <strong>Instructor Comments:</strong><br>
                       \(assignment.instructorComments!)
                   </div>
               """ : ""
            
            return """
                <div class="checklist">
                    <div class="checklist-header">\(assignment.displayName) (\(completedCount)/\(totalCount) - \(percentage)%)</div>
                    \(itemsHTML)
                    \(dualGivenHTML)
                    \(commentsHTML)
                </div>
            """
        }.joined()
        
        return """
            <div class="section">
                <h2>Training Checklists</h2>
                \(checklistHTML)
            </div>
        """
    }
    
    private func extractPhase(_ templateName: String) -> Int {
        // Define phase order: First Steps = 0, Phase 1 = 1, Phase 1.5 Pre-Solo/Solo = 2, Phase 2 = 3, etc.
        if templateName.contains("Student Onboard") || templateName.contains("First Steps") {
            return 0
        } else if templateName.contains("P1-") {
            return 1
        } else if templateName.contains("Pre-Solo") {
            return 2
        } else if templateName.contains("P2-") {
            return 3
        } else if templateName.contains("P3-") {
            return 4
        } else if templateName.contains("P4-") {
            return 5
        } else {
            return 99 // Other items go to the end
        }
    }
    
    private func extractLessonNumber(_ templateName: String) -> Int {
        // Extract lesson number from template name (e.g., "P1-L1" -> 1, "P1-L2" -> 2)
        let regex = try! NSRegularExpression(pattern: "L(\\d+)", options: [])
        let range = NSRange(location: 0, length: templateName.utf16.count)
        
        if let match = regex.firstMatch(in: templateName, options: [], range: range) {
            if let lessonRange = Range(match.range(at: 1), in: templateName) {
                let lessonString = String(templateName[lessonRange])
                return Int(lessonString) ?? 999
            }
        }
        
        // For non-lesson items, use alphabetical order
        return 999
    }
    
    private func generateEndorsementsSection() -> String {
        let endorsementsHTML = (student.endorsements ?? []).map { endorsement in
            // Check if this is a PDF file
            if let imageData = endorsement.imageData {
                if endorsement.filename.hasSuffix(".pdf") {
                    // For PDF files, generate a thumbnail and embed as image
                    if let thumbnailData = generatePDFThumbnail(from: imageData) {
                        let base64String = thumbnailData.base64EncodedString()
                        return """
                        <div class="endorsement-item" style="text-align:center;width:120px;margin:0 auto;">
                            <div style="width:100px;height:100px;overflow:hidden;border-radius:4px;margin:0 auto 8px auto;border:1px solid #ddd;">
                                <img src="data:image/png;base64,\(base64String)" style="width:100%;height:100%;object-fit:contain;" alt="\(endorsement.filename)">
                            </div>
                            <div class="endorsement-filename">\(getEndorsementDisplayName(for: endorsement))</div>
                        </div>
                        """
                    } else {
                        // Fallback if thumbnail generation fails
                        return """
                        <div class="endorsement-item">
                            <div style="width:100px;height:100px;background:#f0f0f0;border:1px solid #ddd;display:flex;align-items:center;justify-content:center;color:#666;margin:0 auto;">
                                PDF Document
                            </div>
                            <div class="endorsement-filename">\(getEndorsementDisplayName(for: endorsement))</div>
                        </div>
                        """
                    }
                } else {
                    // For regular image files
                    let base64String = imageData.base64EncodedString()
                    return """
                    <div class="endorsement-item">
                        <img src="data:image/jpeg;base64,\(base64String)" class="endorsement-photo" alt="\(endorsement.filename)">
                        <div class="endorsement-filename">\(getEndorsementDisplayName(for: endorsement))</div>
                    </div>
                    """
                }
            } else {
                return """
                <div class="endorsement-item">
                    <div class="endorsement-filename">\(getEndorsementDisplayName(for: endorsement)) (No data)</div>
                </div>
                """
            }
        }.joined()
        
        return """
            <div class="section">
                <h2>Endorsements & Documents</h2>
                <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:10px;">
                    \(endorsementsHTML)
                </div>
            </div>
        """
    }
    
    private func generatePDFThumbnail(from pdfData: Data) -> Data? {
        print("🔍 Generating PDF thumbnail, data size: \(pdfData.count) bytes")
        
        guard let pdfDocument = PDFDocument(data: pdfData) else {
            print("⚠️ Failed to create PDFDocument from data")
            return nil
        }
        
        guard let page = pdfDocument.page(at: 0) else {
            print("⚠️ Failed to get first page of PDF")
            return nil
        }
        
        let thumbnailSize = CGSize(width: 300, height: 300)
        let thumbnail = page.thumbnail(of: thumbnailSize, for: .mediaBox)
        
        guard let pngData = thumbnail.pngData() else {
            print("⚠️ Failed to convert thumbnail to PNG data")
            return nil
        }
        
        print("✅ Generated PDF thumbnail, PNG size: \(pngData.count) bytes")
        return pngData
    }
    
    private func getEndorsementDisplayName(for endorsement: EndorsementImage) -> String {
        if let code = endorsement.endorsementCode {
            switch code {
            case "A.1":
                return "Authorization to Take Practical Test"
            case "A.2":
                return "Authorization for Solo Flight"
            case "A.3":
                return "Aeronautical Knowledge"
            case "A.4":
                return "Pre-Solo Training to Proficiency"
            case "A.5":
                return "Solo Flight Training"
            case "A.6":
                return "Solo Cross-Country Flight Training"
            case "A.7":
                return "Solo Flight in Complex Airplane"
            case "A.8":
                return "Instrument Proficiency Check"
            case "A.9":
                return "Instrument Training"
            case "A.10":
                return "Instrument Experience"
            case "A.11":
                return "Instrument Recency"
            case "A.12":
                return "Instrument Approach Procedures"
            case "A.13":
                return "Instrument Training for Private Pilot"
            case "A.14":
                return "Instrument Training for Commercial Pilot"
            case "A.15":
                return "Instrument Training for Airline Transport Pilot"
            case "A.16":
                return "Instrument Training for Flight Instructor"
            case "A.17":
                return "Instrument Training for Ground Instructor"
            case "A.18":
                return "Instrument Training for Instrument Instructor"
            case "A.19":
                return "Instrument Training for Multi-Engine Instructor"
            case "A.20":
                return "Instrument Training for Sport Pilot"
            case "A.21":
                return "Instrument Training for Recreational Pilot"
            case "A.22":
                return "Instrument Training for Glider Pilot"
            case "A.23":
                return "Instrument Training for Lighter-Than-Air Pilot"
            case "A.24":
                return "Instrument Training for Powered-Lift Pilot"
            case "A.25":
                return "Instrument Training for Rotorcraft Pilot"
            case "A.26":
                return "Instrument Training for Powered Parachute Pilot"
            case "A.27":
                return "Instrument Training for Weight-Shift-Control Pilot"
            case "A.28":
                return "Instrument Training for Balloon Pilot"
            case "A.29":
                return "Instrument Training for Airship Pilot"
            case "A.30":
                return "Instrument Training for Powered-Lift Pilot"
            default:
                return code
            }
        }
        return endorsement.filename
    }
    
    private func generateDocumentsSection() -> String {
        let documentsHTML = (student.documents ?? []).map { document in
            let icon = getDocumentIcon(for: document.documentType)
            let uploadDate = document.uploadedAt.formatted(date: .abbreviated, time: .omitted)
            let expirationInfo = document.expirationDate != nil ? 
                "<div class=\"document-date\">Expires: \(document.expirationDate!.formatted(date: .abbreviated, time: .omitted))</div>" : ""
            
            // Use optimized image display instead of base64 embedding
            let imageHTML: String
            if document.fileData != nil {
                // Create a placeholder that doesn't load the full image into memory
                imageHTML = "<div style=\"text-align:center;color:#666;font-style:italic;margin:20px 0;padding:40px;border:2px dashed #ccc;border-radius:8px;\">📄 Document: \(document.filename)<br><small>Click to view full document</small></div>"
            } else {
                imageHTML = "<div style=\"text-align:center;color:#666;font-style:italic;margin:20px 0;\">No image data available</div>"
            }
            
            return """
            <div class="document-item">
                <div class="document-icon">\(icon)</div>
                <div class="document-info">
                    <div class="document-type">\(document.documentType.rawValue)</div>
                    <div class="document-filename">\(document.filename)</div>
                    <div class="document-date">Uploaded: \(uploadDate)</div>
                    \(expirationInfo)
                </div>
                <div class="document-photo">
                    \(imageHTML)
                </div>
            </div>
            """
        }.joined()
        
        return """
            <div class="section">
                <h2>Required Documents</h2>
                <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:10px;">
                    \(documentsHTML)
                </div>
            </div>
        """
    }
    
    private func getDocumentIcon(for documentType: DocumentType) -> String {
        switch documentType {
        case .studentPilotCertificate:
            return "✈️"
        case .medicalCertificate:
            return "🏥"
        case .passportBirthCertificate:
            return "📄"
        case .logBook:
            return "📖"
        }
    }
    
}

struct WebViewRepresentable: UIViewRepresentable {
    let htmlContent: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Web view finished loading
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let htmlContent: String
    let studentName: String
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        // Share HTML content directly as string for maximum speed
        let activityViewController = UIActivityViewController(
            activityItems: [htmlContent],
            applicationActivities: nil
        )
        
        // Set the subject for email sharing
        activityViewController.setValue("Student Pilot Record - \(studentName)", forKey: "subject")
        
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}

#Preview {
    let student = Student(firstName: "John", lastName: "Doe", email: "john@example.com", telephone: "555-1234", homeAddress: "123 Main St", ftnNumber: "123456789")
    StudentRecordWebView(student: student)
        .modelContainer(for: [Student.self, ChecklistAssignment.self, ItemProgress.self, CustomChecklistDefinition.self, CustomChecklistItem.self, EndorsementImage.self, ChecklistTemplate.self, ChecklistItem.self], inMemory: true)
}

// MARK: - Helper Functions
extension StudentRecordWebView {
    private func extractNumberFromTitle(_ title: String) -> Int {
        let pattern = "^\\d+\\."
        if let range = title.range(of: pattern, options: .regularExpression) {
            let numberString = String(title[range]).replacingOccurrences(of: ".", with: "")
            return Int(numberString) ?? 999
        }
        return 999
    }
    
    private func removeNumberFromTitle(_ title: String) -> String {
        let pattern = "^\\d+\\.\\s*"
        return title.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
    }
}

