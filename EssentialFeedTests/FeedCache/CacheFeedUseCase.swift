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

		sut.save(uniqueItems().models) { _ in }
		
		XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
	}

	func test_save_doesNotRequestCacheInsertionOnDeletionError() {
		let (sut, store) = makeSUT()

		sut.save(uniqueItems().models) { _ in }
		let deletionError = anyNSError()
		store.completeDeletion(with: deletionError)
		
		XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
	}

	func test_save_requestNewCacheInsertionWithTimestampOnSuccessfullDeletion() {
		let timestamp = Date()
		let (sut, store) = makeSUT(currentDate: { timestamp })

		let (items, localItems) = uniqueItems()
		sut.save(items) { _ in }
		store.completeDeletionSuccessfully()
		
		XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(localItems, timestamp)])
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
		sut?.save(uniqueItems().models, completion: { receivedResults.append($0) })
		
		sut = nil
		store.completeDeletion(with: anyNSError())
		
		XCTAssertTrue(receivedResults.isEmpty)
	}
	
	func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
		let store = FeedStoreSpy()
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
		
		var receivedResults = [LocalFeedLoader.SaveResult]()
		sut?.save(uniqueItems().models, completion: { receivedResults.append($0) })
		
		store.completeDeletionSuccessfully()
		sut = nil
		store.completeInsertion(with: anyNSError())
		
		XCTAssertTrue(receivedResults.isEmpty)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(
		currentDate: @escaping () -> Date = Date.init,
		file: StaticString = #file,
		line: UInt = #line
	) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {

		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}

	private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
		var receivedError: Error?
		let exp = expectation(description: "Wait for save completion")
		
		sut.save(uniqueItems().models) { error in
			receivedError = error
			exp.fulfill()
		}
		action()
		wait(for: [exp], timeout: 1.0)
		
		XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
	}
	
	private func uniqueItem() -> FeedItem {
		return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
	}
	
	private func uniqueItems() -> (models: [FeedItem], local: [LocalFeedItem]) {
		let items = [uniqueItem(), uniqueItem()]
		let localItems = items.map({ LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) })
		return (items, localItems)
	}
	
	private func anyURL() -> URL {
		return URL(string: "http://any-url.com")!
	}

	private func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 0)
	}

	private class FeedStoreSpy: FeedStore {
		enum ReceivedMessage: Equatable {
		 case deleteCacheFeed
		 case insert([LocalFeedItem], Date)
	 }
	 
	 private(set) var receivedMessages = [ReceivedMessage]()
	 private var deletionCompletions = [DeletionCompletion]()
	 private var insertionCompletions = [InsertionCompletion]()
	 
	 func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		 deletionCompletions.append(completion)
		 receivedMessages.append(.deleteCacheFeed)
	 }
	 
	 func insert(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
		 receivedMessages.append(.insert(items, timestamp))
		 insertionCompletions.append(completion)
	 }
	 
	 func completeDeletion(with error: Error, at index: Int = 0) {
		 deletionCompletions[index](error)
	 }
	 
	 func completeDeletionSuccessfully(at index: Int = 0) {
		 deletionCompletions[index](nil)
	 }

	 func completeInsertion(with error: Error, at index: Int = 0) {
		 insertionCompletions[index](error)
	 }
	 
	 func completeInsertionSuccessfully(at index: Int = 0) {
		 insertionCompletions[index](nil)
	 }
 }

}
