//
//  Playground.swift
//  MoneyManager
//
//  Created by Eshaan Kansagara on 8/18/24.
//

import SwiftUI

// MARK: Playground

//struct Playground: View{
//    var body: some View{
//        NavigationStack() {
//            FinancialAccountsView()
//                .navigationTitle("Playground")
//        }
//        .tabItem {
//            Label("Playground", systemImage: "hammer")
//        }
//        .tag(4)
//    }
//
//}
//
//// MARK: - Models
//
//struct FinancialAccount1: Identifiable {
//    var id = UUID()
//    var name: String
//    var balance: Double
//}
//
//// MARK: - Views
//
//struct FinancialAccountsView: View {
//    @State private var isCreditCardsExpanded: Bool = true
//    @State private var isCheckingExpanded: Bool = true
//    @State private var isSavingsExpanded: Bool = true
//
//    @State private var showAddAccountSheet: Bool = false
//    @State private var selectedAccountType: AccountType = .creditCard
//
//    @State private var creditCards: [FinancialAccount] = [
//        FinancialAccount(name: "Visa", balance: 2000),
//        FinancialAccount(name: "Long Account Name", balance: 2000)]
//
//    @State private var checkingAccounts: [FinancialAccount] = []
//
//    @State private var savingsAccounts: [FinancialAccount] = []
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading) {
//                AccountDisclosureGroup(
//                    title: accountDisclosureGroupTitle(title: "Credit Cards", account: creditCards),
//                    isExpanded: $isCreditCardsExpanded,
//                    accounts: creditCards,
//                    titleColor: .purple,
//                    onAddAccount: {
//                        selectedAccountType = .creditCard
//                        showAddAccountSheet = true
//                    }
//                )
//
//                AccountDisclosureGroup(
//                    title: accountDisclosureGroupTitle(title: "Checkings", account: checkingAccounts),
//                    isExpanded: $isCheckingExpanded,
//                    accounts: checkingAccounts,
//                    titleColor: .purple,
//                    onAddAccount: {
//                        selectedAccountType = .checkingAccount
//                        showAddAccountSheet = true
//                    }
//                )
//
//                AccountDisclosureGroup(
//                    title: accountDisclosureGroupTitle(title: "Savings", account: savingsAccounts),
//                    isExpanded: $isSavingsExpanded,
//                    accounts: savingsAccounts,
//                    titleColor: .purple,
//                    onAddAccount: {
//                        selectedAccountType = .savingsAccount
//                        showAddAccountSheet = true
//                    }
//                )
//            }
//            .padding(.top)
//        }
//        .sheet(isPresented: $showAddAccountSheet) {
//            AddAccountSheet(
//                accountType: selectedAccountType,
//                onAddAccount: addNewAccount
//            )
//        }
//    }
//
//    // MARK: - Functions
//
//    private func addNewAccount(account: FinancialAccount) {
//        switch selectedAccountType {
//        case .creditCard:
//            creditCards.append(account)
//        case .checkingAccount:
//            checkingAccounts.append(account)
//        case .savingsAccount:
//            savingsAccounts.append(account)
//        }
//    }
//
//    private func accountTotals(accounts: [FinancialAccount]) -> String {
//        let total = accounts.reduce(0) { $0 + $1.balance }
//
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
//        formatter.minimumFractionDigits = 2
//        formatter.maximumFractionDigits = 2
//
//        return formatter.string(from: NSNumber(value: total)) ?? "0.00"
//    }
//
//    private func accountDisclosureGroupTitle(title: String, account: [FinancialAccount]) -> Text{
//        return Text(title).font(.title3) +
//        Text(" $\(accountTotals(accounts: account))").font(.subheadline)
//    }
//}
//
//// MARK: - AddAccountSheet View
//
//struct AddAccountSheet: View {
//    @Environment(\.presentationMode) var presentationMode
//    @State private var name: String = ""
//    @State private var balance: String = ""
//
//    var accountType: AccountType
//    var onAddAccount: (FinancialAccount) -> Void
//
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Account Details")) {
//                    TextField("Account Name", text: $name)
//
//                    TextField("Account Balance", text: $balance)
//                        .keyboardType(.decimalPad)
//                }
//            }
//            .navigationBarTitle("Add \(accountType.rawValue.capitalized)", displayMode: .inline)
//            .navigationBarItems(
//                leading: Button("Cancel") {
//                    presentationMode.wrappedValue.dismiss()
//                },
//                trailing: Button("Save") {
//                    if validateFields() {
//                        let formattedBalance = Double(balance) ?? 0
//                        let newAccount = FinancialAccount(name: name, balance: formattedBalance)
//                        onAddAccount(newAccount)
//                        presentationMode.wrappedValue.dismiss()
//                    }
//                }
//                .disabled(!validateFields())
//            )
//        }
//    }
//
//    // MARK: - Validation
//
//    private func validateFields() -> Bool {
//        return !name.isEmpty && !balance.isEmpty && Double(balance) != nil
//    }
//}
//
//// MARK: - AccountDisclosureGroup View
//
//struct AccountDisclosureGroup: View {
//    let title: Text
//    @Binding var isExpanded: Bool
//    let accounts: [FinancialAccount]
//    let titleColor: Color
//    var onAddAccount: () -> Void
//
//    var body: some View {
//        HStack(alignment: .firstTextBaseline) { // Center align the content vertically
//            DisclosureGroup(isExpanded: $isExpanded) {
//                ForEach(accounts) { account in
//                    VStack() {
//                        Text(account.name)
//                            .font(.headline)
//                            .foregroundColor(.blue)
//                        Text("$\(account.balance, specifier: "%.2f")")
//                            .font(.subheadline)
//                            .foregroundColor(titleColor)
//                        }
//                        .padding(.vertical, 5)
//                }
//                .padding(.leading) // Ensure content within DisclosureGroup has consistent left padding
//            } label: {
//                title
//                    .foregroundColor(Color.mint)
//            }
//            .padding()
//            .bold()
//            .padding(.horizontal)
//
//            Spacer() // Pushes the button to the far right
//
//            Button(action: onAddAccount) {
//                Text("Add")
//                    .foregroundColor(.blue)
//            }
//            .padding(.trailing) // Add padding to the right for spacing
//        }
//        .background(Color(.systemGray6))
//        .foregroundColor(Color(.systemBlue))
//        .bold()
//        .cornerRadius(8)
//    }
//}
//
//
//// MARK: - Supporting Models
//
//enum AccountType1: String, CaseIterable {
//    case creditCard = "Credit Card"
//    case checkingAccount = "Checking Account"
//    case savingsAccount = "Savings Account"
//}
