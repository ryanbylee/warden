//
//  DashboardView.swift
//  Warden
//

import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
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
                        },
                        onNext: {
                            withAnimation(.spring(duration: 0.4)) {
                                viewModel.goToNextMonth()
                            }
                            viewModel.loadData(context: modelContext)
                        }
                    )

                    SpendingSummaryCard(
                        spent: viewModel.totalSpent,
                        budget: viewModel.totalBudget
                    )

                    CategoryBreakdownChart(rows: viewModel.spendingByCategory)

                    BudgetComparisonChart(rows: viewModel.spendingByCategory)
                }
                .padding()
            }
            .scrollEdgeEffectStyle(.soft, for: .top)
            .navigationTitle("Dashboard")
            .onAppear {
                viewModel.loadData(context: modelContext)
            }
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [Transaction.self, Category.self, Budget.self], inMemory: true)
}
