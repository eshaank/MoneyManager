//
//  PlaidLinkView.swift
//  MoneyManager
//
//  Created by Eshaan Kansagara on 9/1/24.

import SwiftUI
import UIKit

struct PlaidLinkView: UIViewControllerRepresentable {
    @Binding var accounts: [FinancialAccount]
    var onDismiss: (Bool, String?) -> Void

    func makeUIViewController(context: Context) -> PlaidLinkViewController {
        let controller = PlaidLinkViewController()
        controller.completion = { success, newAccounts, errorMessage in
            if let newAccounts = newAccounts {
                self.accounts.append(contentsOf: newAccounts)
            }
            self.onDismiss(success, errorMessage)
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: PlaidLinkViewController, context: Context) {}
}
