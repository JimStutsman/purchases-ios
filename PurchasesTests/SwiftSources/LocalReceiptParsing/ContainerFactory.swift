//
// Created by Andrés Boedo on 8/6/20.
// Copyright (c) 2020 Purchases. All rights reserved.
//

import Foundation
@testable import Purchases

class ContainerFactory {
    func buildSimpleDataContainer() -> ASN1Container {
        let length = 55
        return ASN1Container(containerClass: .application,
                             containerIdentifier: .octetString,
                             encodingType: .primitive,
                             length: ASN1Length(value: length, bytesUsedForLength: 1),
                             internalPayload: ArraySlice(Array(repeating: UInt8(0b1), count: length)),
                             internalContainers: [])
    }

    func buildStringContainer(string: String) -> ASN1Container {
        let stringAsBytes = string.utf8
        guard stringAsBytes.count < 128 else { fatalError("this method is intended for short strings only") }
        return ASN1Container(containerClass: .application,
                             containerIdentifier: .octetString,
                             encodingType: .primitive,
                             length: ASN1Length(value: stringAsBytes.count, bytesUsedForLength: 1),
                             internalPayload: ArraySlice(Array(stringAsBytes)),
                             internalContainers: [])
    }

    func buildDateContainer(date: Date) -> ASN1Container {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"

        let dateString = dateFormatter.string(from: date)
        guard let stringAsData = (dateString.data(using: .ascii)) else { fatalError() }
        let stringAsBytes = [UInt8](stringAsData)
        guard stringAsBytes.count < 128 else { fatalError("this method is intended for short strings only") }

        return ASN1Container(containerClass: .application,
                             containerIdentifier: .octetString,
                             encodingType: .primitive,
                             length: ASN1Length(value: stringAsBytes.count, bytesUsedForLength: 1),
                             internalPayload: ArraySlice(stringAsBytes),
                             internalContainers: [])
    }

    func buildBoolContainer(bool: Bool) -> ASN1Container {
        return ASN1Container(containerClass: .application,
                             containerIdentifier: .octetString,
                             encodingType: .primitive,
                             length: ASN1Length(value: 1, bytesUsedForLength: 1),
                             internalPayload: ArraySlice([UInt8(booleanLiteral: bool)]),
                             internalContainers: [])
    }

    func buildIntContainer(int: Int) -> ASN1Container {
        let intAsBytes = intToBytes(int: int)

        return ASN1Container(containerClass: .application,
                             containerIdentifier: .octetString,
                             encodingType: .primitive,
                             length: ASN1Length(value: 1, bytesUsedForLength: 1),
                             internalPayload: ArraySlice(intAsBytes),
                             internalContainers: [])
    }

    func buildConstructedContainer(containers: [ASN1Container],
                                   encodingType: ASN1EncodingType = .constructed) -> ASN1Container {
        let payload = containers.flatMap { self.headerBytes(forContainer: $0) + $0.internalPayload }
        let bytesUsedForLength = payload.count < 128 ? 1 : intToBytes(int: payload.count).count + 1
        return ASN1Container(containerClass: .application,
                             containerIdentifier: .octetString,
                             encodingType: encodingType,
                             length: ASN1Length(value: payload.count, bytesUsedForLength: bytesUsedForLength),
                             internalPayload: ArraySlice(payload),
                             internalContainers: containers)
    }

    func buildReceiptDataAttributeContainer(attributeType: ReceiptAttributeType) -> ASN1Container {
        let typeContainer = buildIntContainer(int: attributeType.rawValue)
        let versionContainer = buildIntContainer(int: 1)
        let valueContainer = buildSimpleDataContainer()

        return buildConstructedContainer(containers: [typeContainer, versionContainer, valueContainer])
    }

    func buildReceiptAttributeContainer(attributeType: ReceiptAttributeType, _ value: Int) -> ASN1Container {
        let typeContainer = buildIntContainer(int: attributeType.rawValue)
        let versionContainer = buildIntContainer(int: 1)
        let valueContainer = buildConstructedContainer(containers: [buildIntContainer(int: value)])

        return buildConstructedContainer(containers: [typeContainer, versionContainer, valueContainer])
    }

    func buildReceiptAttributeContainer(attributeType: ReceiptAttributeType, _ date: Date) -> ASN1Container {
        let typeContainer = buildIntContainer(int: attributeType.rawValue)
        let versionContainer = buildIntContainer(int: 1)
        let valueContainer = buildConstructedContainer(containers: [buildDateContainer(date: date)])

        return buildConstructedContainer(containers: [typeContainer, versionContainer, valueContainer])
    }

    func buildReceiptAttributeContainer(attributeType: ReceiptAttributeType, _ bool: Bool) -> ASN1Container {
        let typeContainer = buildIntContainer(int: attributeType.rawValue)
        let versionContainer = buildIntContainer(int: 1)
        let valueContainer = buildConstructedContainer(containers: [buildBoolContainer(bool: bool)])

        return buildConstructedContainer(containers: [typeContainer, versionContainer, valueContainer])
    }

    func buildReceiptAttributeContainer(attributeType: ReceiptAttributeType, _ string: String) -> ASN1Container {
        let typeContainer = buildIntContainer(int: attributeType.rawValue)
        let versionContainer = buildIntContainer(int: 1)
        let valueContainer = buildConstructedContainer(containers: [buildStringContainer(string: string)])

        return buildConstructedContainer(containers: [typeContainer, versionContainer, valueContainer])
    }

    func buildReceiptContainerFromContainers(containers: [ASN1Container]) -> ASN1Container {
        let attributesContainer = buildConstructedContainer(containers: containers)

        let receiptWrapper = buildConstructedContainer(containers: [attributesContainer],
                                                       encodingType: .primitive)
        return buildConstructedContainer(containers: [receiptWrapper],
                                         encodingType: .constructed)
    }
}

private extension ContainerFactory {
    func intToBytes(int: Int) -> [UInt8] {
        let intAsBytes = withUnsafeBytes(of: int.bigEndian, Array.init)
        let arrayWithoutInsignificantBytes = Array(intAsBytes.drop(while: { $0 == 0 }))
        return arrayWithoutInsignificantBytes
    }

    func headerBytes(forContainer container: ASN1Container) -> [UInt8] {
        let identifierHeader = (container.containerClass.rawValue << 6
            | container.encodingType.rawValue << 5
            | container.containerIdentifier.rawValue)
        if container.length.value < 128 {
            return [identifierHeader] + [UInt8(container.length.value)]
        } else {
            var lengthHeader = intToBytes(int: container.length.value)
            let firstByte = 0b10000000 | UInt8(container.length.bytesUsedForLength - 1)
            lengthHeader.insert(firstByte, at: 0)
            return [identifierHeader] + lengthHeader
        }
    }
}
