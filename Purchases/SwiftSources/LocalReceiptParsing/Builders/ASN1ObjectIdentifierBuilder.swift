//
// Created by Andrés Boedo on 7/28/20.
// Copyright (c) 2020 Purchases. All rights reserved.
//

import Foundation

class ASN1ObjectIdentifierBuilder {
    func build(fromPayload payload: ArraySlice<UInt8>) -> ASN1ObjectIdentifier? {
        guard let firstByte = payload.first else { return nil }

        var objectIdentifierNumbers: [UInt] = []
        objectIdentifierNumbers.append(UInt(firstByte / 40))
        objectIdentifierNumbers.append(UInt(firstByte % 40))

        let trailingPayload = payload.dropFirst()
        var currentBuffer: UInt = 0
        var isShortLength = false
        for byte in trailingPayload {
            isShortLength = byte.bitAtIndex(0) == 0
            let byteValue = UInt(byte.valueInRange(from: 1, to: 7))

            currentBuffer = (currentBuffer << 7) | byteValue
            if isShortLength {
                objectIdentifierNumbers.append(currentBuffer)
                currentBuffer = 0
            }
        }

        let objectIdentifierString = objectIdentifierNumbers.map { String($0) }
                                                            .joined(separator: ".")
        return ASN1ObjectIdentifier(rawValue: objectIdentifierString)
    }
}
