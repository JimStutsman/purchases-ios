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
        expect {
            try self.appleReceiptBuilder.build(fromASN1Container: sampleReceiptContainer)
        } .notTo(throwError())
    }

    func testBuildGetsCorrectBundleId() {
        let sampleReceiptContainer = sampleReceiptContainerWithMinimalAttributes()
        let receipt = try! self.appleReceiptBuilder.build(fromASN1Container: sampleReceiptContainer)
        expect(receipt.bundleId) == bundleId
    }

    func testBuildGetsCorrectApplicationVersion() {
        let sampleReceiptContainer = sampleReceiptContainerWithMinimalAttributes()
        let receipt = try! self.appleReceiptBuilder.build(fromASN1Container: sampleReceiptContainer)
        expect(receipt.applicationVersion) == applicationVersion
    }

    func testBuildGetsCorrectOriginalApplicationVersion() {
        let sampleReceiptContainer = sampleReceiptContainerWithMinimalAttributes()
        let receipt = try! self.appleReceiptBuilder.build(fromASN1Container: sampleReceiptContainer)
        expect(receipt.originalApplicationVersion) == originalApplicationVersion
    }

    func testBuildGetsCorrectCreationDate() {
        let sampleReceiptContainer = sampleReceiptContainerWithMinimalAttributes()
        let receipt = try! self.appleReceiptBuilder.build(fromASN1Container: sampleReceiptContainer)
        expect(receipt.creationDate) == creationDate
    }
}

private extension AppleReceiptBuilderTests {
    func minimalAttributes() -> [ASN1Container] {
        let bundleIdContainer = containerFactory.buildReceiptAttributeContainer(attributeType: .bundleId,
                                                                                bundleId)
        let appVersionContainer = containerFactory.buildReceiptAttributeContainer(attributeType: .applicationVersion,
                                                                                  applicationVersion)
        let originalAppVersionContainer = containerFactory
            .buildReceiptAttributeContainer(attributeType: .originalApplicationVersion, originalApplicationVersion)
        let opaqueValueContainer = containerFactory.buildReceiptDataAttributeContainer(attributeType: .opaqueValue)
        let sha1HashContainer = containerFactory.buildReceiptDataAttributeContainer(attributeType: .sha1Hash)
        let creationDateContainer = containerFactory.buildReceiptAttributeContainer(attributeType: .creationDate,
                                                                                    creationDate)
        return [
            bundleIdContainer,
            appVersionContainer,
            originalAppVersionContainer,
            opaqueValueContainer,
            sha1HashContainer,
            creationDateContainer
        ]
    }

    func sampleReceiptContainerWithMinimalAttributes() -> ASN1Container {
        return containerFactory.buildReceiptContainerFromContainers(containers: minimalAttributes())
    }
}
