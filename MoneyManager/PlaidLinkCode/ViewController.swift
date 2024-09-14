//
//  ViewController.swift
//  LinkDemo-Swift-UIKit
//
//  Copyright © 2023 Plaid Inc. All rights reserved.
//

import UIKit
import LinkKit

class ViewController: UIViewController {

    private let vStack = UIStackView()
    private let titleLabel = UILabel() // Title label
    private let connectButton = UIButton()
    private let transactionsButton = UIButton()
    private let plaidBlue = UIColor(red: 0.039, green: 0.522, blue: 0.918, alpha: 1.0)

    // Link Handler
    let communicator = ServerCommunicator()
    var linkToken: String?
    var handler: Handler?
    var onAccountsLinked: (([Account]) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchLinkToken() // Fetch the link token when the view loads
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Setup title label
        titleLabel.text = "Connect Accounts" // Set the title text
        titleLabel.font = .systemFont(ofSize: 26, weight: .bold) // Set font size and weight
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Add a dismiss button
        let dismissButton = UIButton(type: .system)
        dismissButton.setTitle("Close", for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissButtonPressed), for: .touchUpInside)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dismissButton)

        // Setup constraints for title label
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        setupButtons()
    }

    @objc private func dismissButtonPressed() {
        self.dismiss(animated: true, completion: nil) // Dismiss the current view controller
    }

    @objc private func connectButtonPressed() {
        if let handler = handler {
            openLink(with: handler)
        } else {
            createLinkHandler()
        }
    }

    @objc private func transactionsButtonPressed() {
        presentAccountsSheet()
    }

    private func createLinkHandler() {
        guard let linkToken = linkToken else {
            print("Link token is not available. Fetching a new one.")
            fetchLinkToken()
            return
        }
        
        let config = createLinkConfiguration(linkToken: linkToken)
        let creationResult = Plaid.create(config)
        
        switch creationResult {
        case .failure(let error):
            print("Unable to create Plaid handler due to: \(error)")
        case .success(let handler):
            self.handler = handler
            openLink(with: handler)
        }
    }

    private func openLink(with handler: Handler) {
        handler.open(presentUsing: .viewController(self))
    }

    private func presentTransactionsSheet() {
        let accountsVC = AccountsViewController()
        let navigationController = UINavigationController(rootViewController: accountsVC)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true, completion: nil)
    }

    private func presentAccountsSheet() {
        let accountsVC = AccountsViewController()
        let navigationController = UINavigationController(rootViewController: accountsVC)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true, completion: nil)
    }

    private func setupButtons() {

        vStack.axis = .vertical
        vStack.spacing = 4
        vStack.distribution = .fill
        vStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(vStack)
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
        ])

        connectButton.backgroundColor = plaidBlue
        connectButton.addTarget(self, action: #selector(connectButtonPressed), for: .touchUpInside)
        connectButton.layer.cornerRadius = 8
        connectButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        connectButton.setTitle("Connect to Plaid", for: .normal)
        connectButton.translatesAutoresizingMaskIntoConstraints = false

        transactionsButton.backgroundColor = plaidBlue
        transactionsButton.addTarget(self, action: #selector(transactionsButtonPressed), for: .touchUpInside)
        transactionsButton.layer.cornerRadius = 8
        transactionsButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        transactionsButton.setTitle("Coming Soon", for: .normal)
        transactionsButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(connectButton)
        view.addSubview(transactionsButton)
        NSLayoutConstraint.activate([
            connectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -72),
            connectButton.leadingAnchor.constraint(equalTo: vStack.leadingAnchor),
            connectButton.trailingAnchor.constraint(equalTo: vStack.trailingAnchor),
            connectButton.heightAnchor.constraint(equalToConstant: 56),

            transactionsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            transactionsButton.leadingAnchor.constraint(equalTo: vStack.leadingAnchor),
            transactionsButton.trailingAnchor.constraint(equalTo: vStack.trailingAnchor),
            transactionsButton.heightAnchor.constraint(equalToConstant: 56),
        ])
    }

    private func createLinkConfiguration(linkToken: String) -> LinkTokenConfiguration {
        var linkTokenConfig = LinkTokenConfiguration(token: linkToken) { success in
            print("Link was finished successfully! \(success)")
            self.fetchAccountInfo(publicToken: success.publicToken)
        }
        linkTokenConfig.onExit = { linkEvent in
            print("User exited link early. \(linkEvent)")
        }
        linkTokenConfig.onEvent = { linkExit in
            print("Hit an event \(linkExit.eventName)")
        }
        return linkTokenConfig
    }
    
    private func exchangePublicTokenForAccessToken(_ publicToken: String, completion: @escaping (Result<String, Error>) -> Void) {
        self.communicator.callMyServer(path: "/api/set_access_token", httpMethod: .post, params: ["public_token": publicToken]) { (result: Result<SwapPublicTokenResponse, ServerCommunicator.Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.accessToken))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
       
    private func fetchLinkToken() {
        communicator.callMyServer(path: "/api/create_link_token", httpMethod: .post) { [weak self] (result: Result<LinkTokenCreateResponse, ServerCommunicator.Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.linkToken = response.linkToken
                print("Link token fetched successfully")
                DispatchQueue.main.async {
                    self.connectButton.isEnabled = true
                }
            case .failure(let error):
                print("Failed to fetch link token: \(error)")
                DispatchQueue.main.async {
                    self.connectButton.isEnabled = false
                }
            }
        }
    }
    
    private func fetchAccountInfo(publicToken: String) {
        exchangePublicTokenForAccessToken(publicToken) { result in
            switch result {
            case .success(let accessToken):
                self.communicator.callMyServer(path: "/api/accounts", httpMethod: .get) { (result: Result<AccountsResponse, ServerCommunicator.Error>) in
                    switch result {
                    case .success(let accountsResponse):
                        print("Accounts information:")
                        accountsResponse.accounts.forEach { account in
                            print("Account name: \(account.name)")
                            print("Account type: \(account.type)")
                            print("Account subtype: \(account.subtype ?? "N/A")")
                            print("Account balance: \(account.balances.current) \(account.balances.isoCurrencyCode ?? "USD")")
                            print("--------------------")
                        }
                        DispatchQueue.main.async {
                            self.transactionsButton.isEnabled = true
                            self.onAccountsLinked?(accountsResponse.accounts)
                        }
                    case .failure(let error):
                        print("Failed to fetch accounts: \(error)")
                    }
                }
            case .failure(let error):
                print("Failed to exchange public token: \(error)")
            }
        }
    }
}
