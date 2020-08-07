import XCTest
import Nimble

@testable import Purchases

class AppleReceiptBuilderTests: XCTestCase {
    let containerFactory = ContainerFactory()
    var appleReceiptBuilder: AppleReceiptBuilder!

    override func setUp() {
        super.setUp()
        self.appleReceiptBuilder = AppleReceiptBuilder()
    }

    func testCanBuildCorrectlyWithMinimalAttributes() {
        let sampleReceipt = sampleReceiptContainerWithMinimalAttributes()
        try! self.appleReceiptBuilder.build(fromASN1Container: sampleReceipt)

//        expect {
//            return try self.appleReceiptBuilder.build(fromASN1Container: sampleReceipt)
//        }.notTo(
//            throwError())
    }
}

private extension AppleReceiptBuilderTests {
    func sampleReceiptContainerWithMinimalAttributes() -> ASN1Container {
        let bundleIdContainer = containerFactory.buildReceiptAttributeContainer(attributeType: .bundleId,
                                                                                "com.revenuecat.test")
        let applicationVersionContainer = containerFactory.buildReceiptAttributeContainer(attributeType: .applicationVersion,
                                                                                          "3.2.1")
        let originalApplicationVersionContainer = containerFactory.buildReceiptAttributeContainer(attributeType: .originalApplicationVersion,
                                                                                                  "1.2.2")
        let opaqueValueContainer = containerFactory.buildReceiptDataAttributeContainer(attributeType: .opaqueValue)
        let sha1HashContainer = containerFactory.buildReceiptDataAttributeContainer(attributeType: .sha1Hash)
        let creationDateContainer = containerFactory.buildReceiptAttributeContainer(attributeType: .creationDate, Date())

        let receiptContainer = containerFactory.buildConstructedContainer(containers: [
            bundleIdContainer,
            applicationVersionContainer,
            originalApplicationVersionContainer,
            opaqueValueContainer,
            sha1HashContainer,
            creationDateContainer
        ], encodingType: .constructed)

        let receiptWrapper = containerFactory.buildConstructedContainer(containers: [receiptContainer],
                                                                        encodingType: .primitive)
        return containerFactory.buildConstructedContainer(containers: [receiptWrapper],
                                                          encodingType: .constructed)
    }

//    func sampleReceiptContainerWithAllAttributes() -> ASN1Container {
//        let expirationDateContainer = containerFactory.buildReceiptAttributeContainer(attributeType: .expir, Date())
//        let inAppPurchasesContainer = containerFactory.buildStringContainer(string: <#T##String##Swift.String#>)

//    }


}
