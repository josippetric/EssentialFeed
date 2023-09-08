//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 07.09.2023..
//

import Foundation
import EssentialFeed

class FeedImageDataStoreSpy: FeedImageDataStore {
	enum Message: Equatable {
		case insert(data: Data, for: URL)
		case retrive(dataFor: URL)
	}
	
	private var retrievalCompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
	private var insertionCompletions = [(FeedImageDataStore.InsertionResult) -> Void]()

	private(set) var receivedMessages = [Message]()
	
	func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
		receivedMessages.append(.retrive(dataFor: url))
		retrievalCompletions.append(completion)
	}

	func insert(data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
		receivedMessages.append(.insert(data: data, for: url))
		insertionCompletions.append(completion)
	}
	
	func completeRetrieval(with error: Error, at index: Int = 0) {
		retrievalCompletions[index](.failure(error))
	}

	func completeRetrieval(with data: Data?, at index: Int = 0) {
		retrievalCompletions[index](.success(data))
	}
	
	func completeInsertion(with error: Error, at index: Int = 0) {
		insertionCompletions[index](.failure(error))
	}
	
	func completeInsertionSuccessfully(at index: Int = 0) {
		insertionCompletions[index](.success(()))
	}
}
