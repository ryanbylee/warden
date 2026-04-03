//
//  TransactionImporter.swift
//  Warden
//

import Foundation
import SwiftData

struct TransactionImporter {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func apply(_ response: PlaidSyncResponse) throws {
        let categoryMap = try fetchCategoryMap()

        for plaidTx in response.added {
            try insertIfNeeded(plaidTx, categoryMap: categoryMap)
        }
        for plaidTx in response.modified {
            try updateIfExists(plaidTx, categoryMap: categoryMap)
        }
        for removed in response.removed {
            try deleteIfExists(transactionId: removed.transactionId)
        }

        try context.save()
    }

    // MARK: - Private

    private func fetchCategoryMap() throws -> [String: Category] {
        let all = try context.fetch(FetchDescriptor<Category>())
        return Dictionary(uniqueKeysWithValues: all.map { ($0.name, $0) })
    }

    private func insertIfNeeded(_ plaidTx: PlaidTransaction, categoryMap: [String: Category]) throws {
        let txId: String? = plaidTx.transactionId
        var descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate { $0.plaidTransactionId == txId }
        )
        descriptor.fetchLimit = 1
        guard try context.fetch(descriptor).isEmpty else { return }

        let tx = buildTransaction(from: plaidTx, categoryMap: categoryMap)
        context.insert(tx)
    }

    private func updateIfExists(_ plaidTx: PlaidTransaction, categoryMap: [String: Category]) throws {
        let txId: String? = plaidTx.transactionId
        var descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate { $0.plaidTransactionId == txId }
        )
        descriptor.fetchLimit = 1
        guard let tx = try context.fetch(descriptor).first else { return }

        let mapping = PlaidCategoryMapper.map(plaidTx.personalFinanceCategory)
        tx.descriptionText = plaidTx.merchantName ?? plaidTx.name
        tx.amount = abs(plaidTx.amount)
        tx.date = parseDate(plaidTx.date)
        tx.type = resolveType(plaidAmount: plaidTx.amount, mappingType: mapping.transactionType)
        tx.category = categoryMap[mapping.categoryName]
    }

    private func deleteIfExists(transactionId: String) throws {
        let txId: String? = transactionId
        var descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate { $0.plaidTransactionId == txId }
        )
        descriptor.fetchLimit = 1
        if let tx = try context.fetch(descriptor).first {
            context.delete(tx)
        }
    }

    private func buildTransaction(from plaidTx: PlaidTransaction, categoryMap: [String: Category]) -> Transaction {
        let mapping = PlaidCategoryMapper.map(plaidTx.personalFinanceCategory)
        return Transaction(
            descriptionText: plaidTx.merchantName ?? plaidTx.name,
            amount: abs(plaidTx.amount),
            date: parseDate(plaidTx.date),
            type: resolveType(plaidAmount: plaidTx.amount, mappingType: mapping.transactionType),
            isMock: false,
            source: "plaid",
            plaidTransactionId: plaidTx.transactionId,
            category: categoryMap[mapping.categoryName]
        )
    }

    /// Plaid: positive amount = money leaving (expense), negative = money entering (income).
    /// If the Plaid category explicitly indicates income, that takes precedence.
    private func resolveType(plaidAmount: Double, mappingType: String) -> String {
        if mappingType == "income" { return "income" }
        return plaidAmount >= 0 ? "expense" : "income"
    }

    private func parseDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: dateString) ?? Date()
    }
}
