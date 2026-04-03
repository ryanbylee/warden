//
//  SupabaseConfig.swift
//  Warden
//

import Foundation

enum SupabaseConfig {
    static let url = URL(string: Secrets.supabaseURL)!
    static let anonKey = Secrets.supabaseAnonKey
}
