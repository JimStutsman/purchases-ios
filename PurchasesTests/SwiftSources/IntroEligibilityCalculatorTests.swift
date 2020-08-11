import XCTest
import Nimble


@testable import class Purchases.IntroEligibilityCalculator
@testable import class Purchases.ProductsManager
@testable import class Purchases.ReceiptParser

class IntroEligibilityCalculatorTests: XCTestCase {

    var introEligibilityCalculator: IntroEligibilityCalculator!
    let productsManager = ProductsManager()
    let receiptParser = ReceiptParser()
    

    override func setUp() {
        super.setUp()
        introEligibilityCalculator = IntroEligibilityCalculator(productsManager: productsManager, receiptParser: receiptParser)
    }

    func testCheckTrialOrIntroductoryPriceEligibilityReturnsEmptyIfNoProductIds() {

    }
}
