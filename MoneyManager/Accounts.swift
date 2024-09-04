import SwiftUI

struct AccountSection: Identifiable {
    let id: String
    let title: String
    var isExpanded: Bool
    var accounts: [FinancialAccount]
}

struct Accounts: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        AccountsPageView()
            .tabItem {
                Label("Accounts", systemImage: "hammer")
            }
            .tag(0)
    }
}

struct AccountsPageView: View {
    @State private var accountSections: [AccountSection] = DummyData.loadDummyAccounts()
    @State private var showAccountTotals: Bool = true
    @State private var showPlaidLink: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Spacer().frame(height: 20)  // Add this line to create space
                    ForEach($accountSections) { $section in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Button(action: {
                                    section.isExpanded.toggle()
                                }) {
                                    Image(systemName: section.isExpanded ? "chevron.down" : "chevron.right")
                                }
                                Text(section.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                                Button(action: {
                                    showPlaidLink = true
                                }) {
                                    HStack {
                                        Image(systemName: "plus")
                                        Text("Add")
                                    }
                                    .padding(.vertical, 5)
                                    .padding(.horizontal, 10)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(20)
                                    .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 2)
                                }
                                .font(.system(size: 14, weight: .semibold))
                            }
                            
                            if section.isExpanded {
                                AccountSectionView(accounts: $section.accounts, showAccountTotals: $showAccountTotals)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Accounts")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAccountTotals.toggle()
                    }) {
                        Image(systemName: showAccountTotals ? "eye.fill" : "eye.slash.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing, 8)
                }
            }
        }
        .sheet(isPresented: $showPlaidLink) {
            PlaidLinkView(accountSections: $accountSections) { success, errorMessage in
                showPlaidLink = false
                // Handle success or error here if needed
            }
        }
    }
}

struct AccountSectionView: View {
    @Binding var accounts: [FinancialAccount]
    @Binding var showAccountTotals: Bool
    @State private var selectedAccount: FinancialAccount?
    
    var body: some View {
        ForEach(accounts) { account in
            CardView(cardTitle: account.name, 
                     balance: account.balance, 
                     isSelected: selectedAccount?.id == account.id, 
                     showAccountTotals: $showAccountTotals,
                     onViewDetails: {
                         selectedAccount = account
                     })
                .frame(height: 150)
        }
        .sheet(item: $selectedAccount) { account in
            GeometryReader { geometry in
                ExpandedCardView(
                    cardTitle: account.name,
                    balance: account.balance,
                    geometry: geometry,
                    showAccountTotals: $showAccountTotals,
                    onClose: { selectedAccount = nil }
                )
            }
        }
    }
}

struct CardView: View {
    @Environment(\.colorScheme) var colorScheme
    var cardTitle: String
    var balance: Double
    var isSelected: Bool
    @Binding var showAccountTotals: Bool
    var onViewDetails: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(cardTitle)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Spacer() 
                Image(systemName: "creditcard.fill")
                    .foregroundColor(.blue)
            }
            
            if showAccountTotals {
                Text(formatBalance(balance))
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.green)
            } else {
                Text("••••••")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.green)
            }
            
            HStack {
                Text("Available Balance")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                Spacer()
                Button(action: onViewDetails) {
                    Text("View Details")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.blue)
                }
            }
        }        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
    
    private func formatBalance(_ balance: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: balance)) ?? "$0.00"
    }
}

struct CardHeaderView: View {
    @Environment(\.colorScheme) var colorScheme
    var cardTitle: String
    var balance: Double
    var isSelected: Bool
    @Binding var showAccountTotals: Bool
    
    var body: some View {
        HStack(alignment: .firstTextBaseline,spacing: 20){
            Text(cardTitle)
                .font(.system(size: 28))
                .fontWeight(.bold)
                .foregroundColor(colorScheme == .dark ? .black : .white)
            
            Spacer()
            
            if !isSelected && showAccountTotals{
                Text("$\(balance, specifier: "%.2f")")
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .padding(.bottom)
            }
            
        }
        
    }
}

struct ExpandedCardView: View {
    @Environment(\.colorScheme) var colorScheme
    var cardTitle: String
    var balance: Double
    var geometry: GeometryProxy
    @Binding var showAccountTotals: Bool
    var onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(cardTitle)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 24))
                }
            }
            
            Text("Available Balance")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
            
            if showAccountTotals {
                Text(formatBalance(balance))
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.green)
            } else {
                Text("••••••")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.green)
            }
            
            Text("Recent Transactions")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            ScrollView(.vertical, showsIndicators: true) {
                ForEach(0..<10) { _ in
                    HStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: geometry.size.height / 15)
                        Spacer()
                    }
                }
            }
            
            Text("Spending Overview")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.2))
                .frame(height: geometry.size.height / 4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
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
    
    private func formatBalance(_ balance: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: balance)) ?? "$0.00"
    }
}

