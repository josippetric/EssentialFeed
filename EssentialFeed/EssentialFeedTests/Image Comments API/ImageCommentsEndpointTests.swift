//
//  ImageCommentsEndpointTests.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 01.11.2023..
//

import XCTest
import EssentialFeed

final class ImageCommentsEndpointTests: XCTestCase {

	func test_imageComments_endpointURL() {
		let baseURL = URL(string: "http://base-url.com")!
		let uuid = UUID()
		
		let receivedURL = ImageCommentsEndpoint.get(uuid).url(baseURL: baseURL)
		let expectedURL = URL(string: "http://base-url.com/v1/image/\(uuid)/comments")!
		
		XCTAssertEqual(expectedURL, receivedURL)
	}

}
