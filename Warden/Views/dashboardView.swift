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
                VStack(spacing: 0) {
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
