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
    var filterState = TransactionFilterState()
    var showingAddForm: Bool = false
    var showingFilterSheet: Bool = false
    var transactionToEdit: Transaction? = nil

    var filteredTransactions: [Transaction] {
        var result = transactions

        // 1. Search text
        if !searchText.isEmpty {
            result = result.filter {
                $0.descriptionText.localizedCaseInsensitiveContains(searchText)
            }
        }

        // 2. Category
        if let catId = filterState.selectedCategoryId {
            result = result.filter { $0.category?.id == catId }
        }

        // 3. Transaction type
        switch filterState.transactionType {
        case .all: break
        case .expense: result = result.filter { $0.type == "expense" }
        case .income:  result = result.filter { $0.type == "income" }
        }

        // 4. Date range
        if filterState.dateRangePreset == .custom {
            let calendar = Calendar.current
            let start = calendar.startOfDay(for: filterState.customStartDate)
            let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: filterState.customEndDate)) ?? filterState.customEndDate
            result = result.filter { $0.date >= start && $0.date < end }
        } else if let range = filterState.dateRangePreset.dateRange() {
            result = result.filter { $0.date >= range.start && $0.date <= range.end }
        }

        // 5. Amount range
        if let min = filterState.minAmount {
            result = result.filter { $0.amount >= min }
        }
        if let max = filterState.maxAmount {
            result = result.filter { $0.amount <= max }
        }

        // 6. Sort
        switch filterState.sortOption {
        case .dateDesc:   result.sort { $0.date > $1.date }
        case .dateAsc:    result.sort { $0.date < $1.date }
        case .amountDesc: result.sort { $0.amount > $1.amount }
        case .amountAsc:  result.sort { $0.amount < $1.amount }
        case .category:   result.sort { ($0.category?.name ?? "zzz") < ($1.category?.name ?? "zzz") }
        }

        return result
    }

    func resetFilters() {
        filterState.reset()
    }

    func selectedCategory(from categories: [Category]) -> Category? {
        guard let id = filterState.selectedCategoryId else { return nil }
        return categories.first { $0.id == id }
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
