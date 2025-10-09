//
//  WhatsNewService.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation
import Combine

class WhatsNewService: ObservableObject {
    @Published var shouldShowWhatsNew = false
    
    private let whatsNewShownKey = "WhatsNewShown_v1.3"
    
    init() {
        checkIfShouldShowWhatsNew()
    }
    
    private func checkIfShouldShowWhatsNew() {
        let hasShownWhatsNew = UserDefaults.standard.bool(forKey: whatsNewShownKey)
        if !hasShownWhatsNew {
            shouldShowWhatsNew = true
        }
    }
    
    func markWhatsNewAsShown() {
        UserDefaults.standard.set(true, forKey: whatsNewShownKey)
        shouldShowWhatsNew = false
    }
}
