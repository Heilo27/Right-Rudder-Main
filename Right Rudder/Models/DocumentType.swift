//
//  DocumentType.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation

// MARK: - DocumentType Enum

enum DocumentType: String, Codable, CaseIterable {
  case studentPilotCertificate = "Student Pilot Certificate"
  case medicalCertificate = "Medical Certificate"
  case passportBirthCertificate = "Passport/Birth Certificate"
  case logBook = "LogBook"

  var icon: String {
    switch self {
    case .studentPilotCertificate: return "airplane.circle"
    case .medicalCertificate: return "heart.text.square"
    case .passportBirthCertificate: return "person.text.rectangle"
    case .logBook: return "book.closed"
    }
  }

  var isOptional: Bool {
    return self == .logBook
  }
}

