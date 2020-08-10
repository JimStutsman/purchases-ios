import XCTest
import Nimble

@testable import Purchases

class ASN1ObjectIdentifierBuilderTests: XCTestCase {
    func testBuildFromPayloadBuildsCorrectlyForDataPayload() {
        let payload = objectIdentifierPayload(.data)
        expect(try! ASN1ObjectIdentifierBuilder().build(fromPayload: payload)) == .data
    }
}

private extension ASN1ObjectIdentifierBuilderTests {

    func objectIdentifierPayload(_ objectIdentifier: ASN1ObjectIdentifier) -> ArraySlice<UInt8> {
        return encodeASN1ObjectIdentifier(numbers: objectIdentifierNumbers(objectIdentifier))
    }

    func objectIdentifierNumbers(_ objectIdentifier: ASN1ObjectIdentifier) -> [Int] {
        return objectIdentifier.rawValue.split(separator: ".").map { Int($0)! }
    }

    func encodeASN1ObjectIdentifier(numbers: [Int]) -> ArraySlice<UInt8> {
        // https://docs.microsoft.com/en-us/windows/win32/seccertenroll/about-object-identifier

        var encodedNumbers: [UInt8] = []

        let firstValue = numbers[0]
        let secondValue = numbers[1]
        encodedNumbers.append(UInt8(firstValue * 40 + secondValue))
        for number in numbers.dropFirst(2) {
            if number < 127 {
                encodedNumbers.append(UInt8(number))
            } else {
                let numberAsBytes = encodeLongNumber(number: number)
                encodedNumbers.append(contentsOf: numberAsBytes)
            }
        }

        return ArraySlice(encodedNumbers)
    }

    func encodeLongNumber(number: Int) -> [UInt8] {
        let numberAsBinaryString = String(number, radix: 2)
        let splitString = splitNumberStringIntoGroups(ofLength: 7, string: numberAsBinaryString)
        let splitNumbers = splitString.map { UInt8($0, radix: 2)! }
        let numberAsBytes = listByAddingOneToTheFirstBitOfAllButLast(numbers: splitNumbers)
        return numberAsBytes
    }

    func splitNumberStringIntoGroups(ofLength length: Int, string: String) -> [String] {
        guard length > 0 else { return [] }
        let range = 0..<((string.count + length - 1) / length)
        let indices = range.map { length * $0..<min(length * ($0 + 1), string.count) }
        return indices
            .map { string.reversed()[$0.startIndex..<$0.endIndex] }
            .map { String.init($0.reversed()) }
            .reversed()
    }

    func listByAddingOneToTheFirstBitOfAllButLast(numbers: [UInt8]) -> [UInt8] {
        guard numbers.count > 0, let lastNumber = numbers.last else { return [] }
        return numbers.dropLast().map { $0 | (1 << 7) } + [lastNumber]
    }
}