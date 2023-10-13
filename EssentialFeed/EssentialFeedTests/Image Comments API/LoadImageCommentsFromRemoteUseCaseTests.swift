//
//  LoadImageCommentsFromRemoteUseCase.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 10.10.2023..
//

import XCTest
import EssentialFeed

final class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {

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
			message: "a message",
			createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
			username: "a username")
		
		let item2 = makeItem(
			id: UUID(),
			message: "another message",
			createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
			username: "another username")

		let items = [item1.model, item2.model]
		
		let samples = [200, 201, 250, 280, 299]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWithResult: .success(items)) {
				let json = makeItemsJson([item1.json, item2.json])
				client.complete(withStatusCode: code, data: json, at: index)
			}
		}
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

	private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (model: ImageComment, json: [String: Any]) {
		
		let item = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)
		let json: [String: Any] = [
			"id": id.uuidString,
			"message": message,
			"created_at": createdAt.iso8601String,
			"author": ["username": username]
		]
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
