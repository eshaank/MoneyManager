//
//  TransactionCell.swift
//  LinkDemo-Swift-UIKit
//
//  Created by Eshaan Kansagara on 9/8/24.
//  Copyright © 2024 Plaid Inc. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell {
    
    private let dateLabel = UILabel()
    private let nameLabel = UILabel()
    private let amountLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        dateLabel.font = .systemFont(ofSize: 12)
        nameLabel.font = .systemFont(ofSize: 16)
        amountLabel.font = .systemFont(ofSize: 16)
        amountLabel.textAlignment = .right

        let stackView = UIStackView(arrangedSubviews: [dateLabel, nameLabel, amountLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with transaction: Transaction) {
        dateLabel.text = transaction.date
        nameLabel.text = transaction.name
        amountLabel.text = String(format: "$%.2f", transaction.amount)
    }
}
