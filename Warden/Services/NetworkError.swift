//
//  NetworkError.swift
//  Warden
//

import Foundation

enum NetworkError: LocalizedError {
    case authFailed(String)
    case linkTokenFailed(String)
    case exchangeFailed(String)
    case syncFailed(String)
    case networkUnavailable

    var errorDescription: String? {
        switch self {
        case .authFailed(let msg):       return "Authentication failed: \(msg)"
        case .linkTokenFailed(let msg):  return "Could not create link token: \(msg)"
        case .exchangeFailed(let msg):   return "Token exchange failed: \(msg)"
        case .syncFailed(let msg):       return "Transaction sync failed: \(msg)"
        case .networkUnavailable:        return "No network connection."
        }
    }
}
