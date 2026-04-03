//
//  PlaidModels.swift
//  Warden
//

import Foundation

// MARK: - Edge Function Responses

struct LinkTokenResponse: Decodable {
    let linkToken: String

    enum CodingKeys: String, CodingKey {
        case linkToken = "link_token"
    }
}

struct ExchangeTokenResponse: Decodable {
    let success: Bool
    let itemId: String

    enum CodingKeys: String, CodingKey {
        case success
        case itemId = "item_id"
    }
}

// MARK: - Sync Response

struct PlaidSyncResponse: Decodable {
    let added: [PlaidTransaction]
    let modified: [PlaidTransaction]
    let removed: [PlaidRemovedTransaction]
}

struct PlaidTransaction: Decodable {
    let transactionId: String
    let name: String
    let amount: Double
    let date: String          // "YYYY-MM-DD"
    let merchantName: String?
    let personalFinanceCategory: PlaidPersonalFinanceCategory?

    enum CodingKeys: String, CodingKey {
        case transactionId = "transaction_id"
        case name
        case amount
        case date
        case merchantName = "merchant_name"
        case personalFinanceCategory = "personal_finance_category"
    }
}

struct PlaidPersonalFinanceCategory: Decodable {
    let primary: String
    let detailed: String
}

struct PlaidRemovedTransaction: Decodable {
    let transactionId: String

    enum CodingKeys: String, CodingKey {
        case transactionId = "transaction_id"
    }
}
