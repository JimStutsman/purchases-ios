import XCTest
import Nimble

@testable import Purchases

class ASN1ContainerBuilderTests: XCTestCase {
    var containerBuilder: ASN1ContainerBuilder!
    let mockContainerPayload: [UInt8] = [0b01, 0b01, 0b01]
    let mockConstructedContainerPayload: [UInt8] = [0b11, 0b11, 0b01, 0b01, 0b01, 0b01, 0b01, 0b01, 0b01]

    override func setUp() {
        super.setUp()
        containerBuilder = ASN1ContainerBuilder()
    }

    func testBuildFromContainerExtractsClassCorrectly() {
        let universalClassByte: UInt8 = 0b00000000
        var payloadArray = mockContainerPayload
        payloadArray.insert(universalClassByte, at: 0)
        var payload = ArraySlice(payloadArray)
        try! expect(self.containerBuilder.build(fromPayload: payload).containerClass) == .universal
        
        let applicationClassByte: UInt8 = 0b01000000
        payloadArray = mockContainerPayload
        payloadArray.insert(applicationClassByte, at: 0)
        payload = ArraySlice(payloadArray)
        try! expect(self.containerBuilder.build(fromPayload: payload).containerClass) == .application

        let contextSpecificClassByte: UInt8 = 0b10000000
        payloadArray = mockContainerPayload
        payloadArray.insert(contextSpecificClassByte, at: 0)
        payload = ArraySlice(payloadArray)
        try! expect(self.containerBuilder.build(fromPayload: payload).containerClass) == .contextSpecific

        let privateClassByte: UInt8 = 0b11000000
        payloadArray = mockContainerPayload
        payloadArray.insert(privateClassByte, at: 0)
        payload = ArraySlice(payloadArray)
        try! expect(self.containerBuilder.build(fromPayload: payload).containerClass) == .private
    }
    
    func testBuildFromContainerExtractsEncodingTypeCorrectly() {
        let primitiveEncodingByte: UInt8 = 0b00000000
        var payloadArray = mockContainerPayload
        payloadArray.insert(primitiveEncodingByte, at: 0)
        var payload = ArraySlice(payloadArray)
        try! expect(self.containerBuilder.build(fromPayload: payload).encodingType) == .primitive
        
        let constructedEncodingByte: UInt8 = 0b00100000
        payloadArray = mockConstructedContainerPayload
        payloadArray.insert(constructedEncodingByte, at: 0)
        payload = ArraySlice(payloadArray)
        try! expect(self.containerBuilder.build(fromPayload: payload).encodingType) == .constructed
    }
    
    func testBuildFromContainerExtractsIdentifierCorrectly() {
        for expectedIdentifier in ASN1Identifier.allCases {
            let identifierByte = UInt8(expectedIdentifier.rawValue)
            
            var payloadArray = mockContainerPayload
            payloadArray.insert(identifierByte, at: 0)
            let payload = ArraySlice(payloadArray)
            try! expect(self.containerBuilder.build(fromPayload: payload).containerIdentifier) == expectedIdentifier
        }
    }

    func testBuildFromContainerThatIsTooSmallThrows() {
        expect { try self.containerBuilder.build(fromPayload: ArraySlice([0b1])) }.to(throwError())
    }
}