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
        let rules = try fetchRules()

        for plaidTx in response.added {
            try insertIfNeeded(plaidTx, categoryMap: categoryMap, rules: rules)
        }
        for plaidTx in response.modified {
            try updateIfExists(plaidTx, categoryMap: categoryMap, rules: rules)
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

    private func fetchRules() throws -> [CategoryRule] {
        // Fetch newest first, then stable-sort so exact matches take priority over contains matches
        let descriptor = FetchDescriptor<CategoryRule>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let all = try context.fetch(descriptor)
        return all.sorted { $0.isExactMatch && !$1.isExactMatch }
    }

    private func matchRule(for description: String, rules: [CategoryRule]) -> CategoryRule? {
        let lower = description.lowercased()
        return rules.first { rule in
            let pattern = rule.merchantPattern.lowercased()
            return rule.isExactMatch ? lower == pattern : lower.contains(pattern)
        }
    }

    private func insertIfNeeded(_ plaidTx: PlaidTransaction, categoryMap: [String: Category], rules: [CategoryRule]) throws {
        let txId: String? = plaidTx.transactionId
        var descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate { $0.plaidTransactionId == txId }
        )
        descriptor.fetchLimit = 1
        guard try context.fetch(descriptor).isEmpty else { return }

        let tx = buildTransaction(from: plaidTx, categoryMap: categoryMap, rules: rules)
        context.insert(tx)
    }

    private func updateIfExists(_ plaidTx: PlaidTransaction, categoryMap: [String: Category], rules: [CategoryRule]) throws {
        let txId: String? = plaidTx.transactionId
        var descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate { $0.plaidTransactionId == txId }
        )
        descriptor.fetchLimit = 1
        guard let tx = try context.fetch(descriptor).first else { return }

        let description = plaidTx.merchantName ?? plaidTx.name
        tx.descriptionText = description
        tx.amount = abs(plaidTx.amount)
        tx.date = parseDate(plaidTx.date)

        if let matchedRule = matchRule(for: description, rules: rules) {
            tx.category = matchedRule.category
            tx.type = plaidTx.amount >= 0 ? "expense" : "income"
        } else {
            let mapping = PlaidCategoryMapper.map(plaidTx.personalFinanceCategory)
            tx.type = resolveType(plaidAmount: plaidTx.amount, mappingType: mapping.transactionType)
            tx.category = categoryMap[mapping.categoryName]
        }
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

    private func buildTransaction(from plaidTx: PlaidTransaction, categoryMap: [String: Category], rules: [CategoryRule]) -> Transaction {
        let description = plaidTx.merchantName ?? plaidTx.name
        let category: Category?
        let type: String

        if let matchedRule = matchRule(for: description, rules: rules) {
            category = matchedRule.category
            type = plaidTx.amount >= 0 ? "expense" : "income"
        } else {
            let mapping = PlaidCategoryMapper.map(plaidTx.personalFinanceCategory)
            category = categoryMap[mapping.categoryName]
            type = resolveType(plaidAmount: plaidTx.amount, mappingType: mapping.transactionType)
        }

        return Transaction(
            descriptionText: description,
            amount: abs(plaidTx.amount),
            date: parseDate(plaidTx.date),
            type: type,
            isMock: false,
            source: "plaid",
            plaidTransactionId: plaidTx.transactionId,
            category: category
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
