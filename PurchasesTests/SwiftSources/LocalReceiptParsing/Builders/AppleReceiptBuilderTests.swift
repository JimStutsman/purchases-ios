import XCTest
import Nimble

@testable import Purchases

class AppleReceiptBuilderTests: XCTestCase {
    let containerFactory = ContainerFactory()

    func testBuild() {

        let opaqueValueContainer = containerFactory.buildSimpleDataContainer(identifier: .octetString, length: 55)


        let receiptContainer = ASN1Container(containerClass: <#T##ASN1Class##Purchases.ASN1Class#>,
                                             containerIdentifier: <#T##ASN1Identifier##Purchases.ASN1Identifier#>,
                                             encodingType: <#T##ASN1EncodingType##Purchases.ASN1EncodingType#>,
                                             length: <#T##ASN1Length##Purchases.ASN1Length#>,
                                             internalPayload: <#T##ArraySlice<UInt8>##Swift.ArraySlice<Swift.UInt8>#>,
                                             internalContainers: <#T##[ASN1Container]##[Purchases.ASN1Container]#>)
    }
}
