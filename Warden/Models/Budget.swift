//
//  Budget.swift
//  Warden
//

import Foundation
import SwiftData

@Model
final class Budget {
    var id: UUID
    var monthlyLimit: Double
    var month: Int
    var year: Int

    var category: Category?

    init(id: UUID = UUID(), monthlyLimit: Double, month: Int, year: Int, category: Category? = nil) {
        self.id = id
        self.monthlyLimit = monthlyLimit
        self.month = month
        self.year = year
        self.category = category
    }
}
