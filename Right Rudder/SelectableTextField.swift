//
//  SelectableTextField.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftUI

struct SelectableTextField: View {
    let placeholder: String
    @Binding var value: Double
    let format: FloatingPointFormatStyle<Double>
    
    @State private var textValue: String = ""
    @FocusState private var isFocused: Bool
    
    init(placeholder: String, value: Binding<Double>, format: FloatingPointFormatStyle<Double>) {
        self.placeholder = placeholder
        self._value = value
        self.format = format
    }
    
    var body: some View {
        TextField(placeholder, text: $textValue)
            .keyboardType(.decimalPad)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .focused($isFocused)
            .onAppear {
                updateTextValue()
            }
            .onChange(of: value) { _, newValue in
                updateTextValue()
            }
            .onChange(of: textValue) { _, newValue in
                if let doubleValue = Double(newValue) {
                    value = doubleValue
                }
            }
            .onChange(of: isFocused) { _, focused in
                if focused {
                    // Select all text when focused
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        // The system will automatically select all text when the field becomes focused
                        // and the user taps on it
                    }
                }
            }
    }
    
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
