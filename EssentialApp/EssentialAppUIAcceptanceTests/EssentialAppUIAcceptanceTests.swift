//
//  EssentialAppUIAcceptanceTests.swift
//  EssentialAppUIAcceptanceTests
//
//  Created by Josip Petric on 15.09.2023..
//

import XCTest
import EssentialFeed
import EssentialFeediOS

final class EssentialAppUIAcceptanceTests: XCTestCase {

	func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
		let app = XCUIApplication()
		
		app.launch()
		
		XCTAssertEqual(app.cells.count, 22)
		XCTAssertEqual(app.cells.firstMatch.images.count, 1)
	}
}
