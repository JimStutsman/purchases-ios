import XCTest
import Nimble

@testable import Purchases

class ASN1ObjectIdentifierBuilderTests: XCTestCase {

    func testBuildFromPayloadBuildsCorrectlyForDataPayload() {
        let payload = objectIdentifierPayload(.data)
        expect(ASN1ObjectIdentifierBuilder().build(fromPayload: payload)) == .data
    }

    func testBuildFromPayloadBuildsCorrectlyForSignedDataPayload() {
        let payload = objectIdentifierPayload(.signedData)
        expect(ASN1ObjectIdentifierBuilder().build(fromPayload: payload)) == .signedData
    }

    func testBuildFromPayloadBuildsCorrectlyForEnvelopedDataPayload() {
        let payload = objectIdentifierPayload(.envelopedData)
        expect(ASN1ObjectIdentifierBuilder().build(fromPayload: payload)) == .envelopedData
    }

    func testBuildFromPayloadBuildsCorrectlyForSignedAndEnvelopedDataPayload() {
        let payload = objectIdentifierPayload(.signedAndEnvelopedData)
        expect(ASN1ObjectIdentifierBuilder().build(fromPayload: payload)) == .signedAndEnvelopedData
    }

    func testBuildFromPayloadBuildsCorrectlyForDigestedDataPayload() {
        let payload = objectIdentifierPayload(.digestedData)
        expect(ASN1ObjectIdentifierBuilder().build(fromPayload: payload)) == .digestedData
    }

    func testBuildFromPayloadBuildsCorrectlyForEncryptedDataPayload() {
        let payload = objectIdentifierPayload(.encryptedData)
        expect(ASN1ObjectIdentifierBuilder().build(fromPayload: payload)) == .encryptedData
    }

    func testBuildFromPayloadReturnsNilIfIdentifierNotRecognized() {
        let unknownObjectID = [1, 3, 23, 534643, 7454, 1, 7, 2]
        let payload = encodeASN1ObjectIdentifier(numbers: unknownObjectID)
        expect(ASN1ObjectIdentifierBuilder().build(fromPayload: payload)).to(beNil())
    }

    func testBuildFromPayloadReturnsNilIfIdentifierPayloadEmpty() {
        let payload: ArraySlice<UInt8> = ArraySlice([])
        expect(ASN1ObjectIdentifierBuilder().build(fromPayload: payload)).to(beNil())
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
        let numberAsListOfBinaryStrings = splitStringIntoGroups(ofLength: 7, string: numberAsBinaryString)
        let bytes = numberAsListOfBinaryStrings.map { UInt8($0, radix: 2)! }
        let encodedBytes = listByAddingOneToTheFirstBitOfAllButLast(numbers: bytes)
        return encodedBytes
    }

    func splitStringIntoGroups(ofLength length: Int, string: String) -> [String] {
        guard length > 0 else { return [] }

        let totalGroups: Int = (string.count + length - 1) / length
        let range = 0..<totalGroups
        let indices = range.map { length * $0..<min(length * ($0 + 1), string.count) }
        return indices
            .map { string.reversed()[$0.startIndex..<$0.endIndex] } // 1. reverse so we start counting from the right
            .map { String.init($0.reversed()) } // 2. reverse again to form each string
            .reversed() // 3. reverse the whole list to undo the change of step 1
    }

    func listByAddingOneToTheFirstBitOfAllButLast(numbers: [UInt8]) -> [UInt8] {
        guard numbers.count > 0, let lastNumber = numbers.last else { return [] }
        return numbers.dropLast().map { $0 | (1 << 7) } + [lastNumber]
    }
}