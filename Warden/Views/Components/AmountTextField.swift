//
//  AmountTextField.swift
//  Warden
//

import SwiftUI

struct AmountTextField: View {
    let label: String
    @Binding var value: String
    @FocusState.Binding var isFocused: Bool

    var body: some View {
        HStack {
            Text("$")
                .foregroundStyle(.secondary)
            TextField(label, text: $value)
                .keyboardType(.decimalPad)
                .focused($isFocused)
        }
        .toolbar {
            if isFocused {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { isFocused = false }
                }
            }
        }
    }
}
