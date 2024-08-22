//
//  Investments.swift
//  MoneyManager
//
//  Created by Eshaan Kansagara on 8/17/24.
//

import SwiftUI

struct Investments: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View{
        InvestmentsTabViewPage()
    }
}

struct InvestmentsTabViewPage: View{
    var body: some View{
        NavigationStack() {
            Text("Investments")
                .navigationTitle("Investments")
        }
        .tabItem {
            Label("Investments", systemImage: "dog")
        }
        .tag(0)
    }
}

