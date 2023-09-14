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
	
	private class TaskWrapper: LoadImageDataTask {
		var wrapped: LoadImageDataTask?
		
		func cancel() {
			wrapped?.cancel()
		}
	}
	
	init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
		self.primary = primary
		self.fallback = fallback
	}
	
	func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> LoadImageDataTask {
		let task = TaskWrapper()
		
		task.wrapped = primary.loadImageData(from: url) { [weak self] result in
			switch result {
			case .success:
				completion(result)

			case .failure:
				task.wrapped = self?.fallback.loadImageData(from: url, completion: completion)
			}
		}
		return task
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
	
	func test_cancelLoadImageData_cancelsPrimaryLoaderTask() {
		let url = anyURL()
		let (sut, primaryLoader, fallbackLoader) = makeSUT()
		
		let task = sut.loadImageData(from: url, completion: { _ in })
		task.cancel()
		
		XCTAssertEqual(primaryLoader.cancelledURLs, [url], "Expected to cancel URL loading from primary loader")
		XCTAssertTrue(fallbackLoader.cancelledURLs.isEmpty, "Expected no cancelled URLs in the fallback loader")
	}

	func test_cancelLoadImageData_cancelsFallbackLoaderTaskAfterPrimaryLoaderFailure() {
		let url = anyURL()
		let (sut, primaryLoader, fallbackLoader) = makeSUT()
		
		let task = sut.loadImageData(from: url, completion: { _ in })
		primaryLoader.complete(with: anyNSError())
		task.cancel()
		
		XCTAssertTrue(primaryLoader.cancelledURLs.isEmpty, "Expected no canceled URLs from primary loader")
		XCTAssertEqual(fallbackLoader.cancelledURLs, [url], "Expected to cancel URL in the fallback loader")
	}

	func test_loadImageData_deliversPrimaryDataOnPrimaryLoaderSuccess() {
		let primaryData = anyData()
		let (sut, primaryLoader, _) = makeSUT()
		
		expect(sut, toCompleteWith: .success(primaryData)) {
			primaryLoader.complete(with: primaryData)
		}
	}
	
	func test_loadImageData_deliversFallbackDataOnFallbackLoaderSuccess() {
		let fallbackData = anyData()
		let (sut, primaryLoader, fallbackLoader) = makeSUT()
		
		expect(sut, toCompleteWith: .success(fallbackData)) {
			primaryLoader.complete(with: anyNSError())
			fallbackLoader.complete(with: fallbackData)
		}
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
	
	private func anyData() -> Data {
		return Data("any data".utf8)
	}
	
	private func anyNSError() -> NSError {
		return NSError(domain: "any", code: 100)
	}
	
	private func anyURL() -> URL {
		return URL(string: "http://a-url.com")!
	}
	
	private class LoaderSpy: FeedImageDataLoader {
		private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
		private(set) var cancelledURLs = [URL]()

		var loadedURLs: [URL] {
			return messages.map { $0.url }
		}
		
		private struct Task: LoadImageDataTask {
			let callback: () -> Void
			func cancel() {
				callback()
			}
		}
		
		func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> LoadImageDataTask {
			messages.append((url, completion))
			return Task { [weak self] in
				self?.cancelledURLs.append(url)
			}
		}
		
		func complete(with error: Error, at index: Int = 0) {
			messages[index].completion(.failure(error))
		}
		
		func complete(with data: Data, at index: Int = 0) {
			messages[index].completion(.success(data))
		}
	}
}