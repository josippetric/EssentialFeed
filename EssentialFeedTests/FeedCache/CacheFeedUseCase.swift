//
//  CacheFeedUseCase.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 06.07.2023..
//

import XCTest

class LocalFeedLoader {
	init(store: FeedStore) {
		
	}
}

class FeedStore {
	var deleteCachedFeedAllCount = 0
}

final class CacheFeedUseCase: XCTestCase {
	
	func test_init_doesNotDeleteCacheUponCreation() {
		let store = FeedStore()
		_ = LocalFeedLoader(store: store)
		
		XCTAssertEqual(store.deleteCachedFeedAllCount, 0)
	}
}
