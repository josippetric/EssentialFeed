//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  EssentialAppTests
//
//  Created by Josip Petric on 13.09.2023..
//

import XCTest
import EssentialFeed

class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
	private let primary: FeedImageDataLoader
	private let fallback: FeedImageDataLoader
	
	private class Task: LoadImageDataTask {
		func cancel() {
			
		}
	}
	
	init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
		self.primary = primary
		self.fallback = fallback
	}
	
	func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> LoadImageDataTask {
		_ = primary.loadImageData(from: url) { [weak self] result in
			switch result {
			case .success:
				completion(result)

			case .failure:
				_ = self?.fallback.loadImageData(from: url, completion: completion)
			}
		}
		return Task()
	}
}

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
	
	func test_initDoesNotLoadImageData() {
		let (_, primaryLoader, fallbackLoader) = makeSUT()
		
		XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
		XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
	}

	func test_loadImageData_loadsFromPrimaryLoaderFirst() {
		let url = anyURL()
		let (sut, primaryLoader, fallbackLoader) = makeSUT()
		
		_ = sut.loadImageData(from: url, completion: { _ in })
	
		XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
		XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
	}
	
	func test_loadImageData_loadsFromFallbackOnPrimaryLoaderFailure() {
		let url = anyURL()
		let (sut, primaryLoader, fallbackLoader) = makeSUT()
		
		_ = sut.loadImageData(from: url, completion: { _ in })
		
		primaryLoader.complete(with: anyNSError())
		
		XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
		XCTAssertEqual(fallbackLoader.loadedURLs, [url], "Expected to load URL from fallback loader")
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoader, primary: LoaderSpy, fallback: LoaderSpy) {
		let primaryLoader = LoaderSpy()
		let fallbackLoader = LoaderSpy()
		let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
		
		trackForMemoryLeaks(primaryLoader, file: file, line: line)
		trackForMemoryLeaks(fallbackLoader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, primaryLoader, fallbackLoader)
	}
	
	private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
		}
	}
	
	private func anyNSError() -> NSError {
		return NSError(domain: "any", code: 100)
	}
	
	private func anyURL() -> URL {
		return URL(string: "http://a-url.com")!
	}
	
	private class LoaderSpy: FeedImageDataLoader {
		private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()

		var loadedURLs: [URL] {
			return messages.map { $0.url }
		}
		
		private struct Task: LoadImageDataTask {
			func cancel() {}
		}
		
		func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> LoadImageDataTask {
			messages.append((url, completion))
			return Task()
		}
		
		func complete(with error: Error, at index: Int = 0) {
			messages[index].completion(.failure(error))
		}
	}
}
