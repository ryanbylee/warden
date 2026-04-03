//
//  PlaidLinkViewModel.swift
//  Warden
//

import Foundation
import SwiftData

@Observable
final class PlaidLinkViewModel {

    // MARK: - Connection State (persisted via UserDefaults)
    var isConnected: Bool = false
    var institutionName: String = ""
    var connectedItemId: String = ""

    // MARK: - Link Flow State
    var linkToken: String = ""
    var isLoadingLinkToken: Bool = false
    var isShowingLink: Bool = false
    var isSyncing: Bool = false
    var errorMessage: String? = nil

    private let plaidService = PlaidService.shared
    private let supabaseService = SupabaseService.shared

    private enum Keys {
        static let isConnected = "plaid_is_connected"
        static let institutionName = "plaid_institution_name"
        static let connectedItemId = "plaid_connected_item_id"
    }

    init() {
        isConnected = UserDefaults.standard.bool(forKey: Keys.isConnected)
        institutionName = UserDefaults.standard.string(forKey: Keys.institutionName) ?? ""
        connectedItemId = UserDefaults.standard.string(forKey: Keys.connectedItemId) ?? ""
    }

    // MARK: - Link Flow

    func startLinkFlow() async {
        isLoadingLinkToken = true
        errorMessage = nil
        do {
            try await supabaseService.signInAnonymously()
            linkToken = try await plaidService.createLinkToken()
            isShowingLink = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoadingLinkToken = false
    }

    func handleLinkSuccess(publicToken: String, institution: String) async {
        errorMessage = nil
        isShowingLink = false
        do {
            let itemId = try await plaidService.exchangePublicToken(publicToken, institutionName: institution)
            connectedItemId = itemId
            institutionName = institution
            isConnected = true
            persistConnection()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func handleLinkExit() {
        isShowingLink = false
    }

    // MARK: - Sync

    func syncTransactions(context: ModelContext) async {
        guard isConnected, !connectedItemId.isEmpty else { return }
        isSyncing = true
        errorMessage = nil
        do {
            let response = try await plaidService.syncTransactions(itemId: connectedItemId)
            let importer = TransactionImporter(context: context)
            try importer.apply(response)
        } catch {
            errorMessage = error.localizedDescription
        }
        isSyncing = false
    }

    // MARK: - Disconnect

    func disconnect() {
        isConnected = false
        institutionName = ""
        connectedItemId = ""
        linkToken = ""
        UserDefaults.standard.removeObject(forKey: Keys.isConnected)
        UserDefaults.standard.removeObject(forKey: Keys.institutionName)
        UserDefaults.standard.removeObject(forKey: Keys.connectedItemId)
    }

    // MARK: - Private

    private func persistConnection() {
        UserDefaults.standard.set(true, forKey: Keys.isConnected)
        UserDefaults.standard.set(institutionName, forKey: Keys.institutionName)
        UserDefaults.standard.set(connectedItemId, forKey: Keys.connectedItemId)
    }
}
