//
//  TransactionDetailViewController.swift
//  LinkDemo-Swift-UIKit
//
//  Created by Eshaan Kansagara on 9/12/24.
//  Copyright © 2024 Plaid Inc. All rights reserved.
//

import UIKit

class TransactionDetailViewController: UIViewController {
    private let transaction: Transaction
    private let stackView = UIStackView()

    init(transaction: Transaction) {
        self.transaction = transaction
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = "Transaction Details"

        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        addDetailLabel("Date: \(transaction.date)")
        addDetailLabel("Name: \(transaction.name)")
        addDetailLabel("Amount: $\(String(format: "%.2f", transaction.amount))")
        addDetailLabel("Account ID: \(transaction.accountId)")
    }

    private func addDetailLabel(_ text: String) {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        stackView.addArrangedSubview(label)
    }
}
