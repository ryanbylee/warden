//
//  Transaction.swift
//  Warden
//

import Foundation
import SwiftData

enum TransactionType: String, CaseIterable {
    case expense = "expense"
    case income = "income"
}

@Model
final class Transaction {
    var id: UUID
    var descriptionText: String
    var amount: Double
    var date: Date
    var type: String
    var isMock: Bool

    var source: String = "manual"   // "manual", "plaid", "mock"
    var plaidTransactionId: String?

    var category: Category?

    var transactionType: TransactionType {
        TransactionType(rawValue: type) ?? .expense
    }

    init(id: UUID = UUID(), descriptionText: String, amount: Double, date: Date = Date(), type: String = "expense", isMock: Bool = false, source: String = "manual", plaidTransactionId: String? = nil, category: Category? = nil) {
        self.id = id
        self.descriptionText = descriptionText
        self.amount = amount
        self.date = date
        self.type = type
        self.isMock = isMock
        self.source = source
        self.plaidTransactionId = plaidTransactionId
        self.category = category
    }
}
