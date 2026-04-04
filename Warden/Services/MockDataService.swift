//
//  MockDataService.swift
//  Warden
//

import Foundation
import SwiftData

struct MockDataService {

    static let defaultCategories: [(name: String, icon: String, order: Int)] = [
        ("Food", "fork.knife", 0),
        ("Rent", "house", 1),
        ("Transport", "car", 2),
        ("Entertainment", "tv", 3),
        ("Utilities", "bolt", 4),
        ("Shopping", "bag", 5),
        ("Health", "heart", 6),
        ("Other", "ellipsis.circle", 7)
    ]

    static let defaultMonthlyLimits: [String: Double] = [
        "Food": 500,
        "Rent": 2000,
        "Transport": 200,
        "Entertainment": 150,
        "Utilities": 300,
        "Shopping": 300,
        "Health": 150,
        "Other": 100
    ]

    static func seedDefaultCategories(context: ModelContext) {
        let descriptor = FetchDescriptor<Category>(predicate: #Predicate { $0.isDefault == true })
        let existing = (try? context.fetch(descriptor)) ?? []
        guard existing.isEmpty else { return }

        for cat in defaultCategories {
            let category = Category(name: cat.name, systemIcon: cat.icon, isDefault: true, sortOrder: cat.order)
            context.insert(category)
        }
        try? context.save()
    }

    static func generateMockTransactions(context: ModelContext, months: Int = 6) {
        let catDescriptor = FetchDescriptor<Category>()
        let categories = (try? context.fetch(catDescriptor)) ?? []
        guard !categories.isEmpty else { return }

        let calendar = Calendar.current
        let now = Date()

        let mockData: [String: [(String, Double)]] = [
            "Food": [("Grocery run", 85), ("Chipotle", 12), ("Whole Foods", 120), ("Coffee shop", 6), ("DoorDash", 35), ("Farmer's market", 45)],
            "Rent": [("Monthly rent", 1800)],
            "Transport": [("Gas station", 55), ("Uber", 18), ("Metro card", 32), ("Parking", 25)],
            "Entertainment": [("Netflix", 15), ("Movie tickets", 28), ("Concert", 65), ("Spotify", 10)],
            "Utilities": [("Electric bill", 95), ("Internet", 80), ("Water bill", 45), ("Phone bill", 75)],
            "Shopping": [("Amazon", 89), ("Target", 67), ("Clothing store", 140), ("Home goods", 55)],
            "Health": [("Gym membership", 45), ("Pharmacy", 22), ("Doctor copay", 30), ("Vitamins", 28)],
            "Other": [("Miscellaneous", 40), ("Gift", 50), ("Donation", 25)]
        ]

        for monthOffset in 0..<months {
            guard let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: now) else { continue }
            let components = calendar.dateComponents([.month, .year], from: monthDate)
            let month = components.month!
            let year = components.year!

            for category in categories {
                guard let items = mockData[category.name] else { continue }

                // Seed budget for this month
                let budgetDescriptor = FetchDescriptor<Budget>(
                    predicate: #Predicate { $0.month == month && $0.year == year }
                )
                let existingBudgets = (try? context.fetch(budgetDescriptor)) ?? []
                let budgetExists = existingBudgets.contains { $0.category?.id == category.id }

                if !budgetExists, let limit = defaultMonthlyLimits[category.name] {
                    let budget = Budget(monthlyLimit: limit, month: month, year: year, category: category)
                    context.insert(budget)
                }

                // Add transactions
                let count = Int.random(in: 1...min(items.count, 4))
                for i in 0..<count {
                    let item = items[i]
                    let dayOffset = Int.random(in: 0...27)
                    var dateComponents = DateComponents()
                    dateComponents.month = month
                    dateComponents.year = year
                    dateComponents.day = dayOffset + 1
                    let txDate = calendar.date(from: dateComponents) ?? monthDate

                    let variation = Double.random(in: 0.8...1.2)
                    let transaction = Transaction(
                        descriptionText: item.0,
                        amount: (item.1 * variation).rounded(.toNearestOrAwayFromZero),
                        date: txDate,
                        type: "expense",
                        isMock: true,
                        category: category
                    )
                    context.insert(transaction)
                }
            }

            // Add two paychecks per month (bi-weekly)
            var paycheck1Components = DateComponents()
            paycheck1Components.month = month; paycheck1Components.year = year; paycheck1Components.day = 1
            let paycheck1Date = calendar.date(from: paycheck1Components) ?? monthDate
            let paycheck1 = Transaction(
                descriptionText: "Paycheck",
                amount: 3500,
                date: paycheck1Date,
                type: "income",
                isMock: true
            )
            context.insert(paycheck1)

            var paycheck2Components = DateComponents()
            paycheck2Components.month = month; paycheck2Components.year = year; paycheck2Components.day = 15
            let paycheck2Date = calendar.date(from: paycheck2Components) ?? monthDate
            let paycheck2 = Transaction(
                descriptionText: "Paycheck",
                amount: 3500,
                date: paycheck2Date,
                type: "income",
                isMock: true
            )
            context.insert(paycheck2)
        }

        try? context.save()
    }

    static func clearAllData(context: ModelContext) {
        try? context.delete(model: Transaction.self)
        try? context.delete(model: Budget.self)

        let descriptor = FetchDescriptor<Category>(predicate: #Predicate { $0.isDefault == false })
        let customCategories = (try? context.fetch(descriptor)) ?? []
        for cat in customCategories {
            context.delete(cat)
        }
        try? context.save()
    }
}
