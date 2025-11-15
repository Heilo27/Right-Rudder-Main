//
//  TemplateSortingUtilities.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation

// MARK: - TemplateSortingUtilities

/// Shared utilities for template sorting and lesson number extraction
struct TemplateSortingUtilities {
  // MARK: - Properties

  // Static regex patterns for efficient compilation
  private static let lessonNumberRegex = try? NSRegularExpression(pattern: "([PCI]\\d+)-L(\\d+)")
  private static let newFormatRegex = try? NSRegularExpression(pattern: "([PCI]\\d+)-L(\\d+)")
  private static let oldFormatRegex = try? NSRegularExpression(pattern: "([PCI]\\d+)L(\\d+)")

  // MARK: - Methods

  /// Extract lesson number from template names for sorting
  static func extractLessonNumber(from templateName: String) -> Int? {
    guard let regex = lessonNumberRegex else { return nil }

    let range = NSRange(location: 0, length: templateName.utf16.count)
    guard let match = regex.firstMatch(in: templateName, range: range),
      let numberRange = Range(match.range(at: 2), in: templateName)
    else {
      return nil
    }

    return Int(templateName[numberRange])
  }

  /// Extract lesson info from both old and new formats
  static func extractLessonInfo(from name: String) -> (phase: String, lesson: String) {
    // Try new format first (I1-L5, C1-L3, etc.)
    if let regex = newFormatRegex {
      let range = NSRange(location: 0, length: name.utf16.count)
      if let match = regex.firstMatch(in: name, range: range),
        let phaseRange = Range(match.range(at: 1), in: name),
        let lessonRange = Range(match.range(at: 2), in: name)
      {
        return (phase: String(name[phaseRange]), lesson: String(name[lessonRange]))
      }
    }

    // Try old format (P1L5, C1L3, etc.)
    if let regex = oldFormatRegex {
      let range = NSRange(location: 0, length: name.utf16.count)
      if let match = regex.firstMatch(in: name, range: range),
        let phaseRange = Range(match.range(at: 1), in: name),
        let lessonRange = Range(match.range(at: 2), in: name)
      {
        return (phase: String(name[phaseRange]), lesson: String(name[lessonRange]))
      }
    }

    // Fallback - return empty strings
    return (phase: "", lesson: "")
  }

  /// Sort templates by lesson number with fallback to alphabetical
  static func sortTemplatesByLessonNumber(_ templates: [ChecklistTemplate]) -> [ChecklistTemplate] {
    return templates.sorted { template1, template2 in
      let lesson1 = extractLessonNumber(from: template1.name)
      let lesson2 = extractLessonNumber(from: template2.name)

      if let num1 = lesson1, let num2 = lesson2 {
        return num1 < num2
      }

      return template1.name < template2.name
    }
  }

  /// Sort first steps templates with special handling for onboarding
  static func sortFirstStepsTemplates(_ templates: [ChecklistTemplate]) -> [ChecklistTemplate] {
    return templates.sorted { template1, template2 in
      if template1.name == "Student Onboard/Training Overview" {
        return true
      }
      if template2.name == "Student Onboard/Training Overview" {
        return false
      }
      return template1.name < template2.name
    }
  }
}
