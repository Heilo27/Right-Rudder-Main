//
//  DefaultDataService.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import Foundation
import SwiftData

class DefaultDataService {
  static func initializeDefaultData(modelContext: ModelContext) {
    print("Starting default data initialization...")

    // Use smart template update service to preserve user customizations
    SmartTemplateUpdateService.updateDefaultTemplates(modelContext: modelContext)

    // Validate template integrity after initialization
    SmartTemplateUpdateService.validateTemplateIntegrity(modelContext: modelContext)

    print("Default data initialization completed successfully")
  }

  /// Force update all templates (useful for debugging)
  static func forceUpdateTemplates(modelContext: ModelContext) {
    print("Force updating templates...")
    SmartTemplateUpdateService.forceUpdateAllTemplates(modelContext: modelContext)
  }
}
