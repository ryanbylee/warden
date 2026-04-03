//
//  BudgetViewModel.swift
//  Warden
//

import Foundation
import SwiftData
import Observation

struct CategoryBudgetRow: Identifiable {
    let id: UUID
    let category: Category
    let budget: Budget?
    let spent: Double
}

@Observable
final class BudgetViewModel {
    var budgets: [Budget] = []
    var categories: [Category] = []
    var allExpenses: [Transaction] = []
    var currentMonth: Int
    var currentYear: Int
    var showingAddCategory: Bool = false

    var categoryBudgetRows: [CategoryBudgetRow] {
        categories.map { category in
            let budget = budgets.first { $0.category?.id == category.id }
            let spent = allExpenses
                .filter { $0.category?.id == category.id }
                .reduce(0) { $0 + $1.amount }
            return CategoryBudgetRow(id: category.id, category: category, budget: budget, spent: spent)
        }
    }

    init() {
        let now = Date()
        let cal = Calendar.current
        currentMonth = cal.component(.month, from: now)
        currentYear = cal.component(.year, from: now)
    }

    func loadData(context: ModelContext) {
        let month = currentMonth
        let year = currentYear

        let budgetDescriptor = FetchDescriptor<Budget>(
            predicate: #Predicate { $0.month == month && $0.year == year }
        )
        budgets = (try? context.fetch(budgetDescriptor)) ?? []

        let catDescriptor = FetchDescriptor<Category>(
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        categories = (try? context.fetch(catDescriptor)) ?? []

        var comps = DateComponents()
        comps.year = year; comps.month = month; comps.day = 1
        let startDate = Calendar.current.date(from: comps)!
        let endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)!

        let txDescriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate { tx in
                tx.type == "expense" && tx.date >= startDate && tx.date < endDate
            }
        )
        allExpenses = (try? context.fetch(txDescriptor)) ?? []
    }

    func setBudget(for category: Category, amount: Double, context: ModelContext) {
        if let existing = budgets.first(where: { $0.category?.id == category.id }) {
            existing.monthlyLimit = amount
        } else {
            let budget = Budget(monthlyLimit: amount, month: currentMonth, year: currentYear, category: category)
            context.insert(budget)
        }
        try? context.save()
        loadData(context: context)
    }

    func addCategory(name: String, icon: String, context: ModelContext) {
        let maxOrder = (categories.map { $0.sortOrder }.max() ?? 0) + 1
        let category = Category(name: name, systemIcon: icon, isDefault: false, sortOrder: maxOrder)
        context.insert(category)
        try? context.save()
        loadData(context: context)
    }
}
