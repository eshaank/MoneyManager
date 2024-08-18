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
    }
}
