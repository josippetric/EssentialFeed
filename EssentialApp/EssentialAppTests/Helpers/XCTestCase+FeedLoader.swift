//
//  XCTestCase+FeedLoader.swift
//  EssentialAppTests
//
//  Created by Josip Petric on 14.09.2023..
//

//import XCTest
//import EssentialFeed
//
//protocol FeedLoaderTestCase: XCTestCase {}
//
//extension FeedLoaderTestCase {
//	func expect(_ sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result, file: StaticString = #filePath, line: UInt = #line) {
//		let exp = expectation(description: "Wait for load to complete")
//		
//		sut.load { receivedResult in
//			switch (receivedResult, expectedResult) {
//			case let (.success(receivedFeed), .success(expectedFeed)):
//				XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
//				
//			case (.failure, .failure):
//				break
//
//			default:
//				XCTFail("Expected successful load feed result, got \(receivedResult) instead", file: file, line: line)
//			}
//			exp.fulfill()
//		}
//		wait(for: [exp], timeout: 1.0)
//	}
//}
