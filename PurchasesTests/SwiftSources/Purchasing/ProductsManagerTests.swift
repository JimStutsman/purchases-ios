import XCTest
import Nimble

@testable import Purchases

class ProductsManagerTests: XCTestCase {
    var productsRequestFactory: MockProductsRequestFactory!

    override func setUp() {
        super.setUp()
        productsRequestFactory = MockProductsRequestFactory()
    }

    func testProductsWithIdentifiersMakesRightRequest() {
    }

    func testProductsWithIdentifiersReturnsFromCacheIfProductsAlreadyCached() {
    }

    func testProductsWithIdentifiersReturnsDoesntMakeNewRequestIfProductsAreBeingFetched() {
    }

    func testProductsWithIdentifiersMakesNewRequestIfAtLeastOneNewProductRequested() {
    }

    func testProductsWithIdentifiersReturnsErrorAndEmptySetIfRequestFails() {
    }
}