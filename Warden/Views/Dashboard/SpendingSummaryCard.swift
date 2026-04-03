//
//  SpendingSummaryCard.swift
//  Warden
//

import SwiftUI

struct SpendingSummaryCard: View {
    let spent: Double
    let budget: Double

    private var ratio: Double {
        guard budget > 0 else { return 0 }
        return spent / budget
    }

    private var statusColor: Color {
        if ratio >= 1.0 { return .red }
        if ratio >= 0.8 { return .yellow }
        return .green
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Spent")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(spent, format: .currency(code: "USD"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(statusColor)
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
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
    }
}

#Preview {
    VStack(spacing: 12) {
        SpendingSummaryCard(spent: 1240, budget: 2000)
        SpendingSummaryCard(spent: 1700, budget: 2000)
        SpendingSummaryCard(spent: 2200, budget: 2000)
    }
    .padding()
}
