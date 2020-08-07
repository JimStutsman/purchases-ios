import XCTest
import Nimble

@testable import Purchases

class AppleReceiptBuilderTests: XCTestCase {
    let containerFactory = ContainerFactory()
    var appleReceiptBuilder: AppleReceiptBuilder!

    let bundleId = "com.revenuecat.test"
    let applicationVersion = "3.2.1"
    let originalApplicationVersion = "1.2.2"
    let creationDate = Date.from(year: 2020, month: 3, day: 23, hour: 15, minute: 5, second: 3)

    override func setUp() {
        super.setUp()
        self.appleReceiptBuilder = AppleReceiptBuilder()
    }

    func testCanBuildCorrectlyWithMinimalAttributes() {
        let sampleReceiptContainer = sampleReceiptContainerWithMinimalAttributes()
        expect { try self.appleReceiptBuilder.build(fromContainer: sampleReceiptContainer) }.notTo(throwError())
    }

    func testBuildGetsCorrectBundleId() {
        let sampleReceiptContainer = sampleReceiptContainerWithMinimalAttributes()
        let receipt = try! self.appleReceiptBuilder.build(fromContainer: sampleReceiptContainer)
        expect(receipt.bundleId) == bundleId
    }

    func testBuildGetsCorrectApplicationVersion() {
        let sampleReceiptContainer = sampleReceiptContainerWithMinimalAttributes()
        let receipt = try! self.appleReceiptBuilder.build(fromContainer: sampleReceiptContainer)
        expect(receipt.applicationVersion) == applicationVersion
    }

    func testBuildGetsCorrectOriginalApplicationVersion() {
        let sampleReceiptContainer = sampleReceiptContainerWithMinimalAttributes()
        let receipt = try! self.appleReceiptBuilder.build(fromContainer: sampleReceiptContainer)
        expect(receipt.originalApplicationVersion) == originalApplicationVersion
    }

    func testBuildGetsCorrectCreationDate() {
        let sampleReceiptContainer = sampleReceiptContainerWithMinimalAttributes()
        let receipt = try! self.appleReceiptBuilder.build(fromContainer: sampleReceiptContainer)
        expect(receipt.creationDate) == creationDate
    }

    func testBuildGetsSha1Hash() {
        let sampleReceiptContainer = sampleReceiptContainerWithMinimalAttributes()
        let receipt = try! self.appleReceiptBuilder.build(fromContainer: sampleReceiptContainer)
        expect(receipt.sha1Hash).toNot(beNil())
    }

    func testBuildGetsOpaqueValue() {
        let sampleReceiptContainer = sampleReceiptContainerWithMinimalAttributes()
        let receipt = try! self.appleReceiptBuilder.build(fromContainer: sampleReceiptContainer)
        expect(receipt.opaqueValue).toNot(beNil())
    }

    func testBuildGetsExpiresDate() {
        let expirationDate = Date.from(year: 2020, month: 7, day: 4, hour: 5, minute: 3, second: 2)
        let expirationDateContainer = containerFactory
            .buildReceiptAttributeContainer(attributeType: ReceiptAttributeType.expirationDate,
                                            expirationDate)

        let receiptContainer = containerFactory
            .buildReceiptContainerFromContainers(containers: minimalAttributes() + [expirationDateContainer])
        let receipt = try! self.appleReceiptBuilder.build(fromContainer: receiptContainer)
        expect(receipt.expirationDate) == expirationDate
    }

    func testBuildThrowsIfBundleIdIsMissing() {
        let receiptContainer = containerFactory.buildReceiptContainerFromContainers(containers: [
            appVersionContainer(),
            originalAppVersionContainer(),
            opaqueValueContainer(),
            sha1HashContainer(),
            creationDateContainer()
        ])
        expect { try self.appleReceiptBuilder.build(fromContainer: receiptContainer) }.to(throwError())
    }

    func testBuildThrowsIfAppVersionIsMissing() {
        let receiptContainer = containerFactory.buildReceiptContainerFromContainers(containers: [
            bundleIdContainer(),
            originalAppVersionContainer(),
            opaqueValueContainer(),
            sha1HashContainer(),
            creationDateContainer()
        ])
        expect { try self.appleReceiptBuilder.build(fromContainer: receiptContainer) }.to(throwError())
    }

    func testBuildThrowsIfOriginalAppVersionIsMissing() {
        let receiptContainer = containerFactory.buildReceiptContainerFromContainers(containers: [
            bundleIdContainer(),
            appVersionContainer(),
            opaqueValueContainer(),
            sha1HashContainer(),
            creationDateContainer()
        ])
        expect { try self.appleReceiptBuilder.build(fromContainer: receiptContainer) }.to(throwError())
    }

    func testBuildThrowsIfOpaqueValueIsMissing() {
        let receiptContainer = containerFactory.buildReceiptContainerFromContainers(containers: [
            bundleIdContainer(),
            appVersionContainer(),
            originalAppVersionContainer(),
            sha1HashContainer(),
            creationDateContainer()
        ])
        expect { try self.appleReceiptBuilder.build(fromContainer: receiptContainer) }.to(throwError())
    }

    func testBuildThrowsIfSha1HashIsMissing() {
        let receiptContainer = containerFactory.buildReceiptContainerFromContainers(containers: [
            bundleIdContainer(),
            appVersionContainer(),
            originalAppVersionContainer(),
            opaqueValueContainer(),
            creationDateContainer()
        ])
        expect { try self.appleReceiptBuilder.build(fromContainer: receiptContainer) }.to(throwError())
    }

    func testBuildThrowsIfCreationDateIsMissing() {
        let receiptContainer = containerFactory.buildReceiptContainerFromContainers(containers: [
            bundleIdContainer(),
            appVersionContainer(),
            originalAppVersionContainer(),
            opaqueValueContainer(),
            sha1HashContainer()
        ])
        expect { try self.appleReceiptBuilder.build(fromContainer: receiptContainer) }.to(throwError())
    }
}

private extension AppleReceiptBuilderTests {
    func minimalAttributes() -> [ASN1Container] {
        return [
            bundleIdContainer(),
            appVersionContainer(),
            originalAppVersionContainer(),
            opaqueValueContainer(),
            sha1HashContainer(),
            creationDateContainer()
        ]
    }

    func sampleReceiptContainerWithMinimalAttributes() -> ASN1Container {
        return containerFactory.buildReceiptContainerFromContainers(containers: minimalAttributes())
    }
}

private extension AppleReceiptBuilderTests {

    func creationDateContainer() -> ASN1Container {
        containerFactory.buildReceiptAttributeContainer(attributeType: ReceiptAttributeType.creationDate,
                                                        creationDate)
    }

    func sha1HashContainer() -> ASN1Container {
        containerFactory.buildReceiptDataAttributeContainer(attributeType: ReceiptAttributeType.sha1Hash)
    }

    func opaqueValueContainer() -> ASN1Container {
        containerFactory.buildReceiptDataAttributeContainer(attributeType: ReceiptAttributeType.opaqueValue)
    }

    func originalAppVersionContainer() -> ASN1Container {
        containerFactory
            .buildReceiptAttributeContainer(attributeType: ReceiptAttributeType.originalApplicationVersion,
                                            originalApplicationVersion)
    }

    func appVersionContainer() -> ASN1Container {
        containerFactory.buildReceiptAttributeContainer(attributeType: ReceiptAttributeType.applicationVersion,
                                                        applicationVersion)
    }

    func bundleIdContainer() -> ASN1Container {
        containerFactory.buildReceiptAttributeContainer(attributeType: ReceiptAttributeType.bundleId,
                                                        bundleId)
    }
}
