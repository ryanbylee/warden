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
        context.delete(rule)
        try? context.save()
        loadRules(context: context)
    }
}
