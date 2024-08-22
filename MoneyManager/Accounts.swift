import SwiftUI

struct Accounts: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        FinancialView()
            .tabItem {
                Label("Accounts", systemImage: "hammer")
            }
            .navigationTitle("Accounts")
    }
}

struct FinancialView: View{
    @State private var isCreditCardsExpanded: Bool = true
    @State private var isCheckingExpanded: Bool = true
    @State private var isSavingsExpanded: Bool = true

    @State private var showAddAccountSheet: Bool = false
    @State private var selectedAccountType: AccountType = .creditCard

    @State private var creditCards: [FinancialAccount] = [
        FinancialAccount(name: "Visa", balance: 2000),
        FinancialAccount(name: "Wells Fargo Active Cash", balance: 2000),
        FinancialAccount(name: "American Express Platinum", balance: 50000)]

    @State private var checkingAccounts: [FinancialAccount] = [FinancialAccount(name: "Everything", balance: 2000)]

    @State private var savingsAccounts: [FinancialAccount] = [FinancialAccount(name: "Nothing", balance: 2000)]
    
    var body: some View{
        TabView {
            WalletView(title: "Credit Cards",
                       accounts: creditCards)
            WalletView(title: "Savings",
                       accounts: savingsAccounts)
            WalletView(title: "Checkings",
                       accounts: checkingAccounts)
        }
        .tabViewStyle(PageTabViewStyle())

    }
}

struct WalletView: View {
    @State private var selectedCardIndex: Int? = nil
    @State private var isCardExpanded: Bool = false
    
    let title: String
    let accounts: [FinancialAccount]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if !isCardExpanded {
                    ScrollView(.vertical, showsIndicators: false) {
                        Text(title)
                            .font(.largeTitle)
                        VStack(spacing: -geometry.size.height / 6) { // Dynamic spacing based on screen height
                            ForEach(accounts.indices, id: \.self) { index in
                                let account = accounts[index]
                                CardView(cardTitle: account.name, isSelected: selectedCardIndex == index)
                                    .padding(.horizontal)
                                    .frame(height: geometry.size.height / 4) // Dynamic card height
                                    .zIndex(selectedCardIndex == index ? 1 : 0)
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            selectedCardIndex = selectedCardIndex == index ? nil : index
                                            isCardExpanded = selectedCardIndex != nil
                                        }
                                    }
                            }
                        }
                        .padding(.top, geometry.size.height / 10) // Dynamic top padding
                    }
                } else if let index = selectedCardIndex {
                    let selectedAccount = accounts[index]
                    ExpandedCardView(cardTitle: selectedAccount.name,
                                     balance: "$\(formatNumber(number: selectedAccount.balance))",
                                     geometry: geometry) {
                        withAnimation(.spring()) {
                            isCardExpanded = false
                            selectedCardIndex = nil
                        }
                    }
                    .zIndex(2)
                }
            }
        }
    }

    private func formatNumber(number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        return formatter.string(from: NSNumber(value: number)) ?? "0.00"
    }
}

struct CardView: View {
    @Environment(\.colorScheme) var colorScheme
    var cardTitle: String
    var isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            CardHeaderView(cardTitle: cardTitle)
            
           Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                gradient: Gradient(colors: colorScheme == .dark ? [Color.blue, Color.purple] : [Color.purple, Color.blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(15)
        .shadow(radius: isSelected ? 10 : 5)
        .scaleEffect(isSelected ? 1.05 : 1.0)
    }
}

struct CardHeaderView: View {
    var cardTitle: String
    var body: some View {
        Text(cardTitle)
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.white)
    }
}

struct ExpandedCardView: View {
    var cardTitle: String
    var balance: String
    var geometry: GeometryProxy
    //let accounts: [FinancialAccount]
    var onClose: () -> Void
    

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                CardHeaderView(cardTitle: cardTitle)
                
                Text("Balance")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(balance)
                    .font(.title)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                
                // Placeholder for "Recent Transactions"
                Text("Recent Transactions")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top)

                ForEach(0..<3) { transaction in
                    HStack {
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: geometry.size.width / 3, height: geometry.size.height / 15)
                            .cornerRadius(10)
                        Spacer()
                    }
                    .padding(.vertical, 5)
                }

                // Placeholder for "Spending Overview"
                Text("Spending Overview")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top)

                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: geometry.size.height / 4)
                    .cornerRadius(15)
                
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
        .onTapGesture {
            withAnimation(.spring()) {
                onClose()
            }
        }
        .gesture(
            DragGesture().onEnded { value in
                if value.translation.height > 100 {
                    withAnimation(.spring()) {
                        onClose()
                    }
                }
            }
        )
    }
}
