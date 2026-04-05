//
//  CategoryBreakdownChart.swift
//  Warden
//

import SwiftUI
import Charts

struct CategoryBreakdownChart: View {
    let rows: [SpendingRow]

    private let chartColors: [Color] = [
        .teal, Color(red: 1.0, green: 0.4, blue: 0.3),
        Color(red: 1.0, green: 0.75, blue: 0.2), .indigo,
        .mint, Color(red: 1.0, green: 0.3, blue: 0.6),
        Color(red: 0.7, green: 0.6, blue: 1.0), Color(red: 0.4, green: 0.5, blue: 0.6)
    ]

    private var totalSpent: Double {
        rows.reduce(0) { $0 + $1.spent }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Spending by Category")
                .font(.headline)

            if rows.isEmpty {
                ContentUnavailableView("No spending data", systemImage: "chart.pie")
                    .frame(height: 200)
            } else {
                ZStack {
                    Chart(rows) { row in
                        SectorMark(
                            angle: .value("Spent", row.spent),
                            innerRadius: .ratio(0.6),
                            angularInset: 1.5
                        )
                        .foregroundStyle(by: .value("Category", row.category.name))
                        .cornerRadius(4)
                        .opacity(0.85)
                    }
                    .chartForegroundStyleScale(
                        domain: rows.map { $0.category.name },
                        range: chartColors
                    )
                    .frame(height: 200)

                    VStack(spacing: 2) {
                        Text(totalSpent, format: .currency(code: "USD"))
                            .font(.subheadline)
                            .fontWeight(.bold)
                        Text("total")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .chartLegend(position: .bottom, alignment: .center)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
    }
}
