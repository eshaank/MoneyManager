//
//  DummyData.swift
//  MoneyManager
//
//  Created by Eshaan Kansagara on 9/2/24.
//

import Foundation

struct DummyData {
    static let dummyAccounts: [AccountSection] = [
        AccountSection(id: "creditCards", title: "Credit Cards", isExpanded: true, accounts: [
            FinancialAccount(name: "Chase Sapphire", balance: 1500.50),
            FinancialAccount(name: "American Express", balance: 2750.75)
        ]),
        AccountSection(id: "savings", title: "Savings", isExpanded: true, accounts: [
            FinancialAccount(name: "Vacation Savings", balance: 5000.00)
        ]),
        AccountSection(id: "checking", title: "Checking", isExpanded: true, accounts: [
            FinancialAccount(name: "Main Checking", balance: 3500.25),
        ])
    ]
    
    static func loadDummyAccounts() -> [AccountSection] {
        return dummyAccounts
    }
}