struct WalletHeaderView: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let accountTotal: String
    @Binding var showAddAccount: Bool
    @Binding var showAccountTotals: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Spacer()
                Button(action: {
                    showAddAccount = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 24))
                }
            }
            
            HStack {
                Text(showAccountTotals ? "Total: \(accountTotal)" : "Total: ••••••")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.green)
                Spacer()
                Button(action: {
                    showAccountTotals.toggle()
                }) {
                    Image(systemName: showAccountTotals ? "eye.fill" : "eye.slash.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 18))
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
}

struct WalletView: View {
    @Binding var accounts: [FinancialAccount]
    @Binding var showAccountTotals: Bool
    @State private var selectedCardIndex: Int? = nil
    @State private var isCardExpanded: Bool = false
    @State private var scrollOffset: CGFloat = 0
    @State private var initialTopCardPosition: CGFloat? = nil
    @State private var showAddAccount: Bool = false

    let title: String

    var body: some View {
        GeometryReader { geometry in
            VStack {
                if !isCardExpanded {
                    WalletHeaderView(title: title, 
                                     accountTotal: accountTotal(accounts: accounts), 
                                     showAddAccount: $showAddAccount,
                                     showAccountTotals: $showAccountTotals)
                }
                ZStack {
                    if !isCardExpanded {
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack {
                                GeometryReader { innerGeometry in
                                    VStack(spacing: calculateSpacing(innerGeometry)) {
                                        ForEach(accounts.indices, id: \.self) { index in
                                            let account = accounts[index]
                                            CardView(cardTitle: account.name,
                                                     balance: account.balance,
                                                     isSelected: selectedCardIndex == index,
                                                     showAccountTotals: $showAccountTotals,
                                                     onViewDetails: {
                                                         // Handle view details action here
                                                         print("View details tapped for \(account.name)")
                                                     })
                                                .padding(.horizontal)
                                                .frame(height: geometry.size.height / 4) // Dynamic card height
                                                .offset(y: calculateOffset(innerGeometry, index: index, scrollViewHeight: geometry.size.height))
                                                .zIndex(selectedCardIndex == index ? 1 : 0)
                                                .onTapGesture {
                                                    withAnimation(.easeInOut(duration: 0.3)) {
                                                        selectedCardIndex = selectedCardIndex == index ? nil : index
                                                        isCardExpanded = selectedCardIndex != nil
                                                    }
                                                }
                                                .onAppear {
                                                    if index == 0 {
                                                        initialTopCardPosition = innerGeometry.frame(in: .global).minY
                                                    }
                                                }
                                        }
                                    }
                                    .onAppear {
                                        scrollOffset = innerGeometry.frame(in: .global).minY
                                    }
                                    .onChange(of: innerGeometry.frame(in: .global).minY) { newOffset in
                                        scrollOffset = newOffset
                                    }
                                }
                                .frame(height: CGFloat(accounts.count) * (geometry.size.height / 4) + CGFloat((accounts.count - 1) * -110))
                                .padding(.top, 10) // Move cards lower by adding top padding
                            }
                        }
                    } else if let index = selectedCardIndex {
                        let selectedAccount = accounts[index]
                        ExpandedCardView(cardTitle: selectedAccount.name,
                                         balance: selectedAccount.balance,
                                         geometry: geometry,
                                         showAccountTotals: $showAccountTotals) {
                            withAnimation(.spring()) {
                                isCardExpanded = false
                                selectedCardIndex = nil
                            }
                        }
                        .zIndex(2)
                    }
                }
            }
            .animation(.spring(), value: showAddAccount)
        }
    }
    
    private func calculateSpacing(_ geometry: GeometryProxy) -> CGFloat {
        let baseSpacing: CGFloat = -150
        let additionalSpacing = max(0, scrollOffset / 10)
        return baseSpacing + additionalSpacing
    }
    
    private func calculateOffset(_ geometry: GeometryProxy, index: Int, scrollViewHeight: CGFloat) -> CGFloat {
        guard let initialTopCardPosition = initialTopCardPosition else {
            return 0
        }
        
        let currentOffset = geometry.frame(in: .global).minY - initialTopCardPosition
        let adjustedOffset = max(currentOffset, 0)
        
        let pullOffset = max(0, scrollOffset / 10)
        return pullOffset * CGFloat(index) + adjustedOffset
    }

    private func accountTotal(accounts: [FinancialAccount]) -> String {
        let total = accounts.reduce(0) { $0 + $1.balance }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        return formatter.string(from: NSNumber(value: total)) ?? "0.00"
    }
}
