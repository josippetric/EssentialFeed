//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 15.06.2023..
//

import XCTest
@testable import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {

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
		expect(sut, toCompleteWithResult: .failure(.connectivity)) {
			let clientError = NSError(domain: "Test", code: 0)
			client.complete(with: clientError)
		}
	}

	func test_load_deliversErrorOnNon200HttpResponse() {
		let (sut, client) = makeSUT()
		let samples = [199, 201, 300, 400, 401, 404, 500]
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWithResult: .failure(.invalidData)) {
				let json = makeItemsJson([])
				client.complete(withStatusCode: code, data: json, at: index)
			}
		}
	}

	func test_load_deliversErrorOn200HttpResponseWithInvalidJson() {
		let (sut, client) = makeSUT()
		expect(sut, toCompleteWithResult: .failure(.invalidData)) {
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

	// MARK: - Helpers

	private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(url: url, client: client)
		return (sut, client)
	}

	private func makeItem(
		id: UUID, description: String? = nil,
		location: String? = nil,
		imageUrl: URL
	) -> (model: FeedItem, json: [String: Any]) {
		
		let item = FeedItem(id: id, description: description, location: location, imageURL: imageUrl)
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
		toCompleteWithResult result: RemoteFeedLoader.Result,
		when action: () -> Void,
		file: StaticString = #filePath,
		line: UInt = #line)
	{
		var capturedResults = [RemoteFeedLoader.Result]()
		sut.load { capturedResults.append($0) }

		action()
		XCTAssertEqual(capturedResults, [result], file: file, line: line)
	}

	private class HTTPClientSpy: HTTPClient {
		var requestedURLs: [URL] {
			return messages.map { $0.url }
		}

		private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
		
		func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
			messages.append((url, completion))
		}
		
		func complete(with error: Error, at index: Int = 0) {
			messages[index].completion(.failure(error))
		}

		func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
			let response = HTTPURLResponse(
				url: requestedURLs[index],
				statusCode: code,
				httpVersion: nil,
				headerFields: nil)
			messages[index].completion(.success(data, response!))
			
		}
	}
}
