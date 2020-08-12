//
// Created by Andrés Boedo on 8/5/20.
// Copyright (c) 2020 Purchases. All rights reserved.
//

import Foundation

@testable import Purchases

class MockOperationDispatcher: Purchases.OperationDispatcher {
    override func dispatch(onMainThread block: @escaping () -> ()) {
        block()
    }

    override func dispatch(onWorkerThread block: @escaping () -> ()) {
        block()
    }
}
