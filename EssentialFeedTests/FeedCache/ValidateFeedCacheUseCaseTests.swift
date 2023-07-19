//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 19.07.2023..
//

import XCTest
import EssentialFeed

final class ValidateFeedCacheUseCaseTests: XCTestCase {

	func test_init_doesNotMessageStoreUponCreation() {
		let (_, store) = makeSUT()
		
		XCTAssertEqual(store.receivedMessages, [])
	}
	
	func test_validateCache_deletesCacheOnRetrievalError() {
		let (sut, store) = makeSUT()
		
		sut.validateCache()
		store.completeRetrieval(with: anyNSError())
		
		XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
	}

	func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
		let (sut, store) = makeSUT()
		
		sut.validateCache()
		store.completeRetrievalWithEmptyCache()
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_validateCache_doesNotdeleteCacheOnLessThenSevenDaysOldCache() {
		let (sut, store) = makeSUT()
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let lessThenSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
		
		sut.validateCache()
		store.completeRetrieval(with: feed.local, timestamp: lessThenSevenDaysOldTimestamp)
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
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
}
