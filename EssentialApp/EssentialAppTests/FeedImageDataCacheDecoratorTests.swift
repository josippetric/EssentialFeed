//
//  FeedImageDataCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Josip Petric on 14.09.2023..
//

import XCTest
import EssentialFeed

class FeedImageDataCacheDecorator: FeedImageDataLoader {
	private let decoratee: FeedImageDataLoader
	
	init(decoratee: FeedImageDataLoader) {
		self.decoratee = decoratee
	}
	
	func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> LoadImageDataTask {
		return decoratee.loadImageData(from: url, completion: completion)
	}
}

final class FeedImageDataCacheDecoratorTests: XCTestCase {

	func test_initDoesNotLoadImageData() {
		let (_, loader) = makeSUT()
		
		XCTAssertTrue(loader.loadedURLs.isEmpty, "Expected no loaded URLs")
	}

	func test_loadImageData_loadsFromLoader() {
		let url = anyURL()
		let (sut, loader) = makeSUT()
		
		_ = sut.loadImageData(from: url) { _ in }
		
		XCTAssertEqual(loader.loadedURLs, [url], "Expected to load from the URL")
	}
	
	func test_cancelLoadImageData_cancelsLoaderTask() {
		let url = anyURL()
		let (sut, loader) = makeSUT()
		
		let task = sut.loadImageData(from: url) { _ in }
		task.cancel()
		
		XCTAssertEqual(loader.cancelledURLs, [url], "Expected to cancel the the URL load")
	}
	
	func test_loadImageData_deliversErrorOnLoaderFailure() {
		let (sut, loader) = makeSUT()
		
		expect(sut, toCompleteWith: .failure(anyNSError())) {
			loader.complete(with: anyNSError())
		}
	}
	
   // MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImageDataLoader, loader: FeedImageDataLoaderSpy) {
		let loader = FeedImageDataLoaderSpy()
		let sut = FeedImageDataCacheDecorator(decoratee: loader)
		trackForMemoryLeaks(loader)
		trackForMemoryLeaks(sut)
		return (sut, loader)
	}
	
	private func expect(_ sut: FeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")
		
		_ = sut.loadImageData(from: anyURL(), completion: { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedData), .success(expectedData)):
				XCTAssertEqual(receivedData, expectedData, file: file, line: line)
				
			case (.failure, .failure):
				break
				
			default:
				XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
			}
			exp.fulfill()
		})
		action()
		wait(for: [exp], timeout: 1.0)
	}
}
