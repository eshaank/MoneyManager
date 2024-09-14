//
//  TransactionsViewController.swift
//  LinkDemo-Swift-UIKit
//
//  Created by Eshaan Kansagara on 9/8/24.
//  Copyright © 2024 Plaid Inc. All rights reserved.
//

import UIKit

class TransactionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    private var transactions: [Transaction] = []
    private let accountId: String

    init(accountId: String) {
        self.accountId = accountId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchTransactions()
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = "Transactions"

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TransactionCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func fetchTransactions() {
        ServerCommunicator().callMyServer(path: "/api/transactions", httpMethod: .get, params: ["account_id": accountId]) { (result: Result<TransactionsResponse, ServerCommunicator.Error>) in
            switch result {
            case .success(let response):
                self.transactions = response.latest_transactions.filter { $0.accountId == self.accountId }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch transactions: \(error)")
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)
        let transaction = transactions[indexPath.row]
        cell.textLabel?.text = "\(transaction.date): \(transaction.name) - \(transaction.amount)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let transaction = transactions[indexPath.row]
        let detailVC = TransactionDetailViewController(transaction: transaction)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
