//
//  DashboardViewModel.swift
//  Warden
//

import Foundation
import SwiftData
import Observation

struct SpendingRow: Identifiable {
    let id: UUID
    let category: Category
    let spent: Double
    let budgeted: Double
}

@Observable
final class DashboardViewModel {
    var selectedMonth: Int
    var selectedYear: Int
    var transactions: [Transaction] = []
    var budgets: [Budget] = []
    var categories: [Category] = []

    var totalSpent: Double {
        transactions
            .filter { $0.type == "expense" }
            .reduce(0) { $0 + $1.amount }
    }

    var totalBudget: Double {
        budgets.reduce(0) { $0 + $1.monthlyLimit }
    }

    var spendingByCategory: [SpendingRow] {
        categories.compactMap { category in
            let spent = transactions
                .filter { $0.type == "expense" && $0.category?.id == category.id }
                .reduce(0) { $0 + $1.amount }
            guard spent > 0 else { return nil }
            let budgeted = budgets.first { $0.category?.id == category.id }?.monthlyLimit ?? 0
            return SpendingRow(id: category.id, category: category, spent: spent, budgeted: budgeted)
        }
    }

    init() {
        let now = Date()
        let cal = Calendar.current
        selectedMonth = cal.component(.month, from: now)
        selectedYear = cal.component(.year, from: now)
    }

    var monthDateRange: (start: Date, end: Date) {
        var comps = DateComponents()
        comps.year = selectedYear
        comps.month = selectedMonth
        comps.day = 1
        comps.hour = 0; comps.minute = 0; comps.second = 0
        let start = Calendar.current.date(from: comps)!
        let end = Calendar.current.date(byAdding: .month, value: 1, to: start)!
        return (start, end)
    }

    func loadData(context: ModelContext) {
        let range = monthDateRange
        let startDate = range.start
        let endDate = range.end
        let month = selectedMonth
        let year = selectedYear

        let txDescriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate { tx in
                tx.date >= startDate && tx.date < endDate
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        transactions = (try? context.fetch(txDescriptor)) ?? []

        let budgetDescriptor = FetchDescriptor<Budget>(
            predicate: #Predicate { $0.month == month && $0.year == year }
        )
        budgets = (try? context.fetch(budgetDescriptor)) ?? []

        let catDescriptor = FetchDescriptor<Category>(
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        categories = (try? context.fetch(catDescriptor)) ?? []
    }

    func goToPreviousMonth() {
        if selectedMonth == 1 {
            selectedMonth = 12
            selectedYear -= 1
        } else {
            selectedMonth -= 1
        }
    }

    func goToNextMonth() {
        if selectedMonth == 12 {
            selectedMonth = 1
            selectedYear += 1
        } else {
            selectedMonth += 1
        }
    }

    var monthLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        var components = DateComponents()
        components.month = selectedMonth
        components.year = selectedYear
        components.day = 1
        let date = Calendar.current.date(from: components) ?? Date()
        return formatter.string(from: date)
    }
}
