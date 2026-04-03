//
//  TransactionsViewModel.swift
//  Warden
//

import Foundation
import SwiftData
import Observation

@Observable
final class TransactionsViewModel {
    var transactions: [Transaction] = []
    var categories: [Category] = []
    var searchText: String = ""
    var selectedCategory: Category? = nil
    var showingAddForm: Bool = false
    var transactionToEdit: Transaction? = nil

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
}
