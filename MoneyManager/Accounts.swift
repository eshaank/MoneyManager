import SwiftUI

// MARK: - Main View

struct Accounts: View {
    var body: some View {
        WalletView()
            .tabItem {
                Label("Accounts", systemImage: "bank")
            }
            .navigationTitle("Accounts")
    }
}

// MARK: - Wallet View

struct WalletView: View {
    @State private var selectedCardIndex: Int? = nil
    @State private var isCardExpanded: Bool = false
    
    @State private var creditCards: [FinancialAccount] = [
        FinancialAccount(name: "Visa", balance: 2000),
        FinancialAccount(name: "Long Account Name", balance: 2000)
    ]
    
    @State private var checkingAccounts: [FinancialAccount] = []
    @State private var savingsAccounts: [FinancialAccount] = []
    
    @State private var showAddAccountSheet: Bool = false
    @State private var selectedAccountType: AccountType = .creditCard

    var body: some View {
        ZStack {
            if !isCardExpanded {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: -125) { // Adjust spacing for overlap
                        ForEach(0..<3) { index in
                            CardView(cardTitle: index, balance: "$\(accountTotals(accounts: accounts(for: index)))", isSelected: selectedCardIndex == index)
                                .padding(.horizontal)
                                .zIndex(selectedCardIndex == index ? 1 : 0)
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        selectedCardIndex = selectedCardIndex == index ? nil : index
                                        isCardExpanded = selectedCardIndex != nil
                                    }
                                }
                        }
                    }
                    .padding(.top, 50)
                }
                .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
            } else if let index = selectedCardIndex {
                ExpandedCardView(cardTitle: index, balance: "$\(accountTotals(accounts: accounts(for: index)))") {
                    withAnimation(.spring()) {
                        isCardExpanded = false
                        selectedCardIndex = nil
                    }
                }
                .zIndex(2)
            }
        }
        accountDisclosureGroupTitle(title: accountTypeTitle(for: index), account: accounts(for: index))
        .sheet(isPresented: $showAddAccountSheet) {
            AddAccountSheet(
                accountType: selectedAccountType,
                onAddAccount: addNewAccount
            )
        }
    }

    // MARK: - Utility Functions
    
    private func accountTypeTitle(for index: Int) -> String {
        switch index {
        case 0: return "Credit Cards"
        case 1: return "Checking Accounts"
        case 2: return "Savings Accounts"
        default: return ""
        }
    }

    private func accounts(for index: Int) -> [FinancialAccount] {
        switch index {
        case 0: return creditCards
        case 1: return checkingAccounts
        case 2: return savingsAccounts
        default: return []
        }
    }

    private func addNewAccount(account: FinancialAccount) {
        switch selectedAccountType {
        case .creditCard:
            creditCards.append(account)
        case .checkingAccount:
            checkingAccounts.append(account)
        case .savingsAccount:
            savingsAccounts.append(account)
        }
    }
    
    private func accountTotals(accounts: [FinancialAccount]) -> String {
        let total = accounts.reduce(0) { $0 + $1.balance }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        return formatter.string(from: NSNumber(value: total)) ?? "0.00"
    }
    
    private func accountDisclosureGroupTitle(title: String, account: [FinancialAccount]) -> String {
        return Text(title).font(.title3) +
        Text(" $\(accountTotals(accounts: account))"
    }
}

// MARK: - Card View

struct CardView: View {
    var cardTitle: Text
    var balance: String
    var isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            cardTitle
                .foregroundColor(.white)
            
            if isSelected {
                Text("Balance")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(balance)
                    .font(.title2)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(15)
        .shadow(radius: isSelected ? 10 : 5)
        .scaleEffect(isSelected ? 1.05 : 1.0) // Slightly enlarge the selected card
    }
}

// MARK: - Expanded Card View

struct ExpandedCardView: View {
    var cardTitle: String
    var balance: String
    var onClose: () -> Void

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(cardTitle)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Balance")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(balance)
                    .font(.title)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(15)
            .shadow(radius: 10)
            .padding()
        }
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all)) // Background similar to Wallet app
        .onTapGesture {
            withAnimation(.spring()) {
                onClose()
            }
        }
        .gesture(
            DragGesture().onEnded { value in
                if value.translation.height > 100 { // Detect downward swipe
                    withAnimation(.spring()) {
                        onClose()
                    }
                }
            }
        )
    }
}

// MARK: - Add Account Sheet

struct AddAccountSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String = ""
    @State private var balance: String = ""
    
    var accountType: AccountType
    var onAddAccount: (FinancialAccount) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account Details")) {
                    TextField("Account Name", text: $name)
                    
                    TextField("Account Balance", text: $balance)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationBarTitle("Add \(accountType.rawValue.capitalized)", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    if validateFields() {
                        let formattedBalance = Double(balance) ?? 0
                        let newAccount = FinancialAccount(name: name, balance: formattedBalance)
                        onAddAccount(newAccount)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .disabled(!validateFields())
            )
        }
    }
    
    // MARK: - Validation
    
    private func validateFields() -> Bool {
        return !name.isEmpty && !balance.isEmpty && Double(balance) != nil
    }
}

// MARK: - Supporting Models

struct FinancialAccount: Identifiable {
    var id = UUID()
    var name: String
    var balance: Double
}

enum AccountType: String, CaseIterable {
    case creditCard = "Credit Card"
    case checkingAccount = "Checking Account"
    case savingsAccount = "Savings Account"
}
