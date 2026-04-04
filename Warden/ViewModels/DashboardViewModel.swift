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

struct MonthlyTrendPoint: Identifiable {
    let id = UUID()
    let monthDate: Date       // First day of month (for X-axis sorting)
    let categoryName: String
    let total: Double
}

struct MonthlySummary {
    let monthDate: Date
    let totalExpenses: Double
    let totalIncome: Double
    var netSavings: Double { totalIncome - totalExpenses }
}

@Observable
final class DashboardViewModel {
    var selectedMonth: Int
    var selectedYear: Int
    var transactions: [Transaction] = []
    var budgets: [Budget] = []
    var categories: [Category] = []
    var monthlySummaries: [MonthlySummary] = []
    var trendDataPoints: [MonthlyTrendPoint] = []

    var totalSpent: Double {
        transactions
            .filter { $0.type == "expense" }
            .reduce(0) { $0 + $1.amount }
    }

    var totalBudget: Double {
        budgets.reduce(0) { $0 + $1.monthlyLimit }
    }

    var totalIncome: Double {
        transactions
            .filter { $0.type == "income" }
            .reduce(0) { $0 + $1.amount }
    }

    var netSavings: Double {
        totalIncome - totalSpent
    }

    var monthOverMonthDelta: Double? {
        let cal = Calendar.current
        var comps = DateComponents()
        comps.year = selectedYear; comps.month = selectedMonth; comps.day = 1
        guard let currentDate = cal.date(from: comps),
              let previousDate = cal.date(byAdding: .month, value: -1, to: currentDate) else { return nil }
        let current = monthlySummaries.first { cal.isDate($0.monthDate, equalTo: currentDate, toGranularity: .month) }
        let previous = monthlySummaries.first { cal.isDate($0.monthDate, equalTo: previousDate, toGranularity: .month) }
        guard let c = current?.totalExpenses, let p = previous?.totalExpenses, p > 0 else { return nil }
        return ((c - p) / p) * 100
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

    func loadTrendData(context: ModelContext) {
        let cal = Calendar.current
        var comps = DateComponents()
        comps.year = selectedYear; comps.month = selectedMonth; comps.day = 1
        guard let selectedMonthStart = cal.date(from: comps),
              let endDate = cal.date(byAdding: .month, value: 1, to: selectedMonthStart),
              let startDate = cal.date(byAdding: .month, value: -5, to: selectedMonthStart)
        else { return }

        // Single fetch covering the entire 6-month window
        let descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate { tx in
                tx.date >= startDate && tx.date < endDate
            },
            sortBy: [SortDescriptor(\.date)]
        )
        let allTransactions = (try? context.fetch(descriptor)) ?? []

        // Initialize all 6 months so months with zero spend still appear
        var summariesDict: [Date: (expenses: Double, income: Double)] = [:]
        for offset in 0..<6 {
            if let monthStart = cal.date(byAdding: .month, value: offset, to: startDate) {
                let normalized = cal.startOfMonth(for: monthStart)
                summariesDict[normalized] = (0, 0)
            }
        }

        // Aggregate transactions into their respective months
        for tx in allTransactions {
            let monthStart = cal.startOfMonth(for: tx.date)
            var entry = summariesDict[monthStart] ?? (0, 0)
            if tx.type == "expense" {
                entry.expenses += tx.amount
            } else if tx.type == "income" {
                entry.income += tx.amount
            }
            summariesDict[monthStart] = entry
        }

        monthlySummaries = summariesDict.map { (date, totals) in
            MonthlySummary(monthDate: date, totalExpenses: totals.expenses, totalIncome: totals.income)
        }.sorted { $0.monthDate < $1.monthDate }

        // Build trend points for top 5 spending categories (by total across 6 months)
        let expenseTransactions = allTransactions.filter { $0.type == "expense" }

        var categoryTotals: [String: Double] = [:]
        for tx in expenseTransactions {
            let name = tx.category?.name ?? "Other"
            categoryTotals[name, default: 0] += tx.amount
        }

        let topCategories = Set(
            categoryTotals.sorted { $0.value > $1.value }
                .prefix(5)
                .map { $0.key }
        )

        var points: [MonthlyTrendPoint] = []
        for summary in monthlySummaries {
            let monthTxs = expenseTransactions.filter {
                cal.isDate($0.date, equalTo: summary.monthDate, toGranularity: .month)
            }
            for categoryName in topCategories {
                let total = monthTxs
                    .filter { ($0.category?.name ?? "Other") == categoryName }
                    .reduce(0) { $0 + $1.amount }
                points.append(MonthlyTrendPoint(
                    monthDate: summary.monthDate,
                    categoryName: categoryName,
                    total: total
                ))
            }
        }

        trendDataPoints = points.sorted { $0.monthDate < $1.monthDate }
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

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let comps = dateComponents([.year, .month], from: date)
        return self.date(from: comps)!
    }
}
