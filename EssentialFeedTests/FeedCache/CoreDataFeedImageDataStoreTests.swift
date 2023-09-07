//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 07.09.2023..
//

import XCTest
import EssentialFeed

extension CoreDataFeedStore: FeedImageDataStore {
	public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
		completion(.success(.none))
	}
	
	public func insert(data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
		
	}
}

final class CoreDataFeedImageDataStoreTests: XCTestCase {
	
	func test_retrieveImageData_deliversNotFoundWhenEmpty() {
		let sut = makeSUT()
		
		expect(sut, toCompleteRetrievalWith: notFound())
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataFeedStore {
		let storeBundle = Bundle(for: CoreDataFeedStore.self)
		let storeURL = URL(fileURLWithPath: "/dev/null")
		let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
	
	private func notFound() -> FeedImageDataStore.RetrievalResult {
		return .success(.none)
	}

	private func expect(_ sut: CoreDataFeedStore, toCompleteRetrievalWith expectedResult: FeedImageDataStore.RetrievalResult, file: StaticString = #file, line: UInt = #line) {
		
		let exp = expectation(description: "Waiting for data to be retrieved")
		
		sut.retrieve(dataForURL: anyURL()) { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedData), .success(expectedData)):
				XCTAssertEqual(receivedData, expectedData, file: file, line: line)
				
			default:
				XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
			}
			
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
}
