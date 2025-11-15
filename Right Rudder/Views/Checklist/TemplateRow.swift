//
//  TemplateRow.swift
//  Right Rudder
//
//  Created by AI on 10/6/25.
//

import SwiftData
import SwiftUI

// MARK: - TemplateRow

struct TemplateRow: View {
  // MARK: - Properties

  let template: ChecklistTemplate
  let isSelected: Bool
  let onToggle: () -> Void

  // MARK: - Body

  var body: some View {
    Button(action: onToggle) {
      HStack {
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
          .foregroundColor(isSelected ? .blue : .gray)
          .font(.title3)

        VStack(alignment: .leading, spacing: 4) {
          HStack {
            Text(template.name)
              .font(.headline)
              .foregroundColor(.primary)

            if template.isUserCreated {
              Image(systemName: "person.badge.plus")
                .font(.caption)
                .foregroundColor(.green)
            } else if template.isUserModified {
              Image(systemName: "pencil.circle")
                .font(.caption)
                .foregroundColor(.orange)
            }
          }

          HStack {
            Text(template.category)
              .font(.caption)
              .foregroundColor(.secondary)

            if let phase = template.phase {
              Text("•")
                .foregroundColor(.secondary)
              Text(phase)
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Text("•")
              .foregroundColor(.secondary)
            Text("\(template.items?.count ?? 0) items")
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }

        Spacer()
      }
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
  }
}

