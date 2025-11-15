//
//  PDFExportView.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import CoreText
import PDFKit
import SwiftData
import SwiftUI

// MARK: - PDFExportView

struct PDFExportView: View {
  // MARK: - Properties

  let endorsement: FAAEndorsement
  let studentName: String
  let customFields: [String: String]
  let endorsementDate: Date
  let instructorName: String
  let cfiNumber: String
  let cfiExpirationDate: Date
  let cfiHasExpiration: Bool
  let signatureImage: UIImage?
  let selectedStudent: Student?

  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @State private var pdfData: Data?
  @State private var hasBeenSaved = false

  // MARK: - Body

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
              .background(Color.appAdaptiveMutedBox)
              .cornerRadius(8)
          }
          .padding()
        }

        Button("Print / Save as PDF") {
          generatePDF()
          if !hasBeenSaved {
            saveEndorsementToStudent()
            hasBeenSaved = true
          }
          printPDF()
        }
        .buttonStyle(.borderedProminent)
        .frame(maxWidth: .infinity)
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
    }
    .onAppear {
      generatePDF()
    }
  }

  // MARK: - Private Helpers

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
    let text = generateEndorsementText()
    print("🔍 Generated endorsement text: \(text)")

    // Create attributed string with proper attributes
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 6
    paragraphStyle.alignment = .left

    let attributes: [NSAttributedString.Key: Any] = [
      .font: UIFont.systemFont(ofSize: 14, weight: .regular),
      .foregroundColor: UIColor.black,
      .paragraphStyle: paragraphStyle,
    ]

    let attributedString = NSAttributedString(string: text, attributes: attributes)

    // Calculate text size
    let maxWidth: CGFloat = 500
    let textSize = attributedString.boundingRect(
      with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude),
      options: [.usesLineFragmentOrigin, .usesFontLeading],
      context: nil
    )

    print("🔍 Text size: \(textSize)")

    // Calculate content bounds for automatic cropping
    let textHeight = textSize.height
    let padding: CGFloat = 20
    let contentHeight = textHeight + padding * 2
    let contentWidth = signatureImage != nil ? maxWidth + 140 + 20 : maxWidth  // Add space for signature if present

    // Create a smaller page size that fits the content
    let pageSize = CGSize(width: min(612, contentWidth + 100), height: max(200, contentHeight + 40))  // Minimum height of 200
    let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))

    pdfData = renderer.pdfData { context in
      context.beginPage()

      // Set white background
      context.cgContext.setFillColor(UIColor.white.cgColor)
      context.cgContext.fill(CGRect(origin: .zero, size: pageSize))

      // Draw text using Core Text for better control
      context.cgContext.saveGState()

      // Flip the coordinate system for Core Text
      context.cgContext.textMatrix = CGAffineTransform.identity
      context.cgContext.translateBy(x: 0, y: pageSize.height)
      context.cgContext.scaleBy(x: 1.0, y: -1.0)

      // Create framesetter
      let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
      let textRect = CGRect(
        x: 50, y: pageSize.height - textHeight - padding, width: maxWidth, height: textHeight)
      let path = CGPath(rect: textRect, transform: nil)
      let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)

      // Draw the frame
      CTFrameDraw(frame, context.cgContext)

      context.cgContext.restoreGState()

      // Draw signature if available (positioned to the right of the date)
      if let signatureImage = signatureImage {
        // Position signature to the right of the text, aligned with the date line
        let signatureX: CGFloat = 50 + maxWidth + 20  // 20 points to the right of text
        let signatureY: CGFloat = padding + textHeight - 60  // Aligned with bottom of text (date line)
        let signatureRect = CGRect(x: signatureX, y: signatureY, width: 120, height: 60)
        signatureImage.draw(in: signatureRect)

        // Add a subtle border around the signature
        context.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
        context.cgContext.setLineWidth(0.5)
        context.cgContext.stroke(signatureRect)
      }
    }

    print("🔍 PDF generated with auto-crop, size: \(pdfData?.count ?? 0) bytes")
  }

  private func printPDF() {
    guard let pdfData = pdfData else { return }

    let printController = UIPrintInteractionController.shared
    let printInfo = UIPrintInfo(dictionary: nil)
    printInfo.outputType = .general
    printInfo.jobName = "Endorsement - \(endorsement.code)"
    printInfo.orientation = .portrait

    // Set up for Avery sticker paper layout
    printInfo.duplex = .none  // Single-sided for labels

    // Configure for Avery 5160 labels (30 labels per sheet)
    if let printPageRenderer = printController.printPageRenderer {
      // Set up for label printing with proper margins
      printPageRenderer.setValue(
        NSValue(cgRect: CGRect(x: 0, y: 0, width: 612, height: 792)), forKey: "paperRect")
      printPageRenderer.setValue(
        NSValue(cgRect: CGRect(x: 0, y: 0, width: 612, height: 792)), forKey: "printableRect")
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

  /// Calculates the expiration date based on endorsement type
  private func calculateExpirationDate(for endorsementCode: String, from date: Date) -> Date? {
    let calendar = Calendar.current

    // Solo endorsements (A.6, A.7): 90 calendar days
    if endorsementCode == "A.6" || endorsementCode == "A.7" {
      return calendar.date(byAdding: .day, value: 90, to: date)
    }

    // Practical test authorization (A.1): 2 calendar months
    // A calendar month means it goes until the last day of the 2nd month
    // e.g., April 13 → June 30
    if endorsementCode == "A.1" {
      // Add 2 months
      guard let twoMonthsLater = calendar.date(byAdding: .month, value: 2, to: date) else {
        return nil
      }

      // Get the last day of that month
      let components = calendar.dateComponents([.year, .month], from: twoMonthsLater)
      guard let firstDayOfMonth = calendar.date(from: components),
        let lastDayOfMonth = calendar.date(
          byAdding: DateComponents(month: 1, day: -1), to: firstDayOfMonth)
      else {
        return nil
      }

      return lastDayOfMonth
    }

    // Other endorsements don't have expiration
    return nil
  }

  /// Saves the endorsement PDF to the student's profile
  private func saveEndorsementToStudent() {
    guard let student = selectedStudent else {
      print("⚠️ Cannot save endorsement: no student selected")
      return
    }

    // Ensure PDF is generated before saving
    generatePDF()

    guard let pdfData = pdfData else {
      print("⚠️ Cannot save endorsement: PDF data is nil after generation")
      return
    }

    print("🔍 Saving endorsement with PDF data size: \(pdfData.count) bytes")

    // Generate descriptive filename
    let formatter = DateFormatter()
    formatter.dateFormat = "MMddyy"
    let dateString = formatter.string(from: endorsementDate)

    // Create a clean student name for filename (remove spaces, special chars)
    let cleanStudentName =
      studentName
      .replacingOccurrences(of: " ", with: "_")
      .replacingOccurrences(of: "[^a-zA-Z0-9_-]", with: "", options: .regularExpression)

    // Create a clean endorsement title for filename
    let cleanEndorsementTitle = endorsement.title
      .replacingOccurrences(of: ":", with: "")
      .replacingOccurrences(of: "§", with: "")
      .replacingOccurrences(of: " ", with: "_")
      .replacingOccurrences(of: "[^a-zA-Z0-9_-]", with: "", options: .regularExpression)
      .prefix(30)  // Limit length

    // Count existing endorsements for this student and type to get sequence number
    let todayEndorsements = (student.endorsements ?? []).filter { end in
      if let code = end.endorsementCode {
        return code == endorsement.code && formatter.string(from: end.createdAt) == dateString
      }
      return end.filename.contains(cleanStudentName)
        && end.filename.contains(String(cleanEndorsementTitle))
    }

    let sequenceNumber =
      todayEndorsements.count > 0 ? "_\(String(format: "%02d", todayEndorsements.count + 1))" : ""
    let filename =
      "\(cleanStudentName)_\(cleanEndorsementTitle)_\(endorsement.code)_\(dateString)\(sequenceNumber).pdf"

    // Calculate expiration date
    let expirationDate = calculateExpirationDate(for: endorsement.code, from: endorsementDate)

    // Create endorsement record
    let endorsementRecord = EndorsementImage(
      filename: filename,
      imageData: pdfData,
      endorsementCode: endorsement.code,
      expirationDate: expirationDate
    )

    print("🔍 Created EndorsementImage with:")
    print("   - Filename: \(filename)")
    print("   - Image data size: \(pdfData.count) bytes")
    print("   - Endorsement code: \(endorsement.code)")
    print("   - Expiration date: \(expirationDate?.description ?? "None")")

    // Set up the relationship
    endorsementRecord.student = student

    // Add to student's endorsements array
    if student.endorsements == nil {
      student.endorsements = []
    }
    student.endorsements?.append(endorsementRecord)

    // Insert and save
    modelContext.insert(endorsementRecord)

    do {
      try modelContext.save()
      print("✅ Saved endorsement \(endorsement.code) to student \(student.displayName)")
      if let expiration = expirationDate {
        let expirationFormatter = DateFormatter()
        expirationFormatter.dateFormat = "MM/dd/yyyy"
        print("   Expiration date: \(expirationFormatter.string(from: expiration))")
      }
    } catch {
      print("❌ Failed to save endorsement: \(error)")
    }
  }
}

