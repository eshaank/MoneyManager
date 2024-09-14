import SwiftUI
import LinkKit

struct Accounts: View {
    @State private var accounts: [AccountGroup] = [
        AccountGroup(type: "Credit Cards", accounts: [
            FinancialAccount(name: "Apple Card", balance: 1024.45),
            FinancialAccount(name: "Wells Fargo Active Cash", balance: 1342.53),
        ]),
        AccountGroup(type: "Savings", accounts: [
            FinancialAccount(name: "Emergency Fund", balance: 5000),
            FinancialAccount(name: "Vacation Savings", balance: 2500)
        ]),
        AccountGroup(type: "Checking", accounts: [
            FinancialAccount(name: "Main Checking", balance: 3500),
            FinancialAccount(name: "Joint Account", balance: 1200)
        ])
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
            .navigationTitle("Accounts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAccountTotals.toggle() }) {
                        Image(systemName: showAccountTotals ? "eye" : "eye.slash")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddOptions = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(item: $selectedAccount) { account in
            AccountDetailView(account: account)
        }
        .fullScreenCover(isPresented: $showingAddOptions) {
            AddAccountView(isPresented: $showingAddOptions, connectAction: {
                showingPlaidLink = true
            }, manualEntryAction: {
                // TODO: Implement manual entry
                print("Enter manually tapped")
            })
        }
        .fullScreenCover(isPresented: $showingPlaidLink) {
            PlaidLinkView(isPresented: $showingPlaidLink)
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
                .font(.headline)
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
                Text("••••")
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
    let name: String
    let balance: Double
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
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = ViewController()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct AddAccountView: View {
    @Binding var isPresented: Bool
    var connectAction: () -> Void
    var manualEntryAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Add Account")
                    .font(.title)
                    .bold()
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title)
                }
            }
            .padding()

            AddAccountOptionButton(title: "Connect with Plaid", iconName: "link") {
                connectAction()
                isPresented = false
            }

            AddAccountOptionButton(title: "Enter manually", iconName: "pencil") {
                manualEntryAction()
                isPresented = false
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(.horizontal)
        .padding(.bottom, 50) // Space from the bottom
    }
}
