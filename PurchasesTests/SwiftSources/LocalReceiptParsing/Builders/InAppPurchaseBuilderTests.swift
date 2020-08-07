//
// Created by Andrés Boedo on 8/7/20.
// Copyright (c) 2020 Purchases. All rights reserved.
//

import Foundation
import XCTest
import Nimble

@testable import Purchases

class InAppPurchaseBuilderTests: XCTest {
    let quantity = 2
    let productId = "com.revenuecat.sampleProduct"
    let transactionId = "089230953203"
    let originalTransactionId = "089230953101"
    let productType = InAppPurchaseProductType.autoRenewableSubscription
    let purchaseDate = Date.from(year: 2019, month: 5, day: 3, hour: 1, minute: 55, second: 1)
    let originalPurchaseDate = Date.from(year: 2018, month: 6, day: 22, hour: 1, minute: 55, second: 1)
    let expiresDate = Date.from(year: 2018, month: 6, day: 22, hour: 1, minute: 55, second: 1)
    let cancellationDate = Date.from(year: 2019, month: 7, day: 4, hour: 7, minute: 1, second: 45)
    let isInTrialPeriod = false
    let isInIntroOfferPeriod = true
    let webOrderLineItemId = 897501072
    let promotionalOfferIdentifier = "com.revenuecat.productPromoOffer"

    private let containerFactory = ContainerFactory()
    private var inAppPurchaseBuilder: InAppPurchaseBuilder!

    override func setUp() {
        super.setUp()
        self.inAppPurchaseBuilder = InAppPurchaseBuilder()
    }

    func testCanBuildFromMinimalAttributes() {
        let sampleReceiptContainer = sampleInAppPurchaseContainerWithMinimalAttributes()
        expect { try self.inAppPurchaseBuilder.build(fromContainer: sampleReceiptContainer) }.notTo(throwError())
    }

    func testBuildGetsCorrectQuantityContainer() {
        let sampleInAppPurchaseContainer = sampleInAppPurchaseContainerWithMinimalAttributes()
        let inAppPurchase = try! self.inAppPurchaseBuilder.build(fromContainer: sampleInAppPurchaseContainer)
        expect(inAppPurchase.quantity) == quantity
    }

    func testBuildGetsCorrectProductIdContainer() {
        let sampleInAppPurchaseContainer = sampleInAppPurchaseContainerWithMinimalAttributes()
        let inAppPurchase = try! self.inAppPurchaseBuilder.build(fromContainer: sampleInAppPurchaseContainer)
        expect(inAppPurchase.productId) == productId
    }

    func testBuildGetsCorrectTransactionIdContainer() {
        let sampleInAppPurchaseContainer = sampleInAppPurchaseContainerWithMinimalAttributes()
        let inAppPurchase = try! self.inAppPurchaseBuilder.build(fromContainer: sampleInAppPurchaseContainer)
        expect(inAppPurchase.transactionId) == transactionId
    }

    func testBuildGetsCorrectOriginalTransactionIdContainer() {
        let sampleInAppPurchaseContainer = sampleInAppPurchaseContainerWithMinimalAttributes()
        let inAppPurchase = try! self.inAppPurchaseBuilder.build(fromContainer: sampleInAppPurchaseContainer)
        expect(inAppPurchase.originalTransactionId) == originalTransactionId
    }

    func testBuildGetsCorrectPurchaseDateContainer() {
        let sampleInAppPurchaseContainer = sampleInAppPurchaseContainerWithMinimalAttributes()
        let inAppPurchase = try! self.inAppPurchaseBuilder.build(fromContainer: sampleInAppPurchaseContainer)
        expect(inAppPurchase.purchaseDate) == purchaseDate
    }

    func testBuildGetsCorrectOriginalPurchaseDateContainer() {
        let sampleInAppPurchaseContainer = sampleInAppPurchaseContainerWithMinimalAttributes()
        let inAppPurchase = try! self.inAppPurchaseBuilder.build(fromContainer: sampleInAppPurchaseContainer)
        expect(inAppPurchase.originalPurchaseDate) == originalPurchaseDate
    }

