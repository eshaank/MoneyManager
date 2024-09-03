//
//  PlaidLinkView.swift
//  MoneyManager
//
//  Created by Eshaan Kansagara on 9/1/24.

import SwiftUI
import UIKit

struct PlaidLinkView: UIViewControllerRepresentable {
    @Binding var accountSections: [AccountSection]
    var onDismiss: (Bool, String?) -> Void

    func makeUIViewController(context: Context) -> PlaidLinkViewController {
        let controller = PlaidLinkViewController()
        controller.completion = { success, newAccounts, errorMessage in
            if let newAccounts = newAccounts {
                self.addAccountsToSections(newAccounts)
            }
            self.onDismiss(success, errorMessage)
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: PlaidLinkViewController, context: Context) {}

    private func addAccountsToSections(_ newAccounts: [FinancialAccount]) {
        for account in newAccounts {
            if account.name.lowercased().contains("credit") {
                if let index = accountSections.firstIndex(where: { $0.id == "creditCards" }) {
                    accountSections[index].accounts.append(account)
                }
            } else if account.name.lowercased().contains("saving") {
                if let index = accountSections.firstIndex(where: { $0.id == "savings" }) {
                    accountSections[index].accounts.append(account)
                }
            } else {
                if let index = accountSections.firstIndex(where: { $0.id == "checking" }) {
                    accountSections[index].accounts.append(account)
                }
            }
        }
    }
}
