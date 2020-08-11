import XCTest
import Nimble

@testable import class Purchases.IntroEligibilityCalculator

class IntroEligibilityCalculatorTests: XCTestCase {

    var introEligibilityCalculator: IntroEligibilityCalculator!
    let mockProductsManager = MockProductsManager()
    let mockReceiptParser = MockReceiptParser()

    override func setUp() {
        super.setUp()
        introEligibilityCalculator = IntroEligibilityCalculator(productsManager: mockProductsManager,
                                                                receiptParser: mockReceiptParser)
    }

    func testCheckTrialOrIntroductoryPriceEligibilityReturnsEmptyIfNoProductIds() {
    }
}
