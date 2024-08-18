//
//  Accounts.swift
//  MoneyManager
//
//  Created by Eshaan Kansagara on 8/17/24.
//

import SwiftUI

struct Accounts: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View{
        AccountsTabViewPage()
    }
}

struct AccountsTabViewPage: View{
    var body: some View{
        NavigationStack() {
            Text("Investments")
                .navigationTitle("Investments")
        }
        .tabItem {
            Label("Investments", systemImage: "chart.pie.fill")
        }
        .tag(2)
    }
}
