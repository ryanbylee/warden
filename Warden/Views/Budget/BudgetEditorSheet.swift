//
//  BudgetEditorSheet.swift
//  Warden
//

import SwiftUI

struct BudgetEditorSheet: View {
    let categoryName: String
    let categoryIcon: String
    let categoryColor: Color
    let currentBudget: Double?
    let onSave: (Double) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var amountText: String = ""
    @FocusState private var isFocused: Bool

    private var canSave: Bool {
        if let amount = Double(amountText) { return amount >= 0 }
        return false
    }

    var body: some View {
        NavigationStack {
            Form {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(categoryColor.opacity(0.12))
                            .frame(width: 36, height: 36)
                        Image(systemName: categoryIcon)
                            .font(.system(size: 15))
                            .foregroundStyle(categoryColor)
                    }
                    Text(categoryName)
                        .font(.headline)
                }
                .listRowBackground(Color.clear)

                Section("Monthly spending limit") {
                    AmountTextField(label: "0.00", value: $amountText, isFocused: $isFocused)
                }
            }
            .navigationTitle(currentBudget == nil ? "Set Budget" : "Edit Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let amount = Double(amountText), amount >= 0 {
                            onSave(amount)
                            dismiss()
                        }
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                if let budget = currentBudget {
                    amountText = String(format: "%.0f", budget)
                }
                isFocused = true
            }
        }
    }
}
