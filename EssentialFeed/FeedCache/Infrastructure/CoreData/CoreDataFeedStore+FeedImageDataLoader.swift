//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Josip Petric on 07.09.2023..
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
	public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
		completion(.success(.none))
	}
	
	public func insert(data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
		
	}
}
