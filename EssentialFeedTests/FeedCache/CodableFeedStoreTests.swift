//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 01.08.2023..
//

import XCTest
import EssentialFeed

protocol FeedStoreSpecs {
	func test_retrieve_deliversEmptyOnEmptyCache()
	func test_retrieve_hasNoSideEffectsOnEmptyCache()
	func test_retrieve_deliversFoundValuesOnNonEmptyCache()
	func test_retrieve_hasNoSideEffectsOnNonEmptyCache()
	
	func test_insert_deliversNoErrorOnEmptyCache()
	func test_insert_deliversNoErrorOnNonEmptyCache()
	func test_insert_overridesPreviouslyInsertedCacheValues()
	
	func test_delete_hasNoSideEffectsOnEmptyCache()
	func test_delete_emptiesPreviouslyInsertedCache()

	func test_storeSideEffects_runsSerially()
}

protocol FailableRetrieveFeedStoreSpecs {
	func test_retrieve_deliversFailureOnRetrievalError()
	func test_retrieve_hasNoSideEffectsOnFailure()
}

protocol FailableInsertFeedStoreSpecs {
	func test_insert_deliversErrorOnInsertionError()
	func test_insert_hasNoSideEffectsOnInsertionError()
}

protocol FailableDeleteFeedStoreSpecs {
	func test_delete_deliversErrorOnDeletionError()
	func test_delete_hasNoSideEffectsOnDeletionError()
}

final class CodableFeedStoreTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		setupEmptyStoreState()
	}
	
	override func tearDown() {
		super.tearDown()
		undoStoreSideEffects()
	}
	
	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = makeSUT()
		expect(sut, toRetrieve: .empty)
	}

	func test_retrieve_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()
		
		expect(sut, toRetrieveTwice: .empty)
	}

	func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
		let sut = makeSUT()
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		
		insert((feed, timestamp), to: sut)

		expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
	}

	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
		let sut = makeSUT()
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		
		insert((feed, timestamp), to: sut)
		
		expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
	}

	func test_retrieve_deliversFailureOnRetrievalError() {
		let storeURL = testSpecificStoreURL()
		let sut = makeSUT(storeURL: storeURL)
		
		try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
		
		expect(sut, toRetrieve: .failure(anyNSError()))
	}

	func test_retrieve_hasNoSideEffectsOnFailure() {
		let storeURL = testSpecificStoreURL()
		let sut = makeSUT(storeURL: storeURL)
		
		try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
		
		expect(sut, toRetrieveTwice: .failure(anyNSError()))
	}
	
	func test_insert_deliversNoErrorOnEmptyCache() {
		let sut = makeSUT()
		
		let firstInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)
		XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
	}
	
	func test_insert_deliversNoErrorOnNonEmptyCache() {
		let sut = makeSUT()
		insert((uniqueImageFeed().local, Date()), to: sut)

		let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
		
		XCTAssertNil(insertionError, "Expected to override cache successfully")
	}
	
	func test_insert_overridesPreviouslyInsertedCacheValues() {
		let sut = makeSUT()
		insert((uniqueImageFeed().local, Date()), to: sut)
		
		let latestFeed = uniqueImageFeed().local
		let latestTimestamp = Date()
		let latestInsertionError = insert((latestFeed, latestTimestamp), to: sut)

		expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
	}
	
	func test_insert_deliversErrorOnInsertionError() {
		let invalidStoreURL = URL(string: "invalid://store-url")!
		let sut = makeSUT(storeURL: invalidStoreURL)
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		
		let insertionError = insert((feed, timestamp), to: sut)
		
		XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
	}
	
	func test_insert_hasNoSideEffectsOnInsertionError() {
		let invalidStoreURL = URL(string: "invalid://store-url")!
		let sut = makeSUT(storeURL: invalidStoreURL)
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		
		insert((feed, timestamp), to: sut)
		
		expect(sut, toRetrieve: .empty)
	}

	func test_delete_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()
		
		let deletionError = deleteCache(from: sut)
		
		XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
		expect(sut, toRetrieve: .empty)
	}
	
	func test_delete_emptiesPreviouslyInsertedCache() {
		let sut = makeSUT()
		insert((uniqueImageFeed().local, Date()), to: sut)
		
		let deletionError = deleteCache(from: sut)
		
		XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
		expect(sut, toRetrieve: .empty)
	}

	func test_delete_deliversErrorOnDeletionError() {
		let noDeletePermissionURL = noDeletePermissionURL()
		let sut = makeSUT(storeURL: noDeletePermissionURL)
		
		let deletionError = deleteCache(from: sut)
		
		XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
	}
	
	func test_delete_hasNoSideEffectsOnDeletionError() {
		let noDeletePermissionURL = noDeletePermissionURL()
		let sut = makeSUT(storeURL: noDeletePermissionURL)
		
		deleteCache(from: sut)
		expect(sut, toRetrieve: .empty)
	}

	func test_storeSideEffects_runsSerially() {
		let sut = makeSUT()
		var completedOperationsOrder = [XCTestExpectation]()
		
		let op1 = expectation(description: "operation 1")
		sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
			completedOperationsOrder.append(op1)
			op1.fulfill()
		}
		
		let op2 = expectation(description: "operation 2")
		sut.deleteCachedFeed { _ in
			completedOperationsOrder.append(op2)
			op2.fulfill()
		}

		let op3 = expectation(description: "operation 3")
		sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
			completedOperationsOrder.append(op3)
			op3.fulfill()
		}
		
		waitForExpectations(timeout: 5.0)
		XCTAssertEqual(completedOperationsOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order")
	}
	
	// MARK: - Helpers
	
	private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
		let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
	
	@discardableResult
	private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore, file: StaticString = #file, line: UInt = #line) -> Error? {
		let exp = expectation(description: "Wait for cache insertion")
		var insertionError: Error?
		sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
			insertionError = receivedInsertionError
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
		return insertionError
	}
	
	private func deleteCache(from sut: FeedStore) -> Error? {
		let exp = expectation(description: "Wait for cache deletion")
		var deletionError: Error?
		sut.deleteCachedFeed{ receivedDeletionError in
			deletionError = receivedDeletionError
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
		return deletionError
	}
	
	private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
	}
	
	private func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
		let exp = expectation(description: "Wait for cache retrieval")
		
		sut.retrieve { retrievalResult in
			switch (expectedResult, retrievalResult) {
			case (.empty, .empty):
				break
			
			case (.failure, .failure):
				break
			
			case let (.found(expected), .found(retrieved)):
				XCTAssertEqual(retrieved.feed, expected.feed, file: file, line: line)
				XCTAssertEqual(retrieved.timestamp, expected.timestamp, file: file, line: line)
				
			default:
				XCTFail("Expected to retrieve \(expectedResult), got \(retrievalResult) instead", file: file, line: line)
			}
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
	
	private func testSpecificStoreURL() -> URL {
		return FileManager.default.urls(
			for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "\(type(of: self)).store")
	}
	
	private func noDeletePermissionURL() -> URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
	}

	private func setupEmptyStoreState() {
		deleteStoreArtefacts()
	}

	private func undoStoreSideEffects() {
		deleteStoreArtefacts()
	}
	
	private func deleteStoreArtefacts() {
		try? FileManager.default.removeItem(at: testSpecificStoreURL())
	}
}
