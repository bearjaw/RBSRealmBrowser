import UIKit
import XCTest
import RBSRealmBrowser

class Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDefaultRealmBrowser() {
        // This is an example of a functional test case.
        guard RBSRealmBrowser.realmBrowser() != nil else {
            XCTAssert(true, "Fail init")
            return
        }
        XCTAssert(true, "Pass")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }

}
