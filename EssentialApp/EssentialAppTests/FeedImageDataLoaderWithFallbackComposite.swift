//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  EssentialAppTests
//
//  Created by Josip Petric on 13.09.2023..
//

import XCTest
import EssentialFeed

class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
	private class Task: LoadImageDataTask {
		func cancel() {
			
		}
	}
	
	init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
		
	}
	
	func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> LoadImageDataTask {
		return Task()
	}
}

final class FeedImageDataLoaderWithFallbackComposite: XCTestCase {
	
	func test_initDoesNotLoadImageData() {
		let primaryLoader = LoaderSpy()
		let fallbackLoader = LoaderSpy()
		let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
		
		XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
		XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
	}
	
	// MARK: - Helpers
	
	private class LoaderSpy: FeedImageDataLoader {
		private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()

		var loadedURLs: [URL] {
			return messages.map { $0.url }
		}
		
		private struct Task: LoadImageDataTask {
			func cancel() {}
		}
		
		func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> LoadImageDataTask {
			messages.append((url, completion))
			return Task()
		}
	}
}
