//
//  ViewController.swift
//  LinkDemo-Swift-UIKit
//
//  Copyright © 2023 Plaid Inc. All rights reserved.
//

import UIKit
import LinkKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let handler = handler {
            openLink(with: handler)
        } else {
            createLinkHandler()
        }
        fetchLinkToken() // Fetch the link token when the view loads
    }

    // Link Handler
    let communicator = ServerCommunicator()
    var linkToken: String?
    var handler: Handler?

    // @objc private func connectButtonPressed() {
    //     if let handler = handler {
    //         openLink(with: handler)
    //     } else {
    //         createLinkHandler()
    //     }
    // }

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
            openLink(with: handler) // Ensure this is called to open the link
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
