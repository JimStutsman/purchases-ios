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
        var intAsVar = int
        let intAsData = NSData(bytes: &intAsVar, length: MemoryLayout<Int>.size)
        let intAsBytes = [UInt8](intAsData)

        return ASN1Container(containerClass: .application,
                             containerIdentifier: .octetString,
                             encodingType: .primitive,
                             length: ASN1Length(value: 1, bytesUsedForLength: 1),
                             internalPayload: ArraySlice(intAsBytes),
                             internalContainers: [])
    }

    func buildConstructedContainer(containers: [ASN1Container]) -> ASN1Container {
        let payload = containers.flatMap { $0.internalPayload }
        return ASN1Container(containerClass: .application,
                             containerIdentifier: .octetString,
                             encodingType: .primitive,
                             length: ASN1Length(value: 1, bytesUsedForLength: 1),
                             internalPayload: ArraySlice(payload),
                             internalContainers: containers)
    }

    func buildReceiptAttributeContainer(attributeType: ReceiptAttributeType, value: Int) -> ASN1Container {
        let typeContainer = buildIntContainer(int: attributeType.rawValue)
        let versionContainer = buildIntContainer(int: 1)
        let valueContainer = buildIntContainer(int: value)

        return buildConstructedContainer(containers: [typeContainer, versionContainer, valueContainer])
    }

    func buildReceiptDataAttributeContainer(attributeType: ReceiptAttributeType) -> ASN1Container {
        let typeContainer = buildIntContainer(int: attributeType.rawValue)
        let versionContainer = buildIntContainer(int: 1)
        let valueContainer = buildSimpleDataContainer()

        return buildConstructedContainer(containers: [typeContainer, versionContainer, valueContainer])
    }

    func buildReceiptAttributeContainer(attributeType: ReceiptAttributeType, date: Date) -> ASN1Container {
        let typeContainer = buildIntContainer(int: attributeType.rawValue)
        let versionContainer = buildIntContainer(int: 1)
        let valueContainer = buildDateContainer(date: date)

        return buildConstructedContainer(containers: [typeContainer, versionContainer, valueContainer])
    }

    func buildReceiptAttributeContainer(attributeType: ReceiptAttributeType, bool: Bool) -> ASN1Container {
        let typeContainer = buildIntContainer(int: attributeType.rawValue)
        let versionContainer = buildIntContainer(int: 1)
        let valueContainer = buildBoolContainer(bool: bool)

        return buildConstructedContainer(containers: [typeContainer, versionContainer, valueContainer])
    }

    func buildReceiptAttributeContainer(attributeType: ReceiptAttributeType, string: String) -> ASN1Container {
        let typeContainer = buildIntContainer(int: attributeType.rawValue)
        let versionContainer = buildIntContainer(int: 1)
        let valueContainer = buildStringContainer(string: string)

        return buildConstructedContainer(containers: [typeContainer, versionContainer, valueContainer])
    }
}
