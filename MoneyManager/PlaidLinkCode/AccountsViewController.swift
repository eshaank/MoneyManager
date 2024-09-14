import UIKit

class AccountsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    private var accounts: [Account] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchAccounts()
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = "Accounts"

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AccountCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func fetchAccounts() {
        ServerCommunicator().callMyServer(path: "/api/accounts", httpMethod: .get) { (result: Result<AccountsResponse, ServerCommunicator.Error>) in
            switch result {
            case .success(let response):
                self.accounts = response.accounts
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch accounts: \(error)")
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath)
        let account = accounts[indexPath.row]
        cell.textLabel?.text = account.name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedAccount = accounts[indexPath.row]
        let transactionsVC = TransactionsViewController(accountId: selectedAccount.accountId)
        navigationController?.pushViewController(transactionsVC, animated: true)
    }
}
