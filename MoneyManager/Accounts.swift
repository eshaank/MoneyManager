import SwiftUI
import LinkKit

struct Accounts: View {
    @State private var accounts: [AccountGroup] = [
        AccountGroup(type: "Credit Card", accounts: []),
        AccountGroup(type: "Checking", accounts: []),
        AccountGroup(type: "Savings", accounts: []),
        AccountGroup(type: "Investment", accounts: []),
        AccountGroup(type: "Other", accounts: [])
    ]
    @State private var showAccountTotals: Bool = true
    @State private var selectedAccount: FinancialAccount?
    @State private var showingAddOptions: Bool = false
    @State private var showingPlaidLink: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(accounts) { group in
                        AccountGroupView(group: group, showAccountTotals: $showAccountTotals, selectedAccount: $selectedAccount)
                    }
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingPlaidLink = true // Show Plaid Link when the plus button is clicked
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingPlaidLink) {
            PlaidLinkView(isPresented: $showingPlaidLink) { plaidAccounts in
                addPlaidAccounts(plaidAccounts)
            }
        }
    }

    func addPlaidAccounts(_ plaidAccounts: [Account]) {
        for plaidAccount in plaidAccounts {
            let accountType = plaidAccount.subtype ?? plaidAccount.type
            let newAccount = FinancialAccount(
                accountId: plaidAccount.accountId,
                name: plaidAccount.name,
                balance: plaidAccount.balances.current,
                type: accountType
            )
            
            if let index = accounts.firstIndex(where: { $0.type == accountType }) {
                var updatedGroup = accounts[index]
                var mutableAccounts = updatedGroup.accounts
                mutableAccounts.append(newAccount)
                updatedGroup = AccountGroup(type: updatedGroup.type, accounts: mutableAccounts)
                accounts[index] = updatedGroup
            } else {
                accounts.append(AccountGroup(type: accountType, accounts: [newAccount]))
            }
        }
    }
}

struct AccountGroup: Identifiable {
    let id = UUID()
    let type: String
    let accounts: [FinancialAccount]
}

struct AccountGroupView: View {
    let group: AccountGroup
    @Binding var showAccountTotals: Bool
    @Binding var selectedAccount: FinancialAccount?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(group.type)
                .font(.title2)
                .bold()
                .padding(.leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(group.accounts) { account in
                        AccountCardView(account: account, showAccountTotals: showAccountTotals)
                            .onTapGesture {
                                selectedAccount = account
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct AccountCardView: View {
    let account: FinancialAccount
    let showAccountTotals: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(account.name)
                .font(.system(size: 16, weight: .semibold))
                .lineLimit(1)
            
            if showAccountTotals {
                Text("$\(account.balance, specifier: "%.2f")")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            } else {
                Text("••••••••")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(width: 150, height: 100)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct AccountDetailView: View {
    let account: FinancialAccount
    
    var body: some View {
        VStack(spacing: 20) {
            Text(account.name)
                .font(.title)
            
            Text("$\(account.balance, specifier: "%.2f")")
                .font(.title2)
                .foregroundColor(.secondary)
            
            // Add more details and functionality here
        }
        .padding()
    }
}

struct FinancialAccount: Identifiable {
    let id = UUID()
    let accountId: String
    let name: String
    let balance: Double
    let type: String
}

struct AddAccountOptionButton: View {
    let title: String
    let iconName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(.blue)
                    .frame(width: 30, height: 30)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 10)
        }
    }
}

struct PlaidLinkView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var onAccountsLinked: ([Account]) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = ViewController()
        viewController.onAccountsLinked = { accounts in
            onAccountsLinked(accounts)
            isPresented = false
        }
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

