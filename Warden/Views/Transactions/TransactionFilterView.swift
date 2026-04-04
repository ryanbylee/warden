//
//  TransactionFilterView.swift
//  Warden
//

import SwiftUI
import SwiftData

struct TransactionFilterView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var filterState: TransactionFilterState
    let categories: [Category]

    @State private var draft: TransactionFilterState
    @State private var minAmountText: String
    @State private var maxAmountText: String
    @FocusState private var focusedField: AmountField?

    enum AmountField { case min, max }

    init(filterState: Binding<TransactionFilterState>, categories: [Category]) {
        _filterState = filterState
        self.categories = categories
        let current = filterState.wrappedValue
        _draft = State(initialValue: current)
        _minAmountText = State(initialValue: current.minAmount.map { String(format: "%.2f", $0) } ?? "")
        _maxAmountText = State(initialValue: current.maxAmount.map { String(format: "%.2f", $0) } ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Sort By") {
                    Picker("Sort", selection: $draft.sortOption) {
                        ForEach(TransactionSortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Transaction Type") {
                    Picker("Type", selection: $draft.transactionType) {
                        ForEach(TransactionTypeFilter.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Category") {
                    categoryPicker
                }

                Section("Date Range") {
                    Picker("Period", selection: $draft.dateRangePreset) {
                        ForEach(DateRangePreset.allCases) { preset in
                            Text(preset.rawValue).tag(preset)
                        }
                    }
                    .pickerStyle(.menu)

                    if draft.dateRangePreset == .custom {
                        DatePicker("From", selection: $draft.customStartDate, displayedComponents: .date)
                        DatePicker("To", selection: $draft.customEndDate, displayedComponents: .date)
                    }
                }

                Section("Amount Range") {
                    HStack(spacing: 12) {
                        HStack {
                            Text("$")
                                .foregroundStyle(.secondary)
                            TextField("Min", text: $minAmountText)
                                .keyboardType(.decimalPad)
                                .focused($focusedField, equals: .min)
                        }

                        Text("to")
                            .foregroundStyle(.tertiary)

                        HStack {
                            Text("$")
                                .foregroundStyle(.secondary)
                            TextField("Max", text: $maxAmountText)
                                .keyboardType(.decimalPad)
                                .focused($focusedField, equals: .max)
                        }
                    }
                }

                Section {
                    Button("Reset All Filters", role: .destructive) {
                        draft.reset()
                        minAmountText = ""
                        maxAmountText = ""
                    }
                    .disabled(draft.isDefault && minAmountText.isEmpty && maxAmountText.isEmpty)
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        applyFilters()
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                }
            }
        }
        .containerBackground(.clear, for: .navigation)
    }

    private var categoryPicker: some View {
        Picker("Category", selection: $draft.selectedCategoryId) {
            Text("All Categories").tag(Optional<UUID>(nil))
            ForEach(categories) { category in
                Label(category.name, systemImage: category.systemIcon)
                    .tag(Optional(category.id))
            }
        }
        .pickerStyle(.menu)
    }

    private func applyFilters() {
        draft.minAmount = Double(minAmountText)
        draft.maxAmount = Double(maxAmountText)
        filterState = draft
        dismiss()
    }
}
