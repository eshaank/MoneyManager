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

struct AccountsTabViewPage: View {
    @State private var accountTypes = ["Checking", "Savings", "Credit Card"]
    @State private var accountSummaries = [
        "Checking": [AccountSummary](),
        "Savings": [AccountSummary](),
        "Credit Card": [AccountSummary]()
    ]
    @State private var showingAddAccount = false
    @State private var newAccount = AccountSummary(type: "", name: "", value: "")
    @State private var showingDetails = false
    @State private var selectedAccount: AccountSummary?
    
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(accountTypes, id: \.self) { type in
                    DisclosureGroup("\(type) - Total: $\(totalBalance(for: type))") {
                        ForEach(accountSummaries[type] ?? []) { summary in
                            HStack {
                                AccountSummaryView(summary: summary)
                                Spacer()
                                Button("Details") {
                                    selectedAccount = summary
                                    showingDetails = true
                                }
                            }
                        }
                        if showingAddAccount && newAccount.type == type {
                            addAccountFields(type: type)
                        }
                        Button(showingAddAccount && newAccount.type == type ? "Cancel" : "Add Account") {
                            if showingAddAccount {
                                if newAccount.type == type {
                                    showingAddAccount = false
                                } else {
                                    newAccount.type = type
                                }
                            } else {
                                showingAddAccount = true
                                newAccount.type = type
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Accounts")
            .sheet(isPresented: $showingDetails) {
                if let account = selectedAccount {
                    AccountDetailsView(account: account)
                }
            }
        }
        .tabItem {
            Label("Accounts", systemImage: "chart.pie.fill")
        }
        .tag(1)
    }
    
    private func addAccountFields(type: String) -> some View {
        VStack {
            TextField("Account Name", text: $newAccount.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Amount", text: $newAccount.value)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .onReceive(newAccount.value.publisher.collect()) {
                    let filtered = $0.map { String($0) }.joined().filter { "0123456789.".contains($0) }
                    if filtered != newAccount.value {
                        newAccount.value = filtered
                    }
                }
            Button("Save") {
                addAccount(type: type)
                showingAddAccount = false
                newAccount = AccountSummary(type: "", name: "", value: "")  // Reset the new account fields
            }
            .padding()
        }
    }
    
    private func totalBalance(for type: String) -> String {
        let total = (accountSummaries[type] ?? []).reduce(0) { sum, summary in
            sum + (Double(summary.value.replacingOccurrences(of: ",", with: "")) ?? 0)
        }
        return numberFormatter.string(from: NSNumber(value: total)) ?? "0"
    }
    
    private func addAccount(type: String) {
        if let value = numberFormatter.number(from: newAccount.value)?.doubleValue {
            let formattedValue = numberFormatter.string(from: NSNumber(value: value)) ?? ""
            let summary = AccountSummary(type: type, name: newAccount.name, value: formattedValue)
            accountSummaries[type]?.append(summary)
        }
    }
}

struct AccountSummary: Identifiable {
    var id = UUID()
    var type: String
    var name: String
    var value: String
}

struct AccountSummaryView: View {
    var summary: AccountSummary
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(summary.name)
                .font(.headline)
            Text("$\(summary.value)")
                .font(.caption)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
    }
}

struct AccountDetailsView: View {
    var account: AccountSummary
    
    var body: some View {
        VStack {
            Text("Account Details")
                .font(.title)
                .padding()
            
            Text("Name: \(account.name)")
            Text("Type: \(account.type)")
            Text("Balance: $\(account.value)")
            
            Spacer()
            
            Button("Close") {
                // Close the sheet
            }
            .padding()
        }
        .padding()
    }
}
