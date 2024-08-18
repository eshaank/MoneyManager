//
//  Playground.swift
//  MoneyManager
//
//  Created by Eshaan Kansagara on 8/18/24.
//

import SwiftUI

// MARK: Models

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

struct FinancialAccount: Identifiable {
    var id = UUID()
    var name: String
    var balance: String
}

// MARK: - Views

struct FinancialAccountsView: View {
    @State private var isCreditCardsExpanded: Bool = false
    @State private var isCheckingExpanded: Bool = false
    @State private var isSavingsExpanded: Bool = false
    
    @State private var newAccount = NewAccount()
    
    @State private var creditCards: [FinancialAccount] = [FinancialAccount(name: "Visa", balance: "$2000")]
    
    @State private var checkingAccounts: [FinancialAccount] = []
    
    @State private var savingsAccounts: [FinancialAccount] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                AddAccountForm(newAccount: $newAccount, onAddAccount: addNewAccount)
                
                AccountDisclosureGroup(
                    title: "Credit Cards",
                    isExpanded: $isCreditCardsExpanded,
                    accounts: creditCards,
                    titleColor: .red
                )
                
                AccountDisclosureGroup(
                    title: "Checking Accounts",
                    isExpanded: $isCheckingExpanded,
                    accounts: checkingAccounts,
                    titleColor: .purple
                )
                
                AccountDisclosureGroup(
                    title: "Savings Accounts",
                    isExpanded: $isSavingsExpanded,
                    accounts: savingsAccounts,
                    titleColor: .mint
                )
            }
            .padding(.top)
        }
    }
    
    // MARK: - Functions
    
    private func addNewAccount() {
        let newAccountEntry = FinancialAccount(name: newAccount.name, balance: newAccount.balance)
        
        switch newAccount.type {
        case .creditCard:
            creditCards.append(newAccountEntry)
        case .checkingAccount:
            checkingAccounts.append(newAccountEntry)
        case .savingsAccount:
            savingsAccounts.append(newAccountEntry)
        }
        
        newAccount.reset()
    }
}

// MARK: - AddAccountForm View

struct AddAccountForm: View {
    @Binding var newAccount: NewAccount
    var onAddAccount: () -> Void
    
    var body: some View {
        VStack {
            Text("Add New Account")
                .font(.headline)
                .padding(.bottom, 10)
            
            Picker("Account Type", selection: $newAccount.type) {
                ForEach(AccountType.allCases, id: \.self) { type in
                    Text(type.rawValue.capitalized).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom, 10)
            
            TextField("Account Name", text: $newAccount.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 10)
            
            TextField("Account Balance", text: $newAccount.balance)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .padding(.bottom, 10)
            
            Button(action: onAddAccount) {
                Text("Add Account")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

// MARK: - AccountDisclosureGroup View

struct AccountDisclosureGroup: View {
    let title: String
    @Binding var isExpanded: Bool
    let accounts: [FinancialAccount]
    let titleColor: Color
    
    var body: some View {
        DisclosureGroup(title, isExpanded: $isExpanded) {
            ForEach(accounts) { account in
                VStack(alignment: .leading) {
                    Text(account.name)
                        .font(.headline)
                        .foregroundColor(titleColor)
                    Text("Balance: \(account.balance)")
                        .font(.subheadline)
                        .foregroundColor(titleColor)
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .foregroundColor(Color(.systemBlue))
        .bold()
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

// MARK: - Supporting Models

struct NewAccount {
    var type: AccountType = .creditCard
    var name: String = ""
    var balance: String = ""
    
    mutating func reset() {
        name = ""
        balance = ""
    }
}

enum AccountType: String, CaseIterable {
    case creditCard = "Credit Card"
    case checkingAccount = "Checking Account"
    case savingsAccount = "Savings Account"
}

struct FinancialAccountsView_Previews: PreviewProvider {
    static var previews: some View {
        FinancialAccountsView()
    }
}
