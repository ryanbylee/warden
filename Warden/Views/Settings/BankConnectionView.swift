//
//  BankConnectionView.swift
//  Warden
//

import SwiftUI
import SwiftData

struct BankConnectionView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = PlaidLinkViewModel()
    @State private var showingDisconnectConfirm = false

    var body: some View {
        if viewModel.isConnected {
            connectedSection
        } else {
            connectSection
        }
    }

    // MARK: - Not Connected

    private var connectSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button {
                Task { await viewModel.startLinkFlow() }
            } label: {
                if viewModel.isLoadingLinkToken {
                    Label("Connecting…", systemImage: "building.columns")
                } else {
                    Label("Connect Bank Account", systemImage: "building.columns")
                }
            }
            .disabled(viewModel.isLoadingLinkToken)

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .sheet(isPresented: $viewModel.isShowingLink) {
            PlaidLinkRepresentable(
                linkToken: viewModel.linkToken,
                onSuccess: { publicToken, institutionName in
                    Task { await viewModel.handleLinkSuccess(publicToken: publicToken, institution: institutionName) }
                },
                onExit: {
                    viewModel.handleLinkExit()
                }
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Connected

    private var connectedSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            LabeledContent("Connected Bank", value: viewModel.institutionName)

            Button {
                Task { await viewModel.syncTransactions(context: modelContext) }
            } label: {
                if viewModel.isSyncing {
                    Label("Syncing…", systemImage: "arrow.triangle.2.circlepath")
                } else {
                    Label("Sync Now", systemImage: "arrow.triangle.2.circlepath")
                }
            }
            .disabled(viewModel.isSyncing)

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Button("Disconnect Bank", role: .destructive) {
                showingDisconnectConfirm = true
            }
            .alert("Disconnect Bank?", isPresented: $showingDisconnectConfirm) {
                Button("Disconnect", role: .destructive) { viewModel.disconnect() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Your imported transactions will remain, but automatic sync will stop.")
            }
        }
    }
}

#Preview {
    BankConnectionView()
        .modelContainer(for: [Transaction.self, Category.self, Budget.self], inMemory: true)
}
