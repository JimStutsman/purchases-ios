//
// Created by Andrés Boedo on 8/11/20.
// Copyright (c) 2020 Purchases. All rights reserved.
//

import Foundation

@testable import Purchases

class MockProductsManager: ProductsManager {

    var invokedProducts = false
    var invokedProductsCount = 0
    var invokedProductsParameters: (identifiers: Set<String>, Void)?
    var invokedProductsParametersList = [(identifiers: Set < String>, Void)]()
    var stubbedProductsCompletionResult: (Set<SKProduct>, Void)?

    override func products(withIdentifiers identifiers: Set<String>, completion: @escaping (Set<SKProduct>) -> Void) {
        invokedProducts = true
        invokedProductsCount += 1
        invokedProductsParameters = (identifiers, ())
        invokedProductsParametersList.append((identifiers, ()))
        if let result = stubbedProductsCompletionResult {
            completion(result.0)
        }
    }
}
