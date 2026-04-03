//
//  Category.swift
//  Warden
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Category {
    var id: UUID
    var name: String
    var systemIcon: String
    var isDefault: Bool
    var sortOrder: Int

    @Relationship(deleteRule: .nullify, inverse: \Transaction.category)
    var transactions: [Transaction] = []

    @Relationship(deleteRule: .nullify, inverse: \Budget.category)
    var budgets: [Budget] = []

    init(id: UUID = UUID(), name: String, systemIcon: String, isDefault: Bool = false, sortOrder: Int = 0) {
        self.id = id
        self.name = name
        self.systemIcon = systemIcon
        self.isDefault = isDefault
        self.sortOrder = sortOrder
    }

    var displayColor: Color {
        switch name {
        case "Food": return .orange
        case "Rent": return .blue
        case "Transport": return .teal
        case "Entertainment": return .purple
        case "Utilities": return .yellow
        case "Shopping": return .pink
        case "Health": return .red
        case "Other": return .gray
        default: return .accentColor
        }
    }
}
