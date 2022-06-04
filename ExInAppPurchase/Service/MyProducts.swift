//
//  MyProducts.swift
//  ExInAppPurchase
//
//  Created by 김종권 on 2022/06/04.
//

import Foundation

enum MyProducts {
  static let productID = "com.jake.sample.ExInAppPurchase.shopping"
  static let iapService: IAPServiceType = IAPService(productIDs: Set<String>([productID]))
  
  static func getResourceProductName(_ id: String) -> String? {
    id.components(separatedBy: ".").last
  }
}
