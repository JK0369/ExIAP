//
//  ViewController.swift
//  ExInAppPurchase
//
//  Created by 김종권 on 2022/06/03.
//

import UIKit
import StoreKit

class ViewController: UIViewController {
  private let restoreButton: UIButton = {
    let button = UIButton()
    button.setTitle("구매 목록 불러오기 버튼", for: .normal)
    button.setTitleColor(.systemBlue, for: .normal)
    button.setTitleColor(.blue, for: .highlighted)
    button.addTarget(self, action: #selector(restore), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  private let tableView: UITableView = {
    let view = UITableView()
    view.allowsSelection = false
    view.backgroundColor = .clear
    view.bounces = true
    view.showsVerticalScrollIndicator = true
    view.contentInset = .zero
    view.register(ProductCell.self, forCellReuseIdentifier: ProductCell.id)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private var products = [SKProduct]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    self.view.addSubview(self.restoreButton)
    self.view.addSubview(self.tableView)
    
    NSLayoutConstraint.activate([
      self.restoreButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 30),
      self.restoreButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
    ])
    NSLayoutConstraint.activate([
      self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
      self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
      self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -16),
      self.tableView.topAnchor.constraint(equalTo: self.restoreButton.bottomAnchor, constant: 16),
    ])
    
    self.tableView.dataSource = self
    
    MyProducts.iapService.getProducts { [weak self] success, products in
      print("load products \(products ?? [])")
      guard let ss = self else { return }
      if success, let products = products {
        DispatchQueue.main.async {
          ss.products = products
          ss.tableView.reloadData()
        }
      }
    }
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handlePurchaseNoti(_:)),
      name: .iapServicePurchaseNotification,
      object: nil
    )
  }
  
  @objc private func restore() {
    MyProducts.iapService.restorePurchases()
  }
  
  @objc private func handlePurchaseNoti(_ notification: Notification) {
    guard
      let productID = notification.object as? String,
      let index = self.products.firstIndex(where: { $0.productIdentifier == productID })
    else { return }
    
    self.tableView.reloadRows(at: [IndexPath(index: index)], with: .fade)
    self.tableView.performBatchUpdates(nil, completion: nil)
  }
}

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    self.products.count
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ProductCell.id, for: indexPath) as! ProductCell
    let product = self.products[indexPath.row]

    if MyProducts.iapService.isProductPurchased(product.productIdentifier) {
      cell.prepare(name: product.localizedTitle, price: "구입 완료", isPurchased: true)
    } else if MyProducts.iapService.canMakePayments {
      let formatter = NumberFormatter()
      formatter.formatterBehavior = .behavior10_4
      formatter.numberStyle = .currency
      cell.prepare(name: product.localizedTitle, price: formatter.string(from: product.price), isPurchased: false)
    } else {
      cell.prepare(name: "Not available", price: nil, isPurchased: nil)
    }
    
    cell.buyButtonTap = { [weak product] in
      guard let product = product else { return }
      MyProducts.iapService.buyProduct(product)
    }
    
    return cell
  }
}
