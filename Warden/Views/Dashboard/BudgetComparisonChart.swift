//
//  BudgetComparisonChart.swift
//  Warden
//

import SwiftUI
import Charts

struct BudgetComparisonChart: View {
    let rows: [SpendingRow]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Budget vs Actual")
                .font(.headline)

            if rows.isEmpty {
                ContentUnavailableView("No budget data", systemImage: "chart.bar")
                    .frame(height: 200)
            } else {
                Chart {
                    ForEach(rows) { row in
                        BarMark(
                            x: .value("Amount", row.budgeted),
                            y: .value("Category", row.category.name)
                        )
                        .foregroundStyle(.quaternary)
                        .cornerRadius(6)

                        BarMark(
                            x: .value("Amount", row.spent),
                            y: .value("Category", row.category.name)
                        )
                        .foregroundStyle(row.spent > row.budgeted ? Color.red : Color.green)
                        .cornerRadius(6)
                    }
                }
                .frame(height: max(Double(rows.count) * 44, 150))
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let amount = value.as(Double.self) {
                                Text(amount.formatted(.currency(code: "USD").precision(.fractionLength(0))))
                                    .font(.caption2)
                            }
                        }
                    }
                }

                let overBudget = rows.filter { $0.spent > $0.budgeted && $0.budgeted > 0 }
                if !overBudget.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(overBudget) { row in
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                Text("\(row.category.name) over by \((row.spent - row.budgeted).formatted(.currency(code: "USD").precision(.fractionLength(0))))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
    }
}
