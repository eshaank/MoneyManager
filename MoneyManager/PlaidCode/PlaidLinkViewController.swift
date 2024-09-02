//
//  PlaidLinkViewController.swift
//  SamplePlaidClients
//
//  Created by Todd Kerpelman on 8/18/23.
//

import UIKit
import LinkKit

class PlaidLinkViewController: UIViewController {
    let communicator = ServerCommunicator()
    var linkToken: String?
    var handler: Handler?
    var completion: ((Bool, [FinancialAccount]?, String?) -> Void)?
    
    private func createLinkConfiguration(linkToken: String) -> LinkTokenConfiguration {
        var linkTokenConfig = LinkTokenConfiguration(token: linkToken) { success in
            print("Link was finished successfully! \(success)")
            self.exchangePublicTokenForAccessToken(success.publicToken)
        }
        linkTokenConfig.onExit = { linkEvent in
            print("User exited link early. \(linkEvent)")
            self.dismissViewController(success: false, accounts: nil)
        }
        linkTokenConfig.onEvent = { linkExit in
            print("Hit an event \(linkExit.eventName)")
        }
        return linkTokenConfig
    }
    
    private func exchangePublicTokenForAccessToken(_ publicToken: String) {
        self.communicator.callMyServer(path: "/server/swap_public_token", httpMethod: .post, params: ["public_token": publicToken]) { (result: Result<SwapPublicTokenResponse, ServerCommunicator.Error>) in
            switch result {
            case .success(let response):
                if response.success {
                    self.fetchAccountInfo()
                } else {
                    print("Got a failed success \(response)")
                    self.dismissViewController(success: false, accounts: nil)
                }
            case .failure(let error):
                print("Got an error \(error)")
                self.dismissViewController(success: false, accounts: nil)
            }
        }
    }
    
    private func fetchLinkToken() {
        self.communicator.callMyServer(path: "/server/generate_link_token", httpMethod: .post) { (result: Result<LinkTokenCreateResponse, ServerCommunicator.Error>) in
            switch result {
            case .success(let response):
                self.linkToken = response.linkToken
                self.startLinkProcess()
            case .failure(let error):
                print(error)
                self.dismissViewController(success: false, accounts: nil)
            }
        }
    }
    
    private func startLinkProcess() {
        guard let linkToken = linkToken else {
            dismissViewController(success: false, accounts: nil)
            return
        }
        let config = createLinkConfiguration(linkToken: linkToken)
        let creationResult = Plaid.create(config)
        switch creationResult {
        case .success(let handler):
            self.handler = handler
            handler.open(presentUsing: .viewController(self))
        case .failure(let error):
            print("Handler creation error\(error)")
            dismissViewController(success: false, accounts: nil)
        }
    }
    
    private func fetchAccountInfo() {
        self.communicator.callMyServer(path: "/server/accounts/get", httpMethod: .post) { (result: Result<AccountsGetResponse, ServerCommunicator.Error>) in
            switch result {
            case .success(let response):
                let accounts = response.accounts.map { account in
                    FinancialAccount(name: account.name, balance: account.balances.current)
                }
                self.dismissViewController(success: true, accounts: accounts)
            case .failure(let error):
                print("Error fetching account info: \(error)")
                let errorMessage: String
                switch error {
                case .decodingError(let message):
                    errorMessage = "Server returned invalid data. Please try again later. Error: \(message)"
                default:
                    errorMessage = "Unable to fetch account information. Please try again later."
                }
                self.dismissViewController(success: false, accounts: nil, errorMessage: errorMessage)
            }
        }
    }
    
    private func dismissViewController(success: Bool, accounts: [FinancialAccount]?, errorMessage: String? = nil) {
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                self.completion?(success, accounts, errorMessage)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchLinkToken()
    }
}
