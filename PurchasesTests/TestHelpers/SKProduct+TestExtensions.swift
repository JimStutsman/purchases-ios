//
// Created by Andrés Boedo on 8/12/20.
// Copyright (c) 2020 Purchases. All rights reserved.
//

import Foundation

extension SKProduct {
    convenience init(productIdentifier: String,
                     subscriptionGroupId: String? = nil) {
        self.init()
        self.setValue(productIdentifier, forKey: "productIdentifier")
        self.setValue(subscriptionGroupId, forKey: "subscriptionGroupIdentifier")
    }
}
