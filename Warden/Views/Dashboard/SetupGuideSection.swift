//
//  SetupGuideSection.swift
//  Warden
//

import SwiftUI
import SwiftData

struct SetupGuideSection: View {
    let categories: [Category]
    @Bindable var plaidViewModel: PlaidLinkViewModel
    let hasTransactions: Bool
    let hasBudgets: Bool
    let onAddTransaction: () -> Void
    let onSetBudget: (Category) -> Void
    let onDismiss: () -> Void

    @State private var bankStepSkipped = false
    @State private var selectedBudgetCategory: Category?

    private var isBankDone: Bool {
        plaidViewModel.isConnected || bankStepSkipped
    }

    private var completedCount: Int {
        var count = 0
        if isBankDone { count += 1 }
        if hasTransactions { count += 1 }
        if hasBudgets { count += 1 }
        return count
    }

    private var isCompletelyEmpty: Bool {
        !isBankDone && !hasTransactions && !hasBudgets
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Welcome header — only when completely empty
            if isCompletelyEmpty {
                welcomeHeader
            }

            // Step 1: Bank connection
            if !isBankDone {
                bankConnectionCard
            } else if !hasTransactions || !hasBudgets {
                completedStepRow(icon: "building.columns", title: "Bank connected")
            }

            // Step 2: Add transaction
            if !hasTransactions {
                addTransactionCard
            } else if !hasBudgets {
                completedStepRow(icon: "plus.circle", title: "Transaction added")
            }

            // Step 3: Set budget
            if !hasBudgets {
                setBudgetCard
            }

            // Dismiss link
            if completedCount < 3 {
                Button {
                    onDismiss()
                } label: {
                    Text("I'll explore on my own")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
        }
    }

    // MARK: - Welcome Header

    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Welcome to Warden")
                .font(.title2)
                .fontWeight(.bold)
            Text("Let's get your finances set up. This only takes a minute.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 8)
    }

    // MARK: - Step 1: Bank Connection

    private var bankConnectionCard: some View {
        setupCard {
            VStack(alignment: .leading, spacing: 12) {
                stepHeader(
                    number: "1",
                    icon: "building.columns",
                    title: "Connect your bank",
                    subtitle: "Automatically import transactions from your bank account."
                )

                Button {
                    Task { await plaidViewModel.startLinkFlow() }
                } label: {
                    if plaidViewModel.isLoadingLinkToken {
                        Label("Connecting...", systemImage: "building.columns")
                    } else {
                        Label("Connect Bank Account", systemImage: "building.columns")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(plaidViewModel.isLoadingLinkToken)

                if let error = plaidViewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Button("Skip \u{2014} I'll add manually") {
                    withAnimation(.spring(duration: 0.4)) {
                        bankStepSkipped = true
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $plaidViewModel.isShowingLink) {
            PlaidLinkRepresentable(
                linkToken: plaidViewModel.linkToken,
                onSuccess: { publicToken, institutionName in
                    Task { await plaidViewModel.handleLinkSuccess(publicToken: publicToken, institution: institutionName) }
                },
                onExit: {
                    plaidViewModel.handleLinkExit()
                }
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Step 2: Add Transaction

    private var addTransactionCard: some View {
        setupCard {
            VStack(alignment: .leading, spacing: 12) {
                stepHeader(
                    number: "2",
                    icon: "plus.circle",
                    title: "Add your first transaction",
                    subtitle: "Record a recent purchase to start tracking your spending."
                )

                Button {
                    onAddTransaction()
                } label: {
                    Label("Add Transaction", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    // MARK: - Step 3: Set Budget

    private var setBudgetCard: some View {
        setupCard {
            VStack(alignment: .leading, spacing: 12) {
                stepHeader(
                    number: "3",
                    icon: "dollarsign.gauge.chart.lefthalf.righthalf",
                    title: "Set a monthly budget",
                    subtitle: "Start with one category \u{2014} you can always adjust later."
                )

                if let category = budgetCategory {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(category.displayColor.opacity(0.12))
                                .frame(width: 36, height: 36)
                            Image(systemName: category.systemIcon)
                                .font(.system(size: 15))
                                .foregroundStyle(category.displayColor)
                        }
                        Text(category.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                    }
                }

                Button {
                    if let category = budgetCategory {
                        onSetBudget(category)
                    }
                } label: {
                    Label("Set Budget", systemImage: "dollarsign")
                }
                .buttonStyle(.borderedProminent)

                if categories.count > 1 {
                    Menu("Choose a different category") {
                        ForEach(categories) { cat in
                            Button {
                                selectedBudgetCategory = cat
                            } label: {
                                Label(cat.name, systemImage: cat.systemIcon)
                            }
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Helpers

    private var budgetCategory: Category? {
        selectedBudgetCategory ?? categories.first { $0.name == "Food" } ?? categories.first
    }

    private func setupCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(20)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
    }

    private func stepHeader(number: String, icon: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "\(number).circle.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.headline)
            }
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func completedStepRow(icon: String, title: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundStyle(.green)
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
