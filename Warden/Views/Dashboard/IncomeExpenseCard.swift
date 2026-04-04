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
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("Income vs Expenses")
                    .font(.headline)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Income")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(income, format: .currency(code: "USD"))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Expenses")
                            .font(.caption)
                            .foregroundStyle(.secondary)
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
                    Text(netSavings, format: .currency(code: "USD"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(netSavings >= 0 ? .green : .red)
                }
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
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
