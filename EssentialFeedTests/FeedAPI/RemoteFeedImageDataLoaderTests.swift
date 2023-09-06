//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 06.09.2023..
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {
	public enum Error: Swift.Error {
		case invalidData
	}
	
	let client: HTTPClient
	
	init(client: HTTPClient) {
		self.client = client
	}
	
	func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case let .success((data, response)):
				if response.statusCode == 200 && !data.isEmpty {
					completion(.success(data))
				} else {
					completion(.failure(Error.invalidData))
				}

			case let .failure(error):
				completion(.failure(error))
			}
		}
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
	
	func test_loadImageDataFromURL_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		let clientError = anyNSError()
		
		expect(sut, toCompleteWith: .failure(clientError), when: {
			client.complete(with: clientError)
		})
	}
	
	func test_loadImageDataFromURL_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()
		
		let samples = [199, 201, 300, 400, 500]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: failure(.invalidData)) {
				client.complete(withStatusCode: code, data: anyData(), at: index)
			}
		}
	}

	func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HTTPResponsewithEmptyData() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: failure(.invalidData)) {
			let emptyData = Data()
			client.complete(withStatusCode: 200, data: emptyData)
		}
	}

	func test_loadImageDataFromURL_deliversReceivedNonEmptyDataOn200HTTPResponse() {
		let (sut, client) = makeSUT()
		let nonEmptyData = anyData()
		
		expect(sut, toCompleteWith: .success(nonEmptyData)) {
			client.complete(withStatusCode: 200, data: nonEmptyData)
		}
	}
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedImageDataLoader(client: client)
		trackForMemoryLeaks(client)
		trackForMemoryLeaks(sut)
		return (sut, client)
	}
	
	private func anyData() -> Data {
		return Data("any data".utf8)
	}
	
	private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
		return .failure(error)
	}
	
	private func expect(_ sut: RemoteFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
		let url = anyURL()
		let exp = expectation(description: "Wait for load to complete")
		
		sut.loadImageData(from: url) { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedData), .success(expectedData)):
				XCTAssertEqual(receivedData, expectedData, file: file, line: line)
				
			case let (.failure(receivedError), .failure(expectedError)):
				XCTAssertEqual(receivedError as NSError, expectedError as NSError, file: file, line: line)

			default:
				XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
			}
			exp.fulfill()
		}
		
		action()
		
		wait(for: [exp], timeout: 1.0)
	}
	
	private class HTTPClientSpy: HTTPClient {
		var messages: [(url: URL, completion: (HTTPClient.Result) -> Void)] = []

		var requestedURLs: [URL] {
			return messages.map({ $0.url })
		}
		
		func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
			messages.append((url, completion))
		}
		
		func complete(with error: Error, at index: Int = 0) {
			messages[index].completion(.failure(error))
		}
		
		func complete(withStatusCode statusCode: Int, data: Data, at index: Int = 0) {
			let response = HTTPURLResponse(
				url: requestedURLs[index],
				statusCode: statusCode,
				httpVersion: nil,
				headerFields: nil
			)!
			messages[index].completion(.success((data, response)))
		}
	}
}
