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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    MonthPickerView(
                        label: viewModel.monthLabel,
                        onPrevious: {
                            withAnimation(.spring(duration: 0.4)) {
                                viewModel.goToPreviousMonth()
                            }
                            viewModel.loadData(context: modelContext)
                            viewModel.loadTrendData(context: modelContext)
                        },
                        onNext: {
                            withAnimation(.spring(duration: 0.4)) {
                                viewModel.goToNextMonth()
                            }
                            viewModel.loadData(context: modelContext)
                            viewModel.loadTrendData(context: modelContext)
                        }
                    )

                    SpendingSummaryCard(
                        spent: viewModel.totalSpent,
                        budget: viewModel.totalBudget
                    )

                    if settings.showIncomeExpenses {
                        IncomeExpenseCard(
                            income: viewModel.totalIncome,
                            expenses: viewModel.totalSpent
                        )
                    }

                    CategoryBreakdownChart(rows: viewModel.spendingByCategory)

                    if settings.showSpendingTrends {
                        MonthlyTrendsChart(
                            dataPoints: viewModel.trendDataPoints,
                            monthOverMonthDelta: viewModel.monthOverMonthDelta
                        )
                    }

                    BudgetComparisonChart(rows: viewModel.spendingByCategory)
                }
                .padding()
            }
            .scrollEdgeEffectStyle(.soft, for: .top)
            .navigationTitle("Dashboard")
            .onAppear {
                viewModel.loadData(context: modelContext)
                viewModel.loadTrendData(context: modelContext)
            }
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [Transaction.self, Category.self, Budget.self], inMemory: true)
        .environment(SettingsViewModel())
}
