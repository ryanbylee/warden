//
//  TransactionFormView.swift
//  Warden
//

import SwiftUI
import SwiftData

enum FormMode {
    case add
    case edit(Transaction)
}

struct TransactionFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let mode: FormMode
    let categories: [Category]
    let onSave: (Transaction) -> Void

    @State private var descriptionText: String = ""
    @State private var amountText: String = ""
    @State private var date: Date = Date()
    @State private var selectedType: String = "expense"
    @State private var selectedCategory: Category? = nil
    @FocusState private var amountFocused: Bool

    var title: String {
        switch mode {
        case .add: return "New Transaction"
        case .edit: return "Edit Transaction"
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Description", text: $descriptionText)

                    HStack {
                        Text("$")
                            .foregroundStyle(.secondary)
                        TextField("0.00", text: $amountText)
                            .keyboardType(.decimalPad)
                            .focused($amountFocused)
                    }

                    DatePicker("Date", selection: $date, displayedComponents: .date)

                    Picker("Type", selection: $selectedType) {
                        Text("Expense").tag("expense")
                        Text("Income").tag("income")
                    }
                    .pickerStyle(.segmented)
                }

                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        Text("None").tag(Optional<Category>(nil))
                        ForEach(categories) { cat in
                            Label(cat.name, systemImage: cat.systemIcon)
                                .tag(Optional(cat))
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(descriptionText.trimmingCharacters(in: .whitespaces).isEmpty || amountText.isEmpty)
                }
                if amountFocused {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") { amountFocused = false }
                    }
                }
            }
            .onAppear { prepopulate() }
        }
        .containerBackground(.clear, for: .navigation)
    }

    private func prepopulate() {
        if case .edit(let tx) = mode {
            descriptionText = tx.descriptionText
            amountText = String(tx.amount)
            date = tx.date
            selectedType = tx.type
            selectedCategory = tx.category
        }
    }

    private func save() {
        guard let amount = Double(amountText), amount > 0 else { return }

        switch mode {
        case .add:
            let tx = Transaction(
                descriptionText: descriptionText.trimmingCharacters(in: .whitespaces),
                amount: amount,
                date: date,
                type: selectedType,
                isMock: false,
                category: selectedCategory
            )
            onSave(tx)
        case .edit(let tx):
            tx.descriptionText = descriptionText.trimmingCharacters(in: .whitespaces)
            tx.amount = amount
            tx.date = date
            tx.type = selectedType
            tx.category = selectedCategory
            onSave(tx)
        }
        dismiss()
    }
}
