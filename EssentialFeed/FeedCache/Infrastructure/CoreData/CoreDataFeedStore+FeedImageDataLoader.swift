//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Josip Petric on 07.09.2023..
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
	public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
		perform { context in
			completion(Result(catching: {
				try ManagedFeedImage.first(with: url, in: context)?.data
			}))
		}
	}
	
	public func insert(data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
		perform { context in
			completion(Result(catching: {
				try ManagedFeedImage.first(with: url, in: context)
					.map({ $0.data = data })
					.map(context.save)
			}))
		}
	}
}
