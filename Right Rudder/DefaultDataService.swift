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
        
        print("Default data initialization completed successfully")
    }
}