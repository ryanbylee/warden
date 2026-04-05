//
//  SpendingSummaryCard.swift
//  Warden
//

import SwiftUI

struct SpendingSummaryCard: View {
    let spent: Double
    let budget: Double
    var monthOverMonthDelta: Double?

    private var ratio: Double {
        guard budget > 0 else { return 0 }
        return spent / budget
    }

    private var statusColor: Color {
        if ratio >= 1.0 { return .red }
        if ratio >= 0.8 { return .yellow }
        return .green
    }

    private var statusIcon: String {
        if ratio >= 1.0 { return "xmark.circle.fill" }
        if ratio >= 0.8 { return "exclamationmark.triangle.fill" }
        return "checkmark.circle.fill"
    }

    private var remaining: Double {
        budget - spent
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("Total Spent")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if let delta = monthOverMonthDelta {
                            HStack(spacing: 2) {
                                Image(systemName: delta >= 0 ? "arrow.up.right" : "arrow.down.right")
                                Text("\(abs(delta), specifier: "%.0f")%")
                            }
                            .font(.caption)
                            .foregroundStyle(delta >= 0 ? .red : .green)
                        }
                    }
                    Text(spent, format: .currency(code: "USD"))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(statusColor)
                        .contentTransition(.numericText())
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Budget")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if budget > 0 {
                        Text(budget, format: .currency(code: "USD"))
                            .font(.title2)
                            .fontWeight(.bold)
                    } else {
                        Text("—")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            ProgressBarView(value: spent, total: budget)

            if budget > 0 {
                HStack(spacing: 6) {
                    Image(systemName: statusIcon)
                        .font(.subheadline)
                        .foregroundStyle(statusColor)
                    Group {
                        if remaining >= 0 {
                            Text("\(remaining, format: .currency(code: "USD")) remaining")
                                .foregroundStyle(statusColor)
                        } else {
                            Text("\(abs(remaining), format: .currency(code: "USD")) over budget")
                                .foregroundStyle(.red)
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .contentTransition(.numericText())
                }
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    VStack(spacing: 12) {
        SpendingSummaryCard(spent: 1240, budget: 2000, monthOverMonthDelta: -12)
        SpendingSummaryCard(spent: 1700, budget: 2000, monthOverMonthDelta: 23.5)
        SpendingSummaryCard(spent: 2200, budget: 2000)
    }
    .padding()
}
