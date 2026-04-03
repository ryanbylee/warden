//
//  WardenApp.swift
//  Warden
//
//  Created by Ryan Lee on 3/2/26.
//

import SwiftUI
import SwiftData

@main
struct WardenApp: App {
    let sharedModelContainer: ModelContainer

    init() {
        let schema = Schema([
            Transaction.self,
            Category.self,
            Budget.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }

        // Seed default categories on first launch
        let context = sharedModelContainer.mainContext
        MockDataService.seedDefaultCategories(context: context)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    try? await SupabaseService.shared.signInAnonymously()
                    let viewModel = PlaidLinkViewModel()
                    if viewModel.isConnected {
                        await viewModel.syncTransactions(context: sharedModelContainer.mainContext)
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
