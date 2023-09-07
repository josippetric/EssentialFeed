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
	private final class Task: FeedImageDataLoaderTask {
		private var completion: ((FeedImageDataLoader.Result) -> Void)?
		
		init(completion: @escaping (FeedImageDataLoader.Result) -> Void) {
			self.completion = completion
		}
		
		func complete(with result: FeedImageDataLoader.Result) {
			completion?(result)
		}
		
		func cancel() {
			preventFurtherCompletions()
		}
		
		private func preventFurtherCompletions() {
			completion = nil
		}
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
		let task = Task(completion: completion)
		store.retrieve(dataForURL: url, completion: { [weak self] result in
			guard self != nil else { return }

			task.complete(with: result
				.mapError({ _ in Error.failed })
				.flatMap({ data in data.map { .success($0) } ?? .failure(Error.notFound) })
			)
		})
		return task
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

	func test_loadImageDataFromURL_deliversStoredDataOnFoundData() {
		let (sut, store) = makeSUT()
		let foundData = anyData()
		
		expect(sut, toCompleteWith: .success(foundData)) {
			store.complete(with: foundData)
		}
	}

	func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
		let (sut, store) = makeSUT()
		let foundData = anyData()
		
		var received = [FeedImageDataLoader.Result]()
		let task = sut.loadImageData(from: anyURL()) { received.append($0) }
		task.cancel()
		
		store.complete(with: foundData)
		store.complete(with: .none)
		store.complete(with: anyNSError())
		
		XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
	}

	func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let store = FeedStoreSpy()
		var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
		
		var received = [FeedImageDataLoader.Result]()
		_ = sut?.loadImageData(from: anyURL(), completion: { received.append($0) })

		sut = nil
		store.complete(with: anyData())
		
		XCTAssertTrue(received.isEmpty, "Expected no received results after instance has been deallocated")
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
	
	private func never(file: StaticString = #file, line: UInt = #line) {
		XCTFail("Expected no no invocations", file: file, line: line)
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
