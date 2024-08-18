//
//  Playground.swift
//  MoneyManager
//
//  Created by Eshaan Kansagara on 8/18/24.
//

import SwiftUI

struct Playground: View{
    var body: some View{
        NavigationStack() {
            FinancialAccountsView()
                .navigationTitle("Playground")
        }
        .tabItem {
            Label("Playground", systemImage: "hammer")
        }
        .tag(4)
    }

}

struct CreditCard: Identifiable {
    var id = UUID() // Unique ID for each card
    var name: String
    var balance: String
    var cardNumber: String
}

struct FinancialAccountsView: View {
    @State private var isCreditCardsExpanded: Bool = false
    @State private var isCheckingExpanded: Bool = false
    @State private var isSavingsExpanded: Bool = false

    // Sample data for credit cards
    let creditCards = [
        CreditCard(name: "Visa", balance: "$2000", cardNumber: "**** 1234"),
        CreditCard(name: "MasterCard", balance: "$500", cardNumber: "**** 5678"),
        CreditCard(name: "Amex", balance: "$1500", cardNumber: "**** 9876")
    ]
    
    // Sample data for checking accounts
    let checkingAccounts = [
        CreditCard(name: "Chase Checking", balance: "$3000", cardNumber: "**** 4321"),
        CreditCard(name: "Bank of America Checking", balance: "$1500", cardNumber: "**** 8765")
    ]
    
    // Sample data for savings accounts
    let savingsAccounts = [
        CreditCard(name: "Ally Savings", balance: "$5000", cardNumber: "**** 1111"),
        CreditCard(name: "Wells Fargo Savings", balance: "$2500", cardNumber: "**** 2222")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                DisclosureGroup("Credit Cards", isExpanded: $isCreditCardsExpanded) {
                    ForEach(creditCards) { card in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(card.name)
                                .font(.headline)
                            Text("Balance: \(card.balance)")
                                .font(.subheadline)
                            Text("Card Number: \(card.cardNumber)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)

                DisclosureGroup("Checking Accounts", isExpanded: $isCheckingExpanded) {
                    ForEach(checkingAccounts) { account in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(account.name)
                                .font(.headline)
                            Text("Balance: \(account.balance)")
                                .font(.subheadline)
                            Text("Account Number: \(account.cardNumber)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)

                DisclosureGroup("Savings Accounts", isExpanded: $isSavingsExpanded) {
                    ForEach(savingsAccounts) { account in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(account.name)
                                .font(.headline)
                            Text("Balance: \(account.balance)")
                                .font(.subheadline)
                            Text("Account Number: \(account.cardNumber)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
            }
            .padding(.top)
        }
    }
}
