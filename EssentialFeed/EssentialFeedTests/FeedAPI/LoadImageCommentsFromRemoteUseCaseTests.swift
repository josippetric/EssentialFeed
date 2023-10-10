//
//  LoadImageCommentsFromRemoteUseCase.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 10.10.2023..
//

import XCTest
import EssentialFeed

final class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
	
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

	func test_load_deliversErrorOnNon2xxHttpResponse() {
		let (sut, client) = makeSUT()
		let samples = [199, 150, 300, 400, 401, 404, 500]
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWithResult: failure(.invalidData)) {
				let json = makeItemsJson([])
				client.complete(withStatusCode: code, data: json, at: index)
			}
		}
	}

	func test_load_deliversErrorOn2xxHttpResponseWithInvalidJson() {
		let (sut, client) = makeSUT()
		
		let samples = [200, 201, 250, 280, 299]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWithResult: failure(.invalidData)) {
				let invalidJson = Data("invalid data".utf8)
				client.complete(withStatusCode: code, data: invalidJson, at: index)
			}
		}
	}

	func test_load_deliversNoItemsOn2xxHttpResponseWithEmptyJsonList() {
		let (sut, client) = makeSUT()
		
		let samples = [200, 201, 250, 280, 299]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWithResult: .success([])) {
				let emptyListJson = makeItemsJson([])
				client.complete(withStatusCode: code, data: emptyListJson, at: index)
			}
		}
	}

	func test_load_deliversItemsOn2xxHttpResponseWithJsonItems() {
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
		
		let samples = [200, 201, 250, 280, 299]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWithResult: .success(items)) {
				let json = makeItemsJson([item1.json, item2.json])
				client.complete(withStatusCode: code, data: json, at: index)
			}
		}
	}

	func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let url = URL(string: "https://any-url.com")!
		let client = HTTPClientSpy()
		var sut: RemoteImageCommentsLoader? = RemoteImageCommentsLoader(url: url, client: client)
		
		var capturedResults = [RemoteImageCommentsLoader.Result]()
		sut?.load { capturedResults.append($0) }
		
		sut = nil

		client.complete(withStatusCode: 200, data: makeItemsJson([]))
		
		XCTAssertTrue(capturedResults.isEmpty)
	}

	// MARK: - Helpers

	private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath,
						 line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentsLoader(url: url, client: client)
		
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}
	
	private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
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
		_ sut: RemoteImageCommentsLoader,
		toCompleteWithResult expectedResult: RemoteImageCommentsLoader.Result,
		when action: () -> Void,
		file: StaticString = #filePath,
		line: UInt = #line)
	{
		let exp = expectation(description: "Wait for load completion")
		
		sut.load { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedItems), .success(expectedItems)):
				XCTAssertEqual(expectedItems, receivedItems, file: file, line: line)

			case let (.failure(receivedError as RemoteImageCommentsLoader.Error), .failure(expectedError as RemoteImageCommentsLoader.Error)):
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
