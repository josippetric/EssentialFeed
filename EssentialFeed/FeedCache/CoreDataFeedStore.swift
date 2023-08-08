//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Josip Petric on 08.08.2023..
//

import Foundation

public final class CoreDataFeedStore: FeedStore {
	public init() {}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		completion(.empty)
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		
	}
}
