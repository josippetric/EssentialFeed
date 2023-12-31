//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 07.09.2023..
//

import XCTest
import EssentialFeed

class LoadFeedImageDataFromCacheUseCaseTests: XCTestCase {
	
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
			store.completeRetrieval(with: retrievalError)
		}
	}
	
	func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFound() {
		let (sut, store) = makeSUT()
		
		expect(sut, toCompleteWith: notFound()) {
			store.completeRetrieval(with: .none)
		}
	}

	func test_loadImageDataFromURL_deliversStoredDataOnFoundData() {
		let (sut, store) = makeSUT()
		let foundData = anyData()
		
		expect(sut, toCompleteWith: .success(foundData)) {
			store.completeRetrieval(with: foundData)
		}
	}

	func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
		let (sut, store) = makeSUT()
		let foundData = anyData()
		
		var received = [FeedImageDataLoader.Result]()
		let task = sut.loadImageData(from: anyURL()) { received.append($0) }
		task.cancel()
		
		store.completeRetrieval(with: foundData)
		store.completeRetrieval(with: .none)
		store.completeRetrieval(with: anyNSError())
		
		XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
	}

	func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let store = FeedImageDataStoreSpy()
		var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
		
		var received = [FeedImageDataLoader.Result]()
		_ = sut?.loadImageData(from: anyURL(), completion: { received.append($0) })

		sut = nil
		store.completeRetrieval(with: anyData())
		
		XCTAssertTrue(received.isEmpty, "Expected no received results after instance has been deallocated")
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (LocalFeedImageDataLoader, FeedImageDataStoreSpy) {
		let store = FeedImageDataStoreSpy()
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
		return .failure(LocalFeedImageDataLoader.LoadError.failed)
	}
	
	private func notFound() -> FeedImageDataLoader.Result {
		return .failure(LocalFeedImageDataLoader.LoadError.notFound)
	}
	
	private func never(file: StaticString = #file, line: UInt = #line) {
		XCTFail("Expected no no invocations", file: file, line: line)
	}
}
