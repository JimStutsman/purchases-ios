import XCTest
import Nimble

@testable import class Purchases.IntroEligibilityCalculator
@testable import enum Purchases.ReceiptReadingError
@testable import struct Purchases.AppleReceipt
@testable import struct Purchases.InAppPurchase

@available(iOS 12.0, macOS 10.14, macCatalyst 13.0, tvOS 12.0, watchOS 6.2, *)
class IntroEligibilityCalculatorTests: XCTestCase {

    var calculator: IntroEligibilityCalculator!
    let mockProductsManager = MockProductsManager()
    let mockReceiptParser = MockReceiptParser()

    override func setUp() {
        super.setUp()
        calculator = IntroEligibilityCalculator(productsManager: mockProductsManager,
                                                receiptParser: mockReceiptParser)
    }

    func testCheckTrialOrIntroductoryPriceEligibilityReturnsEmptyIfNoProductIds() {
        var receivedError: Error? = nil
        var receivedEligibility: [String: NSNumber]? = nil
        var completionCalled = false
        calculator.checkTrialOrIntroductoryPriceEligibility(with: Data(),
                                                            productIdentifiers: Set()) { eligibilityByProductId, error in
            completionCalled = true
            receivedError = error
            receivedEligibility = eligibilityByProductId
        }

        expect(completionCalled).toEventually(beTrue())
        expect(receivedError).to(beNil())
        expect(receivedEligibility).toNot(beNil())
        expect(receivedEligibility).to(beEmpty())
    }

    func testCheckTrialOrIntroductoryPriceEligibilityReturnsErrorIfReceiptParserThrows() {
        var receivedError: Error? = nil
        var receivedEligibility: [String: NSNumber]? = nil
        var completionCalled = false
        let productIdentifiers = Set(["com.revenuecat.test"])

        mockReceiptParser.stubbedParseError = ReceiptReadingError.receiptParsingError

        calculator.checkTrialOrIntroductoryPriceEligibility(with: Data(),
                                                            productIdentifiers: productIdentifiers) { eligibilityByProductId, error in
            completionCalled = true
            receivedError = error
            receivedEligibility = eligibilityByProductId
        }

        expect(completionCalled).toEventually(beTrue())
        expect(receivedError).to(matchError(ReceiptReadingError.receiptParsingError))
        expect(receivedEligibility).toNot(beNil())
        expect(receivedEligibility).to(beEmpty())
    }

    func testCheckTrialOrIntroductoryPriceEligibilityMakesOnlyOneProductsRequest() {
        var receivedError: Error? = nil
        var receivedEligibility: [String: NSNumber]? = nil
        var completionCalled = false
        calculator.checkTrialOrIntroductoryPriceEligibility(with: Data(),
                                                            productIdentifiers: Set()) { eligibilityByProductId, error in
            completionCalled = true
            receivedError = error
            receivedEligibility = eligibilityByProductId
        }

        expect(completionCalled).toEventually(beTrue())
        expect(receivedError).to(beNil())
        expect(receivedEligibility).toNot(beNil())
        expect(receivedEligibility).to(beEmpty())
    }
}

@available(iOS 12.0, macOS 10.14, macCatalyst 13.0, tvOS 12.0, watchOS 6.2, *)
private extension IntroEligibilityCalculatorTests {
    func mockInAppPurchases() -> [InAppPurchase] {
        return [
            InAppPurchase(quantity: 1,
                          productId: "com.revenuecat.product1",
                          transactionId: "65465265651323",
                          originalTransactionId: "65465265651323",
                          productType: .consumable,
                          purchaseDate: Date(),
                          originalPurchaseDate: Date(),
                          expiresDate: nil,
                          cancellationDate: nil,
                          isInTrialPeriod: false,
                          isInIntroOfferPeriod: false,
                          webOrderLineItemId: 516854313,
                          promotionalOfferIdentifier: nil),
            InAppPurchase(quantity: 1,
                          productId: "com.revenuecat.product2",
                          transactionId: "65465265651322",
                          originalTransactionId: "65465265651321",
                          productType: .autoRenewableSubscription,
                          purchaseDate: Date(),
                          originalPurchaseDate: Date(),
                          expiresDate: Date(),
                          cancellationDate: nil,
                          isInTrialPeriod: false,
                          isInIntroOfferPeriod: false,
                          webOrderLineItemId: 64651321,
                          promotionalOfferIdentifier: nil),
            InAppPurchase(quantity: 1,
                          productId: "com.revenuecat.product2",
                          transactionId: "65465265651321",
                          originalTransactionId: "65465265651321",
                          productType: .autoRenewableSubscription,
                          purchaseDate: Date(),
                          originalPurchaseDate: Date(),
                          expiresDate: Date(),
                          cancellationDate: nil,
                          isInTrialPeriod: true,
                          isInIntroOfferPeriod: false,
                          webOrderLineItemId: 64651320,
                          promotionalOfferIdentifier: nil)
        ]
    }

    func mockReceipt() -> AppleReceipt {
        return AppleReceipt(bundleId: "com.revenuecat.test",
                            applicationVersion: "3.4.5",
                            originalApplicationVersion: "3.2.1",
                            opaqueValue: Data(),
                            sha1Hash: Data(),
                            creationDate: Date(),
                            expirationDate: nil,
                            inAppPurchases: mockInAppPurchases())
    }
}
