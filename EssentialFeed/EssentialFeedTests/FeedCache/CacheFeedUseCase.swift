//
//  CacheFeedUseCase.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 06.07.2023..
//

import XCTest
import EssentialFeed

final class CacheFeedUseCase: XCTestCase {
	
	func test_init_doesNotMessageStoreUponCreation() {
		let (_, store) = makeSUT()
		
		XCTAssertEqual(store.receivedMessages, [])
	}

	func test_save_requestsCacheDeletion() {
		let (sut, store) = makeSUT()

		sut.save(uniqueImageFeed().models) { _ in }
		
		XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
	}

	func test_save_doesNotRequestCacheInsertionOnDeletionError() {
		let (sut, store) = makeSUT()

		sut.save(uniqueImageFeed().models) { _ in }
		let deletionError = anyNSError()
		store.completeDeletion(with: deletionError)
		
		XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
	}

	func test_save_requestNewCacheInsertionWithTimestampOnSuccessfullDeletion() {
		let timestamp = Date()
		let (sut, store) = makeSUT(currentDate: { timestamp })

		let (feed, localFeed) = uniqueImageFeed()
		sut.save(feed) { _ in }
		store.completeDeletionSuccessfully()
		
		XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(localFeed, timestamp)])
	}

	func test_save_failsOnDeletionError() {
		let (sut, store) = makeSUT()
		let deletionError = anyNSError()
		
		expect(sut, toCompleteWithError: deletionError) {
			store.completeDeletion(with: deletionError)
		}
	}

	func test_save_failsOnInsertionError() {
		let (sut, store) = makeSUT()
		let insertionError = anyNSError()

		expect(sut, toCompleteWithError: insertionError) {
			store.completeDeletionSuccessfully()
			store.completeInsertion(with: insertionError)
		}
	}

	func test_save_succeedsOnSuccessfulICacheInsertion() {
		let (sut, store) = makeSUT()
		
		expect(sut, toCompleteWithError: nil) {
			store.completeDeletionSuccessfully()
			store.completeInsertionSuccessfully()
		}
	}
	
	func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
		let store = FeedStoreSpy()
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
		
		var receivedResults = [LocalFeedLoader.SaveResult]()
		sut?.save(uniqueImageFeed().models, completion: { receivedResults.append($0) })
		
		sut = nil
		store.completeDeletion(with: anyNSError())
		
		XCTAssertTrue(receivedResults.isEmpty)
	}
	
	func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
		let store = FeedStoreSpy()
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
		
		var receivedResults = [LocalFeedLoader.SaveResult]()
		sut?.save(uniqueImageFeed().models, completion: { receivedResults.append($0) })
		
		store.completeDeletionSuccessfully()
		sut = nil
		store.completeInsertion(with: anyNSError())
		
		XCTAssertTrue(receivedResults.isEmpty)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(
		currentDate: @escaping () -> Date = Date.init,
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {

		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}

	private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		var receivedError: Error?
		let exp = expectation(description: "Wait for save completion")
		
		sut.save(uniqueImageFeed().models) { result in
			if case let Result.failure(error) = result {
				receivedError = error
			}
			exp.fulfill()
		}
		action()
		wait(for: [exp], timeout: 1.0)
		
		XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
	}
}
