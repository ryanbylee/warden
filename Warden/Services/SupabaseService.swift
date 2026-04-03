//
//  SupabaseService.swift
//  Warden
//

import Foundation
import Supabase

@Observable
final class SupabaseService {
    static let shared = SupabaseService()

    let client: SupabaseClient
    /// Access token captured directly from the last successful sign-in or refresh.
    /// Using this instead of re-reading client.auth.session avoids SDK storage issues.
    private(set) var accessToken: String? = nil

    private init() {
        client = SupabaseClient(
            supabaseURL: SupabaseConfig.url,
            supabaseKey: SupabaseConfig.anonKey
        )
    }

    /// Signs in anonymously and stores the access token directly from the response.
    /// Safe to call repeatedly — refreshes if a valid session already exists.
    func signInAnonymously() async throws {
        if let existingSession = try? await client.auth.session {
            do {
                let refreshed = try await client.auth.refreshSession(refreshToken: existingSession.refreshToken)
                accessToken = refreshed.accessToken
                return
            } catch {
                // Stale session — fall through to fresh sign-in
                try? await client.auth.signOut()
                accessToken = nil
            }
        }
        let session = try await client.auth.signInAnonymously()
        accessToken = session.accessToken
    }
}
