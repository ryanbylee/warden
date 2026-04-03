//
//  TransactionRowView.swift
//  Warden
//

import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction

    private var categoryColor: Color {
        transaction.category?.displayColor ?? .accentColor
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: transaction.category?.systemIcon ?? "questionmark.circle")
                    .font(.system(size: 16))
                    .foregroundStyle(categoryColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.descriptionText)
                    .font(.subheadline)
                    .fontWeight(.medium)
                HStack(spacing: 4) {
                    if transaction.source == "plaid" {
                        Image(systemName: "building.columns")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    if let category = transaction.category {
                        Text(category.name)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    Text("·")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Text(transaction.date, style: .date)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            Text(amountText)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(transaction.transactionType == .income ? .green : .primary)
                .contentTransition(.numericText())
        }
        .padding(.vertical, 2)
    }

    private var amountText: String {
        let sign = transaction.transactionType == .income ? "+" : "-"
        return "\(sign)\(transaction.amount.formatted(.currency(code: "USD")))"
    }
}
