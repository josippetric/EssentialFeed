//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Josip Petric on 14.09.2023..
//

import XCTest
import EssentialFeed

class FeedLoaderCacheDecorator: FeedLoader {
	private let decoratee: FeedLoader
	
	init(decoratee: FeedLoader) {
		self.decoratee = decoratee
	}
	
	func load(completion: @escaping (FeedLoader.Result) -> Void) {
		decoratee.load(completion: completion)
	}
}

final class FeedLoaderCacheDecoratorTests: XCTestCase {

	func test_load_deliversFeedOnLoadSuccess() {
		let feed = uniqueFeed()
		let loader = LoaderStub(result: .success(feed))
		let sut = FeedLoaderCacheDecorator(decoratee: loader)

		expect(sut, toCompleteWith: .success(feed))
	}
	
	func test_load_deliversErrorOnLoaderFailure() {
		let loader = LoaderStub(result: .failure(anyNSError()))
		let sut = FeedLoaderCacheDecorator(decoratee: loader)
		
		expect(sut, toCompleteWith: .failure(anyNSError()))
	}
	
	// MARK: - Helpers
	
	private func expect(_ sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result, file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for load to complete")
		
		sut.load { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedFeed), .success(expectedFeed)):
				XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
				
			case (.failure, .failure):
				break

			default:
				XCTFail("Expected successful load feed result, got \(receivedResult) instead", file: file, line: line)
			}
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}
	
	private func uniqueFeed() -> [FeedImage] {
		return [FeedImage(id: UUID(), description: "any", location: "any location", url: URL(string: "http;//any-url.com")!)]
	}
	
	private class LoaderStub: FeedLoader {
		private let result: FeedLoader.Result
		
		init(result: FeedLoader.Result) {
			self.result = result
		}
		
		func load(completion: @escaping (FeedLoader.Result) -> Void) {
			completion(result)
		}
	}
}