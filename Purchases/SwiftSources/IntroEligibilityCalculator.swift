//
//  IntroEligibilityCalculator.swift
//  Purchases
//
//  Created by Andrés Boedo on 7/14/20.
//  Copyright © 2020 Purchases. All rights reserved.
//

import Foundation
import StoreKit

@objc(RCIntroEligibilityCalculator) class IntroEligibilityCalculator: NSObject {
    private let productsManager: ProductsManager
    private let receiptParser: ReceiptParser
    
    override init() {
        self.productsManager = ProductsManager()
        self.receiptParser = ReceiptParser()
    }
    
    internal init(productsManager: ProductsManager,
                  receiptParser: ReceiptParser) {
        self.productsManager = productsManager
        self.receiptParser = receiptParser
    }
    
    @available(iOS 12.0, macOS 10.14, macCatalyst 13.0, tvOS 12.0, watchOS 6.2, *)
    @objc func checkTrialOrIntroductoryPriceEligibility(with receiptData: Data,
                                                        productIdentifiers candidateProductIdentifiers: Set<String>,
                                                        completion: @escaping ([String: NSNumber], Error?) -> Void) {
        guard candidateProductIdentifiers.count > 0 else {
            completion([:], nil)
            return
        }
        
        var result: [String: NSNumber] = candidateProductIdentifiers.reduce(into: [:]) { resultDict, productId in
            resultDict[productId] = IntroEligibilityStatus.unknown.toNSNumber()
        }
        do {
            let receipt = try receiptParser.parse(from: receiptData)
            let purchasedProductIdsWithIntroOffers = receipt.purchasedIntroOfferOrFreeTrialProductIdentifiers()
            
            let allProductIdentifiers = candidateProductIdentifiers.union(purchasedProductIdsWithIntroOffers)
            
            productsManager.products(withIdentifiers: allProductIdentifiers) { allProducts in
                let purchasedProductsWithIntroOffers = allProducts.filter { purchasedProductIdsWithIntroOffers.contains($0.productIdentifier) }
                let candidateProducts = allProducts.filter { candidateProductIdentifiers.contains($0.productIdentifier) }
                
                let eligibility: [String: NSNumber] = self.checkIntroEligibility(candidateProducts: candidateProducts,
                                                                                 purchasedProductsWithIntroOffers: purchasedProductsWithIntroOffers)
                result.merge(eligibility) { (_, new) in new }
                
                completion(result, nil)
            }
        }
        catch let error {
            completion([:], error)
            return
        }
    }
}

@available(iOS 12.0, macOS 10.14, macCatalyst 13.0, tvOS 12.0, watchOS 6.2, *)
private extension IntroEligibilityCalculator {
    
    func checkIntroEligibility(candidateProducts: Set<SKProduct>,
                               purchasedProductsWithIntroOffers: Set<SKProduct>) -> [String: NSNumber] {
        var result: [String: NSNumber] = [:]
        for candidate in candidateProducts {
            let usedIntroForProductIdentifier = purchasedProductsWithIntroOffers
                .contains { purchased in
                    let foundByProductId = candidate.productIdentifier == purchased.productIdentifier
                    let foundByGroupId = candidate.subscriptionGroupIdentifier == purchased.subscriptionGroupIdentifier
                        && candidate.subscriptionGroupIdentifier != nil
                    return foundByProductId || foundByGroupId
                }
            result[candidate.productIdentifier] = usedIntroForProductIdentifier
                ? IntroEligibilityStatus.ineligible.toNSNumber()
                : IntroEligibilityStatus.eligible.toNSNumber()
        }
        return result
    }
}

enum IntroEligibilityStatus: Int {
    case unknown,
         ineligible,
         eligible
}

extension IntroEligibilityStatus {
    func toNSNumber() -> NSNumber {
        return NSNumber(integerLiteral: self.rawValue)
    }
}
