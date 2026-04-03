//
//  PlaidCategoryMapper.swift
//  Warden
//

import Foundation

enum PlaidCategoryMapper {

    struct MappingResult {
        let categoryName: String   // Warden Category.name
        let transactionType: String  // "expense" or "income"
    }

    static func map(_ category: PlaidPersonalFinanceCategory?) -> MappingResult {
        guard let category else {
            return MappingResult(categoryName: "Other", transactionType: "expense")
        }

        switch category.primary {
        case "FOOD_AND_DRINK":
            return MappingResult(categoryName: "Food", transactionType: "expense")

        case "RENT_AND_UTILITIES":
            let categoryName = category.detailed.contains("RENT") ? "Rent" : "Utilities"
            return MappingResult(categoryName: categoryName, transactionType: "expense")

        case "TRANSPORTATION", "TRAVEL":
            return MappingResult(categoryName: "Transport", transactionType: "expense")

        case "ENTERTAINMENT":
            return MappingResult(categoryName: "Entertainment", transactionType: "expense")

        case "GENERAL_MERCHANDISE", "HOME_IMPROVEMENT":
            return MappingResult(categoryName: "Shopping", transactionType: "expense")

        case "MEDICAL", "PERSONAL_CARE":
            return MappingResult(categoryName: "Health", transactionType: "expense")

        case "INCOME", "TRANSFER_IN":
            return MappingResult(categoryName: "Other", transactionType: "income")

        default:
            return MappingResult(categoryName: "Other", transactionType: "expense")
        }
    }
}
