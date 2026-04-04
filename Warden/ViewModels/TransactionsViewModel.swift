//
//  TransactionsViewModel.swift
//  Warden
//

import Foundation
import SwiftData
import Observation

struct RuleSuggestion: Identifiable {
    let id = UUID()
    let merchantName: String
    let category: Category
}

@Observable
final class TransactionsViewModel {
    var transactions: [Transaction] = []
    var categories: [Category] = []
    var searchText: String = ""
    var selectedCategory: Category? = nil
    var showingAddForm: Bool = false
    var transactionToEdit: Transaction? = nil
    var pendingRuleSuggestion: RuleSuggestion? = nil

    var filteredTransactions: [Transaction] {
        transactions.filter { tx in
            let matchesSearch = searchText.isEmpty ||
                tx.descriptionText.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == nil ||
                tx.category?.id == selectedCategory?.id
            return matchesSearch && matchesCategory
        }
    }

    func loadTransactions(context: ModelContext) {
        let descriptor = FetchDescriptor<Transaction>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        transactions = (try? context.fetch(descriptor)) ?? []

        let catDescriptor = FetchDescriptor<Category>(
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        categories = (try? context.fetch(catDescriptor)) ?? []
    }

    func addTransaction(_ transaction: Transaction, context: ModelContext) {
        context.insert(transaction)
        try? context.save()
        loadTransactions(context: context)
    }

    func updateTransaction(_ transaction: Transaction, context: ModelContext) {
        try? context.save()
        loadTransactions(context: context)
    }

    func deleteTransaction(_ transaction: Transaction, context: ModelContext) {
        context.delete(transaction)
        try? context.save()
        loadTransactions(context: context)
    }

    func recategorizeTransaction(_ transaction: Transaction, to category: Category, context: ModelContext) {
        transaction.category = category
        try? context.save()
        loadTransactions(context: context)

        if transaction.source == "plaid" {
            pendingRuleSuggestion = RuleSuggestion(
                merchantName: transaction.descriptionText,
                category: category
            )
        }
    }

    func createRuleFromSuggestion(context: ModelContext) {
        guard let suggestion = pendingRuleSuggestion else { return }
        let rule = CategoryRule(
            merchantPattern: suggestion.merchantName,
            isExactMatch: false,
            category: suggestion.category
        )
        context.insert(rule)
        try? context.save()
        pendingRuleSuggestion = nil
    }

    func dismissRuleSuggestion() {
        pendingRuleSuggestion = nil
    }
}
