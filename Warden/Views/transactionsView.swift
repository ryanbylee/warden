//
//  TransactionsView.swift
//  Warden
//

import SwiftUI
import SwiftData

struct TransactionsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TransactionsViewModel()
    @State private var plaidViewModel = PlaidLinkViewModel()

    var body: some View {
        NavigationStack {
            List {
                // Active filter chips
                if viewModel.filterState.activeFilterCount > 0 {
                    filterChipsSection
                }

                if !viewModel.filteredTransactions.isEmpty {
                    ForEach(viewModel.filteredTransactions) { transaction in
                        TransactionRowView(transaction: transaction)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.transactionToEdit = transaction
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.deleteTransaction(transaction, context: modelContext)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                } else if viewModel.transactions.isEmpty {
                    ContentUnavailableView(
                        "No Transactions",
                        systemImage: "list.bullet",
                        description: Text("Add your first transaction using the + button.")
                    )
                } else {
                    ContentUnavailableView {
                        Label("No Results", systemImage: "magnifyingglass")
                    } description: {
                        Text("Try adjusting your filters or search term.")
                    } actions: {
                        Button("Clear Filters") {
                            withAnimation {
                                viewModel.searchText = ""
                                viewModel.resetFilters()
                            }
                        }
                    }
                }
            }
            .refreshable {
                if plaidViewModel.isConnected {
                    await plaidViewModel.syncTransactions(context: modelContext)
                    viewModel.loadTransactions(context: modelContext)
                }
            }
            .scrollEdgeEffectStyle(.soft, for: .top)
            .animation(.spring(duration: 0.3), value: viewModel.filteredTransactions.count)
            .navigationTitle("Transactions")
            .searchable(text: $viewModel.searchText, prompt: "Search transactions")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    filterButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    sortMenu
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showingAddForm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingFilterSheet) {
                TransactionFilterView(
                    filterState: $viewModel.filterState,
                    categories: viewModel.categories
                )
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $viewModel.showingAddForm) {
                TransactionFormView(mode: .add, categories: viewModel.categories) { tx in
                    viewModel.addTransaction(tx, context: modelContext)
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(item: $viewModel.transactionToEdit) { tx in
                TransactionFormView(mode: .edit(tx), categories: viewModel.categories) { updated in
                    viewModel.updateTransaction(updated, context: modelContext)
                }
                .presentationDetents([.medium, .large])
            }
            .onAppear {
                viewModel.loadTransactions(context: modelContext)
            }
        }
    }

    // MARK: - Filter Button

    private var filterButton: some View {
        Button {
            viewModel.showingFilterSheet = true
        } label: {
            Image(systemName: viewModel.filterState.activeFilterCount > 0
                  ? "line.3.horizontal.decrease.circle.fill"
                  : "line.3.horizontal.decrease.circle")
        }
        .overlay(alignment: .topTrailing) {
            if viewModel.filterState.activeFilterCount > 0 {
                Text("\(viewModel.filterState.activeFilterCount)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(minWidth: 16, minHeight: 16)
                    .background(.red, in: Circle())
                    .offset(x: 8, y: -8)
            }
        }
    }

    // MARK: - Sort Menu

    private var sortMenu: some View {
        Menu {
            Picker("Sort", selection: $viewModel.filterState.sortOption) {
                ForEach(TransactionSortOption.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
        }
    }

    // MARK: - Filter Chips

    private var filterChipsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let catId = viewModel.filterState.selectedCategoryId,
                   let cat = viewModel.categories.first(where: { $0.id == catId }) {
                    FilterChipView(label: cat.name, icon: cat.systemIcon) {
                        withAnimation { viewModel.filterState.selectedCategoryId = nil }
                    }
                }

                if viewModel.filterState.transactionType != .all {
                    FilterChipView(
                        label: viewModel.filterState.transactionType.rawValue,
                        icon: "arrow.left.arrow.right"
                    ) {
                        withAnimation { viewModel.filterState.transactionType = .all }
                    }
                }

                if viewModel.filterState.dateRangePreset != .all {
                    FilterChipView(
                        label: viewModel.filterState.dateRangePreset.rawValue,
                        icon: "calendar"
                    ) {
                        withAnimation { viewModel.filterState.dateRangePreset = .all }
                    }
                }

                if viewModel.filterState.minAmount != nil || viewModel.filterState.maxAmount != nil {
                    FilterChipView(
                        label: amountRangeLabel,
                        icon: "dollarsign"
                    ) {
                        withAnimation {
                            viewModel.filterState.minAmount = nil
                            viewModel.filterState.maxAmount = nil
                        }
                    }
                }

                Button {
                    withAnimation { viewModel.resetFilters() }
                } label: {
                    Text("Clear All")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 4)
        }
        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    private var amountRangeLabel: String {
        let min = viewModel.filterState.minAmount
        let max = viewModel.filterState.maxAmount
        switch (min, max) {
        case let (min?, max?):
            return "$\(Int(min))–$\(Int(max))"
        case let (min?, nil):
            return "$\(Int(min))+"
        case let (nil, max?):
            return "Up to $\(Int(max))"
        default:
            return ""
        }
    }
}

#Preview {
    TransactionsView()
        .modelContainer(for: [Transaction.self, Category.self, Budget.self], inMemory: true)
}
