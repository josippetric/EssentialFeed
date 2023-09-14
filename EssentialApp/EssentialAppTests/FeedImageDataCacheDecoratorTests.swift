//
//  FeedImageDataCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Josip Petric on 14.09.2023..
//

import XCTest
import EssentialFeed

protocol FeedImageDataCache {
	typealias SaveResult = Result<Void, Error>

	func save(data: Data, for url: URL, completion: @escaping (SaveResult) -> Void)
}

class FeedImageDataCacheDecorator: FeedImageDataLoader {
	private let decoratee: FeedImageDataLoader
	private let cache: FeedImageDataCache
	
	init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
		self.decoratee = decoratee
		self.cache = cache
	}
	
	func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> LoadImageDataTask {
		return decoratee.loadImageData(from: url) { [weak self] result in
			completion(result.map { imageData in
				self?.cache.save(data: imageData, for: url, completion: { _ in })
				return imageData
			})
		}
	}
}

final class FeedImageDataCacheDecoratorTests: XCTestCase, FeedImageDataLoaderTestCase {

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
	
	func test_loadImageData_cachesLoadedDataOnLoaderSuccess() {
		let cache = CacheSpy()
		let url = anyURL()
		let imageData = anyData()
		let (sut, loader) = makeSUT(cache: cache)
		
		_ = sut.loadImageData(from: url) { _ in }
		loader.complete(with: imageData)
		
		XCTAssertEqual(cache.messages, [.save(data: imageData, for: url)], "Expected to cache the image data when load is successful")
	}
	
	func test_loadImageData_doesNotCacheOnLoaderFailure() {
		let cache = CacheSpy()
		let url = anyURL()
		let (sut, loader) = makeSUT(cache: cache)
		
		_ = sut.loadImageData(from: url) { _ in }
		loader.complete(with: anyNSError())
		
		XCTAssertTrue(cache.messages.isEmpty, "Expected no cache message on loader failure")
	}
	
   // MARK: - Helpers
	
	private func makeSUT(cache: CacheSpy = .init(), file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImageDataLoader, loader: FeedImageDataLoaderSpy) {
		let loader = FeedImageDataLoaderSpy()
		let sut = FeedImageDataCacheDecorator(decoratee: loader, cache: cache)
		trackForMemoryLeaks(loader)
		trackForMemoryLeaks(sut)
		return (sut, loader)
	}
	
	private class CacheSpy: FeedImageDataCache {
		private(set) var messages = [Message]()
		
		enum Message: Equatable {
			case save(data: Data, for: URL)
		}
		
		func save(data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
			messages.append(.save(data: data, for: url))
		}
	}
}
