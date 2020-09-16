//
//	VersionTests.swift
//	neuCKANTests
//
//	Created by you on 20-09-15.
//	Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import XCTest
@testable import neuCKAN

class VersionTests: XCTestCase {

    override func setUpWithError() throws {
        //	Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        //	Put teardown code here. This method is called after the invocation of each test method in the class.
    }
	
	///	Tests the basics of `SemanticVersion`.
	///
	///	- ToDo: Embelish this test case.
	func testVersionBasics() {
		let v1: SemanticVersion = "1.0.0"
		let v2 = SemanticVersion(2, 3, 4, prereleaseIdentifiers: ["alpha", "beta"], buildMetadataIdentifiers: ["232"])
		XCTAssert(v2 > v1)
		XCTAssertFalse(v2 == v1)
		XCTAssert("1.0.0" == v1)
		XCTAssertLessThan(SemanticVersion("1.2.3-alpha.beta.2"), SemanticVersion("1.2.3-alpha.beta.3"))
		XCTAssertEqual(SemanticVersion("1.2.3-alpha.beta.2").description, "1.2.3-alpha.beta.2")
		XCTAssertEqual(SemanticVersion(1), v1)
		XCTAssertEqual(SemanticVersion(1, 2), SemanticVersion(1, 2, 0))
	}

}
