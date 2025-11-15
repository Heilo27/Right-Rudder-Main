//
//  CSVTemplateGeneratorView.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import SwiftUI

// MARK: - CSVTemplateGeneratorView

struct CSVTemplateGeneratorView: View {
  // MARK: - Properties

  @Environment(\.dismiss) private var dismiss
  @State private var templateName = ""
  @State private var templateCategory = "Custom"
  @State private var templatePhase = "Custom"
  @State private var showingShareSheet = false
  @State private var generatedCSVURL: URL?

  let categories = ["PPL", "Instrument", "Commercial", "Custom"]
  let phases = ["Phase 1", "Phase 2", "Phase 3", "Phase 4", "Custom"]

  // MARK: - Body

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

  // MARK: - Methods

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

