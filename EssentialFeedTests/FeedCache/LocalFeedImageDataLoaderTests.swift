//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 07.09.2023..
//

import XCTest
import EssentialFeed

protocol FeedImageDataStore {
	func retrieve(dataForURL url: URL)
}

final class LocalFeedImageDataLoader {
	private struct Task: FeedImageDataLoaderTask {
		func cancel() {}
	}
	
	let store: FeedImageDataStore
	
	init(store: FeedImageDataStore) {
		self.store = store
	}
	
	func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
		store.retrieve(dataForURL: url)
		return Task()
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
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (LocalFeedImageDataLoader, FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedImageDataLoader(store: store)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}
	
	private class FeedStoreSpy: FeedImageDataStore {
		enum Message: Equatable {
			case retrive(dataFor: URL)
		}
		
		var receivedMessages = [Message]()
		
		func retrieve(dataForURL url: URL) {
			receivedMessages.append(.retrive(dataFor: url))
		}
	}
}
