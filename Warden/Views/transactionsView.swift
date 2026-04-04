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
                if !viewModel.filteredTransactions.isEmpty {
                    ForEach(viewModel.filteredTransactions) { transaction in
                        TransactionRowView(transaction: transaction)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.transactionToEdit = transaction
                            }
                            .contextMenu {
                                Menu("Recategorize") {
                                    ForEach(viewModel.categories) { cat in
                                        Button {
                                            viewModel.recategorizeTransaction(transaction, to: cat, context: modelContext)
                                        } label: {
                                            Label(cat.name, systemImage: cat.systemIcon)
                                        }
                                    }
                                }
                                Button {
                                    viewModel.transactionToEdit = transaction
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                Button(role: .destructive) {
                                    viewModel.deleteTransaction(transaction, context: modelContext)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.deleteTransaction(transaction, context: modelContext)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                } else {
                    ContentUnavailableView(
                        "No Transactions",
                        systemImage: "list.bullet",
                        description: Text("Add your first transaction using the + button.")
                    )
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showingAddForm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Picker("Filter", selection: $viewModel.selectedCategory) {
                        Text("All").tag(Optional<Category>(nil))
                        ForEach(viewModel.categories) { cat in
                            Label(cat.name, systemImage: cat.systemIcon)
                                .tag(Optional(cat))
                        }
                    }
                    .pickerStyle(.menu)
                }
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
            .alert("Create Category Rule?", isPresented: Binding(
                get: { viewModel.pendingRuleSuggestion != nil },
                set: { if !$0 { viewModel.dismissRuleSuggestion() } }
            )) {
                Button("Create Rule") {
                    viewModel.createRuleFromSuggestion(context: modelContext)
                }
                Button("Just This Once", role: .cancel) {
                    viewModel.dismissRuleSuggestion()
                }
            } message: {
                if let suggestion = viewModel.pendingRuleSuggestion {
                    Text("Always categorize \"\(suggestion.merchantName)\" as \(suggestion.category.name)?")
                }
            }
            .onAppear {
                viewModel.loadTransactions(context: modelContext)
            }
        }
    }
}

#Preview {
    TransactionsView()
        .modelContainer(for: [Transaction.self, Category.self, Budget.self, CategoryRule.self], inMemory: true)
}
