//
//  IAPProducts.swift
//  AntTracker
//
//  Created by test on 30.09.2021.
//

import Foundation

public struct IAPProducts {
  
  public static let SwiftShopping = "AntTrackerGift"
  
  private static let productIdentifiers: Set<ProductIdentifier> = [IAPProducts.SwiftShopping]

  public static let store = IAPHelper(productIds: IAPProducts.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
  return productIdentifier.components(separatedBy: ".").last
}
