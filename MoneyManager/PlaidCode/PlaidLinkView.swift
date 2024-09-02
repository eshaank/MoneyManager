//
//  PlaidLinkView.swift
//  MoneyManager
//
//  Created by Eshaan Kansagara on 9/1/24.

import SwiftUI
import UIKit

struct PlaidLinkView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> PlaidLinkViewController {
        return PlaidLinkViewController()
    }

    func updateUIViewController(_ uiViewController: PlaidLinkViewController, context: Context) {}
}
