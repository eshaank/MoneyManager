//
//  ContentView.swift
//  MoneyManager
//
//  Created by Eshaan Kansagara on 8/17/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        SelectView()
    }
}

struct SelectView: View {
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            
            Dashboard() // Dashboard page
            Accounts() // Accounts page
            Investments() // Investments page
            Monthly() // Monthly page
        }
        .onAppear(perform: {
            //2
            UITabBar.appearance().unselectedItemTintColor = .systemBrown
            //3
            UITabBarItem.appearance().badgeColor = .systemPink
            //4
            UITabBar.appearance().backgroundColor = .systemGray4.withAlphaComponent(0.4)
            //5
            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.systemPink]
            //UITabBar.appearance().scrollEdgeAppearance = UITabBarAppearance()
            //Above API will kind of override other behaviour and bring the default UI for TabView
        })
    }
}
