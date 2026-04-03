//
//  PlaidService.swift
//  Warden
//

import Foundation
import Supabase

final class PlaidService {
    static let shared = PlaidService()
    private let supabase = SupabaseService.shared

    private init() {}

    // MARK: - Private

    /// Returns the Authorization header from the last sign-in token.
    /// Throws `NetworkError.authFailed` if `signInAnonymously()` was never called.
    private func authHeader() throws -> [String: String] {
        guard let token = supabase.accessToken else {
            throw NetworkError.authFailed("Not authenticated — call signInAnonymously() first")
        }
        return ["Authorization": "Bearer \(token)"]
    }

    // MARK: - Create Link Token

    func createLinkToken() async throws -> String {
        do {
            let headers = try authHeader()
            let response: LinkTokenResponse = try await supabase.client.functions
                .invoke("create-link-token", options: .init(method: .post, headers: headers))
            return response.linkToken
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.linkTokenFailed(error.localizedDescription)
        }
    }

    // MARK: - Exchange Public Token

    func exchangePublicToken(_ publicToken: String, institutionName: String) async throws -> String {
        struct Body: Encodable {
            let publicToken: String
            let institutionName: String
            enum CodingKeys: String, CodingKey {
                case publicToken = "public_token"
                case institutionName = "institution_name"
            }
        }
        do {
            let headers = try authHeader()
            let response: ExchangeTokenResponse = try await supabase.client.functions
                .invoke("exchange-public-token", options: .init(method: .post, headers: headers, body: Body(publicToken: publicToken, institutionName: institutionName)))
            return response.itemId
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.exchangeFailed(error.localizedDescription)
        }
    }

    // MARK: - Sync Transactions

    func syncTransactions(itemId: String) async throws -> PlaidSyncResponse {
        struct Body: Encodable {
            let itemId: String
            enum CodingKeys: String, CodingKey {
                case itemId = "item_id"
            }
        }
        do {
            let headers = try authHeader()
            let response: PlaidSyncResponse = try await supabase.client.functions
                .invoke("sync-transactions", options: .init(method: .post, headers: headers, body: Body(itemId: itemId)))
            return response
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.syncFailed(error.localizedDescription)
        }
    }
}
