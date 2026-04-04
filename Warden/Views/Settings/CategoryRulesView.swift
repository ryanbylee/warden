//
//  CategoryRulesView.swift
//  Warden
//

import SwiftUI
import SwiftData

struct CategoryRulesView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = CategoryRulesViewModel()

    var body: some View {
        List {
            if viewModel.rules.isEmpty {
                ContentUnavailableView(
                    "No Rules",
                    systemImage: "arrow.triangle.swap",
                    description: Text("Add a rule to automatically categorize transactions from specific merchants.")
                )
            } else {
                ForEach(viewModel.rules) { rule in
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(rule.merchantPattern)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(rule.isExactMatch ? "Exact match" : "Contains")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if let category = rule.category {
                            HStack(spacing: 6) {
                                Image(systemName: category.systemIcon)
                                    .font(.caption)
                                    .foregroundStyle(category.displayColor)
                                Text(category.name)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 2)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewModel.deleteRule(rule, context: modelContext)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .scrollEdgeEffectStyle(.soft, for: .top)
        .navigationTitle("Category Rules")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.showingAddRule = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.showingAddRule) {
            CategoryRuleFormView(categories: viewModel.categories) { pattern, exactMatch, category in
                viewModel.addRule(merchantPattern: pattern, isExactMatch: exactMatch, category: category, context: modelContext)
            }
            .presentationDetents([.medium])
        }
        .onAppear {
            viewModel.loadRules(context: modelContext)
        }
    }
}

#Preview {
    NavigationStack {
        CategoryRulesView()
            .modelContainer(for: [Transaction.self, Category.self, Budget.self, CategoryRule.self], inMemory: true)
    }
}
