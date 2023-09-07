//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 06.09.2023..
//

import XCTest
import EssentialFeed

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
	
	func test_loadImageDataFromURL_deliversConnectivityErrorOnClientError() {
		let (sut, client) = makeSUT()
		let clientError = anyNSError()
		
		expect(sut, toCompleteWith: failure(.connectivity), when: {
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
	
	func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let client = HTTPClientSpy()
		var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
		
		var capturedResult: FeedImageDataLoader.Result?
		sut?.loadImageData(from: anyURL(), completion: { capturedResult = $0 })
		
		sut = nil
		client.complete(withStatusCode: 200, data: anyData())
		
		XCTAssertNil(capturedResult)
	}
	
	func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
		let (sut, client) = makeSUT()
		let url = anyURL()
		
		let task = sut.loadImageData(from: url) { _ in }
		XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no canceled URL requests until the task is canceled")
		
		task.cancel()
		XCTAssertEqual(client.cancelledURLs, [url], "Expected canceled URL request after the task has been canceled")
	}
	
	func test_loadImageDataFromURL_doesNotDeliverResultAfterCancelingTask() {
		let (sut, client) = makeSUT()
		let nonEmptyData = anyData()
		
		var received = [FeedImageDataLoader.Result]()
		let task = sut.loadImageData(from: anyURL()) { received.append($0) }
		task.cancel()
		
		client.complete(withStatusCode: 404, data: anyData())
		client.complete(withStatusCode: 200, data: nonEmptyData)
		client.complete(with: anyNSError())
		
		XCTAssertTrue(received.isEmpty, "Expected no received result after canceling the task")
	}
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedImageDataLoader(client: client)
		trackForMemoryLeaks(client)
		trackForMemoryLeaks(sut)
		return (sut, client)
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
}
