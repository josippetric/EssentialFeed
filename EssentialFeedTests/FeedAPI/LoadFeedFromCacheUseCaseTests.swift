//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 17.07.2023..
//

import XCTest
import EssentialFeed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
	
	func test_init_doesNotMessageStoreUponCreation() {
		let (_, store) = makeSUT()
		
		XCTAssertEqual(store.receivedMessages, [])
	}
	
	func test_load_requestsCacheRetrieval() {
		let (sut, store) = makeSUT()
		
		sut.load() { _ in }
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	func test_load_failsOnTestRetrieval() {
		let (sut, store) = makeSUT()
		let retrievalError = anyNSError()
		expect(sut, toCompleteWith: .failure(retrievalError)) {
			store.completeRetrieval(with: retrievalError)
		}
	}

	func test_load_deliversNoImagesOnEmptyCache() {
		let (sut, store) = makeSUT()
		expect(sut, toCompleteWith: .success([]), when: {
			store.completeRetrievalWithEmptyCache()
		})
	}
	
	func test_load_deliversCachedImagesOnLessThenSevenDaysOldCache() {
		let (sut, store) = makeSUT()
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let lessThenSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)

		expect(sut, toCompleteWith: .success(feed.models), when: {
			store.completeRetrieval(with: feed.local, timestamp: lessThenSevenDaysOldTimestamp)
		})
	}
	
	func test_load_deliversNoImagesOnSevenDaysOldCache() {
		let (sut, store) = makeSUT()
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)

		expect(sut, toCompleteWith: .success([]), when: {
			store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldTimestamp)
		})
	}

	func test_load_deliversNoImagesOnMoreThenSevenDaysOldCache() {
		let (sut, store) = makeSUT()
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let moreThenSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)

		expect(sut, toCompleteWith: .success([]), when: {
			store.completeRetrieval(with: feed.local, timestamp: moreThenSevenDaysOldTimestamp)
		})
	}
	
	func test_load_hasNoSideEffectsOnRetrievalError() {
		let (sut, store) = makeSUT()
		
		sut.load { _  in }
		store.completeRetrieval(with: anyNSError())
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_load_hasNoSideEffectsOnCacheOnEmptyCache() {
		let (sut, store) = makeSUT()
		
		sut.load { _  in }
		store.completeRetrievalWithEmptyCache()
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_load_noSideEffectsOnLessThenSevenDaysOldCache() {
		let (sut, store) = makeSUT()
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let lessThenSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
		
		sut.load { _  in }
		store.completeRetrieval(with: feed.local, timestamp: lessThenSevenDaysOldTimestamp)
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_load_hasNoSideEffectsOnSevenDaysOldCache() {
		let (sut, store) = makeSUT()
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
		
		sut.load { _  in }
		store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldTimestamp)
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	func test_load_hasNoSideEffectsOnMoreThenSevenDaysOldCache() {
		let (sut, store) = makeSUT()
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
		
		sut.load { _  in }
		store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldTimestamp)
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_load_doesNotDeliversResultAfterSUTInstanceHasBeenDeallocated() {
		let store = FeedStoreSpy()
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
		
		var receivedResults = [LocalFeedLoader.LoadResult]()
		sut?.load(completion: { result in
			receivedResults.append(result)
		})
		
		sut = nil
		store.completeRetrievalWithEmptyCache()

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
	
	private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")

		sut.load { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedImages), .success(expectedImages)):
				XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
			case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)
			default:
				XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
			}
			exp.fulfill()
		}
		action()
		wait(for: [exp], timeout: 1.0)
	}
}
