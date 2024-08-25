//
//  AccountInformation.swift
//  MoneyManager
//
//  Created by Eshaan Kansagara on 8/25/24.
//

import SwiftUI

// MARK: - Models

struct FinancialAccount: Identifiable {
    var id = UUID()
    var name: String
    var balance: Double
}

// MARK: - Supporting Models
enum AccountType: String, CaseIterable {
    case creditCard = "Credit Card"
    case checkingAccount = "Checking Account"
    case savingsAccount = "Savings Account"
}

// MARK: - AddAccountSheet View
struct AddAccountSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String = ""
    @State private var balance: String = ""

    var accountType: AccountType
    var onAddAccount: (FinancialAccount) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account Details")) {
                    TextField("Account Name", text: $name)

                    TextField("Account Balance", text: $balance)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationBarTitle("Add \(accountType.rawValue.capitalized)", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    if validateFields() {
                        let formattedBalance = Double(balance) ?? 0
                        let newAccount = FinancialAccount(name: name, balance: formattedBalance)
                        onAddAccount(newAccount)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .disabled(!validateFields())
            )
        }
    }

    // MARK: - Validation

    private func validateFields() -> Bool {
        return !name.isEmpty && !balance.isEmpty && Double(balance) != nil
    }
}

