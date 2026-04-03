//
//  ContentView.swift
//  Warden
//
//  Created by Ryan Lee on 3/2/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Dashboard", systemImage: "chart.pie") {
                DashboardView()
            }
            Tab("Transactions", systemImage: "list.bullet") {
                TransactionsView()
            }
            Tab("Budget", systemImage: "creditcard") {
                BudgetView()
            }
            Tab("Settings", systemImage: "gearshape") {
                SettingsView()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

#Preview {
    ContentView()
}
