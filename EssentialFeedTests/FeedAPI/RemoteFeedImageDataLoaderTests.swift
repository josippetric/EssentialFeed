//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 06.09.2023..
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {
	let client: HTTPClient
	
	init(client: HTTPClient) {
		self.client = client
	}
	
	func loadImageData(from url: URL, completion: @escaping (Any) -> Void) {
		client.get(from: url) { _ in }
	}
}

final class RemoteFeedImageDataLoaderTests: XCTestCase {

	func test_init_doesNotPerformAnyURLRequest() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_loadImageDataFromURL_requestsDataFromURL() {
		let url = anyURL()
		let (sut, client) = makeSUT()
		
		sut.loadImageData(from: url) { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadImageDataFromURL_requestsDataFromURLTwice() {
		let url = anyURL()
		let (sut, client) = makeSUT()
		
		sut.loadImageData(from: url) { _ in }
		sut.loadImageData(from: url) { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedImageDataLoader(client: client)
		trackForMemoryLeaks(client)
		trackForMemoryLeaks(sut)
		return (sut, client)
	}
	
	private class HTTPClientSpy: HTTPClient {
		var requestedURLs = [URL]()
		
		func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
			requestedURLs.append(url)
		}
	}
}
