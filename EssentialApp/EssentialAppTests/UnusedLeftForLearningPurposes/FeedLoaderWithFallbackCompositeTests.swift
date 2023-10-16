//
//  RemoteWithLocalFeedbackFeedLoaderTests.swift
//  EssentialAppTests
//
//  Created by Josip Petric on 13.09.2023..
//

// The file is not used, but is left here for the future reference and learning purposes

//import XCTest
//import EssentialApp
//import EssentialFeed
//
//class FeedLoaderWithFallbackCompositeTests: XCTestCase, FeedLoaderTestCase {
//	
//	func test_load_deliverPrimaryFeedOnPrimaryLoaderSuccess() {
//		let primaryFeed = uniqueFeed()
//		let fallbackFeed = uniqueFeed()
//		let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
//		
//		expect(sut, toCompleteWith: .success(primaryFeed))
//	}
//	
//	func test_load_deliversFallbackFeedOnPrimaryFailure() {
//		let fallbackFeed = uniqueFeed()
//		let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackFeed))
//		
//		expect(sut, toCompleteWith: .success(fallbackFeed))
//	}
//	
//	func test_load_deliversErrorOnBothPrimaryAndFallbackLoaderFailure() {
//		let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .failure(anyNSError()))
//		
//		expect(sut, toCompleteWith: .failure(anyNSError()))
//	}
//	
//	// MARK: - Helpers
//	
//	private func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result, file: StaticString = #filePath, line: UInt = #line) -> FeedLoader {
//		let primaryLoader = FeedLoaderStub(result: primaryResult)
//		let fallbackLoader = FeedLoaderStub(result: fallbackResult)
//		let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
//		trackForMemoryLeaks(primaryLoader, file: file, line: line)
//		trackForMemoryLeaks(fallbackLoader, file: file, line: line)
//		trackForMemoryLeaks(sut, file: file, line: line)
//		return sut
//	}
//}
