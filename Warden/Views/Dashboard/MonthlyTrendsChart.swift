//
//  MonthlyTrendsChart.swift
//  Warden
//

import SwiftUI
import Charts

struct MonthlyTrendsChart: View {
    let dataPoints: [MonthlyTrendPoint]
    let monthOverMonthDelta: Double?

    private var uniqueCategories: [String] {
        Array(Set(dataPoints.map { $0.categoryName })).sorted()
    }

    private var categoryColors: [Color] {
        let colorMap: [String: Color] = [
            "Food": .orange,
            "Rent": .blue,
            "Transport": .teal,
            "Entertainment": .purple,
            "Utilities": .yellow,
            "Shopping": .pink,
            "Health": .red,
            "Other": .gray
        ]
        return uniqueCategories.map { colorMap[$0] ?? .accentColor }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Spending Trends")
                    .font(.headline)

                if let delta = monthOverMonthDelta {
                    HStack(spacing: 4) {
                        Image(systemName: delta >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption)
                            .foregroundStyle(delta >= 0 ? .red : .green)
                        Text("\(abs(delta), specifier: "%.0f")% vs last month")
                            .font(.caption)
                            .foregroundStyle(delta >= 0 ? .red : .green)
                    }
                }
            }

            if dataPoints.isEmpty {
                ContentUnavailableView("No trend data", systemImage: "chart.line.uptrend.xyaxis")
                    .frame(height: 220)
            } else {
                Chart(dataPoints) { point in
                    LineMark(
                        x: .value("Month", point.monthDate, unit: .month),
                        y: .value("Amount", point.total)
                    )
                    .foregroundStyle(by: .value("Category", point.categoryName))
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 2))

                    PointMark(
                        x: .value("Month", point.monthDate, unit: .month),
                        y: .value("Amount", point.total)
                    )
                    .foregroundStyle(by: .value("Category", point.categoryName))
                    .symbolSize(30)
                }
                .chartForegroundStyleScale(
                    domain: uniqueCategories,
                    range: categoryColors
                )
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { _ in
                        AxisValueLabel(format: .dateTime.month(.abbreviated))
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let amount = value.as(Double.self) {
                                Text(amount.formatted(.currency(code: "USD").precision(.fractionLength(0))))
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartLegend(position: .bottom, alignment: .center)
                .frame(height: 220)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
    }
}

#Preview {
    MonthlyTrendsChart(
        dataPoints: previewTrendData(),
        monthOverMonthDelta: 23.5
    )
    .padding()
}

private func previewTrendData() -> [MonthlyTrendPoint] {
    let cal = Calendar.current
    let categories = ["Food", "Rent", "Transport", "Entertainment", "Shopping"]
    var points: [MonthlyTrendPoint] = []

    for offset in 0..<6 {
        guard let date = cal.date(byAdding: .month, value: -5 + offset, to: Date()) else { continue }
        var comps = cal.dateComponents([.year, .month], from: date)
        comps.day = 1
        let monthStart = cal.date(from: comps) ?? date
        for cat in categories {
            points.append(MonthlyTrendPoint(
                monthDate: monthStart,
                categoryName: cat,
                total: Double.random(in: 100...800)
            ))
        }
    }
    return points.sorted { $0.monthDate < $1.monthDate }
}
