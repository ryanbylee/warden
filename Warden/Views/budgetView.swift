//
//  BudgetView.swift
//  Warden
//

import SwiftUI
import SwiftData

struct BudgetView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = BudgetViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section("Categories") {
                    ForEach(viewModel.categoryBudgetRows) { row in
                        BudgetCategoryRow(row: row) { amount in
                            viewModel.setBudget(for: row.category, amount: amount, context: modelContext)
                        }
                    }
                }

                Section {
                    Button {
                        viewModel.showingAddCategory = true
                    } label: {
                        Label("Add Category", systemImage: "plus.circle")
                    }
                    .buttonStyle(.glassProminent)
                }
            }
            .scrollEdgeEffectStyle(.soft, for: .top)
            .navigationTitle("Budget")
            .onAppear {
                viewModel.loadData(context: modelContext)
            }
            .sheet(isPresented: $viewModel.showingAddCategory, onDismiss: {
                viewModel.loadData(context: modelContext)
            }) {
                AddCategoryView { name, icon in
                    viewModel.addCategory(name: name, icon: icon, context: modelContext)
                }
                .presentationDetents([.medium, .large])
            }
        }
    }
}

#Preview {
    BudgetView()
        .modelContainer(for: [Transaction.self, Category.self, Budget.self], inMemory: true)
}
