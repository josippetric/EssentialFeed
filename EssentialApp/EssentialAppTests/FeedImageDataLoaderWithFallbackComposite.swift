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
	
	private class Task: LoadImageDataTask {
		func cancel() {
			
		}
	}
	
	init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
		self.primary = primary
	}
	
	func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> LoadImageDataTask {
		_ = primary.loadImageData(from: url) { _ in }
		return Task()
	}
}

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
	
	func test_initDoesNotLoadImageData() {
		let primaryLoader = LoaderSpy()
		let fallbackLoader = LoaderSpy()
		_ = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
		
		XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
		XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
	}

	func test_loadImageData_loadsFromPrimaryLoaderFirst() {
		let url = anyURL()
		let primaryLoader = LoaderSpy()
		let fallbackLoader = LoaderSpy()
		let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
		
		_ = sut.loadImageData(from: url, completion: { _ in })
	
		XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
		XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
	}
	
	// MARK: - Helpers
	
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
	}
}
