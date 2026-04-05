//
//  IncomeExpenseCard.swift
//  Warden
//

import SwiftUI

struct IncomeExpenseCard: View {
    let income: Double
    let expenses: Double

    private var netSavings: Double { income - expenses }

    var body: some View {
        if income == 0 && expenses == 0 {
            ContentUnavailableView("No data this month", systemImage: "dollarsign.circle")
                .frame(height: 120)
                .padding()
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("Income vs Expenses")
                    .font(.headline)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.down.left")
                                .font(.caption)
                                .foregroundStyle(.green)
                            Text("Income")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Text(income, format: .currency(code: "USD"))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Text("Expenses")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                        Text(expenses, format: .currency(code: "USD"))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.red)
                    }
                }

                Divider()

                HStack {
                    Text("Net Savings")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: netSavings >= 0 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .font(.subheadline)
                            .foregroundStyle(netSavings >= 0 ? .green : .red)
                        Text("\(netSavings >= 0 ? "+" : "")\(netSavings, format: .currency(code: "USD"))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(netSavings >= 0 ? .green : .red)
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        IncomeExpenseCard(income: 7000, expenses: 4200)
        IncomeExpenseCard(income: 3000, expenses: 4200)
        IncomeExpenseCard(income: 0, expenses: 0)
    }
    .padding()
}
