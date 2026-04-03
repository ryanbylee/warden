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
                        .foregroundStyle(
                            row.spent > row.budgeted
                                ? LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing)
                                : LinearGradient(colors: [.green, .teal], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(6)
                        .shadow(
                            color: row.spent > row.budgeted ? .red.opacity(0.3) : .clear,
                            radius: 4
                        )
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
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
    }
}
