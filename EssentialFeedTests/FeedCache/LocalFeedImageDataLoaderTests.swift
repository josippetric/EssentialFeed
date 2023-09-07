//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 07.09.2023..
//

import XCTest
import EssentialFeed

final class LocalFeedImageDataLoader {
	init(store: Any) {
		
	}
}

class LocalFeedImageDataLoaderTests: XCTestCase {
	
	func test_init_doesNotMessegeStorageUponCreation() {
		let (_, store) = makeSUT()
		
		XCTAssertTrue(store.receivedMessage.isEmpty)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (LocalFeedImageDataLoader, FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedImageDataLoader(store: store)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}
	
	private class FeedStoreSpy {
		let receivedMessage = [Any]()
	}
}
