//
//  TextInputWarmingService.swift
//  Right Rudder
//
//  Created by AI on 12/19/25.
//

import Combine
import Foundation
import SwiftUI
import UIKit

// MARK: - TextInputWarmingService

/// Service to pre-warm text input components to prevent cold start delays
class TextInputWarmingService: ObservableObject {
  // MARK: - Singleton

  static let shared = TextInputWarmingService()

  // MARK: - Published Properties

  @Published var isWarmed = false

  // MARK: - Initialization

  private init() {}

  // MARK: - Methods

  /// Pre-warms the text input system by creating hidden text input components
  func warmTextInput() {
    guard !isWarmed else { return }

    // Create multiple hidden text input components to initialize the text input system
    DispatchQueue.main.async {
      let warmingView = VStack {
        // TextEditor for multi-line text (warm first as it's the most complex)
        TextEditor(text: .constant(""))
          .frame(width: 1, height: 1)
          .opacity(0)

        // TextField with default keyboard
        TextField("", text: .constant(""))
          .keyboardType(.default)
          .frame(width: 1, height: 1)
          .opacity(0)

        // TextField with email keyboard
        TextField("", text: .constant(""))
          .keyboardType(.emailAddress)
          .frame(width: 1, height: 1)
          .opacity(0)

        // TextField with phone pad
        TextField("", text: .constant(""))
          .keyboardType(.phonePad)
          .frame(width: 1, height: 1)
          .opacity(0)

        // TextField with decimal pad (most common numeric entry)
        TextField("", text: .constant(""))
          .keyboardType(.decimalPad)
          .frame(width: 1, height: 1)
          .opacity(0)

        // TextField with number pad
        TextField("", text: .constant(""))
          .keyboardType(.numberPad)
          .frame(width: 1, height: 1)
          .opacity(0)

        // TextField with URL keyboard
        TextField("", text: .constant(""))
          .keyboardType(.URL)
          .frame(width: 1, height: 1)
          .opacity(0)

        // TextField with ASCII capable keyboard
        TextField("", text: .constant(""))
          .keyboardType(.asciiCapable)
          .frame(width: 1, height: 1)
          .opacity(0)
      }
      .frame(width: 1, height: 1)
      .opacity(0)

      // Add to a temporary window to trigger initialization
      if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
        let window = windowScene.windows.first
      {
        let hostingController = UIHostingController(rootView: warmingView)
        hostingController.view.frame = CGRect(x: -1000, y: -1000, width: 1, height: 1)
        hostingController.view.isUserInteractionEnabled = false
        window.addSubview(hostingController.view)

        // Create hidden UITextField instances for immediate keyboard initialization
        // This ensures the keyboard system is fully initialized
        let textField = UITextField(frame: CGRect(x: -1000, y: -1000, width: 1, height: 1))
        textField.isHidden = true
        textField.isUserInteractionEnabled = false
        window.addSubview(textField)

        // Warm each keyboard type sequentially to avoid conflicts
        let keyboardTypes: [UIKeyboardType] = [
          .default, .emailAddress, .phonePad, .decimalPad, .numberPad, .URL, .asciiCapable,
        ]
        var currentIndex = 0

        func warmNextKeyboard() {
          guard currentIndex < keyboardTypes.count else {
            // All keyboards warmed, clean up
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
              hostingController.view.removeFromSuperview()
              textField.removeFromSuperview()
              self.isWarmed = true
              print("🔥 Text input system warmed up with \(keyboardTypes.count) keyboard types")
            }
            return
          }

          let keyboardType = keyboardTypes[currentIndex]
          let tempTextField = UITextField(frame: CGRect(x: -1000, y: -1000, width: 1, height: 1))
          tempTextField.isHidden = true
          tempTextField.isUserInteractionEnabled = false
          tempTextField.keyboardType = keyboardType
          window.addSubview(tempTextField)

          // Focus and then unfocus to warm this keyboard type
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            tempTextField.becomeFirstResponder()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
              tempTextField.resignFirstResponder()
              tempTextField.removeFromSuperview()

              // Move to next keyboard type
              currentIndex += 1
              warmNextKeyboard()
            }
          }
        }

        // Start warming keyboards sequentially
        warmNextKeyboard()
      }
    }
  }

  // MARK: - Computed Properties

  /// Check if text input has been warmed
  var isTextInputWarmed: Bool {
    return isWarmed
  }
}
