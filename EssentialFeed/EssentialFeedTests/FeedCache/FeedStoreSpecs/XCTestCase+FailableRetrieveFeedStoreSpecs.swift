//
//  FailableRetrieveFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 05.08.2023..
//

import XCTest
import EssentialFeed

extension FailableRetrieveFeedStoreSpecs where Self: XCTestCase {
	func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
		expect(sut, toRetrieve: .failure(anyNSError()), file: file, line: line)
	}

	func assertThatRetrieveHasNoSideEffectsOnFailure(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
		expect(sut, toRetrieveTwice: .failure(anyNSError()), file: file, line: line)
	}
}
