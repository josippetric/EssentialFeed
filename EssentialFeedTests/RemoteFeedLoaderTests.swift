//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 15.06.2023..
//

import XCTest

class RemoteFeedLoader {
	
}

class HTTPClient {
	var requestedURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {

	func test_init_doesNotRequestDataFromURL() {
		let client = HTTPClient()
		_ = RemoteFeedLoader()

		XCTAssertNil(client.requestedURL)
	}

}