    func testBuildGetsCorrectIsInIntroOfferPeriodContainer() {
        let sampleInAppPurchaseContainer = sampleInAppPurchaseContainerWithMinimalAttributes()
        let inAppPurchase = try! self.inAppPurchaseBuilder.build(fromContainer: sampleInAppPurchaseContainer)
        expect(inAppPurchase.isInIntroOfferPeriod) == isInIntroOfferPeriod
    }

    func testBuildGetsCorrectWebOrderLineItemIdContainer() {
        let sampleInAppPurchaseContainer = sampleInAppPurchaseContainerWithMinimalAttributes()
        let inAppPurchase = try! self.inAppPurchaseBuilder.build(fromContainer: sampleInAppPurchaseContainer)
        expect(inAppPurchase.webOrderLineItemId) == webOrderLineItemId
    }
}

private extension InAppPurchaseBuilderTests {

    func sampleInAppPurchaseContainerWithMinimalAttributes() -> ASN1Container {
        return containerFactory.buildReceiptContainerFromContainers(containers: minimalAttributes())
    }

    func minimalAttributes() -> [ASN1Container] {
        return [
            quantityContainer(),
            productIdContainer(),
            transactionIdContainer(),
            originalTransactionIdContainer(),
            purchaseDateContainer(),
            originalPurchaseDateContainer(),
            isInIntroOfferPeriodContainer(),
            webOrderLineItemIdContainer()
        ]
    }

    func quantityContainer() -> ASN1Container {
        return containerFactory.buildReceiptAttributeContainer(attributeType: InAppPurchaseAttributeType.quantity,
                                                               quantity)
    }

    func productIdContainer() -> ASN1Container {
        return containerFactory.buildReceiptAttributeContainer(attributeType: InAppPurchaseAttributeType.productId,
                                                               productId)
    }

    func transactionIdContainer() -> ASN1Container {
        return containerFactory.buildReceiptAttributeContainer(attributeType: InAppPurchaseAttributeType.transactionId,
                                                               transactionId)
    }

    func originalTransactionIdContainer() -> ASN1Container {
        return containerFactory.buildReceiptAttributeContainer(attributeType: InAppPurchaseAttributeType.originalTransactionId,
                                                               originalTransactionId)
    }

    func productTypeContainer() -> ASN1Container {
        return containerFactory.buildReceiptAttributeContainer(attributeType: InAppPurchaseAttributeType.productType,
                                                               productType.rawValue)
    }

    func purchaseDateContainer() -> ASN1Container {
        return containerFactory.buildReceiptAttributeContainer(attributeType: InAppPurchaseAttributeType.purchaseDate,
                                                               purchaseDate)
    }

    func originalPurchaseDateContainer() -> ASN1Container {
        return containerFactory.buildReceiptAttributeContainer(attributeType: InAppPurchaseAttributeType.originalPurchaseDate,
                                                               originalPurchaseDate)
    }

    func expiresDateContainer() -> ASN1Container {
        return containerFactory.buildReceiptAttributeContainer(attributeType: InAppPurchaseAttributeType.expiresDate,
                                                               expiresDate)
    }

    func cancellationDateContainer() -> ASN1Container {
        return containerFactory.buildReceiptAttributeContainer(attributeType: InAppPurchaseAttributeType.cancellationDate,
                                                               cancellationDate)
    }

    func isInTrialPeriodContainer() -> ASN1Container {
        return containerFactory.buildReceiptAttributeContainer(attributeType: InAppPurchaseAttributeType.isInTrialPeriod,
                                                               isInTrialPeriod)
    }

    func isInIntroOfferPeriodContainer() -> ASN1Container {
        return containerFactory.buildReceiptAttributeContainer(attributeType: InAppPurchaseAttributeType.isInIntroOfferPeriod,
                                                               isInIntroOfferPeriod)
    }

    func webOrderLineItemIdContainer() -> ASN1Container {
        return containerFactory.buildReceiptAttributeContainer(attributeType: InAppPurchaseAttributeType.webOrderLineItemId,
                                                               webOrderLineItemId)
    }

    func promotionalOfferIdentifierContainer() -> ASN1Container {
        return containerFactory.buildReceiptAttributeContainer(attributeType: InAppPurchaseAttributeType.promotionalOfferIdentifier,
                                                               promotionalOfferIdentifier)
    }
}
