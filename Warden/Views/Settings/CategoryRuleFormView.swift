//
//  CategoryRuleFormView.swift
//  Warden
//

import SwiftUI

struct CategoryRuleFormView: View {
    let categories: [Category]
    let onSave: (String, Bool, Category) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var merchantPattern: String = ""
    @State private var isExactMatch: Bool = false
    @State private var selectedCategory: Category? = nil

    private var canSave: Bool {
        !merchantPattern.trimmingCharacters(in: .whitespaces).isEmpty && selectedCategory != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Merchant name") {
                    TextField("e.g. Starbucks, Amazon", text: $merchantPattern)
                    Toggle("Exact name only", isOn: $isExactMatch)
                    Text(isExactMatch
                         ? "Only matches transactions with this exact name."
                         : "Matches any transaction whose name contains this text.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Assign to category") {
                    CategoryPicker(selection: $selectedCategory, categories: categories)
                }
            }
            .scrollContentBackground(.hidden)
            .containerBackground(.clear, for: .navigation)
            .navigationTitle("Auto-Categorize")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let category = selectedCategory {
                            onSave(merchantPattern.trimmingCharacters(in: .whitespaces), isExactMatch, category)
                            dismiss()
                        }
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
}
