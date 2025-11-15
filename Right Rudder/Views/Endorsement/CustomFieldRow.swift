//
//  CustomFieldRow.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

// MARK: - CustomFieldRow

struct CustomFieldRow: View {
  // MARK: - Properties

  let field: String
  let endorsement: FAAEndorsement
  @Binding var customFields: [String: String]
  @Binding var fieldDescriptionCache: [String: String]

  // Certificate type options
  private let certificateTypes = [
    "Private Pilot", "Instrument", "Commercial Pilot", "Certified Flight Instructor",
  ]

  // MARK: - Body

  var body: some View {
    VStack(alignment: .leading) {
      Text(getFieldDescription(field: field, endorsement: endorsement))
        .font(.caption)
        .foregroundColor(.secondary)

      // Show dropdown for certificate type fields
      if field.lowercased().contains("certificate type")
        || field.lowercased().contains("applicable")
      {
        Picker(
          "Certificate Type",
          selection: Binding(
            get: { customFields[field] ?? "" },
            set: { customFields[field] = $0 }
          )
        ) {
          Text("Select Certificate Type").tag("")
          ForEach(certificateTypes, id: \.self) { certificateType in
            Text(certificateType).tag(certificateType)
          }
        }
        .pickerStyle(.menu)
        .textFieldStyle(.roundedBorder)
      } else {
        TextField(
          "Enter \(getFieldPlaceholder(field: field))",
          text: Binding(
            get: { customFields[field] ?? "" },
            set: { customFields[field] = $0 }
          )
        )
        .textFieldStyle(.roundedBorder)
      }
    }
  }

  // MARK: - Private Helpers

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
      "name of specific aircraft category/class/type": "specific aircraft type",
    ]

    return placeholders[field] ?? field.lowercased()
  }
}

