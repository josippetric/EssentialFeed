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
		
		var capturedErrors = [RemoteFeedLoader.Error]()
		sut.load {
			capturedErrors.append($0)
		}
		
		let clientError = NSError(domain: "Test", code: 0)
		client.complete(with: clientError)

		XCTAssertEqual(capturedErrors, [.connectivity])
	}

	func test_load_deliversErrorOnNon200HttpResponse() {
		let (sut, client) = makeSUT()
		
		let samples = [199, 201, 300, 400, 401, 404, 500]
		samples.enumerated().forEach { index, code in
			var capturedErrors = [RemoteFeedLoader.Error]()
			sut.load {
				capturedErrors.append($0)
			}

			client.complete(withStatusCode: code, at: index)
			XCTAssertEqual(capturedErrors, [.invalidData])
		}
	}

	func test_load_deliversErrorOn200HttpResponseWithInvalidJson() {
		let (sut, client) = makeSUT()
		var capturedErrors = [RemoteFeedLoader.Error]()
		sut.load {
			capturedErrors.append($0)
		}

		let invalidJson = Data(bytes: "invalid data".utf8)
		client.complete(withStatusCode: 200, data: invalidJson)
		XCTAssertEqual(capturedErrors, [.invalidData])
	}

	// MARK: - Helpers

	private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(url: url, client: client)
		return (sut, client)
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

		func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
			let response = HTTPURLResponse(
				url: requestedURLs[index],
				statusCode: code,
				httpVersion: nil,
				headerFields: nil)
			messages[index].completion(.success(data, response!))
			
		}
	}
}
