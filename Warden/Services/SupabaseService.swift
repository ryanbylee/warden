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

    private init() {
        client = SupabaseClient(
            supabaseURL: SupabaseConfig.url,
            supabaseKey: SupabaseConfig.anonKey
        )
    }

    /// Signs in anonymously. Validates any existing session against the server first.
    /// If the cached session is stale or invalid, clears it and creates a fresh anonymous session.
    func signInAnonymously() async throws {
        if let existingSession = try? await client.auth.session {
            // Refresh against the server to confirm the session is still valid
            if (try? await client.auth.refreshSession(refreshToken: existingSession.refreshToken)) != nil {
                return
            }
            // Stale session — clear it before creating a new one
            try? await client.auth.signOut()
        }
        try await client.auth.signInAnonymously()
    }
}
