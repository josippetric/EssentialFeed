//
//  XCTestCase+FeedStoreSpec.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 05.08.2023..
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
	@discardableResult
	func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore, file: StaticString = #file, line: UInt = #line) -> Error? {
		let exp = expectation(description: "Wait for cache insertion")
		var insertionError: Error?
		sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
			insertionError = receivedInsertionError
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
		return insertionError
	}
	
	func deleteCache(from sut: FeedStore) -> Error? {
		let exp = expectation(description: "Wait for cache deletion")
		var deletionError: Error?
		sut.deleteCachedFeed{ receivedDeletionError in
			deletionError = receivedDeletionError
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
		return deletionError
	}
	
	func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
	}
	
	func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
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
}
