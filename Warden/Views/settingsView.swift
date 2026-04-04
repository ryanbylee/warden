//
//  SettingsView.swift
//  Warden
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SettingsViewModel()
    @State private var showingClearConfirm = false
    @State private var showingSampleDataConfirm = false

    let currencies = ["USD", "EUR", "GBP", "JPY", "KRW"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Preferences") {
                    Picker("Currency", selection: Binding(
                        get: { viewModel.currencyCode },
                        set: { viewModel.saveCurrencyCode($0) }
                    )) {
                        ForEach(currencies, id: \.self) { code in
                            Text(code).tag(code)
                        }
                    }
                }

                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: Binding(
                        get: { viewModel.notificationsEnabled },
                        set: { viewModel.saveNotificationsEnabled($0) }
                    ))
                    Toggle("Over-Budget Alerts", isOn: Binding(
                        get: { viewModel.overBudgetAlerts },
                        set: { viewModel.saveOverBudgetAlerts($0) }
                    ))
                    .disabled(!viewModel.notificationsEnabled)
                }

                Section("Bank Connection") {
                    BankConnectionView()
                }

                Section("Category Rules") {
                    NavigationLink {
                        CategoryRulesView()
                    } label: {
                        Label("Manage Rules", systemImage: "arrow.triangle.swap")
                    }
                }

                Section("Data") {
                    Button("Load Sample Data") {
                        showingSampleDataConfirm = true
                    }

                    Button("Clear All Data", role: .destructive) {
                        showingClearConfirm = true
                    }
                }

                Section("About") {
                    LabeledContent("Version", value: viewModel.appVersion)
                    LabeledContent("Developer", value: "Ryan Lee")
                }
            }
            .scrollEdgeEffectStyle(.soft, for: .top)
            .navigationTitle("Settings")
            .alert("Load Sample Data?", isPresented: $showingSampleDataConfirm) {
                Button("Load") {
                    MockDataService.generateMockTransactions(context: modelContext)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will add mock transactions and budgets for the last 3 months.")
            }
            .alert("Clear All Data?", isPresented: $showingClearConfirm) {
                Button("Clear", role: .destructive) {
                    MockDataService.clearAllData(context: modelContext)
                    MockDataService.seedDefaultCategories(context: modelContext)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will delete all transactions, budgets, and custom categories. Default categories will be kept.")
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [Transaction.self, Category.self, Budget.self, CategoryRule.self], inMemory: true)
}
