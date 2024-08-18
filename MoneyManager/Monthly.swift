//
//  Monthly.swift
//  MoneyManager
//
//  Created by Eshaan Kansagara on 8/17/24.
//

import SwiftUI

struct Monthly: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View{
        MonthlyTabViewPage()
    }
}

struct MonthlyTabViewPage: View{
    var body: some View{
        NavigationStack() {
            Text("Monthly Payments")
                .navigationTitle("Monthly")
        }
        .tabItem {
            Label("Monthly", systemImage: "calendar.circle.fill")
        }
        .tag(3)
    }
}


