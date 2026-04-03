//
//  BudgetCategoryRow.swift
//  Warden
//

import SwiftUI

struct BudgetCategoryRow: View {
    let row: CategoryBudgetRow
    let onSetBudget: (Double) -> Void

    @State private var showingEditor = false
    @State private var budgetText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    Circle()
                        .fill(row.category.displayColor.opacity(0.12))
                        .frame(width: 32, height: 32)
                    Image(systemName: row.category.systemIcon)
                        .font(.system(size: 14))
                        .foregroundStyle(row.category.displayColor)
                }

                Text(row.category.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    if let budget = row.budget {
                        Text("\(row.spent.formatted(.currency(code: "USD"))) / \(budget.monthlyLimit.formatted(.currency(code: "USD")))")
                            .font(.caption)
                            .foregroundStyle(row.spent > budget.monthlyLimit ? .red : .secondary)
                    } else {
                        Text("\(row.spent.formatted(.currency(code: "USD"))) / —")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if let budget = row.budget {
                ProgressBarView(value: row.spent, total: budget.monthlyLimit, showPercentage: false)
            }

            Button(row.budget == nil ? "Set Budget" : "Edit Budget") {
                budgetText = row.budget.map { String($0.monthlyLimit) } ?? ""
                showingEditor = true
            }
            .font(.caption)
            .buttonStyle(.glass)
        }
        .padding(.vertical, 4)
        .alert("Set Budget for \(row.category.name)", isPresented: $showingEditor) {
            TextField("Monthly limit", text: $budgetText)
                .keyboardType(.decimalPad)
            Button("Save") {
                if let amount = Double(budgetText), amount >= 0 {
                    onSetBudget(amount)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter the monthly spending limit.")
        }
    }
}
