//
//  FeedEndpointTests.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 01.11.2023..
//

import XCTest
import EssentialFeed

final class FeedEndpointTests: XCTestCase {
	
	func test_feed_endpointURL() {
		let baseURL = URL(string: "http://base-url.com")!
		
		let receivedURL = FeedEndpoint.get.url(baseURL: baseURL)
		let expectedURL = URL(string: "http://base-url.com/v1/feed")!
		
		XCTAssertEqual(expectedURL, receivedURL)
	}
}
