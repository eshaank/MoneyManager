//
//  Dashboard.swift
//  MoneyManager
//
//  Created by Eshaan Kansagara on 8/17/24.
//

import SwiftUI

struct Dashboard: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View{
        DashboardTabViewPage()
    }
}

struct DashboardTabViewPage: View{
    var body: some View{
        NavigationStack() {
            Text("Dashboard")
                .navigationTitle("Dashboard")
        }
        .tabItem {
            Label("--", systemImage: "construction")
        }
        .tag(1)
    }
}

