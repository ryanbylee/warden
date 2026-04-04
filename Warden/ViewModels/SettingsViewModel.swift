//
//  SettingsViewModel.swift
//  Warden
//

import Foundation
import Observation

@Observable
final class SettingsViewModel {
    var currencyCode: String = "USD"
    var notificationsEnabled: Bool = false
    var overBudgetAlerts: Bool = false
    var showSpendingTrends: Bool = true
    var showIncomeExpenses: Bool = true
    let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"

    init() {
        loadSettings()
    }

    func loadSettings() {
        currencyCode = UserDefaults.standard.string(forKey: "currencyCode") ?? "USD"
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        overBudgetAlerts = UserDefaults.standard.bool(forKey: "overBudgetAlerts")
        showSpendingTrends = UserDefaults.standard.object(forKey: "showSpendingTrends") as? Bool ?? true
        showIncomeExpenses = UserDefaults.standard.object(forKey: "showIncomeExpenses") as? Bool ?? true
    }

    func saveCurrencyCode(_ code: String) {
        currencyCode = code
        UserDefaults.standard.set(code, forKey: "currencyCode")
    }

    func saveNotificationsEnabled(_ value: Bool) {
        notificationsEnabled = value
        UserDefaults.standard.set(value, forKey: "notificationsEnabled")
    }

    func saveOverBudgetAlerts(_ value: Bool) {
        overBudgetAlerts = value
        UserDefaults.standard.set(value, forKey: "overBudgetAlerts")
    }

    func saveShowSpendingTrends(_ value: Bool) {
        showSpendingTrends = value
        UserDefaults.standard.set(value, forKey: "showSpendingTrends")
    }

    func saveShowIncomeExpenses(_ value: Bool) {
        showIncomeExpenses = value
        UserDefaults.standard.set(value, forKey: "showIncomeExpenses")
    }
}
