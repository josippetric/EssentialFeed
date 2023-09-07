//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 07.09.2023..
//

import XCTest
import EssentialFeed

protocol FeedImageDataStore {
	typealias Result = Swift.Result<Data?, Error>

	func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}

final class LocalFeedImageDataLoader {
	private struct Task: FeedImageDataLoaderTask {
		func cancel() {}
	}
	
	public enum Error: Swift.Error {
		case failed
		case notFound
	}
	
	let store: FeedImageDataStore
	
	init(store: FeedImageDataStore) {
		self.store = store
	}
	
	func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
		store.retrieve(dataForURL: url, completion: { result in
			completion(result
				.mapError({ _ in Error.failed })
				.flatMap({ _ in .failure(Error.notFound) })
			)
		})
		return Task()
	}
}

class LocalFeedImageDataLoaderTests: XCTestCase {
	
	func test_init_doesNotMessegeStorageUponCreation() {
		let (_, store) = makeSUT()
		
		XCTAssertTrue(store.receivedMessages.isEmpty)
	}
	
	func test_loadImageDataFromURL_requestsStoredDataFromURL() {
		let (sut, store) = makeSUT()
		let url = anyURL()
		
		_ = sut.loadImageData(from: url) { _ in }
		
		XCTAssertEqual(store.receivedMessages, [.retrive(dataFor: url)])
	}
	
	func test_loadImageDataFromURL_failsOnStoreError() {
		let (sut, store) = makeSUT()
		
		expect(sut, toCompleteWith: failed()) {
			let retrievalError = anyNSError()
			store.complete(with: retrievalError)
		}
	}
	
	func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFound() {
		let (sut, store) = makeSUT()
		
		expect(sut, toCompleteWith: notFound()) {
			store.complete(with: .none)
		}
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (LocalFeedImageDataLoader, FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedImageDataLoader(store: store)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}
	
	private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")
		
		_ = sut.loadImageData(from: anyURL(), completion: { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedData), .success(expectedData)):
				XCTAssertEqual(receivedData, expectedData, file: file, line: line)
			
			case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)
				
			default:
				XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
			}
			exp.fulfill()
		})
		
		action()
		wait(for: [exp], timeout: 1.0)
	}
	
	private func failed() -> FeedImageDataLoader.Result {
		return .failure(LocalFeedImageDataLoader.Error.failed)
	}
	
	private func notFound() -> FeedImageDataLoader.Result {
		return .failure(LocalFeedImageDataLoader.Error.notFound)
	}
	
 	private class FeedStoreSpy: FeedImageDataStore {
		enum Message: Equatable {
			case retrive(dataFor: URL)
		}
		
		private var completions = [(FeedImageDataStore.Result) -> Void]()
		private(set) var receivedMessages = [Message]()
		
		func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void) {
			receivedMessages.append(.retrive(dataFor: url))
			completions.append(completion)
		}
		
		func complete(with error: Error, at index: Int = 0) {
			completions[index](.failure(error))
		}

		func complete(with data: Data?, at index: Int = 0) {
			completions[index](.success(data))
		}
	}
}
