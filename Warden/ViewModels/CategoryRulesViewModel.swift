//
//  CategoryRulesViewModel.swift
//  Warden
//

import Foundation
import SwiftData
import Observation

@Observable
final class CategoryRulesViewModel {
    var rules: [CategoryRule] = []
    var categories: [Category] = []
    var showingAddRule: Bool = false
    var pendingUndo: UndoState? = nil

    func loadRules(context: ModelContext) {
        let ruleDescriptor = FetchDescriptor<CategoryRule>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        rules = (try? context.fetch(ruleDescriptor)) ?? []

        let catDescriptor = FetchDescriptor<Category>(
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        categories = (try? context.fetch(catDescriptor)) ?? []
    }

    func addRule(merchantPattern: String, isExactMatch: Bool, category: Category, context: ModelContext) {
        let rule = CategoryRule(merchantPattern: merchantPattern, isExactMatch: isExactMatch, category: category)
        context.insert(rule)
        try? context.save()
        loadRules(context: context)
    }

    func deleteRule(_ rule: CategoryRule, context: ModelContext) {
        // Capture snapshot before deletion
        let id = rule.id
        let merchantPattern = rule.merchantPattern
        let isExactMatch = rule.isExactMatch
        let createdAt = rule.createdAt
        let category = rule.category

        context.delete(rule)
        try? context.save()
        loadRules(context: context)

        pendingUndo = UndoState(message: "Rule deleted") {
            let restored = CategoryRule(
                id: id,
                merchantPattern: merchantPattern,
                isExactMatch: isExactMatch,
                createdAt: createdAt,
                category: category
            )
            context.insert(restored)
            try? context.save()
            self.loadRules(context: context)
        }
    }
}
