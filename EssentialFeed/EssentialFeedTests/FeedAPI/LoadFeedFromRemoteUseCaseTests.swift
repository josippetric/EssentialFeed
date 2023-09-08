//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 15.06.2023..
//

import XCTest
@testable import EssentialFeed

final class LoadFeedFromRemoteUseCaseTests: XCTestCase {

	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()

		XCTAssertTrue(client.requestedURLs.isEmpty)
	}

	func test_load_requestsDataFromURL() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)

		sut.load { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}

	func test_loadTwice_requestsDataFromURLTwice() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)

		sut.load { _ in }
		sut.load { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		expect(sut, toCompleteWithResult: failure(.connectivity)) {
			let clientError = NSError(domain: "Test", code: 0)
			client.complete(with: clientError)
		}
	}

	func test_load_deliversErrorOnNon200HttpResponse() {
		let (sut, client) = makeSUT()
		let samples = [199, 201, 300, 400, 401, 404, 500]
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWithResult: failure(.invalidData)) {
				let json = makeItemsJson([])
				client.complete(withStatusCode: code, data: json, at: index)
			}
		}
	}

	func test_load_deliversErrorOn200HttpResponseWithInvalidJson() {
		let (sut, client) = makeSUT()
		expect(sut, toCompleteWithResult: failure(.invalidData)) {
			let invalidJson = Data("invalid data".utf8)
			client.complete(withStatusCode: 200, data: invalidJson)
		}
	}

	func test_load_deliversNoItemsOn200HttpResponseWithEmptyJsonList() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWithResult: .success([])) {
			let emptyListJson = makeItemsJson([])
			client.complete(withStatusCode: 200, data: emptyListJson)
		}
	}

	func test_load_deliversItemsOn200HttpResponseWithJsonItems() {
		let (sut, client) = makeSUT()

		let item1 = makeItem(
			id: UUID(),
			imageUrl: URL(string: "https://a-given-url.com")!)

		let item2 = makeItem(
			id: UUID(),
			description: "A description",
			location: "A location",
			imageUrl: URL(string: "https://a-given-url.com")!)

		let items = [item1.model, item2.model]
		
		expect(sut, toCompleteWithResult: .success(items)) {
			let json = makeItemsJson([item1.json, item2.json])
			client.complete(withStatusCode: 200, data: json)
		}
	}

	func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let url = URL(string: "https://any-url.com")!
		let client = HTTPClientSpy()
		var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
		
		var capturedResults = [RemoteFeedLoader.Result]()
		sut?.load { capturedResults.append($0) }
		
		sut = nil

		client.complete(withStatusCode: 200, data: makeItemsJson([]))
		
		XCTAssertTrue(capturedResults.isEmpty)
	}

	// MARK: - Helpers

	private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath,
						 line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(url: url, client: client)
		
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}
	
	private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
		return .failure(error)
	}

	private func makeItem(
		id: UUID, description: String? = nil,
		location: String? = nil,
		imageUrl: URL
	) -> (model: FeedImage, json: [String: Any]) {
		
		let item = FeedImage(id: id, description: description, location: location, url: imageUrl)
		let json = [
			"id": id.uuidString,
			"description": description,
			"location": location,
			"image": imageUrl.absoluteString
		].compactMapValues({ $0 })
		return (item, json)
	}

	private func makeItemsJson(_ items: [[String: Any]]) -> Data {
		let json = ["items": items]
		return try! JSONSerialization.data(withJSONObject: json)
	}

	private func expect(
		_ sut: RemoteFeedLoader,
		toCompleteWithResult expectedResult: RemoteFeedLoader.Result,
		when action: () -> Void,
		file: StaticString = #filePath,
		line: UInt = #line)
	{
		let exp = expectation(description: "Wait for load completion")
		
		sut.load { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedItems), .success(expectedItems)):
				XCTAssertEqual(expectedItems, receivedItems, file: file, line: line)

			case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
				XCTAssertEqual(expectedError, receivedError, file: file, line: line)

			default:
				XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
			}
		}
		
		exp.fulfill()

		action()

		wait(for: [exp], timeout: 1.0)
	}
}
