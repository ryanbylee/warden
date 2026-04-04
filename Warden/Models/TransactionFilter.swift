//
//  TransactionFilter.swift
//  Warden
//

import Foundation
import SwiftData

// MARK: - Sort

enum TransactionSortOption: String, CaseIterable, Identifiable {
    case dateDesc   = "Newest First"
    case dateAsc    = "Oldest First"
    case amountDesc = "Highest Amount"
    case amountAsc  = "Lowest Amount"
    case category   = "Category"

    var id: String { rawValue }
}

// MARK: - Date Range Presets

enum DateRangePreset: String, CaseIterable, Identifiable {
    case all        = "All Time"
    case today      = "Today"
    case thisWeek   = "This Week"
    case thisMonth  = "This Month"
    case last30Days = "Last 30 Days"
    case last90Days = "Last 90 Days"
    case thisYear   = "This Year"
    case custom     = "Custom Range"

    var id: String { rawValue }

    func dateRange() -> (start: Date, end: Date)? {
        let calendar = Calendar.current
        let now = Date()
        switch self {
        case .all:
            return nil
        case .today:
            return (calendar.startOfDay(for: now), now)
        case .thisWeek:
            let start = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            return (start, now)
        case .thisMonth:
            let start = calendar.dateInterval(of: .month, for: now)?.start ?? now
            return (start, now)
        case .last30Days:
            return (calendar.date(byAdding: .day, value: -30, to: now) ?? now, now)
        case .last90Days:
            return (calendar.date(byAdding: .day, value: -90, to: now) ?? now, now)
        case .thisYear:
            let start = calendar.dateInterval(of: .year, for: now)?.start ?? now
            return (start, now)
        case .custom:
            return nil
        }
    }
}

// MARK: - Transaction Type Filter

enum TransactionTypeFilter: String, CaseIterable, Identifiable {
    case all     = "All"
    case expense = "Expenses"
    case income  = "Income"

    var id: String { rawValue }
}

// MARK: - Aggregate Filter State

struct TransactionFilterState {
    var sortOption: TransactionSortOption = .dateDesc
    var selectedCategoryId: UUID? = nil
    var transactionType: TransactionTypeFilter = .all
    var dateRangePreset: DateRangePreset = .all
    var customStartDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    var customEndDate: Date = Date()
    var minAmount: Double? = nil
    var maxAmount: Double? = nil

    var activeFilterCount: Int {
        var count = 0
        if selectedCategoryId != nil { count += 1 }
        if transactionType != .all { count += 1 }
        if dateRangePreset != .all { count += 1 }
        if minAmount != nil || maxAmount != nil { count += 1 }
        return count
    }

    var isDefault: Bool {
        selectedCategoryId == nil
            && transactionType == .all
            && dateRangePreset == .all
            && minAmount == nil
            && maxAmount == nil
    }

    mutating func reset() {
        selectedCategoryId = nil
        transactionType = .all
        dateRangePreset = .all
        customStartDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        customEndDate = Date()
        minAmount = nil
        maxAmount = nil
    }
}
