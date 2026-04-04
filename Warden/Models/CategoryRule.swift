//
//  CategoryRule.swift
//  Warden
//

import Foundation
import SwiftData

@Model
final class CategoryRule {
    var id: UUID
    var merchantPattern: String
    var isExactMatch: Bool
    var createdAt: Date

    var category: Category?

    init(id: UUID = UUID(), merchantPattern: String, isExactMatch: Bool = false,
         createdAt: Date = Date(), category: Category? = nil) {
        self.id = id
        self.merchantPattern = merchantPattern
        self.isExactMatch = isExactMatch
        self.createdAt = createdAt
        self.category = category
    }
}
