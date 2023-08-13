//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 08.08.2023..
//

import XCTest
import EssentialFeed

final class CoreDataFeedStoreTests: XCTestCase, FailableFeedStore {

	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = makeSUT()
		assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()
		assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
	}
	
	func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
		let sut = makeSUT()
		
		assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
	}
	
	func test_retrieve_deliversFailureOnRetrievalError() {
		
	}
	
	func test_retrieve_hasNoSideEffectsOnFailure() {
		
	}
	
	func test_insert_deliversNoErrorOnEmptyCache() {
		let sut = makeSUT()
		
		assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
	}
	
	func test_insert_deliversNoErrorOnNonEmptyCache() {
		let sut = makeSUT()
		
		assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
	}
	
	func test_insert_overridesPreviouslyInsertedCacheValues() {
		
	}

	func test_insert_deliversErrorOnInsertionError() {
		
	}

	func test_insert_hasNoSideEffectsOnInsertionError() {
		
	}
	
	func test_delete_deliversNoErrorOnEmptyCache() {
		
	}
	
	func test_delete_hasNoSideEffectsOnEmptyCache() {
		
	}
	
	func test_delete_emptiesPreviouslyInsertedCache() {
		
	}

	func test_delete_deliversErrorOnDeletionError() {
		
	}
	
	func test_delete_hasNoSideEffectsOnDeletionError() {
		
	}

	func test_storeSideEffects_runsSerially() {
		
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
		let storeBundle = Bundle(for: CoreDataFeedStore.self)
		let storeURL = URL(fileURLWithPath: "/dev/null")
		let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
}
