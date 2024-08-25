import SwiftUI

struct Accounts: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        AccountsPageView()
            .tabItem {
                Label("Accounts", systemImage: "hammer")
            }
            .navigationTitle("Accounts")
            .tag(0)
    }
}

struct AccountsPageView: View {
    @State private var creditCards: [FinancialAccount] = [
        FinancialAccount(name: "Apple Card", balance: 1024.45),
        FinancialAccount(name: "Wells Fargo Active Cash", balance: 1342453),
        FinancialAccount(name: "American Express", balance: 500)
    ]
    @State private var checkingAccounts: [FinancialAccount] = [FinancialAccount(name: "Everything", balance: 2000)]
    @State private var savingsAccounts: [FinancialAccount] = [FinancialAccount(name: "Nothing", balance: 2000)]
    
    @State private var showAccountTotals: Bool = true
    
    var body: some View {
        TabView {
            WalletView(accounts: $creditCards, showAccountTotals: $showAccountTotals, title: "Credit Cards")
            WalletView(accounts: $savingsAccounts, showAccountTotals: $showAccountTotals, title: "Savings")
            WalletView(accounts: $checkingAccounts, showAccountTotals: $showAccountTotals, title: "Checkings")
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

struct CardView: View {
    @Environment(\.colorScheme) var colorScheme
    var cardTitle: String
    var balance: Double
    var isSelected: Bool
    @Binding var showAccountTotals: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            CardHeaderView(cardTitle: cardTitle, balance: balance, isSelected: false, showAccountTotals: $showAccountTotals)
            
           Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                gradient: Gradient(colors: colorScheme == .dark ? [Color.purple, Color.indigo, Color.blue] : [Color.purple, Color.indigo, Color.blue]),
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
    @Environment(\.colorScheme) var colorScheme
    var cardTitle: String
    var balance: Double
    var isSelected: Bool
    @Binding var showAccountTotals: Bool

    
    var body: some View {
        HStack(alignment: .firstTextBaseline,spacing: 20){
            Text(cardTitle)
                .font(.system(size: 26))
                .fontWeight(.bold)
                .foregroundColor(colorScheme == .dark ? .black : .white)
            
            Spacer()
            
            if !isSelected && showAccountTotals{
                Text("$\(balance, specifier: "%.2f")")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .padding(.bottom)
            }
            else{
                Text("")
            }
            
        }
        
    }
}

struct ExpandedCardView: View {
    var cardTitle: String
    var balance: Double
    var geometry: GeometryProxy
    @Binding var showAccountTotals: Bool
    //let accounts: [FinancialAccount]
    var onClose: () -> Void
    

    var body: some View {
        
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                HStack{
                    CardHeaderView(cardTitle: cardTitle, balance: balance, isSelected: true, showAccountTotals: $showAccountTotals)
                    Spacer()
                    VStack{
                        Button(action: {
                            onClose()
                        }) {
                            Text("close")
                                .foregroundColor(.white)
                                .font(Font.callout)
                                .bold()
                        }
                    }
                }
                    
                Text("Balance")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
                
                Text("$\(balance, specifier: "%.2f")")
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

struct WalletHeaderView: View{
    let title: String
    let accountTotal: String
    @Binding var showAddAccount: Bool
    @Binding var showAccountTotals: Bool
    
    var body: some View{
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.system(size: 36))
                    .bold()
                    .padding(.top, 40)  // Adjust padding here if needed
                    .alignmentGuide(.firstTextBaseline) { d in d[.firstTextBaseline] }
                Button(action: {
                    showAccountTotals.toggle() // Toggles between showing and hiding the total
                }) {
                    Image(systemName: showAccountTotals ? "eye" : "eye.slash")
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                        .padding(.top, 45)
                        
                }
                
                Spacer()
                
                Button(action: {
                    showAddAccount = true
                }) {
                    Text("add")
                        .foregroundColor(.blue)
                        .font(Font.callout)
                        .bold()
                        .padding(.top, 30)
                        .padding(.horizontal, 20)
                }
                .padding(.top)
                
            }
            
            Text(showAccountTotals ? "Total: $\(accountTotal)" : "")
                .bold()
        }
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
                                                     showAccountTotals: $showAccountTotals)
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
                 if showAddAccount {
                    AddAccountView(accounts: $accounts, isSelected: $showAddAccount)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                        .cornerRadius(15)
                        .shadow(radius: 10)
                        .padding()
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

struct AddAccountView: View {
    @Binding var accounts: [FinancialAccount]
    @Environment(\.colorScheme) var colorScheme
    @Binding var isSelected: Bool
    @State private var accountName: String = ""
    @State private var accountBalance: String = ""

    var body: some View {
        VStack {
            TextField("Account Name", text: $accountName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Balance", text: $accountBalance)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
            HStack {
                Button("Cancel") {
                    // Dismiss the view
                    isSelected = false
                }
                .foregroundColor(.red)
                
                Spacer()
                
                Button("Save") {
                    if let balance = Double(accountBalance) {
                        let newAccount = FinancialAccount(name: accountName, balance: balance)
                        accounts.append(newAccount)
                        // Dismiss the view
                        isSelected = false
                    }
                }
                .disabled(accountName.isEmpty || accountBalance.isEmpty)
            }
            .padding(20)
        }
    }
}
