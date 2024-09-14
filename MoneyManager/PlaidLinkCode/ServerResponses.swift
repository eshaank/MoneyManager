//
//  UserStatus.swift
//  SamplePlaidClient
//
//  Created by Dave Troupe on 8/30/23.
//

import Foundation

enum UserConnectionStatus: String, Codable {
    case connected
    case disconnected
}

struct UserStatusResponse: Codable {
    let userStatus: UserConnectionStatus
    let userId: String
}

struct LinkTokenCreateResponse: Codable {
    let linkToken: String
    let expiration: String

    enum CodingKeys: String, CodingKey {
        case linkToken = "link_token"
        case expiration
    }
}

struct SwapPublicTokenResponse: Codable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

struct SimpleAuthResponse: Codable{
    let accountName: String
    let accountMask: String
    let routingNumber: String
}
 
// Add this struct to parse the transactions response
struct TransactionsResponse: Codable {
    let latest_transactions: [Transaction]
}

struct Transaction: Codable {
    let date: String
    let amount: Double
    let name: String
    let accountId: String

    enum CodingKeys: String, CodingKey {
        case date, amount, name
        case accountId = "account_id"
    }
}

struct AccountsResponse: Codable {
    let accounts: [Account]
}

struct Account: Codable {
    let accountId: String
    let name: String
    let type: String
    let subtype: String?
    let balances: AccountBalance
    
    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
        case name, type, subtype, balances
    }
}

struct AccountBalance: Codable {
    let current: Double
    let available: Double?
    let isoCurrencyCode: String?
}