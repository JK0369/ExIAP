//
//  IAPService.swift
//  ExInAppPurchase
//
//  Created by 김종권 on 2022/06/04.
//

import StoreKit

// 1. request, response 처리
// 외부에서 productsCompletion를 통해 데이터 획득
// 내부에서는 completion을 가지고 있다가, delegate에서 completion을 호출

// 2. SKPaymentQueue라는 큐를 사용하여 데이터를 가져오기 처리
// 구입 - SKPaymentQueue.default().add()
// 복구 - SKPaymentQueue.default().restoreCompletedTransactions()
// payments가 가능한지 확인 - SKPaymentQueue.canMakePayments()

typealias ProductsRequestCompletion = (_ success: Bool, _ products: [SKProduct]?) -> Void

protocol IAPServiceType {
  var canMakePayments: Bool { get }
  
  func getProducts(completion: @escaping ProductsRequestCompletion)
  func buyProduct(_ product: SKProduct)
  func isProductPurchased(_ productID: String) -> Bool
  func restorePurchases()
}

final class IAPService: NSObject, IAPServiceType {
  private let productIDs: Set<String>
  private var purchasedProductIDs: Set<String> = []
  private var productsRequest: SKProductsRequest?
  private var productsCompletion: ProductsRequestCompletion?
  
  var canMakePayments: Bool {
    SKPaymentQueue.canMakePayments()
  }
  
  init(productIDs: Set<String>) {
    self.productIDs = productIDs
  }
  
  func getProducts(completion: @escaping ProductsRequestCompletion) {
    self.productsRequest?.cancel()
    self.productsCompletion = completion
    self.productsRequest = SKProductsRequest(productIdentifiers: self.productIDs)
    self.productsRequest?.delegate = self
    self.productsRequest?.start()
  }
  func buyProduct(_ product: SKProduct) {
    SKPaymentQueue.default().add(SKPayment(product: product))
  }
  func isProductPurchased(_ productID: String) -> Bool {
    self.purchasedProductIDs.contains(productID)
  }
  func restorePurchases() {
    SKPaymentQueue.default().restoreCompletedTransactions()
  }
}

extension IAPService: SKProductsRequestDelegate {
  // didReceive
  func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    let products = response.products
    self.productsCompletion?(true, products)
    self.clearRequestAndHandler()
    
    products.forEach { print("Found product: \($0.productIdentifier) \($0.localizedTitle) \($0.price.floatValue)") }
  }
  
  // failed
  func request(_ request: SKRequest, didFailWithError error: Error) {
    print("Erorr: \(error.localizedDescription)")
    self.productsCompletion?(false, nil)
    self.clearRequestAndHandler()
  }
  
  private func clearRequestAndHandler() {
    self.productsRequest = nil
    self.productsCompletion = nil
  }
}
