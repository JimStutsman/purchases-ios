import XCTest
import Nimble

@testable import Purchases

class ReceiptParserTests: XCTestCase {
    var receiptParser: ReceiptParser!
    var mockAppleReceiptBuilder: MockAppleReceiptBuilder!
    var mockASN1ContainerBuilder: MockASN1ContainerBuilder!

    let containerFactory = ContainerFactory()

    override func setUp() {
        super.setUp()
        mockAppleReceiptBuilder = MockAppleReceiptBuilder()
        mockASN1ContainerBuilder = MockASN1ContainerBuilder()
        receiptParser = ReceiptParser(containerBuilder: mockASN1ContainerBuilder,
                                      receiptBuilder: mockAppleReceiptBuilder)
    }

    func testParseFromReceiptDataBuildsContainerAfterObjectIdentifier() {
        let receiptContainer = containerFactory.buildReceiptContainerFromContainers(containers: [])
        let dataObjectIdentifierContainer = containerFactory.buildObjectIdentifierContainer(.data)
        let constructedContainer = containerFactory.buildConstructedContainer(containers: [
            dataObjectIdentifierContainer,
            receiptContainer
        ])

        mockASN1ContainerBuilder.stubbedBuildResult = constructedContainer
        let expectedReceipt = mockAppleReceipt()
        mockAppleReceiptBuilder.stubbedBuildResult = expectedReceipt

        let receivedReceipt = try! self.receiptParser.parse(from: Data())

        expect(self.mockAppleReceiptBuilder.invokedBuildCount) == 1
        expect(self.mockAppleReceiptBuilder.invokedBuildParameters) == receiptContainer
        expect(receivedReceipt) == expectedReceipt
    }

    func testParseFromReceiptDataBuildsContainerAfterObjectIdentifierInComplexContainer() {
        let receiptContainer = containerFactory.buildReceiptContainerFromContainers(containers: [])
        let dataObjectIdentifierContainer = containerFactory.buildObjectIdentifierContainer(.data)

        let complexContainer = containerFactory.buildConstructedContainer(containers: [
            containerFactory.simpleDataContainer(),
            containerFactory.buildObjectIdentifierContainer(.signedData),
            containerFactory.buildConstructedContainer(containers: [
                containerFactory.simpleDataContainer(),
                containerFactory.buildIntContainer(int: 656),
            ]),
            containerFactory.simpleDataContainer(),
            containerFactory.buildStringContainer(string: "some string"),
            containerFactory.buildConstructedContainer(containers: [
                containerFactory.simpleDataContainer(),
                containerFactory.buildIntContainer(int: 656),
                containerFactory.buildConstructedContainer(containers: [
                    dataObjectIdentifierContainer,
                    receiptContainer,
                ]),
                containerFactory.buildDateContainer(date: Date()),
            ]),
            containerFactory.buildObjectIdentifierContainer(.encryptedData),
        ])

        mockASN1ContainerBuilder.stubbedBuildResult = complexContainer
        let expectedReceipt = mockAppleReceipt()
        mockAppleReceiptBuilder.stubbedBuildResult = expectedReceipt

        let receivedReceipt = try! self.receiptParser.parse(from: Data())

        expect(self.mockAppleReceiptBuilder.invokedBuildCount) == 1
        expect(self.mockAppleReceiptBuilder.invokedBuildParameters) == receiptContainer
        expect(receivedReceipt) == expectedReceipt
    }

    func testParseFromReceiptThrowsIfNoDataObjectIdentifierFound() {
    }

    func testParseFromReceiptThrowsIfReceiptBuilderThrows() {
    }
}

private extension ReceiptParserTests {
    func containerWithDataObjectIdentifier() -> ASN1Container {
        let receiptContainer = containerFactory.buildReceiptContainerFromContainers(containers: [])
        let dataObjectIdentifierContainer = containerFactory.buildObjectIdentifierContainer(.data)
        let constructedContainer = containerFactory.buildConstructedContainer(containers: [
            dataObjectIdentifierContainer,
            receiptContainer
        ])
        return constructedContainer
    }

    func mockAppleReceipt() -> AppleReceipt {
        return AppleReceipt(bundleId: "com.revenuecat.testapp",
                            applicationVersion: "3.2.3",
                            originalApplicationVersion: "3.1.1",
                            opaqueValue: Data(),
                            sha1Hash: Data(),
                            creationDate: Date(),
                            expirationDate: nil,
                            inAppPurchases: [])
    }
}