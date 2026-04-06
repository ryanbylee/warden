//
//  DashboardView.swift
//  Warden
//

import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(SettingsViewModel.self) private var settings
    @State private var viewModel = DashboardViewModel()
    @State private var plaidViewModel = PlaidLinkViewModel()
    @State private var onboardingDismissed = UserDefaults.standard.bool(forKey: "onboardingDismissed")
    @State private var showingOnboardingTransactionForm = false
    @State private var showingOnboardingBudgetEditor = false
    @State private var onboardingBudgetCategory: Category?

    private var showSetupGuide: Bool {
        !onboardingDismissed && !viewModel.hasAnyTransactionsEver && (viewModel.transactions.isEmpty || viewModel.budgets.isEmpty)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    if showSetupGuide {
                        SetupGuideSection(
                            categories: viewModel.categories,
                            plaidViewModel: plaidViewModel,
                            hasTransactions: !viewModel.transactions.isEmpty,
                            hasBudgets: !viewModel.budgets.isEmpty,
                            onAddTransaction: { showingOnboardingTransactionForm = true },
                            onSetBudget: { category in
                                onboardingBudgetCategory = category
                                showingOnboardingBudgetEditor = true
                            },
                            onDismiss: {
                                withAnimation(.spring(duration: 0.4)) {
                                    onboardingDismissed = true
                                    UserDefaults.standard.set(true, forKey: "onboardingDismissed")
                                }
                            }
                        )
                        .padding(.bottom, 24)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    MonthPickerView(
                        label: viewModel.monthLabel,
                        onPrevious: {
                            withAnimation(.spring(duration: 0.4)) {
                                viewModel.goToPreviousMonth()
                            }
                            loadDashboard()
                        },
                        onNext: {
                            withAnimation(.spring(duration: 0.4)) {
                                viewModel.goToNextMonth()
                            }
                            loadDashboard()
                        }
                    )

                    SpendingSummaryCard(
                        spent: viewModel.totalSpent,
                        budget: viewModel.totalBudget,
                        monthOverMonthDelta: viewModel.monthOverMonthDelta
                    )
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                    .redacted(reason: viewModel.isLoading ? .placeholder : [])
                    .shimmer(when: viewModel.isLoading)

                    if settings.showIncomeExpenses {
                        IncomeExpenseCard(
                            income: viewModel.totalIncome,
                            expenses: viewModel.totalSpent
                        )
                        .padding(.bottom, 24)
                        .redacted(reason: viewModel.isLoading ? .placeholder : [])
                        .shimmer(when: viewModel.isLoading)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Details")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)

                        CategoryBreakdownChart(rows: viewModel.spendingByCategory)
                            .redacted(reason: viewModel.isLoading ? .placeholder : [])
                            .shimmer(when: viewModel.isLoading)

                        if settings.showSpendingTrends {
                            MonthlyTrendsChart(dataPoints: viewModel.trendDataPoints)
                                .redacted(reason: viewModel.isLoading ? .placeholder : [])
                                .shimmer(when: viewModel.isLoading)
                        }

                        BudgetComparisonChart(rows: viewModel.spendingByCategory)
                            .redacted(reason: viewModel.isLoading ? .placeholder : [])
                            .shimmer(when: viewModel.isLoading)
                    }
                }
                .padding()
            }
            .scrollEdgeEffectStyle(.soft, for: .top)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Dashboard")
            .onAppear {
                loadDashboard()
            }
            .sheet(isPresented: $showingOnboardingTransactionForm) {
                TransactionFormView(mode: .add, categories: viewModel.categories) { tx in
                    modelContext.insert(tx)
                    try? modelContext.save()
                    loadDashboard()
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showingOnboardingBudgetEditor) {
                if let category = onboardingBudgetCategory {
                    BudgetEditorSheet(
                        categoryName: category.name,
                        categoryIcon: category.systemIcon,
                        categoryColor: category.displayColor,
                        currentBudget: nil,
                        onSave: { amount in
                            let cal = Calendar.current
                            let now = Date()
                            let budget = Budget(
                                monthlyLimit: amount,
                                month: cal.component(.month, from: now),
                                year: cal.component(.year, from: now),
                                category: category
                            )
                            modelContext.insert(budget)
                            try? modelContext.save()
                            loadDashboard()
                        }
                    )
                    .presentationDetents([.height(280)])
                }
            }
            .onChange(of: plaidViewModel.isConnected) { _, connected in
                if connected {
                    Task {
                        await plaidViewModel.syncTransactions(context: modelContext)
                        loadDashboard()
                    }
                }
            }
        }
    }

    private func loadDashboard() {
        viewModel.isLoading = true
        Task { @MainActor in
            await Task.yield()
            viewModel.loadData(context: modelContext)
            viewModel.loadTrendData(context: modelContext)
            withAnimation(.easeOut(duration: 0.3)) {
                viewModel.isLoading = false
            }
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [Transaction.self, Category.self, Budget.self], inMemory: true)
        .environment(SettingsViewModel())
}
