//
//  SelectableTextField.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

// MARK: - SelectableTextField

struct SelectableTextField: View {
  // MARK: - Properties

  let placeholder: String
  @Binding var value: Double
  let format: FloatingPointFormatStyle<Double>

  @State private var textValue: String = ""
  @State private var isUserTyping: Bool = false
  @FocusState private var isFocused: Bool

  // MARK: - Initialization

  init(placeholder: String, value: Binding<Double>, format: FloatingPointFormatStyle<Double>) {
    self.placeholder = placeholder
    self._value = value
    self.format = format
  }

  // MARK: - Body

  var body: some View {
    TextField(placeholder, text: $textValue)
      .keyboardType(.decimalPad)
      .textFieldStyle(RoundedBorderTextFieldStyle())
      .focused($isFocused)
      .onTapGesture {
        // Ensure text input system is warmed before focusing
        TextInputWarmingService.shared.warmTextInput()

        isFocused = true
        // Multiple focus attempts for better reliability
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
          isFocused = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
          isFocused = true
        }
      }
      .onAppear {
        updateTextValue()
      }
      .onChange(of: value) { _, newValue in
        // Only update text if user is not currently typing
        if !isUserTyping {
          updateTextValue()
        }
      }
      .onChange(of: textValue) { _, newValue in
        isUserTyping = true

        if newValue.isEmpty {
          value = 0.0
        } else if let doubleValue = Double(newValue) {
          value = doubleValue
        }

        // Reset typing flag after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          isUserTyping = false
        }
      }
      .onChange(of: isFocused) { _, focused in
        if focused {
          isUserTyping = true
          // Clear default value (0.0) when focused
          if value == 0.0 {
            textValue = ""
          } else {
            // Select all text for non-zero values
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
              // The system will automatically select all text when the field becomes focused
            }
          }
        } else {
          // When losing focus, format the final value
          isUserTyping = false
          updateTextValue()
        }
      }
  }

  // MARK: - Private Helpers

  private func updateTextValue() {
    textValue = value.formatted(format)
  }
}

#Preview {
  @Previewable @State var testValue: Double = 0.0

  return VStack {
    SelectableTextField(
      placeholder: "0.0",
      value: $testValue,
      format: .number.precision(.fractionLength(1))
    )
    .frame(width: 100)

    Text("Current value: \(testValue)")
  }
  .padding()
}
